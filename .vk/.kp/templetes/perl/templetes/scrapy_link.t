package =substitute(expand('%:t'), '\v\.\w+$', '', '');
use strict;
use warnings;

use Web::Scraper;
use Data::Dump;

use lib "=$KP_PERL_LIB_HOME";
use Clone 'clone';
use WWW::Mech::Try;
use =common#mov_thru_user_mark#get_template('c', 'child_module_name')

$| = 1;

sub new {
  my $class = shift;
  my %arg = @_;

  my $data_h;
  if (defined($arg{data_h})) {
    $data_h = clone($arg{data_h});
  }
  else {
    $data_h = {};
  }

  foreach my $carg (qw(mech csv_kp)) {
    die "Error: Argument $carg not provided!!!" if (!defined($arg{$carg}));
  }

  my $mech = $arg{mech};

  $mech -> get($mech -> {url});

  my $self = bless {
    data_h   => $data_h,
    mech      => $mech,
    log_file => $arg{log_file},
    csv_kp   => $arg{csv_kp},
    lookup   => $arg{lookup},
  }, $class;
  return $self;

}

sub tee {
  my $self = shift;
  my $text = shift;

  if (defined($self -> {log_file})) {
    my $log_file = $self -> {log_file};
    open (my $fh, ">>$log_file") or die ("Error: Couln't open file $log_file $!");
    print $fh ("$text\n");
  }
  print ("$text\n");
}

#-------------------------------------------------------------------------------
# scrape_data :
#-------------------------------------------------------------------------------
sub scrape_data {
  my $self = shift;
  my $url = $self -> {mech} -> {url};

  return $self -> {data_h}; # FIXME Remove this if some data is there to scrape in the current search result page

  $self -> tee ("Scraping $url");

  my $mech = $self -> {mech};

  #my $mech = WWW::Mech::Try -> new (
  #  agent => 'Mozilla/5.0 (X11; Linux i686; rv:12.0) Gecko/20100101 Firefox/12.0',
  #  max_try => -1,
  #);

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
    # =common#mov_thru_user_mark#get_template('d', 'Scraper_Code_here')
    #process "", "" =>
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

  $self -> {data_h} = {%{$self -> {data_h}}, %$scrape};

  dd $self -> {data_h};
  exit; # FIXME
  return $self -> {data_h};
}

sub next_page {
  my $self = shift;
  my $mech = $self -> {mech};
  my $page_no = ++$self -> {page_no};

  # =common#mov_thru_user_mark#get_template('d', 'Check_if_next_page_exists')
  return 0;
}

#-------------------------------------------------------------------------------
# get_links :
#-------------------------------------------------------------------------------
sub get_links {
  my $self = shift;

  my $mech = $self -> {mech};

  my $content = $mech -> content();

  $content =~ s/<meta.*?>//g;
  $content =~ s/<tbody.*?>//g;
  $content =~ s/<link.*?>//g;

  my $p_links = =common#mov_thru_user_mark#get_template('a', 'XPath_of_the_links_on_the_current_page')

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

sub scrape_child_links {
  my $self = shift;
  my $links = $self -> get_links;

  my $csv_kp = $self -> {csv_kp};
  my $mech = $self -> {mech} -> clone;

  my $lookup = $self -> {lookup};

  foreach my $link (@{$links}) {
    if ($lookup -> is_exists($link)) {
      next;
    }

    $mech -> {url} = $link;
    #-------------------------------------------------------------------------------
    # Create Child Scrapy Object
    my $has_a = =common#mov_thru_user_mark#get_template('c', 'child_module_name') -> new (
      data_h   => $self -> {data_h},
      mech      => $mech,
      log_file => $self -> {log_file},
      csv_kp => $self -> {csv_kp},
    );
    #-------------------------------------------------------------------------------

    $has_a -> scrape_data;
    
    $lookup -> save_entry($link);
  }
}

#-------------------------------------------------------------------------------
# scrape_child_links_pagination :
#-------------------------------------------------------------------------------
sub scrape_child_links_pagination {
  my $self = shift;

  # Scrape data on the current search result page if any
  $self -> scrape_data;
  $self -> scrape_child_links;

  $self -> {page_no} = 1;
  while ($self -> next_page()) {
    $self -> tee (" ################### Scraping Page " . $self -> {page_no} . " ###################");
    $self -> scrape_data;
    $self -> scrape_child_links;
  }

  $self -> tee ("Scraping Completed");
}


1;

