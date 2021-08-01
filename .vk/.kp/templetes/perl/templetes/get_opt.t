use Getopt::Std;
use CGI;

#-------------------------------------------------------------------------------
# get_cmd_line_options :
# Description : Get the command line options provided by the user
#-------------------------------------------------------------------------------
sub get_cmd_line_options {
  my $opt = {};
  getopts('hpn', $opt);

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
  my @validArgs = ("csv_file", "zipcode", "time_delay", "username", "password");
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
    |
    | Arguments:
    |   zipcode    : zip code for which the data is to scrape
    |
    |   e.g. 1
    |   perl $0 -h
    |
    |   e.g. 2
    |   perl $0 zipcode=90004 csv_file=sample_out.csv
    |
    +---------------------------------------------------------------------------------------------+

EOF

  print ("$helpTxt\n");
  exit;
}

# Get the command line options and arguments and validate
my $in_opt = get_cmd_line_options();
my $in_arg = get_cmd_line_arguments();



