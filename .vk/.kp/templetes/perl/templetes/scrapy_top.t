package Scrapy;
use Data::Dump;

use lib "=$KP_PERL_LIB_HOME";
use WWW::Mech::Try;
use Data::CSV_KP;
use =common#mov_thru_user_mark#get_template('c', 'child module name');

$| = 1;

#-------------------------------------------------------------------------------
# Arguments: url, csv_file, heading
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

  $mech = WWW::Mech::Try -> new(
    agent => 'Mozilla/5.0 (X11; Linux i686; rv:12.0) Gecko/20100101 Firefox/12.0',
  );
  $mech -> {url} = $arg -> {url};

  # $mech -> get($arg -> {url});

  #-------------------------------------------------------------------------------
  # csv_kp
  my $csv_kp = Data::CSV_KP -> new (
    csv_file => $arg -> {csv_file},
    heading => $arg -> {heading},
  );
  $csv_kp -> print_heading ();
  #-------------------------------------------------------------------------------

  #-------------------------------------------------------------------------------
  # Look Up
  my $lookup = $arg -> {lookup};
  #-------------------------------------------------------------------------------

  my $self = bless {
    mech => $mech,
    csv_kp => $csv_kp,
    lookup => $lookup,
    in_opt => $arg -> {in_opt},
    in_arg => $arg -> {in_arg},
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

sub scrape_all_data {
  my $self = shift;

  #-------------------------------------------------------------------------------
  # Create Child Scrapy Object
  my $has_a = =common#mov_thru_user_mark#get_template('c', 'child module name') -> new (
    data_h   => {},
    mech     => $self -> {mech} -> clone,
    log_file => $self -> {log_file},
    csv_kp   => $self -> {csv_kp},
    lookup   => $self -> {lookup},
  );
  #-------------------------------------------------------------------------------

  $has_a -> scrape_child_links_pagination;
}

# ##############################################################################
# Main program here
# ##############################################################################
package main;
use Lookup;
use Getopt::Std;
use CGI;

#-------------------------------------------------------------------------------
# get_cmd_line_options :
# Description : Get the command line options provided by the user
#-------------------------------------------------------------------------------
sub get_cmd_line_options {
  my $opt = {};
  # -l : Enable Look Up for already scraped URL
  getopts('lh', $opt);

  #-------------------------------------------------------------------------------
  #print help if -h given
  if (exists($opt -> {"h"})) {
    print_help();
    exit;
  }
  #-------------------------------------------------------------------------------

  return $opt;
}

#-------------------------------------------------------------------------------
# get_cmd_line_arguments :
# Description : Get the command line arguments provided by the user
#-------------------------------------------------------------------------------
sub get_cmd_line_arguments {
  my $query = CGI -> new();
  my $args = $query -> Vars;

  #-------------------------------------------------------------------------------
  # Check for invalid argument and show warnings if found
  my @validArgs = ('type', 'postcode');
  my @allArgs = $query -> param();
  my @invalidArgs;
  foreach my $curArg (@allArgs) {
    push (@invalidArgs, $curArg) if ((grep ($curArg eq $_, @validArgs)) == 0);
  }

  warn ("Warning: Unknown argument '$_'") for (@invalidArgs);
  #-------------------------------------------------------------------------------

  return $args;
}

#-------------------------------------------------------------------------------
# print_help :
# Print help and exit
#-------------------------------------------------------------------------------
sub print_help {
my $helpTxt = <<EOF;

    +---------------------------------------------------------------------------------------------+
    |                     Help on $0
    +---------------------------------------------------------------------------------------------+
    | This script is used to scrape airbnb.com website
    |
    | Usages:
    |   perl <Path>/$0 <options> <arguments>
    |
    |   Note: Options must be provided before arguments.
    |
    | Options:
    |   -h : Print Help
    |   -l : Enable Look Up for already scraped url
    |
    | Arguments:
    |   type    : Specialty Types (dentist)
    |   postcode : Suburb Postcode
    |
    |   e.g. 1
    |   perl $0 -h
    |
    |   e.g. 2
    |   perl $0 -l type=dentist postcode="Circular Quay, NSW, 2000"
    |
    +---------------------------------------------------------------------------------------------+


EOF

  print ("$helpTxt\n");
  exit;
}

sub getLoggingTime {

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
    my $nice_timestamp = sprintf ( "%04d%02d%02dT%02d%02d%02d",
                                   $year+1900,$mon+1,$mday,$hour,$min,$sec);
    return $nice_timestamp;
}

my $timestamp = getLoggingTime;

# Get the command line options and arguments and validate
my $in_opt = get_cmd_line_options();
my $in_arg = get_cmd_line_arguments();

$| = 1;

my $url = "=common#mov_thru_user_mark#get_template('u', 'URL')";
my $log_file = "log.txt";

my $result_dir = "output";
make_path($result_dir);
my $csv_file = "$result_dir/sample_$timestamp.csv";
print ("OUTPUT: $csv_file\n");

my $heading = [
  =common#mov_thru_user_mark#get_template('h', 'CSV File Headings')
];

#-------------------------------------------------------------------------------
# Lookup Code
use File::Path qw(make_path remove_tree);
my $lut_dir = "$ENV{HOME}/lut";
make_path($lut_dir);

my $lut_file = "$lut_dir/sample.lut";
if (defined($in_opt -> {l}) and $in_opt -> {l} == 1) {
  print ("LUT File: $lut_file\n");
}

my $lookup = Lookup -> new(
  lut_file => $lut_file,
  auto_files_en => 0, # FIXME: 1: generate auto lut file prefixed by lut_file argument
  is_active => $in_opt -> {l}, # -l: Enable lookup
  log_file => $log_file,
);
#-------------------------------------------------------------------------------

my $scrapy = Scrapy -> new({
  url => $url,
  csv_file => $csv_file,
  log_file => $log_file,
  heading => $heading,
  lookup => $lookup,
});

$scrapy -> scrape_all_data;


