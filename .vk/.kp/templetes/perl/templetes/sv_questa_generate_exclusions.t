#!/usr/bin/perl -w
use strict;
use warnings;

package Getopts;
use strict;
use warnings;

use Getopt::Std;

my $Getopts;

sub new {
  my $class = shift;

  return $Getopts if (defined($Getopts));

  my $options = 'h';

  my $opts = {};
  getopts($options, $opts);

  if (exists($opts -> {"h"})) {
    print_help();
    exit;
  }

  my $self = {
    %$opts,
  };
  $self = bless $self, $class;

  $Getopts = $self;
  return $self;

}

#-------------------------------------------------------------------------------
# print_help :
# Print help and exit
#-------------------------------------------------------------------------------
sub print_help {
my $helpTxt = <<EOF;

    +---------------------------------------------------------------------------------------------+
    |                     Help on $0
    +---------------------------------------------------------------------------------------------+
    | This script is used to scrape airbnb.com website
    |
    | Usages:
    |   perl <Path>/$0 <options> <arguments>
    |
    |   Note: Options must be provided before arguments.
    |
    | Options:
    |   -h : Print Help
    |
    | Arguments:
    |   zipcode    : zip code for which the data is to scrape
    |
    |   e.g. 1
    |   perl $0 -h
    |
    |   e.g. 2
    |   perl $0 zipcode=90004 csv_file=sample_out.csv
    |
    +---------------------------------------------------------------------------------------------+

EOF

  print ("$helpTxt\n");
  exit;
}

package Getargs;
use strict;
use warnings;

use CGI;

my $Getargs;

sub new {
  my $class = shift;

  return $Getargs if (defined($Getargs));

  my $query = CGI -> new();
  my $args = $query -> Vars;

  #-------------------------------------------------------------------------------
  # Check for invalid argument and show warnings if found
  my @validArgs = ("xlsx");
  my @allArgs = $query -> param();
  my @invalidArgs;
  foreach my $curArg (@allArgs) {
    push (@invalidArgs, $curArg) if ((grep ($curArg eq $_, @validArgs)) == 0);
  }

  foreach my $curArg (@{validArgs}) {
    die "command line argument $curArg= not provided!!!" if ((grep ($curArg eq $_, @allArgs)) == 0)
  }

  warn ("Warning: Unknown argument '$_'") for (@invalidArgs);
  #-------------------------------------------------------------------------------

  my $self = {
    %$args,
  };
  $self = bless $self, $class;
  return $self;

}

package Branch;
use strict;
use warnings;
use Data::Dump;
use Spreadsheet::Read;

sub new {
  my $class = shift;
  my $book = shift || die "book not defined!!!";

  my $exclusions = {}; # comments => [excluded xls rows]

  my ($sheet) = grep (((defined($_ -> {label})) and ($_ -> {label} eq 'Branches')), @$book);

  my $file = "branches.do";
  open (my $fh, ">$file") or die ("Error: Couln't open file $file $!");

  print $fh ("#============================================================\n");
  print $fh ("# Branches Exclusions\n");
  print $fh ("#============================================================\n");

  my $self = {
    exclusions => $exclusions,
    sheet => $sheet,
    fh => $fh,
  };
  $self = bless $self, $class;
  return $self;

}

#-------------------------------------------------------------------------------
# Sub : get_row
#-------------------------------------------------------------------------------
sub get_row {
  my $self = shift;
  my $row = shift;

  my $sheet = $self -> {sheet};

  my @row;
  for (my $col = $sheet -> {mincol}; $col <= $sheet -> {maxcol}; $col++) {
    my $cell = $self -> get_cell_value($row, $col);

    push (@{row}, $cell);
  }

  return \@row;
}

