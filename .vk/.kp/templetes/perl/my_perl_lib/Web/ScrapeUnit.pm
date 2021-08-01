package Web::ScrapeUnit;
use strict;
use warnings;
use Web::Scraper;

#-------------------------------------------------------------------------------
# 'Scraper' will be of below form:
# [ <css path> or <xpath>,
#   <column> or <array ref of column>,
#       when <column> is provided as scalar value then all the result store in the column
#       ehen <array ref of column> only the corresponsing element of array will be stored.
#       example: if 'href' is provided and the result is ['http1', 'http2', .. 'httpn']
#                     then 'href' => ['http1', 'http2', .. 'httpn']
#                if ['href'] is provided and the result is ['http1', 'http2', .. 'httpn']
#                     then 'href' => 'http1'
#   <subroutine> or <attribute of same format as in web::scraper> ]
# if columne is array ref then the number of elements return by expression must be array ref
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#'Data' will be of below form
# {
#   column_heading => value,
#   ...
# }
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# new :
# @arg: csv_fh = the instance of MY::Data2CSV
#-------------------------------------------------------------------------------
sub new {
  my $class = shift;
  my %args = @_;

  die ("mech argument not provided!!!!") unless (exists($args{mech}));

  #------------------------------------------------------------
  # Debug
  my $debug;
  if (exists($args{debug})) {
    $debug = $args{debug};
    delete $args{debug};
  }
  else {
    $debug = 0;
  }
  #------------------------------------------------------------

  my $mech = $args{mech};

  my $self = bless {
    mech => $mech,
    debug => $debug,
    h_data => {},
    # Number of urls that have been scraped till now
    url_no => 0,
  }, $class;

  return $self;
}

#-------------------------------------------------------------------------------
# hash_to_csv_data :
# @arg: CSV Column Heading as argument. 
# if the cell value of csv data is array reference then it will be expended to rows and column
# the other cells will be kept blank excep the first rows.
#
# Note: the returned result is array ref in which each element is the array ref which shows the rows.
#-------------------------------------------------------------------------------
sub hash_to_csv_data {
  my $self = shift;
  my %arg = @_;
  my $csv_heading = $arg{heading};

  die ("csv_heading not provided!!!") unless (defined($csv_heading));

  my $h_data = $self -> {h_data};
  
  my $csv_data = [];
  foreach my $col_heading (@{$csv_heading}) {
    push (@{$csv_data}, $h_data -> {$col_heading});
  }

  $self -> pp ($csv_data);
  my $csv_rows = $self -> _get_csv_rows($csv_data);
  $self -> pp ($self -> {csv_data});
  return $csv_rows;
}

#-------------------------------------------------------------------------------
# _get_csv_rows :
#-------------------------------------------------------------------------------
sub _get_csv_rows {
  my $self = shift;

  my $data = shift;
  my $max_rows = 1;
  foreach my $row (@{$data}) {

    if (ref($row) eq ref({})) {
      $self -> pp ($row);
      die ("Not valid format!!!");
    }

    if (ref($row) eq ref([])) {
      $max_rows = $#{$row} + 1 if ($max_rows < ($#{$row} + 1));
    }
  }

  my $data_row = [];
  @$data_row = map {(ref($_) eq (ref([]))) ? ($_) : ([$_])} @$data;

  my $csv_rows = [];
  for (my $i = 0; $i < $max_rows; $i++) {
    my $csv_row = [];
    for (my $j = 0; $j < @$data_row; $j++) {
      my $col_val = $data_row -> [$j] [$i];
      if (ref($col_val) eq ref({})) {
        $self -> pp ($col_val);
        die ("Not valid format!!!");
      }

      # If column element is the array ref then push the array
      if (ref($col_val) eq ref ([])) {
        foreach my $col_v (@{$col_val}) {
          $col_v = remove_multi_char($col_v) if (defined($col_v));
          push (@$csv_row, @{$col_val});
        }
      }
      # else push the scalar element
      else {
        $col_val = remove_multi_char($col_val) if (defined($col_val));
        push (@$csv_row, $col_val);
      }
    }
    push (@$csv_rows, $csv_row);
  }
  $self -> {csv_data} = $csv_rows;
  return $csv_rows;
}


