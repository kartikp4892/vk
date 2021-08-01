package Data::CSV_KP;
use strict;
use warnings;
use Text::CSV_PP;
use Data::Convert;
use Data::Dump;

$| = 1;

#-------------------------------------------------------------------------------
# new :
# @argv: skip write to csv file if csv_file argument is not provided.
#-------------------------------------------------------------------------------
sub new {
  my $class = shift;
  my %args = @_;

  my $caller_line = (caller(0))[2];
  my $caller_file = (caller(0))[1];

  die ("$caller_file\[$caller_line]: csv_file not provided!!!") unless (defined($args{csv_file}));

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

  #------------------------------------------------------------
  # csv file handle
  my $cfh;
  my $csv;

  $csv = Text::CSV_PP -> new ({always_quote => 0});
  $csv -> eol ("\n");

  my $csv_file = $args{csv_file};

  #open ($cfh, ">:encoding(utf8)", "$csv_file") or die ("Error: Couln't open file $csv_file $!");
  open ($cfh, ">", "$csv_file") or die ("Error: Couln't open file $csv_file $!");
  #------------------------------------------------------------

  #-------------------------------------------------------------------------------
  # Heading
  my $heading = $args{heading};
  # Make all column types as string
  my @types = ((Text::CSV_PP::PV ()) x @$heading);
  $csv -> types(\@types);
  #-------------------------------------------------------------------------------

  my $self = bless {
    csv_fh => $cfh,
    csv => $csv,
    heading => $heading,
    sr_no => 0,

    debug => $debug,
  }, $class;

  return $self;
}

#-------------------------------------------------------------------------------
# print_heading :
#-------------------------------------------------------------------------------
sub print_heading {
  my $self = shift;
  return 0 unless (defined($self -> {heading}));

  $self -> {csv} -> print ($self -> {csv_fh}, $self -> {heading});

  return 1;
}

#-------------------------------------------------------------------------------
# print :
# THis method handles the multiple rows. Argument to the sub is the arrary ref
# in which each array element must be array ref which shows the single row.
# If argument is provided array ref to represent single row and elements are not
# array ref the script will convert the row to rows of single row
#-------------------------------------------------------------------------------
sub print {
  my $self = shift;
  my $csv_data = shift;

  my $csv_rows;
  if (ref($csv_data) eq ref({})) {
    $self -> {sr_no}++;
    $csv_data -> {"Sr. No."} = $self -> {sr_no};
    $csv_rows = Data::Convert::hash_to_csv_data(heading => $self -> {heading}, h_data => $csv_data);
  }
  else {
    $csv_rows = $csv_data;
  }

  # Check if the single row or multiple rows provided
  # In case of single row the elements will be scalar
  if (ref($csv_rows -> [0]) eq ref("")) {
    $csv_rows = [$csv_rows];
  }

  foreach my $csv_row (@{$csv_rows}) {
    @$csv_row = map {Data::Convert::remove_multi_char($_)} @{$csv_row};
    $self -> {csv} -> print ($self -> {csv_fh}, $csv_row);
  }

  return 1;
}

################################################################################
# Other Methods
################################################################################
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

    my $me = get_hierarchy_caller;

    print ("$me\n");
    dd $data;
  }
}

1;