#-------------------------------------------------------------------------------
# Sub : get_cell_value
#-------------------------------------------------------------------------------
sub get_cell_value {
  my $self = shift;
  
  my $row = shift;
  my $col = shift;
  
  my $sheet = $self -> {sheet};

  foreach my $merged (@{$sheet -> {merged}}) {
    my ($col1, $row1, $col2, $row2) = @$merged;

    if ($col >= $col1 && $col <= $col2) {
      if ($row >= $row1 && $row <= $row2) {
        $row = $row1;
        $col = $col1;
      }
    }
  }

  my $cell = Spreadsheet::Read::cr2cell($col, $row);

  return $sheet -> {$cell};
}

#-------------------------------------------------------------------------------
# Sub : parse
#-------------------------------------------------------------------------------
sub parse {
  my $self = shift;
  my $sheet = $self -> {sheet};

  my @exclusions_rows;
  for (my $col = $sheet -> {mincol}; $col <= $sheet -> {maxcol}; $col++) {
    for (my $row = $sheet -> {minrow}; $row <= $sheet -> {maxrow}; $row++) {
      if (defined $sheet -> {cell}[$col][$row]) {
        if ($sheet -> {cell}[$col][$row] =~ m{^Exclusion}) {
          push (@{exclusions_rows}, $row);
        }
      }
    }
  }

  foreach my $row (@{exclusions_rows}) {
    my $row_a = $self -> get_row ($row);

    my ($rational) = grep (/^Exclusion/i, @$row_a);
    $rational =~ s{\n+}{ }g;
    $rational =~ s{^\s*|\s*$}{}g;

    $self -> {exclusions} {$rational} = [] if (!defined($self -> {exclusions} {$rational}));

    push (@{$self -> {exclusions} {$rational}}, $row_a);
  }

  $self -> put_exclusion_cmds ($self -> {exclusions});
}

#-------------------------------------------------------------------------------
# Sub : put_exclusion_cmds
#-------------------------------------------------------------------------------
sub put_exclusion_cmds {
  my $self = shift;
  my $exclusions = $self -> {exclusions};
  my $fh = $self -> {fh};

  foreach my $rational (keys %{$self -> {exclusions}}) {
    print $fh ("# $rational\n");

    my $skip_all_false = 0;
    my $prev_line_num;
    my $prev_branch;
    foreach my $row (@{$self -> {exclusions}{$rational}}) {
      my ($instance_path, $source_file, $line_number, $source, $branch, $comment) = @$row;
      $source_file =~ s{/+}{/}g;
      $source_file =~ s{\$(\w+)}{\$env($1)};

      my $all_false_arg = "";
      $all_false_arg = '-allfalse' if ($branch eq "ALL FALSE");

      if (defined($prev_line_num) and $line_number == $prev_line_num and defined($prev_branch) and $prev_branch ne "ALL FALSE" and $branch eq "ALL FALSE") {
        $prev_line_num = $line_number;
        $prev_branch = $branch;
        next;
      }

      print $fh ("coverage exclude -src $source_file -scope $instance_path $all_false_arg -line $line_number -code b\n");


      $prev_line_num = $line_number;
      $prev_branch = $branch;
    }
    print $fh ("\n");
  }
}

package FSM;
use strict;
use warnings;
use Data::Dump;
use Spreadsheet::Read;

sub new {
  my $class = shift;
  my $book = shift || die "book not defined!!!";

  my $exclusions = {}; # comments => [excluded xls rows]

  my ($sheet) = grep (((defined($_ -> {label})) and ($_ -> {label} eq 'FSMs')), @$book);

  my $file = "fsms.do";
  open (my $fh, ">$file") or die ("Error: Couln't open file $file $!");

  print $fh ("#============================================================\n");
  print $fh ("# FSMs Exclusions\n");
  print $fh ("#============================================================\n");

  my $self = {
    exclusions => $exclusions,
    sheet => $sheet,
    fh => $fh,
  };
  $self = bless $self, $class;
  return $self;

}

