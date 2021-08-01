#!/usr/bin/perl -w
use strict;
use warnings;

package Scrapy;
use Web::Scraper;
use WWW::Mechanize;
use Data::Dump;
use Error qw(:try);

use threads;
use threads::shared;

use lib "=$KP_PERL_LIB_HOME";
use Data::CSV_KP;

$| = 1;

#-------------------------------------------------------------------------------
# pp :
my $log_file = "log.txt";
open (my $fh_l, ">$log_file") or die ("Error: Couln't open file $log_file $!");
close $fh_l;
#-------------------------------------------------------------------------------
sub pp {
  my $text = shift;

  open (my $fh_l, ">>$log_file") or die ("Error: Couln't open file $log_file $!");
  print ("# $text\n");
  print $fh_l ("# $text\n");
}

#-------------------------------------------------------------------------------
# Arguments: url, csv_file, heading, [use_threads],
#-------------------------------------------------------------------------------
sub new {
  my $class = shift;
  my $arg = shift;

  if (ref($arg) eq ref({})) {
    die ("Provide url") if (!defined($arg -> {url}));
    die ("Provide csv_file") if (!defined($arg -> {csv_file}));
    die ("Provide heading") if (!defined($arg -> {heading}));
  }
  else {
    die ("Invalid argument!!!");
  }

  my $use_threads;
  # Enable and disable threads
  if (!defined($arg -> {use_threads})) {
    $use_threads = 0;
  }
  else {
    $use_threads = $arg -> {use_threads};
  }

  my $use_proxy;
  my $proxy_container;

  # Enable and disable proxies
  if (!defined($arg -> {use_threads})) {
    $use_threads = 0;
  }
  else {
    $use_threads = $arg -> {use_threads};
  }

  if (!defined($arg -> {use_proxy})) {
    $use_proxy = 0;
  }
  else {
    $use_proxy = $arg -> {use_proxy};
  }

  my @shared_csv_rows;
  share(@shared_csv_rows);

  #-------------------------------------------------------------------------------
  # mech using proxy
  my $mech;
  RETRY_2:
  try {
    # mech use proxy
    if ($use_proxy == 1) {
      require Proxy::PContainer;
      $proxy_container = Proxy::PContainer -> new();
      # If threads are enabled share the ptr to switch to different uniq proxies in threads
      share($proxy_container -> {ptr}) if ($use_threads);

      $mech = $proxy_container -> get($arg -> {url});
    }
    # don't use proxy
    else {
      $mech = WWW::Mechanize -> new(
        agent => 'Mozilla/5.0 (X11; Linux i686; rv:12.0) Gecko/20100101 Firefox/12.0',
      );
      $mech -> get($arg -> {url});
    }
  }
  catch Error with {
    pp "$@";
    pp "Retrying after 1 sec";
    sleep (1);
    goto RETRY_2;
  };
  #-------------------------------------------------------------------------------

  #-------------------------------------------------------------------------------
  # csv_kp
  my $csv_kp = Data::CSV_KP -> new (
    csv_file => $arg -> {csv_file},
    heading => $arg -> {heading},
  );
  $csv_kp -> print_heading ();
  #-------------------------------------------------------------------------------

  my $self = bless {
    mech => $mech,
    csv_kp => $csv_kp,
    use_threads => $use_threads,
    use_proxy => $use_proxy,
    proxy_container => $proxy_container,
  }, $class;

  $self -> {shared_csv_rows} = \@shared_csv_rows if (defined($use_threads));

  return $self;
}

#-------------------------------------------------------------------------------
# mech :
#-------------------------------------------------------------------------------
sub mech {
  my $self = shift;

  return $self -> {mech};
}

#-------------------------------------------------------------------------------
# csv_kp :
#-------------------------------------------------------------------------------
sub csv_kp {
  my $self = shift;

  return $self -> {csv_kp};
}

#-------------------------------------------------------------------------------
# l2_scrape_url_data :
#-------------------------------------------------------------------------------
sub l2_scrape_url_data {
  my $self = shift;
  my $url = shift;
  my $proxy_container = $self -> {proxy_container};
  my $use_proxy = $self -> {use_proxy};

  pp "Scraping $url";

  #-------------------------------------------------------------------------------
  my $mech;
  RETRY_1:
  try {
    # Use proxy 
    if ($use_proxy == 1) {
      $mech = $proxy_container -> get($url);
    }
    # Don't use proxy
    else {
      $mech = WWW::Mechanize -> new(
        agent => 'Mozilla/5.0 (X11; Linux i686; rv:12.0) Gecko/20100101 Firefox/12.0',
      );
      $mech -> get($url);
    }
  }
  catch Error with {
    pp "$@";
    pp "Retrying after 1 sec";
    sleep (1);
    goto RETRY_1;
  };
  #-------------------------------------------------------------------------------

  my $content = $mech -> content();

  $content =~ s/<meta.*?>//g;
  $content =~ s/<tbody.*?>//g;
  $content =~ s/<link.*?>//g;

  my $s_text = sub {
    my $he = shift;
    my $text = $he -> as_HTML();

    $text =~ s/<br.*?>/\n/g;
    $text =~ s/<.*?>//g;

    return $text;
  };

  my $s_num_text = sub {
    my $he = shift;
    my $text = $s_text -> ($he);

    return '="' . $text . '"';
  };

  my $scraper = scraper {
    # =common#mov_thru_user_mark#get_template('a', "Scraper Code here")
    process "", "" =>
  };

  my $scrape = $scraper -> scrape ($content);

  $scrape -> {URL} = $url;

  # Convert all arrays to text separated by newline
  while (my ($key, $value) = each %$scrape) {
    if (ref($value) eq ref([])) {
      $value = join ("\n", @{$value});
      $scrape -> {$key} = $value;
    }
  }

  if ($self -> {use_threads}) {
    my $scrape_shared :shared = shared_clone($scrape);
    lock @{$self -> {shared_csv_rows}};
    push (@{$self -> {shared_csv_rows}}, $scrape_shared);
  }

  dd $scrape;
  exit; # FIXME
  return $scrape;
}

