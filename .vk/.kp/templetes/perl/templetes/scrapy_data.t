package =substitute(expand('%:t'), '\v\.\w+$', '', '');
use strict;
use warnings;
use Web::Scraper;
use Data::Dump;

use lib "=$KP_PERL_LIB_HOME";
use Clone 'clone';
use WWW::Mech::Try;

$| = 1;
sub new {
  my $class = shift;
  my %arg = @_;

  my $data_h;
  if (defined($arg{data_h})) {
    $data_h = clone($arg{data_h});
  }
  else {
    $data_h = {};
  }

  foreach my $carg (qw(mech)) {
    die "Error: Argument $carg not provided!!!" if (!defined($arg{$carg}));
  }

  my $mech = $arg{mech};
  $mech -> get ($mech -> {url});

  my $self = bless {
    data_h   => $data_h,
    mech      => $mech,
    log_file => $arg{log_file},
    csv_kp   => $arg{csv_kp},
  }, $class;
  return $self;

}

sub tee {
  my $self = shift;
  my $text = shift;

  if (defined($self -> {log_file})) {
    my $log_file = $self -> {log_file};
    open (my $fh, ">>$log_file") or die ("Error: Couln't open file $log_file $!");
    print $fh ("$text\n");
  }
  print ("$text\n");
}

#-------------------------------------------------------------------------------
# scrape_data :
#-------------------------------------------------------------------------------
sub scrape_data {
  my $self = shift;
  my $url = $self -> {mech} -> {url};

  $self -> tee ("Scraping $url");

  my $mech = $self -> {mech};

  #my $mech = WWW::Mech::Try -> new (
  #  agent => 'Mozilla/5.0 (X11; Linux i686; rv:12.0) Gecko/20100101 Firefox/12.0',
  #  max_try => -1,
  #);

  my $content = $mech -> content();

  $content =~ s/<meta.*?>//g;
  $content =~ s/<tbody.*?>//g;
  $content =~ s/<link.*?>//g;

  my $s_text = sub {
    my $he = shift;
    my $text = $he -> as_HTML();

    $text =~ s/<br.*?>/\n/g;
    $text =~ s/<.*?>//g;

    return $text;
  };

  my $s_num_text = sub {
    my $he = shift;
    my $text = $s_text -> ($he);

    return '="' . $text . '"';
  };

  my $scraper = scraper {
    # =common#mov_thru_user_mark#get_template('d', 'Scraper Code here')
    #process "", "" =>
  };

  my $scrape = $scraper -> scrape ($content);

  $scrape -> {URL} = $url;

  # Convert all arrays to text separated by newline
  while (my ($key, $value) = each %$scrape) {
    if (ref($value) eq ref([])) {
      $value = join ("\n", @{$value});
      $scrape -> {$key} = $value;
    }
  }

  $self -> {data_h} = {%{$self -> {data_h}}, %$scrape};

  dd $self -> {data_h};
  exit; # FIXME

  $self -> {csv_kp} -> print ($self -> {data_h});
  return $self -> {data_h};
}

1;