#-------------------------------------------------------------------------------
# scrape :
#-------------------------------------------------------------------------------
sub scrape {
  my $self = shift;
  my %arg = @_;
  my $scraper = $arg{scraper};

  my $mech = $self -> {mech};
  my $url = $mech -> uri() -> as_string;

  print ("Scraping url $url\n");

  #$mech -> get($url);

  my $content = $mech -> content();

  #-------------------------------------------------------------------------------
  # Remove Meta tags
  $content =~ s/<meta.*?>//g;
  $content =~ s/<\/?tbody.*?>//g;
  #-------------------------------------------------------------------------------

  my $my_scprs = $scraper;

  my $col_data = {url => $url};
  foreach my $my_scpr (@{$my_scprs}) {
    my $path = $my_scpr -> [0];
    my $cols = $my_scpr -> [1];
    # value can be sub ref or valid text in web::scraper.
    my $value = $my_scpr -> [2];

    my $scraper = scraper {
      process "$path", "this[]" => $value;
    };

    my $data = $scraper -> scrape ($content) -> {this};
    $self -> pp ($data);
    $self -> pp ($content);

    # If column is not array ref then return the array ref as a single element
    if (ref($cols) eq ref("")) {
      $col_data -> {$cols} = $data;
      next;
    }

    if (!defined($data)) {
      $data = [];
      # it array ref is provided the data may be suppress if the number of columns are less the numebr of data
      $#{$data} = $#{$cols};
    }

    if (@{$cols} != @{$data}) {
      warn ("Warn: Number of column heading and number of column values are not same!!!");
      $self -> pp ($cols);
      $self -> pp ($data);
      $#{$data} = $#{$cols};
    }

    # Convert to the data => format
    for (my $i = 0; $i <= $#{$cols}; $i++) {
      $col_data -> {$cols -> [$i]} = $data -> [$i];
    }
  }

  # Sr Number of url
  $self -> {url_no}++;
  $col_data -> {sr_no} = $self -> {url_no};

  $self -> {h_data} = $col_data;

  $self -> pp ($self -> {h_data});

  return $self -> {h_data};
  #------------------------------------------------------------
}

#===============================================================================
# Other Methods
#===============================================================================
#-------------------------------------------------------------------------------
# remove_multi_char :
#-------------------------------------------------------------------------------
sub remove_multi_char {
  my $text = shift;
  return $text unless (defined($text));
  return $text if ($text eq "");
  $text =~ s/&eacute;/e/g;
  $text =~ s/&Eacute;/E/g;
  $text =~ s/&ecirc;/e/g;
  $text =~ s/&egrave;/e/g;
  $text =~ s/&acirc;/a/g;
  $text =~ s/&auml;/a/g;
  $text =~ s/&agrave;/a/g;
  $text =~ s/&acute;/'/g;
  $text =~ s/&euro;/Euro/g;
  $text =~ s/&rsquo;/'/g;
  $text =~ s/&quot;/"/g;
  $text =~ s/&amp;/&/g;
  $text =~ s/&nbsp;//g;
  $text =~ s/&#39;/'/g;
  $text =~ s/&icirc;/i/g;
  $text =~ s/&ccedil;/c/g;
  $text =~ s/&uuml;/u/g;
  $text =~ s/&ocirc;/o/g;
  $text =~ s/&oacute;/o/g;
  $text =~ s/&hellip;/.../g;
  $text =~ s/&ndash;/-/g;
  $text =~ s/&pound;/Pound /g;
  $text =~ s/&#x200B;//g;
  $text =~ s/&gt;/>/g;
  $text =~ s/&ouml;/o/g;
  $text =~ s/&laquo;/<</g;
  $text =~ s/&raquo;/>>/g;
  $text =~ s/&euml;/e/g;
  $text =~ s/&ucirc;/u/g;
  $text =~ s/&deg;/o/g;
  $text =~ s/&iuml;/i/g;
  $text =~ s/&#x117;/e/g;
  $text =~ s/\x{20AC}/Euro/g;
  $text =~ s/\xF4/o/g;
  $text =~ s/\xE2/a/g;
  $text =~ s/\xE9/e/g;
  $text =~ s/\xE7/c/g;
  $text =~ s/\xE8/e/g;
  $text =~ s/\xE4/a/g;
  $text =~ s/\xEB/l/g;

  $text =~ s/\xA0/ /g;
  return $text;
}

################################################################################
# Debug Method
################################################################################

#-------------------------------------------------------------------------------
# get_hierarchy_caller :
#-------------------------------------------------------------------------------
sub get_hierarchy_caller {
  my ($line_no, $sub_name);
  my $idx = 0;

  my @sub_list;
  while (($line_no, $sub_name)= (caller($idx)) [2,3]) {
    push (@sub_list, (split("::", $sub_name))[-1] . "[$line_no]");
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
