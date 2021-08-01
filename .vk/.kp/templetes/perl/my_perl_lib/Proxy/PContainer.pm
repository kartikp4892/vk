#!/usr/bin/perl -w
use strict;
use warnings;

package Proxy::PContainer;
use Proxy::HeroProxy;
use Proxy::RapidProxy;
use Proxy::4EverProxy;
use Proxy::GameProxy;
use Proxy::InternetCloak;
use Proxy::WebProxyUsa;
use Proxy::Proxy2014;

use WWW::Mechanize;

sub new {
  my $class = shift;

  my $proxies = [];

  push (@{$proxies}, Proxy::HeroProxy -> new());
  push (@{$proxies}, Proxy::RapidProxy -> new());
  push (@{$proxies}, Proxy::4EverProxy -> new());
  push (@{$proxies}, Proxy::GameProxy -> new());
  push (@{$proxies}, Proxy::InternetCloak -> new());
  push (@{$proxies}, Proxy::WebProxyUsa -> new());
  push (@{$proxies}, Proxy::Proxy2014 -> new());

  my $self = bless {
    mech => undef, # curr proxy mech
    proxies => $proxies,
    ptr => -1,
  }, $class;

  return $self;
}

sub proxies {
  my $self = shift;
  return $self -> {proxies};
}

sub ptr {
  my $self = shift;
  return $self -> {ptr};
}

sub mech {
  my $self = shift;
  return $self -> {mech};
}

sub next_ptr {
  my $self = shift;
  $self -> {ptr}++;
  my $proxies = $self -> proxies;

  $self -> {ptr} = 0 if ($self -> {ptr} > $#{$proxies});

  return $self -> {ptr};
}

sub get {
  my $self = shift;
  my $url = shift;

  my $proxies = $self -> proxies;
  my $ptr = $self -> ptr;

  $self -> {mech} = $proxies -> [$self -> next_ptr] -> get($url);
  return $self -> {mech};
}

1;

__END__
#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------
my $pcontainer = Proxy::PContainer -> new();

for (my $i = 0; $i < 4; $i++) {
  my $mech = $pcontainer -> get("http://checkip.dyndns.org/");
  print $mech -> uri();
  print ("\n");
}
