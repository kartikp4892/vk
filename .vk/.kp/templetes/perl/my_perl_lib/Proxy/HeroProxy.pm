#!/usr/bin/perl -w
use strict;
use warnings;
use WWW::Mechanize;


package Proxy::HeroProxy;
sub new {
  my $class = shift;

  my $mech = WWW::Mechanize -> new(
    agent => 'Mozilla/5.0 (X11; Linux i686; rv:12.0) Gecko/20100101 Firefox/12.0',
  );

  my $base_url = "http://www.heroproxy.com/";
  my $submit_url = "http://www.heroproxy.com/includes/process.php";
  my $query = {};
  my $self = bless {
    mech => $mech,
    base_url => $base_url,
    submit_url => $submit_url,
    query => $query,
  }, $class;

  return $self;
}

sub mech {
  my $self = shift;
  return $self -> {mech};
}

sub base_url {
  my $self = shift;
  return $self -> {base_url};
}

sub submit_url {
  my $self = shift;
  return $self -> {submit_url};
}

sub query {
  my $self = shift;
  return $self -> {query};
}

sub get {
  my $self = shift;
  my $url = shift;

  my $mech = $self -> mech;
  $mech -> get($self -> base_url);

  my $form = $mech -> form_with_fields('u');
  $mech -> field('u', $url);
  $mech -> submit();

  return $mech;
}

1;

__END__
#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------
my $heroproxy = Proxy::HeroProxy -> new();

$heroproxy -> get("http://whatismyipaddress.com/");