#-------------------------------------------------------------------------------
# Sub : get_row
#-------------------------------------------------------------------------------
sub get_row {
  my $self = shift;
  my $row = shift;

  my $sheet = $self -> {sheet};

  my @row;
  for (my $col = $sheet -> {mincol}; $col <= $sheet -> {maxcol}; $col++) {
    my $cell = $self -> get_cell_value($row, $col);

    push (@{row}, $cell);
  }

  return \@row;
}

#-------------------------------------------------------------------------------
# Sub : get_cell_value
#-------------------------------------------------------------------------------
sub get_cell_value {
  my $self = shift;
  
  my $row = shift;
  my $col = shift;
  
  my $sheet = $self -> {sheet};

  foreach my $merged (@{$sheet -> {merged}}) {
    my ($col1, $row1, $col2, $row2) = @$merged;

    if ($col >= $col1 && $col <= $col2) {
      if ($row >= $row1 && $row <= $row2) {
        $row = $row1;
        $col = $col1;
      }
    }
  }

  my $cell = Spreadsheet::Read::cr2cell($col, $row);

  return $sheet -> {$cell};
}

#-------------------------------------------------------------------------------
# Sub : parse
#-------------------------------------------------------------------------------
sub parse {
  my $self = shift;
  my $sheet = $self -> {sheet};

  my @exclusions_rows;
  for (my $col = $sheet -> {mincol}; $col <= $sheet -> {maxcol}; $col++) {
    for (my $row = $sheet -> {minrow}; $row <= $sheet -> {maxrow}; $row++) {
      if (defined $sheet -> {cell}[$col][$row]) {
        if ($sheet -> {cell}[$col][$row] =~ m{^Exclusion}) {
          push (@{exclusions_rows}, $row);
        }
      }
    }
  }

  foreach my $row (@{exclusions_rows}) {
    my $row_a = $self -> get_row ($row);

    my ($rational) = grep (/^Exclusion/i, @$row_a);
    $rational =~ s{\n+}{ }g;
    $rational =~ s{^\s*|\s*$}{}g;

    $self -> {exclusions} {$rational} = [] if (!defined($self -> {exclusions} {$rational}));

    push (@{$self -> {exclusions} {$rational}}, $row_a);
  }

  $self -> put_exclusion_cmds ($self -> {exclusions});
}

