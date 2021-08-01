package Lookup;
use strict;
use warnings;
use Tie::File;

sub new {
  my $class = shift;
  my %arg = @_;

  my $lut_file = $arg{lut_file};
  my $is_active = $arg{is_active};
  my $log_file = $arg{log_file};
  my $auto_files_en = $arg{auto_files_en};

  # Add uniq string to the lut_file name to create several lut files
  # Value 1: generate auto lut file prefixed by lut_file argument
  $auto_files_en = 0 if (!defined($auto_files_en));

  $is_active = 0 if (!defined($is_active));

  my $self = bless {
    lut_file => $lut_file,
    is_active => $is_active,
    log_file => $log_file,
    auto_files_en => $auto_files_en,
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
# parse_url :
# Logic to modify the url into a uniq string which needs to be stored in look up
#-------------------------------------------------------------------------------
sub parse_url {
  my $self = shift;
  my $url = shift;
  my $string = $url;

  # =common#mov_thru_user_mark#get_template('a', 'Code to get the unique string from URL')

  return $string;
}

#-------------------------------------------------------------------------------
# save_entry :
#-------------------------------------------------------------------------------
sub save_entry {
  my $self = shift;
  my $url = shift;

  my $str = $self -> parse_url($url);
  my $lut_file = $self -> auto_lut_file_name($str);

  my @tie_array;
  if ($self -> {is_active} != 0) {
    tie @tie_array, 'Tie::File', $lut_file;

    push (@tie_array, $str);

    untie @tie_array;
  }
}

sub auto_lut_file_name {
  my $self = shift;
  my $str = shift;
  my $lut_file = $self -> {lut_file};

  my $file_str = $str;
  $file_str =~ s/\W+/_/g;

  my $auto_file_name;

  if ($self -> {auto_files_en} == 0) {
    $auto_file_name = $lut_file;
  }
  else {
     my ($filebase, $ext) = ($1, $2) if ($lut_file =~ /^(.*?)\.?(\w*)$/);

     $auto_file_name = "${filebase}_${file_str}.${ext}";
  }

  $self -> tee ("[LUT : $str] file name: $auto_file_name");

  return $auto_file_name;
}

#-------------------------------------------------------------------------------
# is_exists :
# Check that the unique url string exists in lut, if not than save to lut
#-------------------------------------------------------------------------------
sub is_exists {
  my $self = shift;
  my $url = shift;

  return 0 if (!defined($self -> {is_active}) || $self -> {is_active} == 0);

  my $str = $self -> parse_url($url);

  my $lut_file = $self -> auto_lut_file_name($str);

  my @tie_array;

  tie @tie_array, 'Tie::File', $lut_file;

  my $no_entries = grep ($_ eq $str, @tie_array);

  # $self -> save_entry($str) unless ($no_entries);

  if ($no_entries) {
    $self -> tee ("[LUT : $str] Exists in file: $lut_file");
  }

  untie @tie_array;

  return $no_entries;
}

1;