#-------------------------------------------------------------------------------
# l2_scrape_urls :
# Scrape the array urls sequencially
#-------------------------------------------------------------------------------
sub l2_scrape_urls {
  my $self = shift;
  my $urls = shift;

  my $csv_kp = $self -> csv_kp;

  foreach my $url (@$urls) {
    my $data = $self -> l2_scrape_url_data ($url);
    $csv_kp -> print ($data);
  }
}

#-------------------------------------------------------------------------------
# l2_scrape_urls_parallel :
#-------------------------------------------------------------------------------
sub l2_scrape_urls_parallel {
  my $self = shift;
  my $urls = shift;

  my @shared_urls :shared = @$urls;

  my $csv_kp = $self -> csv_kp;

  my $threads_runnings :shared = 0;

  my $thread_scrape_all_links = sub {
    my $urls = shift;
    my $self = shift;
    $threads_runnings ++;

    while (my $url = shift @$urls) {
      $self -> l2_scrape_url_data($url);
    }

    $threads_runnings --;
  };

  my @threads;

  # FIXME default 5
  my $max_parallel_process = 5;

  for (my $i = 0; $i <= $max_parallel_process; $i++) {

    $threads[$i] = threads->create($thread_scrape_all_links, \@shared_urls, $self);
  }

  sleep (3);
  print ("Waiting for childs...");
  while ($threads_runnings) {
    while (my $data = shift @{$self -> {shared_csv_rows}}) {
      $csv_kp -> print ($data);
    }
    print (".");
    sleep(1);
  }
  print ("\n");

  # Print to the csv file for the data scraped by parallel threads.
  while (my $data = shift @{$self -> {shared_csv_rows}}) {
    $csv_kp -> print ($data);
  }

  #
  undef $_ for @threads;
}

#-------------------------------------------------------------------------------
# l1_get_links :
#-------------------------------------------------------------------------------
sub l1_get_links {
  my $self = shift;

  my $mech = $self -> mech;

  my $content = $mech -> content();

  $content =~ s/<meta.*?>//g;
  $content =~ s/<tbody.*?>//g;
  $content =~ s/<link.*?>//g;

  my $p_links = "";

  my $s_links = sub {
    my $he = shift;
    my $href = $he -> attr("href");

    return $href;
  };

  my $scraper = scraper {
    process "$p_links", "Links[]" => $s_links;
  };

  my $scrape = $scraper -> scrape ($content);

  if (defined($scrape -> {Links})) {
    $scrape = $scrape -> {Links};
  }
  else {
    $scrape = [];
  }

  dd $scrape;
  exit; # FIXME
  return $scrape;
}

#-------------------------------------------------------------------------------
# l1_scrape_data :
#-------------------------------------------------------------------------------
sub l1_scrape_data {
  my $self = shift;

  my $links = $self -> l1_get_links;

  # if use_threads is enable scrape parallelly
  if ($self -> {use_threads}) {
    $self -> l2_scrape_urls_parallel($links);
  }
  else {
    $self -> l2_scrape_urls($links);
  }
}

sub next_page {
  my $self = shift;
  my $mech = $self -> mech;
  my $page_no = $self -> {page_no};

  # =common#mov_thru_user_mark#get_template('a', 'Check if next page exists')
  return 0;
}

#-------------------------------------------------------------------------------
# l1_scrape_data_pagination :
#-------------------------------------------------------------------------------
sub l1_scrape_data_pagination {
  my $self = shift;

  $self -> l1_scrape_data;

  $self -> {page_no} = 1;
  while ($self -> next_page()) {
    pp " ################### Scraping Page " . $self -> {page_no} . " ###################";
    $self -> l1_scrape_data;
  }

  pp "Scraping Completed";
}

# ##############################################################################
# Main program here
# ##############################################################################
package main;
my $url = "";
my $csv_file = "sample.csv";
my $heading = [
  =common#mov_thru_user_mark#get_template('a', 'CSV File Headings')
];

my $scrapy = Scrapy -> new({
  url => $url,
  csv_file => $csv_file,
  heading => $heading,

  # optional
  use_threads => 0,
  use_proxy => 0,
});

$scrapy -> l1_scrape_data_pagination;
