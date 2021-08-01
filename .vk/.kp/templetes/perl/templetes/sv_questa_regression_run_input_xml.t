#!/usr/bin/perl -w
use strict;
use warnings;

use XML::Simple;
use Data::Dump;
use Getopt::Std;
use CGI;
use File::Path 'rmtree';

#-------------------------------------------------------------------------------
# getopt_switch :
# Description : Get the command line options provided by the user
#-------------------------------------------------------------------------------
sub getopt_switch {
  my $opt = {};
  getopts('h', $opt);

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
# getopt_arg :
# Description : Get the command line arguments provided by the user
#-------------------------------------------------------------------------------
sub getopt_arg {
  my $query = CGI -> new();
  my $args = $query -> Vars;

  #-------------------------------------------------------------------------------
  # Check for invalid argument and show warnings if found
  my @validArgs = ("test_list_xml");
  my @allArgs = $query -> param();
  my @invalidArgs;
  foreach my $curArg (@allArgs) {
    push (@invalidArgs, $curArg) if ((grep ($curArg eq $_, @validArgs)) == 0);
  }

  warn ("Warning: Unknown argument '$_'") for (@invalidArgs);
  #-------------------------------------------------------------------------------

  if (!defined($args -> {test_list_xml})) {
    print "Error: test_list_xml arugument not provided!!!";
    print_help ();
  }

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
    |   \$ perl <Path>/$0 <options> <arguments>
    |   OR
    |   \$ $0 <options> <arguments>
    |
    |   Note: Options must be provided before arguments.
    |
    | Options:
    |   -h : Print Help
    |
    | Arguments:
    |   test_list_xml    : XML file containing details of all the testcases to be run in regression
    |
    |   e.g. 1
    |   perl $0 -h
    |
    |   e.g. 2
    |   perl $0 test_list_xml=$ENV{TESTDIR}/ofia_dofia24_test_list.xml
    |
    +---------------------------------------------------------------------------------------------+

EOF

  print ("$helpTxt\n");
  exit;
}

#-------------------------------------------------------------------------------
# Sub : compile
#-------------------------------------------------------------------------------
sub compile {
  my $dut = shift;

  my $cmd ="dofia_run.sh -c dut=$dut\n";
  print ($cmd);
  my $ret = system ($cmd);
  die if ($ret != 0);
}

#-------------------------------------------------------------------------------
# Sub : run_test
#-------------------------------------------------------------------------------
sub run_test {
  my %arg = @_;
  my $dut = $arg{dut};
  my $testname = $arg{test};
  my $seed = $arg{seed};

  my $ret;
  if (defined($seed)) {
    my $cmd = "dofia_run.sh -s dut=$dut test=$testname sv_seed=$seed\n";
    print ($cmd);
    $ret = system($cmd)
  }
  else {
    my $cmd = "dofia_run.sh -s dut=$dut test=$testname\n";
    print ($cmd);
    $ret = system ($cmd);
  }
  die if ($ret != 0);
}

#-------------------------------------------------------------------------------
# Sub : run_all_tests
#-------------------------------------------------------------------------------
sub run_all_tests {
  my $in_arg = shift;
  my $config_h = XMLin($in_arg -> {test_list_xml});
  my $dut = $config_h -> {dut};

  # Remove old logs
  print ("Removing old logs from $ENV{LOGDIR} for $dut\n");
  my @log_dirs = <$ENV{LOGDIR}/ofia_${dut}_*>;
  rmtree ([@log_dirs]);

  compile ($dut);

  foreach my $test_h (@{$config_h -> {test}}) {
    my $testname = $test_h -> {testname};

    my $iterations = $test_h -> {iterations};
    if (!defined($iterations)) {
      # Default
      $iterations = $config_h -> {iterations};
    }

    for (my $idx = 0; $idx < $iterations; $idx++) {
      # Run test with random seed
      run_test (dut => $dut, test => $testname);
    }

    if (defined($test_h -> {seeds})) {
      my @seeds = split (/\s*,\s*/, $test_h -> {seeds});
      foreach my $seed (@{seeds}) {
        # Run test with specified seeds
        run_test (dut => $dut, test => $testname, seed => $seed);
      }
    }
  }

  gen_cov_report ($dut);
  grep_failed_testcases ($dut);
}

#-------------------------------------------------------------------------------
# Sub : grep_failed_testcases
#-------------------------------------------------------------------------------
sub grep_failed_testcases {
  my $dut = shift;
  my @log_dirs = <$ENV{LOGDIR}/ofia_${dut}_*>;
  my $failed_tests = `grep -r "STATUS       : FAILED" @log_dirs`;
  if ($failed_tests ne "") {
    print ("##################################################################\n");
    print ("####  FAIED TESTCASES IN SIMULATION\n");
    print ("##################################################################\n");
    print ("$failed_tests\n");
  }
}

#-------------------------------------------------------------------------------
# Sub : gen_cov_report
#-------------------------------------------------------------------------------
sub gen_cov_report {
  my $dut = shift;
  my @ucdb_files = <$ENV{LOGDIR}/ofia_${dut}_*/*.ucdb>;

  # Merge file
  my $merged_ucdb = "$ENV{LOGDIR}/merged_$dut.ucdb";

  system ("vcover merge @ucdb_files -out $merged_ucdb");
  my $htmldir = "$ENV{LOGDIR}/covhtmlreport_$dut";

  print ("Generating Coverage report...\n");

  system ("vcover report -html -htmldir $htmldir $merged_ucdb");
}

# Get the command line options and arguments and validate
my $in_opt = getopt_switch();
my $in_arg = getopt_arg();

run_all_tests ($in_arg);







__END__
XML File format:

========================================================================================================
<?xml version="1.0"?>
<!--comment>
Description: This xml file contains list of all the tests in the regression run.
The format of the tests is shown below:

The tests description XML formate:
<tests>
  <test> 
    <testname>test_sanity</testname>
    <seeds>123,456,789</seeds>
    <iterations>3</iterations>
  </test>
</tests>

Where seeds and iterations are options.
a) If seeds are provided, it will run the test on a given seed. If seeds are not provided, it will run the test on random seed value.
b) If iterations are provided, it will run the same test number of times equal to the iteration value with different random seeds.
c) If both seeds and iterations are provided, test will be run with both a) and b) steps above.
</comment-->


<tests dut="<+a+DUT_NAME+>">
  <!-- The default values of the tags here will be applied to all the testcases unless user override this value in a specific testcase -->
  <iterations>3</iterations>

  <!-- The test description starts from here -->
  <test> 
    <testname>test_sanity</testname>
  </test>

  <test> 
    <testname>test_config</testname>
  </test>

  <test> 
    <testname>test_write_read</testname>
    <iterations>5</iterations>
  </test>

  <!-- SCRIPT USE ONLY DON'T REMOVE -->
</tests>