#-------------------------------------------------------------------------------
# Sub : put_exclusion_cmds
#-------------------------------------------------------------------------------
sub put_exclusion_cmds {
  my $self = shift;
  my $exclusions = $self -> {exclusions};
  my $fh = $self -> {fh};

  foreach my $rational (keys %{$self -> {exclusions}}) {
    print $fh ("# $rational\n");
    foreach my $row (@{$self -> {exclusions}{$rational}}) {
      my ($instance_path, $source_file, $line_number, $state_variable, $missing, $comment) = @$row;

      $source_file =~ s{/+}{/}g;
      $source_file =~ s{\$(\w+)}{\$env($1)};
      $state_variable =~ s{#}{/}g;

      my $state_arg = "";
      if ($missing =~ /^State:/) {
        $state_arg = '-ftrans';
      }
      elsif ($missing =~ /^Trans:/) {
        $state_arg = '-ftrans';
      }
      else {
        die "unknown state type!!!";
      }

      $missing =~ s{^State:\s*|^Trans:\s*}{}g;

      print $fh ("coverage exclude -scope $instance_path $state_arg $state_variable {$missing}\n");
    }
    print $fh ("\n");
  }
}

package Toggle;
use strict;
use warnings;
use Data::Dump;
use Spreadsheet::Read;

sub new {
  my $class = shift;
  my $book = shift || die "book not defined!!!";

  my $exclusions = {}; # comments => [excluded xls rows]

  my ($sheet) = grep (((defined($_ -> {label})) and ($_ -> {label} eq 'Toggles')), @$book);

  my $file = "toggles.do";
  open (my $fh, ">$file") or die ("Error: Couln't open file $file $!");

  print $fh ("#============================================================\n");
  print $fh ("# Toggles Exclusions\n");
  print $fh ("#============================================================\n");

  my $self = {
    exclusions => $exclusions,
    sheet => $sheet,
    fh => $fh,
  };
  $self = bless $self, $class;
  return $self;

}

#-------------------------------------------------------------------------------
# Sub : get_row
#-------------------------------------------------------------------------------
sub get_row {
  my $self = shift;
  my $row = shift;

  my $sheet = $self -> {sheet};

  my @row;
  for (my $col = $sheet -> {mincol}; $col <= $sheet -> {maxcol}; $col++) {
    my $cell = $self -> get_cell_value($row, $col);

    push (@{row}, $cell);
  }

  return \@row;
}

#-------------------------------------------------------------------------------
# Sub : get_cell_value
#-------------------------------------------------------------------------------
sub get_cell_value {
  my $self = shift;
  
  my $row = shift;
  my $col = shift;
  
  my $sheet = $self -> {sheet};

  foreach my $merged (@{$sheet -> {merged}}) {
    my ($col1, $row1, $col2, $row2) = @$merged;

    if ($col >= $col1 && $col <= $col2) {
      if ($row >= $row1 && $row <= $row2) {
        $row = $row1;
        $col = $col1;
      }
    }
  }

  my $cell = Spreadsheet::Read::cr2cell($col, $row);

  return $sheet -> {$cell};
}

#-------------------------------------------------------------------------------
# Sub : parse
#-------------------------------------------------------------------------------
sub parse {
  my $self = shift;
  my $sheet = $self -> {sheet};

  my @exclusions_rows;
  for (my $col = $sheet -> {mincol}; $col <= $sheet -> {maxcol}; $col++) {
    for (my $row = $sheet -> {minrow}; $row <= $sheet -> {maxrow}; $row++) {
      if (defined $sheet -> {cell}[$col][$row]) {
        if ($sheet -> {cell}[$col][$row] =~ m{^Exclusion}) {
          push (@{exclusions_rows}, $row);
        }
      }
    }
  }

  foreach my $row (@{exclusions_rows}) {
    my $row_a = $self -> get_row ($row);

    my ($rational) = grep (/^Exclusion/i, @$row_a);
    $rational =~ s{\n+}{ }g;
    $rational =~ s{^\s*|\s*$}{}g;

    $self -> {exclusions} {$rational} = [] if (!defined($self -> {exclusions} {$rational}));

    push (@{$self -> {exclusions} {$rational}}, $row_a);
  }

  $self -> put_exclusion_cmds ($self -> {exclusions});
}

#-------------------------------------------------------------------------------
# Sub : put_exclusion_cmds
#-------------------------------------------------------------------------------
sub put_exclusion_cmds {
  my $self = shift;
  my $exclusions = $self -> {exclusions};
  my $fh = $self -> {fh};

  foreach my $rational (keys %{$self -> {exclusions}}) {
    print $fh ("# $rational\n");
    foreach my $row (@{$self -> {exclusions}{$rational}}) {
      my ($instance_path, $source_file, $line_number, $signal, $L2H, $H2L, $L2Z, $Z2H, $H2Z, $Z2L, $EXT_MODE, $comment) = @$row;

      $source_file =~ s{/+}{/}g;
      $source_file =~ s{\$(\w+)}{\$env($1)};

      print $fh ("coverage exclude -scope $instance_path -togglenode $signal\n");
    }
    print $fh ("\n");
  }
}

package Statement;
use strict;
use warnings;
use Data::Dump;
use Spreadsheet::Read;

sub new {
  my $class = shift;
  my $book = shift || die "book not defined!!!";

  my $exclusions = {}; # comments => [excluded xls rows]

  my ($sheet) = grep (((defined($_ -> {label})) and ($_ -> {label} eq 'Statements')), @$book);

  my $file = "statements.do";
  open (my $fh, ">$file") or die ("Error: Couln't open file $file $!");

  print $fh ("#============================================================\n");
  print $fh ("# Statements Exclusions\n");
  print $fh ("#============================================================\n");

  my $self = {
    exclusions => $exclusions,
    sheet => $sheet,
    fh => $fh,
  };
  $self = bless $self, $class;
  return $self;

}

#-------------------------------------------------------------------------------
# Sub : get_row
#-------------------------------------------------------------------------------
sub get_row {
  my $self = shift;
  my $row = shift;

  my $sheet = $self -> {sheet};

  my @row;
  for (my $col = $sheet -> {mincol}; $col <= $sheet -> {maxcol}; $col++) {
    my $cell = $self -> get_cell_value($row, $col);

    push (@{row}, $cell);
  }

  return \@row;
}

#-------------------------------------------------------------------------------
# Sub : get_cell_value
#-------------------------------------------------------------------------------
sub get_cell_value {
  my $self = shift;
  
  my $row = shift;
  my $col = shift;
  
  my $sheet = $self -> {sheet};

  foreach my $merged (@{$sheet -> {merged}}) {
    my ($col1, $row1, $col2, $row2) = @$merged;

    if ($col >= $col1 && $col <= $col2) {
      if ($row >= $row1 && $row <= $row2) {
        $row = $row1;
        $col = $col1;
      }
    }
  }

  my $cell = Spreadsheet::Read::cr2cell($col, $row);

  return $sheet -> {$cell};
}

#-------------------------------------------------------------------------------
# Sub : parse
#-------------------------------------------------------------------------------
sub parse {
  my $self = shift;
  my $sheet = $self -> {sheet};

  my @exclusions_rows;
  for (my $col = $sheet -> {mincol}; $col <= $sheet -> {maxcol}; $col++) {
    for (my $row = $sheet -> {minrow}; $row <= $sheet -> {maxrow}; $row++) {
      if (defined $sheet -> {cell}[$col][$row]) {
        if ($sheet -> {cell}[$col][$row] =~ m{^Exclusion}) {
          push (@{exclusions_rows}, $row);
        }
      }
    }
  }

  foreach my $row (@{exclusions_rows}) {
    my $row_a = $self -> get_row ($row);

    my ($rational) = grep (/^Exclusion/i, @$row_a);
    $rational =~ s{\n+}{ }g;
    $rational =~ s{^\s*|\s*$}{}g;

    $self -> {exclusions} {$rational} = [] if (!defined($self -> {exclusions} {$rational}));

    push (@{$self -> {exclusions} {$rational}}, $row_a);
  }

  $self -> put_exclusion_cmds ($self -> {exclusions});
}

#-------------------------------------------------------------------------------
# Sub : put_exclusion_cmds
#-------------------------------------------------------------------------------
sub put_exclusion_cmds {
  my $self = shift;
  my $exclusions = $self -> {exclusions};
  my $fh = $self -> {fh};

  foreach my $rational (keys %{$self -> {exclusions}}) {
    print $fh ("# $rational\n");
    foreach my $row (@{$self -> {exclusions}{$rational}}) {
      my ($instance_path, $source_file, $line_number, $missing, $comment) = @$row;
      $source_file =~ s{/+}{/}g;
      $source_file =~ s{\$(\w+)}{\$env($1)};

      print $fh ("coverage exclude -src $source_file -scope $instance_path -line $line_number -code s\n");
    }
    print $fh ("\n");
  }
}

package Condition;
use strict;
use warnings;
use Data::Dump;
use Spreadsheet::Read;

sub new {
  my $class = shift;
  my $book = shift || die "book not defined!!!";

  my $exclusions = {}; # comments => [excluded xls rows]

  my ($sheet) = grep (((defined($_ -> {label})) and ($_ -> {label} eq 'Conditions')), @$book);

  my $file = "conditions.do";
  open (my $fh, ">$file") or die ("Error: Couln't open file $file $!");

  print $fh ("#============================================================\n");
  print $fh ("# Condition Exclusions\n");
  print $fh ("#============================================================\n");

  my $self = {
    exclusions => $exclusions,
    sheet => $sheet,
    fh => $fh,
  };
  $self = bless $self, $class;
  return $self;

}

#-------------------------------------------------------------------------------
# Sub : parse
#-------------------------------------------------------------------------------
sub parse {
  my $self = shift;
  my $sheet = $self -> {sheet};

  my @exclusions_rows;
  for (my $col = $sheet -> {mincol}; $col <= $sheet -> {maxcol}; $col++) {
    for (my $row = $sheet -> {minrow}; $row <= $sheet -> {maxrow}; $row++) {
      if (defined $sheet -> {cell}[$col][$row]) {
        if ($sheet -> {cell}[$col][$row] =~ m{^Exclusion}) {
          push (@{exclusions_rows}, $row);
        }
      }
    }
  }

  foreach my $row (@{exclusions_rows}) {
    my $row_a = $self -> get_row ($row);

    my ($rational) = grep (/^Exclusion/i, @$row_a);
    $rational =~ s{\n+}{ }g;
    $rational =~ s{^\s*|\s*$}{}g;

    $self -> {exclusions} {$rational} = [] if (!defined($self -> {exclusions} {$rational}));

    push (@{$self -> {exclusions} {$rational}}, $row_a);
  }

  $self -> put_exclusion_cmds ($self -> {exclusions});
}

#-------------------------------------------------------------------------------
# Sub : put_exclusion_cmds
#-------------------------------------------------------------------------------
sub put_exclusion_cmds {
  my $self = shift;
  my $exclusions = $self -> {exclusions};
  my $fh = $self -> {fh};

  foreach my $rational (keys %{$self -> {exclusions}}) {
    print $fh ("# $rational\n");
    foreach my $row (@{$self -> {exclusions}{$rational}}) {
      my ($sr_no, $instance_path, $source_file, $line_number, $fec_condition, $rows, $fec_target, $hits, $matching_input_patterns, $comment) = @$row;
      $source_file =~ s{/+}{/}g;
      $source_file =~ s{\$(\w+)}{\$env($1)};

      my $row_no = $1 if ($rows =~ /^ROW (\d+)$/);

      print $fh ("coverage exclude -src $source_file -scope $instance_path -feccondrow $line_number $row_no\n");
    }
    print $fh ("\n");
  }
}

#-------------------------------------------------------------------------------
# Sub : get_row
#-------------------------------------------------------------------------------
sub get_row {
  my $self = shift;
  my $row = shift;

  my $sheet = $self -> {sheet};

  my @row;
  for (my $col = $sheet -> {mincol}; $col <= $sheet -> {maxcol}; $col++) {
    my $cell = $self -> get_cell_value($row, $col);

    push (@{row}, $cell);
  }

  return \@row;
}

#-------------------------------------------------------------------------------
# Sub : get_cell_value
#-------------------------------------------------------------------------------
sub get_cell_value {
  my $self = shift;
  
  my $row = shift;
  my $col = shift;
  
  my $sheet = $self -> {sheet};

  foreach my $merged (@{$sheet -> {merged}}) {
    my ($col1, $row1, $col2, $row2) = @$merged;

    if ($col >= $col1 && $col <= $col2) {
      if ($row >= $row1 && $row <= $row2) {
        $row = $row1;
        $col = $col1;
      }
    }
  }

  my $cell = Spreadsheet::Read::cr2cell($col, $row);

  return $sheet -> {$cell};
}

package Expression;
use strict;
use warnings;
use Data::Dump;
use Spreadsheet::Read;

sub new {
  my $class = shift;
  my $book = shift || die "book not defined!!!";

  my $exclusions = {}; # comments => [excluded xls rows]

  my ($sheet) = grep (((defined($_ -> {label})) and ($_ -> {label} eq 'Expressions')), @$book);

  my $file = "expressions.do";
  open (my $fh, ">$file") or die ("Error: Couln't open file $file $!");

  print $fh ("#============================================================\n");
  print $fh ("# Expression Exclusions\n");
  print $fh ("#============================================================\n");

  my $self = {
    exclusions => $exclusions,
    sheet => $sheet,
    fh => $fh,
  };
  $self = bless $self, $class;
  return $self;

}

#-------------------------------------------------------------------------------
# Sub : parse
#-------------------------------------------------------------------------------
sub parse {
  my $self = shift;
  my $sheet = $self -> {sheet};

  my @exclusions_rows;
  for (my $col = $sheet -> {mincol}; $col <= $sheet -> {maxcol}; $col++) {
    for (my $row = $sheet -> {minrow}; $row <= $sheet -> {maxrow}; $row++) {
      if (defined $sheet -> {cell}[$col][$row]) {
        if ($sheet -> {cell}[$col][$row] =~ m{^Exclusion}) {
          push (@{exclusions_rows}, $row);
        }
      }
    }
  }

  foreach my $row (@{exclusions_rows}) {
    my $row_a = $self -> get_row ($row);

    my ($rational) = grep (/^Exclusion/i, @$row_a);

    $self -> {exclusions} {$rational} = [] if (!defined($self -> {exclusions} {$rational}));

    push (@{$self -> {exclusions} {$rational}}, $row_a);
  }

  $self -> put_exclusion_cmds ($self -> {exclusions});
}

#-------------------------------------------------------------------------------
# Sub : put_exclusion_cmds
#-------------------------------------------------------------------------------
sub put_exclusion_cmds {
  my $self = shift;
  my $exclusions = $self -> {exclusions};
  my $fh = $self -> {fh};

  foreach my $rational (keys %{$self -> {exclusions}}) {
    print $fh ("# $rational\n");
    foreach my $row (@{$self -> {exclusions}{$rational}}) {
      my ($sr_no, $instance_path, $source_file, $line_number, $fec_condition, $rows, $fec_target, $hits, $matching_input_patterns, $comment) = @$row;
      $source_file =~ s{/+}{/}g;
      $source_file =~ s{\$(\w+)}{\$env($1)};

      my $row_no = $1 if ($rows =~ /^ROW (\d+)$/);

      print $fh ("coverage exclude -src $source_file -scope $instance_path -fecexprrow $line_number $row_no\n");
    }
    print $fh ("\n");
  }
}

#-------------------------------------------------------------------------------
# Sub : get_row
#-------------------------------------------------------------------------------
sub get_row {
  my $self = shift;
  my $row = shift;

  my $sheet = $self -> {sheet};

  my @row;
  for (my $col = $sheet -> {mincol}; $col <= $sheet -> {maxcol}; $col++) {
    my $cell = $self -> get_cell_value($row, $col);

    push (@{row}, $cell);
  }

  return \@row;
}

#-------------------------------------------------------------------------------
# Sub : get_cell_value
#-------------------------------------------------------------------------------
sub get_cell_value {
  my $self = shift;
  
  my $row = shift;
  my $col = shift;
  
  my $sheet = $self -> {sheet};

  foreach my $merged (@{$sheet -> {merged}}) {
    my ($col1, $row1, $col2, $row2) = @$merged;

    if ($col >= $col1 && $col <= $col2) {
      if ($row >= $row1 && $row <= $row2) {
        $row = $row1;
        $col = $col1;
      }
    }
  }

  my $cell = Spreadsheet::Read::cr2cell($col, $row);

  return $sheet -> {$cell};
}

#-------------------------------------------------------------------------------
# Main
package main;
use Spreadsheet::Read;
use Data::Dump;

#-------------------------------------------------------------------------------
my $opts = Getopts -> new();
my $args = Getargs -> new();
my $book  = ReadData ($args -> {xlsx}, attr => 1);

Expression -> new($book) -> parse();
Condition -> new($book) -> parse();
Statement -> new($book) -> parse();
Branch -> new($book) -> parse();
Toggle -> new($book) -> parse();
FSM -> new($book) -> parse();





