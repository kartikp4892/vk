#!/usr/bin/perl -w
use strict;
use warnings;

package Proxy::4EverProxy;
use WWW::Mechanize;
sub new {
  my $class = shift;

  my $mech = WWW::Mechanize -> new(
    agent => 'Mozilla/5.0 (X11; Linux i686; rv:12.0) Gecko/20100101 Firefox/12.0',
  );

  my $base_url = "https://www.4everproxy.com/";
  my $query = {};
  my $self = bless {
    mech => $mech,
    base_url => $base_url,
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

sub select_form {
  my $self = shift;
  my $mech = $self -> mech;

  my $form = $mech -> form_id("foreverproxy_url-form");
  return $form;
}

sub get {
  my $self = shift;
  my $url = shift;

  my $mech = $self -> mech;
  $mech -> get($self -> base_url);

  #$mech -> dump_forms();
  $self -> select_form;

  $mech -> field("u", $url);
  $mech -> submit();

  #$mech -> save_content("4ever.html");
  return $mech;
}

1;

__END__
#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------
my $heroproxy = Proxy::4EverProxy -> new();

for (my $i = 0; $i < 4; $i++) {
  my $mech = $heroproxy -> get("http://whatismyipaddress.com/");
  $mech -> save_content("log$i.html");
}
