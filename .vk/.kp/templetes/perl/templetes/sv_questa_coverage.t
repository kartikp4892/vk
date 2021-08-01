#!/usr/bin/perl -w
use strict;
use warnings;

package CovWriteExcel;
use strict;
use warnings;
use  Excel::Writer::XLSX;
our $CovWriteExcel;

sub new {
  my $class = shift;

  return $CovWriteExcel if (defined($CovWriteExcel));
  my $file = shift;

  my $workbook =  Excel::Writer::XLSX->new( "$file.xlsx" );
  my $heading_format = $workbook->add_format( bold => 1, bg_color => 'gray', text_wrap => 1, border => 1, align => 'center', valign => 'top' );
  my $sub_heading_format = $workbook->add_format( bold => 1, bg_color => 'silver', text_wrap => 1, border => 6, align => 'center', valign => 'top' );
  my $red_row_format = $workbook->add_format( color => 'red', text_wrap => 1, border => 1, align => 'center', valign => 'top' );
  my $row_format = $workbook->add_format( text_wrap => 1, border => 1, align => 'center', valign => 'top' );
  my $merged_row_format = $workbook->add_format( center_across => 1, text_wrap => 1, border => 1, align => 'center', valign => 'top' );

  my $self = {
    workbook => $workbook,
    heading_format => $heading_format,
    sub_heading_format => $sub_heading_format,
    red_row_format => $red_row_format,
    row_format => $row_format,
    merged_row_format => $merged_row_format,
    sheets => {},
  };
  $self = bless $self, $class;

  $CovWriteExcel = $self;

  return $self;
}

#-------------------------------------------------------------------------------
# Sub : sheet
#-------------------------------------------------------------------------------
sub sheet {
  my $self = shift;;
  my $sheetname = shift;

  if (defined($self -> {sheets}{$sheetname})) {
    return $self -> {sheets}{$sheetname};
  }

  my $workbook = $self -> {workbook};
  my $worksheet = $workbook->add_worksheet( $sheetname );
  $self -> {sheets}{$sheetname} = $worksheet;
  return $worksheet;
}

END {
  $CovWriteExcel -> {workbook} -> close() if (defined($CovWriteExcel));
}

package FSMs;
use strict;
use warnings;
use Web::Scraper;
use Data::Dump;

our $FSMs;
our $row_no = 0;
our $col_no = 0;
our $sheet_name = 'FSMs';

sub new {
  my $class = shift;

  return $FSMs if (defined($FSMs));
  my $out_filename = shift;

  my $covwriteexcel = CovWriteExcel -> new();
  my $worksheet = $covwriteexcel -> sheet($sheet_name);
  $worksheet -> set_column (0, 1, 60);
  $worksheet -> set_column (2, 2, 15);
  $worksheet -> set_column (3, 3, 40);
  $worksheet -> set_column (4, 4, 60);
  $worksheet -> set_column (5, 5, 80);

  my $heading = [
    'INSTANCE_PATH',
    'SOURCE_FILE',
    'LINE_NUMBER',
    'STATE_VARIABLE',
    'MISSING',
    'COMMENTS',
  ];

  my $heading_format = $covwriteexcel -> {heading_format};
  $worksheet -> write_row ($row_no++, $col_no, $heading, $heading_format);

  my $self = {
    heading => $heading,
  };
  $self = bless $self, $class;

  $FSMs = $self;
  return $self;

}

#-------------------------------------------------------------------------------
# Sub : write_row_h
#-------------------------------------------------------------------------------
sub write_row_h {
  my $self = shift;
  my $row_h = shift;

  my $covwriteexcel = CovWriteExcel -> new();
  my $worksheet = $covwriteexcel -> sheet($sheet_name);

  if (ref($row_h) eq ref([])) {

    if (@$row_h == 1) {
      foreach my $single_row_h (@{$row_h}) {
        my $row = [@{$single_row_h}{@{$self -> {heading}}}];

        $worksheet -> write_row ($row_no++, $col_no, $row, $covwriteexcel -> {row_format});
      }
    }
    else {
      for (my $idx = 0; $idx < 4; $idx++) {
        my $row = [@{$row_h -> [0]}{@{$self -> {heading}}}];
        $worksheet -> merge_range ($row_no, $idx, ($row_no + @$row_h - 1), $idx, $row -> [$idx], $covwriteexcel -> {row_format});
      }

      foreach my $single_row_h (@{$row_h}) {
        my $row = [@{$single_row_h}{@{$self -> {heading}}}];
        $worksheet -> write_row ($row_no++, 4, [@{$row}[4..(@{$self -> {heading}} - 1)]], $covwriteexcel -> {row_format});
      }
    }
  }
  elsif (ref($row_h) eq ref({})) {
    my $row = [@{$row_h}{@{$self -> {heading}}}];

    $worksheet -> write_row ($row_no++, $col_no, $row, $covwriteexcel -> {row_format});
  }

}

