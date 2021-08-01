package Data::Convert;
use strict;
use warnings;

#-------------------------------------------------------------------------------
# hash_to_csv_data :
# @arg 1: CSV Column Heading as argument. 
# @arg 2: Hash data
# if the cell value of csv data is array reference then it will be expended to rows and column
# the other cells will be kept blank excep the first rows.
#
# Note: the returned result is array ref in which each element is the array ref which shows the rows.
#-------------------------------------------------------------------------------
sub hash_to_csv_data {
  my %arg = @_;
  my $csv_heading = $arg{heading};
  my $h_data = $arg{h_data};

  die ("csv_heading not provided!!!") unless (defined($csv_heading));
  die ("h_data not provided!!!") unless (defined($h_data));

  my $csv_data = [];
  foreach my $col_heading (@{$csv_heading}) {
    push (@{$csv_data}, $h_data -> {$col_heading});
  }

  my $csv_rows = _get_csv_rows($csv_data);
  return $csv_rows;
}

#-------------------------------------------------------------------------------
# _get_csv_rows :
#-------------------------------------------------------------------------------
sub _get_csv_rows {
  my $data = shift;
  my $max_rows = 1;
  foreach my $row (@{$data}) {

    if (ref($row) eq ref({})) {
      die ("Not valid format!!!");
    }

    if (ref($row) eq ref([])) {
      $max_rows = $#{$row} + 1 if ($max_rows < ($#{$row} + 1));
    }
  }

  my $data_row = [];
  @$data_row = map {(ref($_) eq (ref([]))) ? ($_) : ([$_])} @$data;

  my $csv_rows = [];
  for (my $i = 0; $i < $max_rows; $i++) {
    my $csv_row = [];
    for (my $j = 0; $j < @$data_row; $j++) {
      my $col_val = $data_row -> [$j] [$i];
      if (ref($col_val) eq ref({})) {
        die ("Not valid format!!!");
      }

      # If column element is the array ref then push the array
      if (ref($col_val) eq ref ([])) {
        foreach my $col_v (@{$col_val}) {
          #$col_v = remove_multi_char($col_v) if (defined($col_v));
          push (@$csv_row, @{$col_val});
        }
      }
      # else push the scalar element
      else {
        #$col_val = remove_multi_char($col_val) if (defined($col_val));
        push (@$csv_row, $col_val);
      }
    }
    push (@$csv_rows, $csv_row);
  }
  return $csv_rows;
}

#-------------------------------------------------------------------------------
# remove_multi_char :
#-------------------------------------------------------------------------------
sub remove_multi_char {
  my $text = shift;
  return "" unless (defined($text));
  return $text if ($text eq "");
  use utf8;
  use Text::Unidecode;
  use HTML::Entities;

  $text  = unidecode($text);
  $text  = decode_entities($text);

  # Remove leading and trailing spaces
  $text =~ s/^\s+|\s+$//g;

  return $text;
}

1;
