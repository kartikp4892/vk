package Scrapy::Recursive;
use strict;
use warnings;
use Clone 'clone';
use Web::Scraper;
use Data::Dump;


sub new {
  my $class = shift;
  my %arg = @_;

  my $data_h;

  if (!defined($arg{data_h})) {
    $data_h = {};
  }
  else {
    # make clone so that the scraped data don't overritten
    $data_h = clone($arg{data_h});
  }

  my $mech;
  if (defined($arg{mech})) {
    $mech = $arg{mech} -> clone;
  }

  # links_a => Links on the current page
  # hasa => Child Scrapy::Recursive object
  # scraper_l => <link scraper>, scraper_d => <data_scraper>
  my $self = bless {
    data_h   => $data_h,
    links_a  => [],
    hasa     => $arg{hasa},
    url      => $arg{url},
    mech     => $mech,
    log_file => $arg{log_file},
    scraper_l => undef,
    scraper_d => undef,

  }, $class;
  return $self;
}

sub next_page {
  my $self = shift;
  my $mech = $self -> {mech};
  my $page_no = $self -> {page_no};

  # Note: if next page exists it method must be overridden in base class
  return 0;
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
# get_links :
# Scrape links from current page
# @arg1 : web::scraper object which returns {links => [...]}
#-------------------------------------------------------------------------------
sub get_links {
  my $self = shift;
  my $scraper = $self -> {scraper_l};

  # If scraper is not defined return empty list
  if (!defined($scraper)) {
    return [];
  }

  my $mech = $self -> {mech};
  $mech -> get($self -> {url});

  my $content = $mech -> content();

  $content =~ s/<meta.*?>//g;
  $content =~ s/<tbody.*?>//g;
  $content =~ s/<link.*?>//g;

  my $scrape = $scraper -> scrape ($content);

  #-------------------------------------------------------------------------------
  # FIXME
  print ("$content\n");
  #-------------------------------------------------------------------------------

  if (defined($scrape -> {links})) {
    $scrape = $scrape -> {links};
  }
  else {
    $scrape = [];
  }

  $self -> {links_a} = $scrape;

  dd $scrape;

  return $scrape;
}

#-------------------------------------------------------------------------------
# scrape_data :
#-------------------------------------------------------------------------------
sub scrape_data {
  my $self = shift;
  my $url = shift;
  my $scraper = $self -> {scraper_d};

  # If scraper is not defined return
  if (!defined($scraper)) {
    return {};
  }

  $self -> tee ("Scraping $url");

  my $mech = $self -> {mech} -> clone();
  $mech -> get($url);

  my $content = $mech -> content();

  $content =~ s/<meta.*?>//g;
  $content =~ s/<tbody.*?>//g;
  $content =~ s/<link.*?>//g;

  my $scrape = $scraper -> scrape ($content);

  # Convert all arrays to text separated by newline
  while (my ($key, $value) = each %$scrape) {
    if (ref($value) eq ref([])) {
      $value = join ("\n", @{$value});
      $scrape -> {$key} = $value;
    }
  }

  # Merge the scraped data with already scraped data
  $self -> {data_h} = {%{$self -> {data_h}}, %$scrape};

  #-------------------------------------------------------------------------------
  # FIXME
  use Data::Dump;
  dd $self -> {data_h};
  #-------------------------------------------------------------------------------

  return $self -> {data_h};
}

sub scrape_links {
  my $self = shift;

  my $hasa = $self -> {hasa};

  $self -> get_links;
  $self -> scrape_data;

  # If root child scrape data
  if (defined($hasa)) {
    foreach my $link (@{$self -> {links_a}}) {
      $hasa -> {url} = $link;
      $hasa -> {data_h} = $self -> {data_h};
      $hasa -> {links_a} = [];
      $hasa -> scrape_links_pagination;
    }
  }
}

#-------------------------------------------------------------------------------
# scrape_links_pagination :
# Scrape links from all the pages
#-------------------------------------------------------------------------------
sub scrape_links_pagination {
  my $self = shift;

  $self -> scrape_links;

  $self -> {page_no} = 1;
  while ($self -> next_page()) {
    $self -> tee (" ################### Scraping Page " . $self -> {page_no} . " ###################");
    $self -> get_links;
  }

  $self -> tee ("Scraping Completed");
}

1;

