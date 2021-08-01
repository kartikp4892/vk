package MY::ScrapeAll;
use strict;
use warnings;
use MY::ScrapeUnit;
use MY::Data2CSV;

#-------------------------------------------------------------------------------
# 'Scraper' will be of below form:
# [ <css path> or <xpath>,
#   <column> or <array ref of column>,
#   <subroutine> or <attribute of same format as in web::scraper> ]
# if columne is array ref then the number of elements return by expression must be array ref
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# new :
# @arg: urls => [], 
# scraper => []
# csv_file => optional if not provided ignore write to csv file and return the data
# urls => array ref which is optional. update_url method to add url list at later stage
#-------------------------------------------------------------------------------
sub new {
  my $class = shift;
  my %args = @_;

  die ("heading not provided!!!") unless (exists($args{heading}));
  die ("mech not provided!!!") unless (exists($args{mech}));

  my $debug;
  if (exists($args{debug})) {
    $debug = $args{debug};
    delete $args{debug};
  }
  else {
    $debug = 0;
  }

  # use undef if $args{csv_file} is not provided
  my $csv = MY::Data2CSV -> new(csv_file => $args{csv_file},
                                csv_heading => $args{heading},
                                debug => $debug);

  # we will only have file handle
  delete $args{csv_file};

  my $self = bless {
    %args,
    csv => $csv,
    debug => $debug,
  }, $class;

  return $self;
}

#-------------------------------------------------------------------------------
# update_url :
#-------------------------------------------------------------------------------
sub update_url {
  my $self = shift;
  my $urls = shift;

  $self -> {urls} = $urls;
}

#-------------------------------------------------------------------------------
# add_scraper :
#-------------------------------------------------------------------------------
sub add_scraper {
  my $self = shift;
  my $scraper = shift;

  push (@{$self -> {scraper}}, $scraper);
}

#-------------------------------------------------------------------------------
# scrape :
#-------------------------------------------------------------------------------
sub scrape {
  my $self = shift;

  my $urls = $self -> {urls};
  my $scraper = $self -> {scraper};
  my $csv = $self -> {csv};
  my $heading = $self -> {heading};
  my $mech = $self -> {mech};
  my $debug = $self -> {debug};

  my $csv_rows;
  foreach my $url (@$urls) {
    my $msu = MY::ScrapeUnit -> new(
      mech => $mech,
      url => $url,
      heading => $heading,
      csv_fh => $csv,
      scraper => $scraper,
      debug => $debug,
    );

    my $csv_r = $msu -> scrape();

    # default scrape to ScapeAll package will not return any data array to save memory
    # if csv_file is not defined then only the result will be returned.
    push (@$csv_rows, $csv_r) unless (defined($csv -> {csv_file}));
  }

  return $csv_rows;
}

#===============================================================================
# Debug Method
#===============================================================================
#-------------------------------------------------------------------------------
# get_hierarchy_caller :
#-------------------------------------------------------------------------------
sub get_hierarchy_caller {
  my ($file_name, $line_no, $sub_name);
  my $idx = 0;

  my @sub_list;
  while (($file_name, $line_no, $sub_name)= (caller($idx)) [1,2,3]) {
    push (@sub_list, "$file_name\[$line_no]# $sub_name");
    #push (@sub_list, $sub_name);
  }
  continue {
    $idx ++;
  }

  my $me = join (" -> ", reverse(@sub_list));
  return $me;
}

#-------------------------------------------------------------------------------
# pp :
#-------------------------------------------------------------------------------
sub pp {
  my $self = shift;

  my $debug = $self -> {debug};
  if ($debug == 1) {
    my $data = shift;
    use Data::Dump;

    my $me = get_hierarchy_caller;

    print ("$me\n");
    dd $data;
  }
}

1;

__END__
#!/usr/bin/perl -w
use strict;
use warnings;

use lib 'my_perl_lib';
use MY::ScrapeAll;
use Data::Dump;

#-------------------------------------------------------------------------------
# get_url_lists :
#-------------------------------------------------------------------------------
sub get_url_lists {
  my $url = ["https://www.1golf.eu/en/golf-courses/france"];
  my $scraper = [
    "//div[\@id='itemList']/div/div[\@class='info']/h4/a",
    "urls",
    '@href',
  ];

  # csv_file is not provided i.e. ignore write to csv file and return the result instead.
  my $msa = MY::ScrapeAll -> new (
    urls => $url,
    heading => ['urls'],
    scraper => [$scraper],
    debug => 1,
  );

  # data returned is in term of number of rows where each row is arr ref.
  my $data = $msa -> scrape();

  my @urls;
  for (my $i = 0; $i <= $#{$data}; $i++) {
    for (my $j = 0; $j <= $#{$data -> [$i]}; $j++) {
      for (my $k = 0; $k <= $#{$data -> [$i] -> [$j]}; $k++) {
        $data -> [$i] -> [$j] -> [$k] =~ s/^http:/https:/g;
        push (@urls, $data -> [$i] -> [$j] -> [$k]);
      }
    }
  }
  return \@urls;
}

sub s_logo {
  my $he = shift;
  my $logo_url = $he -> attr('src');
  my $logo_name = $he -> attr('alt');
  $logo_url = "https://www.1golf.eu" . $logo_url;
  return ($logo_name, $logo_url);
};

#-------------------------------------------------------------------------------
# s_addr :
#-------------------------------------------------------------------------------
sub s_addr {
  my $he = shift;
  my $addr = $he -> as_HTML();
  $addr =~ s/<a.*?\/a>//g;
  $addr =~ s/<br.*?>/\n/g;
  $addr =~ s/<.*?>//g;
  $addr =~ s/^\n+//g;
  my $map = $he -> look_down(_tag => 'a') -> attr('href');
  return ([$addr], $map);
}

my $urls = ["https://www.1golf.eu/en/club/golf-du-val-secret/", 'https://www.1golf.eu/en/club/golf-club-opio-valbonne/'];
#my $urls = get_url_lists;

my $csv_file = "out.csv";

my $heading = [
  'title',
  'logo_url',
  'logo_name',
  'addr',
  'map',
];

my $scraper = [
  [
    "//div[\@id='title']",
    'title',
    'TEXT',
  ],

  [
    "//div[\@class='logo']/img",
    ['logo_name', 'logo_url'],
    \&s_logo
  ],

  [
    "//p[\@class='address']",
    ['addr', 'map'],
    \&s_addr
  ]
];

my $my_sc = MY::ScrapeAll -> new(
  urls => $urls,
  heading => $heading,
  csv_file => $csv_file,
  scraper => $scraper,
  debug => 0,
);

$my_sc -> scrape();

