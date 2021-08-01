#!/usr/bin/perl
use strict;
use warnings;

use WWW::Mechanize;
use Web::Scraper;

#-------------------------------------------------------------------------------
# is_licensed :
#-------------------------------------------------------------------------------
sub is_licensed {
  my $license_id = shift;
  my $license_url = "https://sites.google.com/site/myfirstsitekp/";

  my $mech = WWW::Mechanize -> new(
    onerror => sub { die ("Error: Couldn't get lwp request!!!\n"); },
    onwarn => sub { warn ("Warn: Couldn't get lwp request!!!\n"); },
  );
  $mech -> get($license_url);

  my $license_s = scraper {
    process "//*[text()='$license_id']", "license" => 'TEXT';
  };

  my $lx = $license_s -> scrape ($mech -> content());

  return 0 unless (exists($lx-> {license}));

  return 1 if ($lx-> {license} eq "$license_id");
  return 0;

}

#-------------------------------------------------------------------------------
# get_ip :
#-------------------------------------------------------------------------------
sub get_ip {
  my $mech = WWW::Mechanize -> new();
  $mech -> get("http://checkip.dyndns.org/");
  return $mech -> content();
}

#-------------------------------------------------------------------------------
# submit_result :
#-------------------------------------------------------------------------------
sub submit_result {
  my $time = shift;
  my $url = shift;
  my $num_links = shift;

  my $form_url = "https://docs.google.com/forms/d/1mFpbFc548bb76J2JsxjiVm_4xOdwoq-mcFUN9dxU3HM/viewform";

  my $mech = WWW::Mechanize -> new(
    onerror => sub { die ("Error: Couldn't post lwp request!!!\n"); },
    onwarn => sub { warn ("Warn: Couldn't post lwp request!!!\n"); },
  );
  $mech -> get($form_url);

  $mech -> form_id("ss-form");
  $mech -> field('entry.1636279226', $time);
  $mech -> field('entry.1373364280', $url);
  $mech -> field('entry.2040310466', $num_links);
  $mech->submit();
}

#my $form_url = "https://docs.google.com/forms/d/1mFpbFc548bb76J2JsxjiVm_4xOdwoq-mcFUN9dxU3HM/viewform";
#
#my $license_url = "https://sites.google.com/site/myfirstsitekp/";

1;
