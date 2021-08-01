#!/usr/bin/perl -w
use strict;
use warnings;

package Proxy::RapidProxy;
use WWW::Mechanize;
sub new {
  my $class = shift;

  my $mech = WWW::Mechanize -> new(
    agent => 'Mozilla/5.0 (X11; Linux i686; rv:12.0) Gecko/20100101 Firefox/12.0',
  );

  my $base_url = "http://www.rapidproxy.us/";
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

sub select_form {
  my $self = shift;
  my $mech = $self -> mech;

  my @forms = $mech -> forms();

  my $form_no = 1;
  foreach my $form (@forms) {
    if ($form -> action =~ /\brapidproxy\.us\b/ &&
        $form -> method =~ /^post$/i) {
      last;
    }
    $form_no++;
  }
  $mech -> form_number($form_no);
}

sub get {
  my $self = shift;
  my $url = shift;

  my $mech = $self -> mech;
  $mech -> get($self -> base_url);

  #$mech -> dump_forms();
  $self -> select_form;

  $mech -> field("q", $url);
  $mech -> submit();

  $mech -> save_content("rapid.html");
  return $mech;
}

1;

__END__
#-------------------------------------------------------------------------------
# Main
#-------------------------------------------------------------------------------
my $heroproxy = Proxy::HeroProxy -> new();

$heroproxy -> get("http://whatismyipaddress.com/");
