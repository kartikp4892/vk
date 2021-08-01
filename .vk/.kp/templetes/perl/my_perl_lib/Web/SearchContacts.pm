#!/usr/bin/perl -w
use strict;
use warnings;

package Web::SearchContacts;
use WWW::Mechanize;
use Email::Find;
use Error qw(:try);

sub new {
  my $class = shift;

  my $mech = WWW::Mechanize -> new(
    agent => 'Mozilla/5.0 (X11; Linux i686; rv:12.0) Gecko/20100101 Firefox/12.0',
  );

  my $self = bless {
    mech => $mech
  }, $class;
  return $self;
}

sub mech {
  my $self = shift;
  return $self -> {mech};
}

# Get the contact us page of url
sub contact_us {
  my $self = shift;
  my $url = shift;

  my $mech = $self -> mech;

  $mech -> get($url);
  
  if ($mech -> find_link(text_regex => qr/^\s*contact(\s+us)?\s*$/i)) {
    my $links = $mech -> find_link(text_regex => qr/^\s*contact(\s+us)?\s*$/i);
    my $n = 1;
    my $success = 0;
    foreach my $link (@$links) {
      print ("## $link\n");
      try {
        $mech -> follow_link(text_regex => qr/^\s*contact(\s+us)?\s*$/i, n => $n++);
        print ("# Success: $link\n");
        $success = 1;
      }
      catch Error with {
        print ("# $@\n");
        $mech -> get($url);
      };
      last if ($success);
    }
    return 1 if ($mech -> success());
    return 0;
  }
  else {
    return 0;
  }
}

sub get_emails {
  my $self = shift;
  my $mech = $self -> mech;

  my $content = $mech -> content();

  my @found_emails;
  my $finder = Email::Find->new(
    sub {
        my ($email, $orig_email) = @_;
        my ($address) = $email->format;
        push (@found_emails, $orig_email);
        # The return value is replaced by email in content
        return $orig_email;
    },
  );
  $finder->find(\$content);

  return \@found_emails;
}

sub uniq_array {
  my $self = shift;
  my $emails = shift;
  my $uniq = [];
  
  my %email_found;

  foreach my $email (@$emails) {
    next if (exists($email_found{lc($email)}));
    $email_found{lc($email)} ++;
    push (@{$uniq}, $email);
  }
  return $uniq;
}

sub get_contact_details {
  my $self = shift;
  my $url = shift;
  my $mech = $self -> mech;

  $self -> contact_us($url);
  my $emails = $self -> get_emails;
  $emails = $self -> uniq_array($emails);
  return {emails => $emails};
}

1;
