#!/usr/bin/perl -w
use strict;
use warnings;

package Proxy::Iterator;
sub new {
  my $class = shift;
  my $arg = shift;

  my $proxies = [];
  # If filename provided
  my $fh;
  my $file;
  if (ref($arg) eq ref("")) {
    open ($fh, "$arg") or die ("Error: Couln't open file $arg $!\n");
    my @inputs = <$fh>;
    @inputs = map {s/\r?\n?$//g; $_} @inputs;
    $proxies = \@inputs;
    $file = $arg;
  }
  elsif (ref($arg) ne ref([])) {
    die ("Valid argument not provided!!!\n");
  }
  else {
    if (@$arg == 0) {
      die ("Please provide proxy list!!!\n");
    }
    $proxies = $arg;
  }

  my $self = bless {
    proxy_file => $file,
    proxy_list => $proxies,
    ptr => -1,
    error_cnt => 0,
    error_threshold => 5,
  }, $class;
  return $self;
}

#-------------------------------------------------------------------------------
# reset :
#-------------------------------------------------------------------------------
sub reset {
  my $self = shift;
  print ("\n# ========== Initializing Proxy From File ==============");

  if (defined($self -> {proxy_file})) {
    my $file = $self -> {proxy_file};
    open (my $fh, "$file") or die ("Error: Couln't open file $file $!");

    my @proxies = <$fh>;
    @proxies = map {s/\r?\n?$//g; $_} @proxies;

    $self -> {proxy_list} = \@proxies;
  }
  $self -> {ptr} = -1;
  $self -> {error_cnt} = 0;
}

#-------------------------------------------------------------------------------
# failed :
#-------------------------------------------------------------------------------
sub failed {
  my $self = shift;
  
  $self -> {error_cnt}++;

  if ($self -> {error_cnt} >= $self -> {error_threshold}) {
    $self -> reset();
  }
}

#-------------------------------------------------------------------------------
# get_next_pointer :
#-------------------------------------------------------------------------------
sub get_next_pointer {
  my $self = shift;

  $self -> {ptr}++;

  $self -> {ptr} = ($self -> {ptr}) % (@{$self -> {proxy_list}});
}

#-------------------------------------------------------------------------------
# get_prev_pointer :
#-------------------------------------------------------------------------------
sub get_prev_pointer {
  my $self = shift;

  $self -> {ptr}--;

  $self -> {ptr} = ($self -> {ptr}) % (@{$self -> {proxy_list}});
}

#-------------------------------------------------------------------------------
# get_next_proxy :
#-------------------------------------------------------------------------------
sub get_next_proxy {
  my $self = shift;
  $self -> get_next_pointer;

  my $proxy = $self -> {proxy_list};
  my $ptr = $self -> {ptr};

  return $proxy -> [$ptr];
}

#-------------------------------------------------------------------------------
# get_prev_proxy :
#-------------------------------------------------------------------------------
sub get_prev_proxy {
  my $self = shift;
  $self -> get_prev_pointer;

  my $proxy = $self -> {proxy_list};
  my $ptr = $self -> {ptr};

  return $proxy -> [$ptr];
}

1;
