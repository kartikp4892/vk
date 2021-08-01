#-------------------------------------------------------------------------------
# WWW::Mech::Try is a subclass of the WWW::Mechanize.
# It combines Try block with Mechanize to handle exceptions
#-------------------------------------------------------------------------------
package WWW::Mech::Try;
use strict;
use warnings;

use WWW::Mechanize;
use Error qw(:try);
use Data::Dump;

our @ISA = qw(WWW::Mechanize);
#-------------------------------------------------------------------------------
# @arg: max_try --> Number of maximum try to handle exception
#-------------------------------------------------------------------------------
sub new {
  my $class = shift;
  my %all_arg = @_;
  my %mech_arg = %all_arg;

  delete $mech_arg{max_try};

  my $mech = WWW::Mechanize -> new(%mech_arg);
  my $self = bless $mech, $class;

  if (exists($all_arg{max_try})) {
    $self -> {max_try} = $all_arg{max_try};
  }
  else {
    # Unlimited number of retry
    $self -> {max_try} = -1;
  }

  return $self;
}

sub get {
  my $self = shift;
  my @arg = @_;
  my $max_try = $self -> {max_try};

  my $retry_cnt = 0;

  GET_RETRY:
  try {
    $self -> SUPER::get(@arg);
  }
  catch Error with {
    print ("[Error]: $@\n");

    if ($max_try == -1 || $retry_cnt < $max_try) {
      $retry_cnt ++;
      #$self -> SUPER::update_html("<try>Error</try>");

      sleep (2);
      print ("## RETRY #$retry_cnt\n");
      goto GET_RETRY;
    }
  };
}

sub post {
  my $self = shift;
  my @arg = @_;
  my $max_try = $self -> {max_try};

  my $retry_cnt = 0;

  POST_RETRY:
  try {
    $self -> SUPER::post(@arg);
  }
  catch Error with {
    print ("[Error]: $@\n");

    if ($max_try == -1 || $retry_cnt < $max_try) {
      $retry_cnt ++;
      #$self -> SUPER::update_html("<try>Error</try>");

      sleep (2);
      print ("## RETRY #$retry_cnt\n");
      goto POST_RETRY;
    }
  };
}

1;

__END__

#-------------------------------------------------------------------------------
# Main
package main;
#-------------------------------------------------------------------------------
my $mech = WWW::Mech::Try -> new(
  agent => 'Mozilla/5.0 (X11; Linux i686; rv:12.0) Gecko/20100101 Firefox/12.0',
  max_try => 3,
);

$mech -> get('http://checkip.dyndns.org/');