#-------------------------------------------------------------------------------
# Sub : missing_fsms
#-------------------------------------------------------------------------------
sub missing_fsms {
  my $self = shift;
  my $statement_ref_h = shift;

  my $mech = WWW::Mechanize -> new ();

  $mech -> get($statement_ref_h -> {file});

  my $p_missing = "//tr[\@cr='m']";
  #my $p_missing = "//tr[\@class='missing' and td[contains(text(), 'Trans:') or contains(text(), 'State:')]]";
  my $s_missing = sub {
    my $he = shift;
    my @left_e = $he -> left();

    my $first_row_e = $left_e[0];

    my $state_variable = $first_row_e -> attr('z');
    my $lnk = $first_row_e -> attr('lnk');

    my ($htm_src_file, $src_ln) = split (/#/, $lnk);
    my $no_hit = $he -> attr('h');

    my $z = $he -> attr('z');
    my $is_state = $he -> attr('s');

    my $states_transitions;

    if (defined($is_state) && ($is_state == 1)) {
      $states_transitions = "State: $z";
    }
    else {
      $states_transitions = "Trans: $z";
    }

    return {
      LINE_NUMBER => $src_ln,
      STATE_VARIABLE => $state_variable,
      MISSING => $states_transitions,
      NO_HIT => $no_hit,
      HTM_SRC_FILE => $htm_src_file,
    };
  };

  my $p_src_file = "//table[\@class='src' and contains(\@id,'__HDL_srcfile_2.htm')]";
  my $s_src_file = sub {
    my $he = shift;
    my $id = $he -> attr('id');

    my $config = Config -> new();

    my $file = "file://$config->{cov_html_report_path}/pages/$id";
    return $file;
  };

  my $scraper = scraper {
    process "$p_src_file", "htm_src_file" => $s_src_file;
    process "$p_missing", "missing[]" => $s_missing;
  };

  my $scrape = $scraper -> scrape ($mech -> content());

  my $prev_row_h;
  my $missing_db_a = [];

  if (defined($scrape -> {missing})) {
    foreach my $miss_info_h (@{$scrape -> {missing}}) {
      my $ln = $miss_info_h -> {LINE_NUMBER};

      my $src_tie_array = CovReport -> current_src_tie_array;
      my $src_file = CovReport -> current_src_file;
      my $instance_path = CovReport -> current_instance_path;

      $miss_info_h -> {SOURCE_FILE} = $src_file;
      $miss_info_h -> {INSTANCE_PATH} = $instance_path;

      if (defined($prev_row_h)) {
        if (($miss_info_h -> {INSTANCE_PATH} eq $prev_row_h -> {INSTANCE_PATH}) and
           ($miss_info_h -> {SOURCE_FILE} eq $prev_row_h -> {SOURCE_FILE}) and
           ($miss_info_h -> {LINE_NUMBER} eq $prev_row_h -> {LINE_NUMBER}) and
           ($miss_info_h -> {STATE_VARIABLE} eq $prev_row_h -> {STATE_VARIABLE})) {
          push (@{$missing_db_a -> [-1]}, $miss_info_h);
        }
        else {
          push (@{$missing_db_a}, [$miss_info_h]);
        }
      }
      else {
        push (@{$missing_db_a}, [$miss_info_h]);
      }

      $prev_row_h = $miss_info_h;
    }

    foreach my $row_ha (@{$missing_db_a}) {
      $self -> write_row_h($row_ha);
    }
  }

}

#-------------------------------------------------------------------------------
# Sub : get_missing_cov
#-------------------------------------------------------------------------------
sub get_missing_cov {
  my $self = shift;
  my $page = shift || die "Page not defined!!!";

  my $p_path = "//a[text()='$sheet_name']";
  my $s_path = sub {
    my $he = shift;
    my $config = Config -> new();

    my $href = $he -> attr('href');
    my ($file, $ln) = split (/#/, $href);
    return {
      file => "file://$config->{cov_html_report_path}/pages/$file",
      ln => $ln,
    };
  };

  my $scraper = scraper {
    process "$p_path", "statement_ref_h" => $s_path;
  };

  my $scrape = $scraper -> scrape ($page);

  if (defined($scrape -> {statement_ref_h})) {
    $self -> missing_fsms ($scrape -> {statement_ref_h});
  }

}


package Statements;
use strict;
use warnings;
use Web::Scraper;
use Data::Dump;

our $Statements;
our $row_no = 0;
our $col_no = 0;
our $sheet_name = 'Statements';

sub new {
  my $class = shift;

  return $Statements if (defined($Statements));
  my $out_filename = shift;

  my $covwriteexcel = CovWriteExcel -> new();
  my $worksheet = $covwriteexcel -> sheet($sheet_name);
  $worksheet -> set_column (0, 1, 60);
  $worksheet -> set_column (2, 2, 15);
  $worksheet -> set_column (3, 3, 80);
  $worksheet -> set_column (4, 4, 60);

  my $heading = [
    'INSTANCE_PATH',
    'SOURCE_FILE',
    'LINE_NUMBER',
    'MISSING',
    'COMMENTS',
  ];

  my $heading_format = $covwriteexcel -> {heading_format};
  $worksheet -> write_row ($row_no++, $col_no, $heading, $heading_format);

  my $self = {
    heading => $heading,
  };
  $self = bless $self, $class;

  $Statements = $self;
  return $self;

}

#-------------------------------------------------------------------------------
# Sub : write_row_h
#-------------------------------------------------------------------------------
sub write_row_h {
  my $self = shift;
  my $row_h = shift;

  my $row = [@{$row_h}{@{$self -> {heading}}}];

  my $covwriteexcel = CovWriteExcel -> new();
  my $worksheet = $covwriteexcel -> sheet($sheet_name);

  $worksheet -> write_row ($row_no++, $col_no, $row, $covwriteexcel -> {row_format});
}

#-------------------------------------------------------------------------------
# Sub : missing_statements
#-------------------------------------------------------------------------------
sub missing_statements {
  my $self = shift;
  my $statement_ref_h = shift;

  my $mech = WWW::Mechanize -> new ();

  $mech -> get($statement_ref_h -> {file});

  my $p_missing = "//tr[contains(\@z,'\$0\$')]";
  my $s_missing = sub {
    my $he = shift;
    my $z = $he -> attr('z');
    my ($src_ln, $src_stmt, $no_hit) = split (/\$/, $z);
    return {
      LINE_NUMBER => $src_ln,
      SRC_STMT => $src_stmt,
      NO_HIT => $no_hit,
    };
  };

  my $p_src_file = "//table[\@class='src' and contains(\@id,'__HDL_srcfile_2.htm')]";
  my $s_src_file = sub {
    my $he = shift;
    my $id = $he -> attr('id');

    my $config = Config -> new();

    my $file = "file://$config->{cov_html_report_path}/pages/$id";
    return $file;
  };

  my $scraper = scraper {
    process "$p_src_file", "htm_src_file" => $s_src_file;
    process "$p_missing", "missing[]" => $s_missing;
  };

  my $scrape = $scraper -> scrape ($mech -> content());

  if (defined($scrape -> {missing})) {
    foreach my $miss_info_h (@{$scrape -> {missing}}) {
      my $ln = $miss_info_h -> {LINE_NUMBER};

      my $src_tie_array = CovReport -> current_src_tie_array;
      my $src_file = CovReport -> current_src_file;
      my $instance_path = CovReport -> current_instance_path;

      my $line = $src_tie_array -> [$ln - 1];
      $line =~ s{^\s*|\s*$}{}g;

      $miss_info_h -> {MISSING} = $line;
      $miss_info_h -> {SOURCE_FILE} = $src_file;
      $miss_info_h -> {INSTANCE_PATH} = $instance_path;

      $self -> write_row_h($miss_info_h);
    }
  }

}

#-------------------------------------------------------------------------------
# Sub : get_missing_cov
#-------------------------------------------------------------------------------
sub get_missing_cov {
  my $self = shift;
  my $page = shift || die "Page not defined!!!";

  my $p_path = "//a[text()='$sheet_name']";
  my $s_path = sub {
    my $he = shift;
    my $config = Config -> new();

    my $href = $he -> attr('href');
    my ($file, $ln) = split (/#/, $href);
    return {
      file => "file://$config->{cov_html_report_path}/pages/$file",
      ln => $ln,
    };
  };

  my $scraper = scraper {
    process "$p_path", "statement_ref_h" => $s_path;
  };

  my $scrape = $scraper -> scrape ($page);

  if (defined($scrape -> {statement_ref_h})) {
    $self -> missing_statements ($scrape -> {statement_ref_h});
  }

}

package Branches;
use strict;
use warnings;
use Web::Scraper;
use WWW::Mechanize;
use Data::Dump;


our $Branches;
our $row_no = 0;
our $col_no = 0;
our $sheet_name = 'Branches';

sub new {
  my $class = shift;

  return $Branches if (defined($Branches));
  my $out_filename = shift;

  my $covwriteexcel = CovWriteExcel -> new();
  my $worksheet = $covwriteexcel -> sheet($sheet_name);
  $worksheet -> set_column (0, 1, 60);
  $worksheet -> set_column (2, 2, 15);
  $worksheet -> set_column (3, 3, 80);
  $worksheet -> set_column (4, 4, 20);
  $worksheet -> set_column (5, 5, 60);

  my $heading = [
    'INSTANCE_PATH',
    'SOURCE_FILE',
    'LINE_NUMBER',
    'SOURCE',
    'BRANCH',
    'COMMENTS',
  ];

  my $heading_format = $covwriteexcel -> {heading_format};
  $worksheet -> write_row ($row_no++, $col_no, $heading, $heading_format);

  my $self = {
    heading => $heading,
  };
  $self = bless $self, $class;

  $Branches = $self;
  return $self;

}

#-------------------------------------------------------------------------------
# Sub : write_row_h
#-------------------------------------------------------------------------------
sub write_row_h {
  my $self = shift;
  my $row_h = shift;

  my $row = [@{$row_h}{@{$self -> {heading}}}];

  my $covwriteexcel = CovWriteExcel -> new();
  my $worksheet = $covwriteexcel -> sheet($sheet_name);

  $worksheet -> write_row ($row_no++, $col_no, $row, $covwriteexcel -> {row_format});
}

#-------------------------------------------------------------------------------
# Sub : missing_branches
#-------------------------------------------------------------------------------
sub missing_branches {
  my $self = shift;
  my $file = shift;

  my $mech = WWW::Mechanize -> new ();

  $mech -> get($file);

  my $p_branches_h = "//tr[\@c='r' and \@cr='m']";
  my $s_branches_h = sub {
    my $he = shift;
    my $ln = $he -> attr('l');
    my $branch = $he -> attr('t');
    my $source = $he -> attr('z'); #

    if ($branch eq 'I') {
      $branch = "IF";
    }
    elsif ($branch eq 'T') {
      $branch = "TRUE";
    }
    elsif ($branch eq 'E') {
      $branch = "ELSE";
    }
    elsif ($branch eq 'A') {
      $branch = "ALL FALSE";
    }

    my $miss_info_h = {};

    my $src_tie_array = CovReport -> current_src_tie_array;
    my $src_file = CovReport -> current_src_file;
    my $instance_path = CovReport -> current_instance_path;

    my $line = $src_tie_array -> [$ln - 1];
    $line =~ s{^\s*|\s*$}{}g;

    $miss_info_h -> {LINE_NUMBER} = $ln;
    $miss_info_h -> {SOURCE} = $line;
    $miss_info_h -> {BRANCH} = $branch;
    $miss_info_h -> {SOURCE_FILE} = $src_file;
    $miss_info_h -> {INSTANCE_PATH} = $instance_path;

    return $miss_info_h;

  };

  my $scraper = scraper {
    process "$p_branches_h", "branches_h[]" => $s_branches_h;
  };

  my $scrape = $scraper -> scrape ($mech -> content());

  if (defined ($scrape -> {branches_h})) {
    foreach my $branche_h (@{$scrape -> {branches_h}}) {
      $self -> write_row_h($branche_h);
    }
  }
}

#-------------------------------------------------------------------------------
# Sub : get_missing_cov
#-------------------------------------------------------------------------------
sub get_missing_cov {
  my $self = shift;
  my $page = shift || die "Page not defined!!!";

  my $p_path = "//a[text()='$sheet_name']";
  my $s_path = sub {
    my $he = shift;
    my $config = Config -> new();

    my $href = $he -> attr('href');
    return "file://$config->{cov_html_report_path}/pages/$href";
  };

  my $scraper = scraper {
    process "$p_path", "branches_file" => $s_path;
  };

  my $scrape = $scraper -> scrape ($page);

  if (defined($scrape -> {branches_file})) {
    $self -> missing_branches ($scrape -> {branches_file});
  }

}

package Expressions;
use strict;
use warnings;
use WWW::Mechanize;
use Web::Scraper;
use Data::Dump;

our $Expressions;
our $row_no = 0;
our $col_no = 0;
our $sheet_name = 'Expressions';
our $sr_no = 1;

sub new {
  my $class = shift;

  return $Expressions if (defined($Expressions));
  my $out_filename = shift;

  my $covwriteexcel = CovWriteExcel -> new();
  my $worksheet = $covwriteexcel -> sheet($sheet_name);
  $worksheet -> set_column (1, 2, 60);
  $worksheet -> set_column (3, 3, 15);
  $worksheet -> set_column (4, 4, 80);
  $worksheet -> set_column (5, 5, 40);
  $worksheet -> set_column (6, 6, 40);
  $worksheet -> set_column (7, 7, 40);
  $worksheet -> set_column (8, 8, 40);
  $worksheet -> set_column (9, 9, 60);

  my $heading = [
    'SR_NO',
    'INSTANCE_PATH',
    'SOURCE_FILE',
    'LINE_NUMBER',
    'FEC_CONDITION',
    'FEC_MISSING',
    'COMMENTS'
  ];

  my $fec_input_term_sub_heading = [
    'INPUT_TERM',
    'COVERED',
    'REASON_FOR_NO_COVERAGE',
    'HINT',
  ];

  my $fec_rows_sub_heading = [
    'ROWS',
    'FEC_TARGET',
    'HITS',
    'MATCHING_INPUT_PATTERNS',
  ];

  my $heading_format = $covwriteexcel -> {heading_format};
  for (my $col_idx = 0; $col_idx < @$heading; $col_idx++) {
    if ($heading -> [$col_idx] ne "FEC_MISSING") {
      $worksheet -> write_row ($row_no, $col_no++, [$heading -> [$col_idx]], $heading_format);
    }
    else {
      $worksheet -> merge_range ($row_no, $col_no, $row_no, $col_idx + 3, $heading -> [$col_idx], $heading_format);
      $col_no += 4;
    }
  }
  $col_no = 0;
  $row_no++;

  my $self = {
    heading => $heading,
    fec_input_term_sub_heading => $fec_input_term_sub_heading,
    fec_rows_sub_heading => $fec_rows_sub_heading,
  };
  $self = bless $self, $class;

  $Expressions = $self;
  return $self;

}

#-------------------------------------------------------------------------------
# Sub : write_row_h
#-------------------------------------------------------------------------------
sub write_row_h {
  my $self = shift;
  my $row_h = shift;

  $row_h -> {SR_NO} = $sr_no++;
  my $row = [@{$row_h}{@{$self -> {heading}}}];

  my ($input_terms_a, $fec_rows_a) = @{$row_h -> {MISSING}};
  my $covwriteexcel = CovWriteExcel -> new();
  my $worksheet = $covwriteexcel -> sheet($sheet_name);

  my $sub_rows_len = @$input_terms_a + @$fec_rows_a + 1;

  for (my $col_idx = 0; $col_idx < @{$row}; $col_idx++) {
    if ($col_idx != @{$row} - 2) {
      $worksheet -> merge_range ($row_no, $col_no, $row_no + $sub_rows_len, $col_no, $row -> [$col_idx], $covwriteexcel -> {row_format});
      $col_no++;
    }
    else {
      $col_no += 4;
    }
  }

  $worksheet -> write_row ($row_no++, scalar(@{$self -> {heading}}) - 2, $self -> {fec_input_term_sub_heading}, $covwriteexcel -> {sub_heading_format});
  foreach my $input_term_h (@{$input_terms_a}) {
    my $format = $covwriteexcel -> {row_format};
    if ($input_term_h -> {COVERED} eq "NO") {
      $format = $covwriteexcel -> {red_row_format};
    }
    $worksheet -> write_row ($row_no++, scalar (@{$self -> {heading}}) - 2, [@{$input_term_h}{@{$self -> {fec_input_term_sub_heading}}}], $format);
  }

  $worksheet -> write_row ($row_no++, scalar (@{$self -> {heading}}) - 2, $self -> {fec_rows_sub_heading}, $covwriteexcel -> {sub_heading_format});
  foreach my $fec_row_h (@{$fec_rows_a}) {
    my $format = $covwriteexcel -> {row_format};
    $worksheet -> write_row ($row_no++, scalar (@{$self -> {heading}}) - 2, [@{$fec_row_h}{@{$self -> {fec_rows_sub_heading}}}], $format);
  }

  $col_no = 0;
}

#-------------------------------------------------------------------------------
# Sub : missing_expression
#-------------------------------------------------------------------------------
sub missing_expression {
  my $self = shift;
  my $file = shift;

  my $mech = WWW::Mechanize -> new ();

  $mech -> get($file);

  my $p_expressions_h = "//div[not (\@class='covered') and a[contains(\@name,'cvg')]]//table";
  my $s_expressions_h = sub {
    my $he = shift;
    my $fc_tr = $he -> look_down('x' => 'FE');
    my $lnk = $fc_tr -> attr('lnk');
    my (undef, $ln) = split (/#/, $lnk);

    my @input_terms_he = $he -> look_down(sub {
      my $he = shift;
      return (defined($he -> attr('r')) and defined($he -> attr('i')));
    });

    my @input_terms_a;
    foreach my $input_term_he (@{input_terms_he}) {
      my %input_term_h;
      $input_term_h {INPUT_TERM} = $input_term_he -> attr('z');
      my $color = $input_term_he -> attr('c');
      if ($color eq 'g') {
        $input_term_h {COVERED} = 'YES';
      }
      elsif ($color eq 'r') {
        $input_term_h {COVERED} = 'NO';
      }
      $input_term_h {REASON_FOR_NO_COVERAGE} = $input_term_he -> attr('r');
      $input_term_h {HINT} = $input_term_he -> attr('i');
      push (@{input_terms_a}, \%input_term_h);

    }

    my @fec_rows_he = $he -> look_down(sub {
      my $he = shift;
      return (defined($he -> attr('n')) and defined($he -> attr('h1')) and ($he -> attr('h1') eq 0) and defined($he -> attr('c1')));
    });

    my @fec_rows;
    foreach my $fec_row_he (@{fec_rows_he}) {
      my %fec_row_h;
      $fec_row_h {ROWS} = 'ROW ' . $fec_row_he -> attr('n');
      $fec_row_h {FEC_TARGET} = $fec_row_he -> attr('z');
      $fec_row_h {HITS} = $fec_row_he -> attr('h1');
      $fec_row_h {MATCHING_INPUT_PATTERNS} = $fec_row_he -> attr('c1');
      push (@{fec_rows}, \%fec_row_h);

    }

    my @all_fec_rows = (\@input_terms_a, \@fec_rows);

    my $miss_info_h = {};

    my $src_tie_array = CovReport -> current_src_tie_array;
    my $src_file = CovReport -> current_src_file;
    my $instance_path = CovReport -> current_instance_path;

    my $line = $src_tie_array -> [$ln - 1];
    $line =~ s{^\s*|\s*$}{}g;

    $miss_info_h -> {LINE_NUMBER} = $ln;
    $miss_info_h -> {FEC_CONDITION} = $line;
    $miss_info_h -> {SOURCE_FILE} = $src_file;
    $miss_info_h -> {INSTANCE_PATH} = $instance_path;
    $miss_info_h -> {MISSING} = \@all_fec_rows;

    return $miss_info_h;
  };

  my $scraper = scraper {
    process "$p_expressions_h", "expressions_h[]" => $s_expressions_h;
  };

  my $scrape = $scraper -> scrape ($mech -> content());

  if (defined($scrape -> {expressions_h})) {
    foreach my $expression_h (@{$scrape -> {expressions_h}}) {
      $self -> write_row_h ($expression_h);
    }
  }
}

#-------------------------------------------------------------------------------
# Sub : get_missing_cov
#-------------------------------------------------------------------------------
sub get_missing_cov {
  my $self = shift;
  my $page = shift || die "Page not defined!!!";

  my $p_path = "//a[text()='$sheet_name']";
  my $s_path = sub {
    my $he = shift;
    my $config = Config -> new();

    my $href = $he -> attr('href');
    return "file://$config->{cov_html_report_path}/pages/$href";
  };

  my $scraper = scraper {
    process "$p_path", "expressions_file" => $s_path;
  };

  my $scrape = $scraper -> scrape ($page);

  if (defined($scrape -> {expressions_file})) {
    $self -> missing_expression ($scrape -> {expressions_file});
  }

}

package Conditions;
use strict;
use warnings;
use WWW::Mechanize;
use Web::Scraper;
use Data::Dump;

our $Conditions;
our $row_no = 0;
our $col_no = 0;
our $sheet_name = 'Conditions';
our $sr_no = 1;

sub new {
  my $class = shift;

  return $Conditions if (defined($Conditions));
  my $out_filename = shift;

  my $covwriteexcel = CovWriteExcel -> new();
  my $worksheet = $covwriteexcel -> sheet($sheet_name);
  $worksheet -> set_column (1, 2, 60);
  $worksheet -> set_column (3, 3, 15);
  $worksheet -> set_column (4, 4, 80);
  $worksheet -> set_column (5, 5, 40);
  $worksheet -> set_column (6, 6, 40);
  $worksheet -> set_column (7, 7, 40);
  $worksheet -> set_column (8, 8, 40);
  $worksheet -> set_column (9, 9, 60);

  my $heading = [
    'SR_NO',
    'INSTANCE_PATH',
    'SOURCE_FILE',
    'LINE_NUMBER',
    'FEC_CONDITION',
    'FEC_MISSING',
    'COMMENTS'
  ];

  my $fec_input_term_sub_heading = [
    'INPUT_TERM',
    'COVERED',
    'REASON_FOR_NO_COVERAGE',
    'HINT',
  ];

  my $fec_rows_sub_heading = [
    'ROWS',
    'FEC_TARGET',
    'HITS',
    'MATCHING_INPUT_PATTERNS',
  ];

  my $heading_format = $covwriteexcel -> {heading_format};
  for (my $col_idx = 0; $col_idx < @$heading; $col_idx++) {
    if ($heading -> [$col_idx] ne "FEC_MISSING") {
      $worksheet -> write_row ($row_no, $col_no++, [$heading -> [$col_idx]], $heading_format);
    }
    else {
      $worksheet -> merge_range ($row_no, $col_no, $row_no, $col_idx + 3, $heading -> [$col_idx], $heading_format);
      $col_no += 4;
    }
  }
  $col_no = 0;
  $row_no++;

  my $self = {
    heading => $heading,
    fec_input_term_sub_heading => $fec_input_term_sub_heading,
    fec_rows_sub_heading => $fec_rows_sub_heading,
  };
  $self = bless $self, $class;

  $Conditions = $self;
  return $self;

}

#-------------------------------------------------------------------------------
# Sub : write_row_h
#-------------------------------------------------------------------------------
sub write_row_h {
  my $self = shift;
  my $row_h = shift;

  $row_h -> {SR_NO} = $sr_no++;
  my $row = [@{$row_h}{@{$self -> {heading}}}];

  my ($input_terms_a, $fec_rows_a) = @{$row_h -> {MISSING}};
  my $covwriteexcel = CovWriteExcel -> new();
  my $worksheet = $covwriteexcel -> sheet($sheet_name);

  my $sub_rows_len = @$input_terms_a + @$fec_rows_a + 1;

  for (my $col_idx = 0; $col_idx < @{$row}; $col_idx++) {
    if ($col_idx != @{$row} - 2) {
      $worksheet -> merge_range ($row_no, $col_no, $row_no + $sub_rows_len, $col_no, $row -> [$col_idx], $covwriteexcel -> {row_format});
      $col_no++;
    }
    else {
      $col_no += 4;
    }
  }

  $worksheet -> write_row ($row_no++, scalar(@{$self -> {heading}}) - 2, $self -> {fec_input_term_sub_heading}, $covwriteexcel -> {sub_heading_format});
  foreach my $input_term_h (@{$input_terms_a}) {
    my $format = $covwriteexcel -> {row_format};
    if ($input_term_h -> {COVERED} eq "NO") {
      $format = $covwriteexcel -> {red_row_format};
    }
    $worksheet -> write_row ($row_no++, scalar (@{$self -> {heading}}) - 2, [@{$input_term_h}{@{$self -> {fec_input_term_sub_heading}}}], $format);
  }

  $worksheet -> write_row ($row_no++, scalar (@{$self -> {heading}}) - 2, $self -> {fec_rows_sub_heading}, $covwriteexcel -> {sub_heading_format});
  foreach my $fec_row_h (@{$fec_rows_a}) {
    my $format = $covwriteexcel -> {row_format};
    $worksheet -> write_row ($row_no++, scalar (@{$self -> {heading}}) - 2, [@{$fec_row_h}{@{$self -> {fec_rows_sub_heading}}}], $format);
  }

  $col_no = 0;
}

#-------------------------------------------------------------------------------
# Sub : missing_condition
#-------------------------------------------------------------------------------
sub missing_condition {
  my $self = shift;
  my $file = shift;

  my $mech = WWW::Mechanize -> new ();

  $mech -> get($file);

  my $p_conditions_h = "//div[not (\@class='covered') and a[contains(\@name,'cvg')]]//table";
  my $s_conditions_h = sub {
    my $he = shift;
    my $fc_tr = $he -> look_down('x' => 'FC');
    my $lnk = $fc_tr -> attr('lnk');
    my (undef, $ln) = split (/#/, $lnk);

    my @input_terms_he = $he -> look_down(sub {
      my $he = shift;
      return (defined($he -> attr('r')) and defined($he -> attr('i')));
    });

    my @input_terms_a;
    foreach my $input_term_he (@{input_terms_he}) {
      my %input_term_h;
      $input_term_h {INPUT_TERM} = $input_term_he -> attr('z');
      my $color = $input_term_he -> attr('c');
      if ($color eq 'g') {
        $input_term_h {COVERED} = 'YES';
      }
      elsif ($color eq 'r') {
        $input_term_h {COVERED} = 'NO';
      }
      $input_term_h {REASON_FOR_NO_COVERAGE} = $input_term_he -> attr('r');
      $input_term_h {HINT} = $input_term_he -> attr('i');
      push (@{input_terms_a}, \%input_term_h);

    }

    my @fec_rows_he = $he -> look_down(sub {
      my $he = shift;
      return (defined($he -> attr('n')) and defined($he -> attr('h1')) and ($he -> attr('h1') eq 0) and defined($he -> attr('c1')));
    });

    my @fec_rows;
    foreach my $fec_row_he (@{fec_rows_he}) {
      my %fec_row_h;
      $fec_row_h {ROWS} = 'ROW ' . $fec_row_he -> attr('n');
      $fec_row_h {FEC_TARGET} = $fec_row_he -> attr('z');
      $fec_row_h {HITS} = $fec_row_he -> attr('h1');
      $fec_row_h {MATCHING_INPUT_PATTERNS} = $fec_row_he -> attr('c1');
      push (@{fec_rows}, \%fec_row_h);

    }

    my @all_fec_rows = (\@input_terms_a, \@fec_rows);

    my $miss_info_h = {};

    my $src_tie_array = CovReport -> current_src_tie_array;
    my $src_file = CovReport -> current_src_file;
    my $instance_path = CovReport -> current_instance_path;

    my $line = $src_tie_array -> [$ln - 1];

    $line =~ s{^\s*|\s*$}{}g;

    $miss_info_h -> {LINE_NUMBER} = $ln;
    $miss_info_h -> {FEC_CONDITION} = $line;
    $miss_info_h -> {SOURCE_FILE} = $src_file;
    $miss_info_h -> {INSTANCE_PATH} = $instance_path;
    $miss_info_h -> {MISSING} = \@all_fec_rows;

    return $miss_info_h;
  };

  my $scraper = scraper {
    process "$p_conditions_h", "conditions_h[]" => $s_conditions_h;
  };

  my $scrape = $scraper -> scrape ($mech -> content());

  if (defined($scrape -> {conditions_h})) {
    foreach my $condition_h (@{$scrape -> {conditions_h}}) {
      $self -> write_row_h ($condition_h);
    }
  }
}

#-------------------------------------------------------------------------------
# Sub : get_missing_cov
#-------------------------------------------------------------------------------
sub get_missing_cov {
  my $self = shift;
  my $page = shift || die "Page not defined!!!";

  my $p_path = "//a[text()='$sheet_name']";
  my $s_path = sub {
    my $he = shift;
    my $config = Config -> new();

    my $href = $he -> attr('href');
    return "file://$config->{cov_html_report_path}/pages/$href";
  };

  my $scraper = scraper {
    process "$p_path", "conditions_file" => $s_path;
  };

  my $scrape = $scraper -> scrape ($page);

  if (defined($scrape -> {conditions_file})) {
    $self -> missing_condition ($scrape -> {conditions_file});
  }

}

package Toggles;
use strict;
use warnings;
use WWW::Mechanize;
use Web::Scraper;
use Data::Dump;

our $row_no = 0;
our $col_no = 0;

our $Toggles;
our $sheet_name = 'Toggles';

sub new {
  my $class = shift;

  return $Toggles if (defined($Toggles));
  my $out_filename = shift;

  my $covwriteexcel = CovWriteExcel -> new();
  my $worksheet = $covwriteexcel -> sheet($sheet_name);
  $worksheet -> set_column (0, 1, 60);
  $worksheet -> set_column (2, 2, 15);
  $worksheet -> set_column (3, 3, 60);
  $worksheet -> set_column (11, 11, 60);

  my $heading = [
    'INSTANCE_PATH',
    'SOURCE_FILE',
    'LINE_NUMBER',
    'SIGNAL',
    '0L->1H',
    '1H->0L',
    '0L->Z',
    'Z->1H',
    '1H->Z',
    'Z->0L',
    'EXT_MODE',
    'COMMENTS',
  ];

  my $heading_format = $covwriteexcel -> {heading_format};
  $worksheet -> write_row ($row_no++, $col_no, $heading, $heading_format);

  my $self = {
    heading => $heading,
  };
  $self = bless $self, $class;

  $Toggles = $self;
  return $self;

}

#-------------------------------------------------------------------------------
# Sub : write_row_h
#-------------------------------------------------------------------------------
sub write_row_h {
  my $self = shift;
  my $row_h = shift;

  my $row = [@{$row_h}{@{$self -> {heading}}}];

  my $covwriteexcel = CovWriteExcel -> new();
  my $worksheet = $covwriteexcel -> sheet($sheet_name);

  $worksheet -> write_row ($row_no++, $col_no, $row, $covwriteexcel -> {row_format});
}

#-------------------------------------------------------------------------------
# Sub : missing_toggle
#-------------------------------------------------------------------------------
sub missing_toggle {
  my $self = shift;
  my $file = shift;

  my $mech = WWW::Mechanize -> new ();

  $mech -> get($file);

  my $p_missing_toggles = "//tr[\@c='R' or \@c='r']";
  my $s_missing_toggles = sub {
    my $he = shift;
    my $lnk = $he -> attr('lnk');
    my (undef, $ln) = split (/#/, $lnk);

    my $signal = $he -> attr('z');
    my $h1 = $he -> attr('h1');
    my $h2 = $he -> attr('h2');
    my $h3 = $he -> attr('h3');
    my $h4 = $he -> attr('h4');
    my $h5 = $he -> attr('h5');
    my $h6 = $he -> attr('h6');
    my $extmode = $he -> attr('em');

    my $miss_info_h = {};

    my $src_tie_array = CovReport -> current_src_tie_array;
    my $src_file = CovReport -> current_src_file;
    my $instance_path = CovReport -> current_instance_path;

    my $line = $src_tie_array -> [$ln - 1];
    $line =~ s{^\s*|\s*$}{}g;

    $miss_info_h -> {LINE_NUMBER} = $ln;
    $miss_info_h -> {SOURCE_FILE} = $src_file;
    $miss_info_h -> {INSTANCE_PATH} = $instance_path;
    $miss_info_h -> {SIGNAL} = $signal;
    $miss_info_h -> {'0L->1H'} = $h1;
    $miss_info_h -> {'1H->0L'} = $h2;
    $miss_info_h -> {'0L->Z'} = $h3;
    $miss_info_h -> {'Z->1H'} = $h4;
    $miss_info_h -> {'1H->Z'} = $h5;
    $miss_info_h -> {'Z->0L'} = $h6;
    $miss_info_h -> {'EXT_MODE'} = $extmode;

    return $miss_info_h;
  };

  my $scraper = scraper {
    process "$p_missing_toggles", "missing_toggles[]" => $s_missing_toggles;
  };

  my $scrape = $scraper -> scrape ($mech -> content());

  if (defined($scrape -> {missing_toggles})) {
    foreach my $missing_toggle_h (@{$scrape -> {missing_toggles}}) {
      $self -> write_row_h ($missing_toggle_h);
    }
  }
}

#-------------------------------------------------------------------------------
# Sub : get_missing_cov
#-------------------------------------------------------------------------------
sub get_missing_cov {
  my $self = shift;
  my $page = shift || die "Page not defined!!!";

  my $p_path = "//a[text()='$sheet_name']";
  my $s_path = sub {
    my $he = shift;
    my $config = Config -> new();

    my $href = $he -> attr('href');
    return "file://$config->{cov_html_report_path}/pages/$href";
  };

  my $scraper = scraper {
    process "$p_path", "toggles_file" => $s_path;
  };

  my $scrape = $scraper -> scrape ($page);

  if (defined($scrape -> {toggles_file})) {
    $self -> missing_toggle ($scrape -> {toggles_file});
  }

}


package CovReport;
use strict;
use warnings;
use WWW::Mechanize;
use Web::Scraper;
use Data::Dump;
use Tie::File;

our $CovReport;

sub new {
  my $class = shift;

  return $CovReport if (defined($CovReport));

  my $mech = WWW::Mechanize -> new ();

  my $cov_report_type = "byinstance";
  #my $cov_report_type = "bydu";

  my $self = {
    mech => $mech,
    current_src_tie_array => '',
    current_src_file => '',
    current_instance_path => '',
    cov_report_type => $cov_report_type,
  };
  $self = bless $self, $class;

  $CovReport = $self;
  return $self;

}

#-------------------------------------------------------------------------------
# Sub : current_src_tie_array
#-------------------------------------------------------------------------------
sub current_src_tie_array {
  my $class = shift;
  if (defined($CovReport)) {
    return $CovReport -> {current_src_tie_array};
  }
  die "No instance found!!!";
}

#-------------------------------------------------------------------------------
# Sub : current_src_file
#-------------------------------------------------------------------------------
sub current_src_file {
  my $class = shift;
  if (defined($CovReport)) {
    return $CovReport -> {current_src_file};
  }
  die "No instance found!!!";
}

#-------------------------------------------------------------------------------
# Sub : current_instance_path
#-------------------------------------------------------------------------------
sub current_instance_path {
  my $class = shift;

  if (defined($CovReport)) {
    return $CovReport -> {current_instance_path};
  }
  die "No instance found!!!";
}

#-------------------------------------------------------------------------------
# Sub : get_sub_module_paths
#-------------------------------------------------------------------------------
sub get_sub_module_paths {
  my $self = shift;
  my $mech = $self -> {mech};

  if ($mech -> content() =~ /Coverage Summary By Instance:/) {
    my $p_sub_module_paths = "//table[preceding-sibling::h3[text()='Coverage Summary By Instance:']]/tr/td[2]/a";
    my $s_sub_module_paths = sub {
      my $he = shift;
      my $href = $he -> attr('href');
      my $config = Config -> new();

      return "file://$config->{cov_html_report_path}/pages/$href";

    };

    my $scraper = scraper {
      process "$p_sub_module_paths", "sub_module_paths[]" => $s_sub_module_paths;

    };

    my $scrape = $scraper -> scrape ($mech -> content());
    if (defined($scrape -> {sub_module_paths})) {
      return @{$scrape -> {sub_module_paths}};
    }
  }
  else {
    return ();
  }
}

#-------------------------------------------------------------------------------
# Sub : get_missing_cov_all
#-------------------------------------------------------------------------------
sub get_missing_cov_all {
  my $self = shift;
  my $file = shift;

  print ("Extracting missing coverage information.\n");
  print ("$file\n");

  my $mech = $self -> {mech};

  $mech -> get($file);

  my $p_design_unit_file = "//dd[preceding-sibling::dt/b[contains(text(),'Design Unit Name:')]]/a";
  my $s_design_unit_file = sub {
    my $he = shift;
    my $href = $he -> attr('href');
    my $config = Config -> new();

    return "file://$config->{cov_html_report_path}/pages/$href";

  };

  my $p_instance_path = "//dd[preceding-sibling::dt/b[contains(text(),'Instance Path:')]]";

  my $scraper = scraper {
    process "$p_design_unit_file", "design_unit_file" => $s_design_unit_file;
    process "$p_instance_path", "instance_path" => 'TEXT';
  };

  my $scrape = $scraper -> scrape ($mech -> content());

  $self -> {current_instance_path} = $scrape -> {instance_path};


  if (defined($scrape -> {design_unit_file})) {
    $self -> update_current_src_file($scrape -> {design_unit_file});

    if ($self -> {cov_report_type} eq "bydu") {
      $self -> get_missing_cov ($scrape -> {design_unit_file});
    }
    else {
      $self -> get_missing_cov ($file);
    }
  }
  else {
    $self -> update_current_src_file($file);
    $self -> get_missing_cov ($file);
  }

  my @sub_paths = $self -> get_sub_module_paths();
  foreach my $sub_path (@{sub_paths}) {
    $self -> get_missing_cov_all ($sub_path);
  }

}

#-------------------------------------------------------------------------------
# Sub : update_current_src_file
#-------------------------------------------------------------------------------
sub update_current_src_file {
  my $self = shift;
  my $file = shift;

  my $mech = WWW::Mechanize -> new (
    agent => 'Mozilla/5.0 (X11; Linux i686; rv:12.0) Gecko/20100101 Firefox/12.0',
  );

  $mech -> get($file);

  my $p_source_file = "//dd[preceding-sibling::dt/b[contains(text(),'Source File:')]]/a";

  my $scraper = scraper {
    process "$p_source_file", "source_file" => 'TEXT';
  };

  my $scrape = $scraper -> scrape ($mech -> content());

  if (defined($scrape->{source_file})) {
    my $file;
    if (-e "$ENV{BASE_DIR}/$scrape->{source_file}") {
      $file = "$ENV{BASE_DIR}/$scrape->{source_file}";
    }
    else {
      $file = "$scrape->{source_file}";
    }

    use Fcntl 'O_RDONLY';
    tie my @src_tie_array, 'Tie::File', $file, mode => O_RDONLY or die "Error: Coundn't open file $file. $!";

    $self -> {current_src_tie_array} = \@src_tie_array;
    if (-e "$ENV{BASE_DIR}/$scrape->{source_file}") {
      $self -> {current_src_file} = "\$BASE_DIR/$scrape->{source_file}";
    }
    else {
      $scrape->{source_file} =~ s($ENV{BASE_DIR})(\$BASE_DIR);
      $self -> {current_src_file} = "$scrape->{source_file}";
    }
  }
  else {
    $self -> {current_src_tie_array} = '';
    $self -> {current_src_file} = '';
  }

}

#-------------------------------------------------------------------------------
# Sub : get_missing_cov
# The script do not generate design coverage instead it generates local instance coverage
# This sub should call when generating design unit coverage
#-------------------------------------------------------------------------------
sub get_missing_cov {
  my $self = shift;
  my $file = shift;

  print ("Instance Coverage Information:\n");
  print ("$file\n");
  my $mech = WWW::Mechanize -> new ();

  $mech -> get($file);

  my $statements = Statements -> new();
  $statements -> get_missing_cov ($mech -> content());

  my $branches = Branches -> new();
  $branches -> get_missing_cov ($mech -> content());

  my $conditions = Conditions -> new();
  $conditions -> get_missing_cov ($mech -> content());

  my $expressions = Expressions -> new();
  $expressions -> get_missing_cov ($mech -> content());

  my $toggles = Toggles -> new();
  $toggles -> get_missing_cov ($mech -> content());

  my $fsms = FSMs -> new();
  $fsms -> get_missing_cov ($mech -> content());
}



#-------------------------------------------------------------------------------
# Config
#-------------------------------------------------------------------------------
package Config;
use strict;
use warnings;
use Getopt::Lucid qw( :all );

our $Config;
our $dut;
our $cov_html_report_path;


sub new {
  my $class = shift;

  return $Config if (defined($Config));

  my @specs = (
    Param("covhtmlreport|c"),
    Param("dut|d"),
    Switch("help|h")->anycase
  );

  my $opt = Getopt::Lucid->getopt( \@specs );
  $opt->validate( {'requires' => ['covhtmlreport', 'dut']} );
  my %all_options = $opt->options;

  if ($all_options {help}) {
    $class -> help;
  }

  $dut = $all_options {dut};
  $cov_html_report_path = $all_options {covhtmlreport};

  my $self = {
    dut => $dut,
    cov_html_report_path => $cov_html_report_path,
    all_options => \%all_options,
  };
  $self = bless $self, $class;
  $Config = $self;

  return $self;

}

END {
  if (!defined($Config)) {
    Config -> help;
  }
}

#-------------------------------------------------------------------------------
# Sub : help
#-------------------------------------------------------------------------------
sub help {
  my $class = shift;

  my $filename = $0;
  $filename =~ s{^.*/}{}g;

  my $msg = <<EOD;
######################################################################
#                        HELP                                        #
######################################################################
# Description: This script is used to generate excel file for
#              missing Code Coverage of the following:
#              1. Statement
#              2. Branch
#              3. Condition
#              4. Expression
#              5. Toggle
# Switches:
#          help|h = Help on the script
# Parameters:
#          dut|d:           Name of the top level DUT module
#          covhtmlreport|c: Path of the HTML report directory 'covhtmlreport'.
#
# Usage:
#      $filename <Switches> <Parameters>
#
#      Example:
#      \$ $filename -h
#      \$ $filename dut=ofia_2_i covhtmlreport=$ENV{HOME}/log/ofia_DOFIA24_20150916T162257/covhtmlreport
######################################################################

EOD

  print ("$msg\n");
  exit;
}

#-------------------------------------------------------------------------------
# Sub : get_design_cov_path
#-------------------------------------------------------------------------------
sub get_design_cov_path {

  my $mech = WWW::Mechanize -> new ();

  $mech -> get("file://$cov_html_report_path/pages/__menu.htm");

  my $content = $mech -> content();
  if ($content =~ /^\s*d.add\(\d+, \d+, '$dut', '(.*?)',/m) {
    my $path = "file://${cov_html_report_path}/pages/$1";
    return $path;
  }

  die "Path for design unit $dut not found!!!";

}


package main;
my $config = Config -> new();
my $design_cov_path = $config -> get_design_cov_path;
#my $design_cov_path = "file:///home/eda3/projects/trustedio/user/kparmar_r1/sim/run/out/covhtmlreport_ACOFIA/pages/z000767.htm";

my $missing_cov_report_file = "$ENV{LOGDIR}/missing_code_coverage";
my $writeexcel = CovWriteExcel -> new($missing_cov_report_file);
my $covreport = CovReport -> new();

$covreport -> get_missing_cov_all($design_cov_path);

print ("\n");
print ("################################################################################\n");
print ("# Missing Code Coverage Report File: $missing_cov_report_file.xlsx\n");
print ("################################################################################\n");






