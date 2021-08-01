#!/usr/bin/perl -w
use strict;
use warnings;

use Recursive;
{
  package Data;
  our @ISA = qw(Scrapy::Recursive);

  sub scraper_d {
    my $self = shift;
    
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
      # =common#mov_thru_user_mark#get_template('a', 'Scraper Code here')
      process "", "" =>
    };

    $self -> {scraper_d} = $scraper;
    
  }

}

{
  package SearchResult;
  our @ISA = qw(Scrapy::Recursive);

  sub scraper_l {
    my $self = shift;
    
    my $p_links = "=common#mov_thru_user_mark#get_template('l', 'xpath to scrape links')";

    my $s_links = sub {
      my $he = shift;
      my $href = $he -> attr("href");

      return $href;
    };

    my $scraper = scraper {
      process "$p_links", "Links[]" => $s_links;
    };

    $self -> {scraper_l} = $scraper;
  }

  sub next_page {
    my $self = shift;
    my $mech = $self -> mech;
    my $page_no = $self -> {page_no};

    # =common#mov_thru_user_mark#get_template('n', 'Logic to check if next page available')
    return 0;
  }
}

#-------------------------------------------------------------------------------
# Main Program Here
#-------------------------------------------------------------------------------
package main;
use WWW::Mech::Try;

my $mech = WWW::Mech::Try -> new (
  agent => 'Mozilla/5.0 (X11; Linux i686; rv:12.0) Gecko/20100101 Firefox/12.0',
  max_try => -1,
);

my $scrapy_data = Data -> new (
  data_h   => =common#mov_thru_user_mark#get_template('a', 'OPTIONAL: Contains the data scraped, this will be set by parent'),
  hasa   => =common#mov_thru_user_mark#get_template('a', 'OPTIONAL: Should be undef for root child'),
  url   => =common#mov_thru_user_mark#get_template('a', 'OPTIONAL: will be set by parent to the URL from which data is scraped'),
  mech     => $mech,
  log_file => 'log.txt',
);
# Set scraper for data
$scrapy_data -> scraper_d;

my $scrapy_link = SearchResult -> new (
  data_h   => =common#mov_thru_user_mark#get_template('a', 'OPTIONAL: Contains the data scraped, this will be set by parent'),
  hasa     => $scrapy_data,
  url   => =common#mov_thru_user_mark#get_template('a', 'OPTIONAL: will be set by parent to the URL from which data is scraped'),
  mech     => $mech,
  log_file => 'log.txt',
);
# Set scraper for link
$scrapy_link -> scraper_l;
