#-----------------------------------------------------------------------------
#<HEADER>
# <COPYRIGHT_STATEMENT>
#    COPYRIGHT 2014.  ALL RIGHTS RESERVED.
# </COPYRIGHT_STATEMENT>
#
# <AUTHOR> Kartik Parmar </AUTHOR>
#
# <FILENAME> cleanup_indent.pl </FILENAME>
#
# <DESCRIPTION>
#   This script is used to cleanup the sv files for indentation and tabs.
# </DESCRIPTION>
#</HEADER>
#-----------------------------------------------------------------------------
package SV::SetIndent;
use strict;
use warnings;

my $debug = 0;
my $log = VIM::Eval('$HOME') . "/vim_sv_indent.log";
my $shiftwidth = 2;

my %paired_keywords = (
  'begin'         => 'end',
  'fork'          => 'join|join_any|join_none',
  'property'      => 'endproperty',
  'class'         => 'endclass',
  'interface'     => 'endinterface',
  'case'          => 'endcase',
  'config'        => 'endconfig',
  'clocking'      => 'endclocking',
  'function'      => 'endfunction',
  'task'          => 'endtask',
  'specify'       => 'endspecify',
  'covergroup'    => 'endgroup',
  'property'      => 'endproperty',
  'sequence'      => 'endsequence',
  'checker'       => 'endchecker',
  'module'        => 'endmodule',
  'program'       => 'endprogram',
  # 'package'       => 'endpackage',

  '{'             => '}',
  '('             => ')',

  # Methedology
  #'ovm_\w+_begin' => 'ovm_\w+_end',
  #'uvm_\w+_begin' => 'uvm_\w+_end',
);

my @unpaired_keywords = (
  'if',
  'else',
  'for',
  'foreach',
  'do',
  'while',
  'forever',
  'repeat',
  'always',
  'always_comb',
  'always_ff',
  'always_latch',
  'initial'
);

my %paired_braces = (
  '{' => '}',
  '(' => ')',
  '[' => ']',
);

#-------------------------------------------------------------------------------
# new :
#-------------------------------------------------------------------------------
sub new {
  my $class = shift;
  my ($start_ln, $end_ln, $indent, $skip_indent_inner_braces) = @_;

  # Overrite the default value of shiftwidth
  $shiftwidth = VIM::Eval("&shiftwidth");

  $start_ln = 1 unless (defined($start_ln));
  $end_ln = VIM::Eval('line("$")') unless (defined($end_ln));
  $indent = 0 unless (defined($indent));
  $skip_indent_inner_braces = 0 unless (defined($skip_indent_inner_braces));

  unlink ($log) if (-e $log);

  pp (&get_sub_name);

  $end_ln = 1 unless (defined($end_ln));

  my $self = bless {
    end_of_line => $end_ln,
    ln_ptr => $start_ln,
    delims => [],
    delim_ptr => 0,
    indent => $indent,
    next_ln_indents => [],
    old_indents => [],
    skip_indent_inner_braces => $skip_indent_inner_braces,
  }, $class;

  return $self;
}

#-------------------------------------------------------------------------------
# Others Non-Class Methods for debugging
#-------------------------------------------------------------------------------
# get_sub_name :
#-------------------------------------------------------------------------------
sub get_sub_name {
  my ($line_no, $sub_name);
  my $idx = 0;

  my @sub_list;
  while (($line_no, $sub_name)= (caller($idx)) [2,3]) {
    push (@sub_list, (split("::", $sub_name))[-1] . "[$line_no]");
    #push (@sub_list, $sub_name);
  }
  continue {
    $idx ++;
  }

  my $me = join (" -> ", reverse(@sub_list));
  return $me;
}

#-------------------------------------------------------------------------------
# pp :
#-------------------------------------------------------------------------------
sub pp {
  return if ($debug == 0);

  use Data::Dump qw(dump);
  my $data = shift;

  my $ln = (caller (0)) [2];
  open (my $log_fh, ">>$log") or die ("Error: Couln't open file $log $!");

  #print $log_fh ( "$data\n") if (ref($data) eq ref(""));
  #print $log_fh ( dump($data) . "\n") unless (ref($data) eq ref(""));

  print $log_fh ("[$ln]" . dump($data) . "\n");
}
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# get_curr_indent_level :
#-------------------------------------------------------------------------------
sub get_curr_indent_level {
  my $self = shift;

  pp (&get_sub_name);

  return $self -> {indent};
}

#-------------------------------------------------------------------------------
# reset_delim_ptr :
#-------------------------------------------------------------------------------
sub reset_delim_ptr {
  my $self = shift;

  pp (&get_sub_name);

  $self -> {delim_ptr} = 0;
}

#-------------------------------------------------------------------------------
# get_ln_delimited_keywords :
#-------------------------------------------------------------------------------
sub get_ln_delimited_keywords {
  my $self = shift;

  pp (&get_sub_name);

  if ($self -> {ln_ptr} > $self -> {end_of_line}) {
    $self -> reset_delim_ptr ();
    $self -> {delims} = [];
    return;
  }

  my $statement = $main::curbuf -> Get($self -> {ln_ptr});
  # Remove trailing spaces
  $statement =~ s/^\s+//g;
  my @delims = split (/(\s+|\W)/, $statement);
  my @non_empty_delims = grep (defined, @delims);
  @non_empty_delims = grep (length, @non_empty_delims);

  $self -> {delims} = \@non_empty_delims;

  # reset the keyword pointer
  $self -> reset_delim_ptr ();
}

#-------------------------------------------------------------------------------
# is_last_ln :
#-------------------------------------------------------------------------------
sub is_last_ln {
  my $self = shift;

  pp (&get_sub_name);

  my $is_last = $self -> {ln_ptr} > $self -> {end_of_line};
  return $is_last;
}

#-------------------------------------------------------------------------------
# get_next_non_empty_ln_number :
#-------------------------------------------------------------------------------
sub get_next_non_empty_ln_number {
  my $self = shift;

  pp (&get_sub_name);

  return if ($self -> {ln_ptr} > $self -> {end_of_line});

  #------------------------------------------------------------
  # Set indent of current line
  my $line = $main::curbuf -> Get($self -> {ln_ptr});
  $line =~ s/^\s+//g;
  $line = (" " x $self -> {indent}) . $line;
  $main::curbuf -> Set($self -> {ln_ptr}, $line);
  #------------------------------------------------------------

  # Seek for next non empty line
  do {

    # if empty line found make remove trailing spaces
    if ($main::curbuf -> Get($self -> {ln_ptr}) =~ /^\s*$/) {
      $main::curbuf -> Set($self -> {ln_ptr}, "");
    }

    $self -> {ln_ptr}++;
    pp ("line: $self->{ln_ptr}");
  } while ((!$self -> is_last_ln) &&
    ($main::curbuf -> Get($self -> {ln_ptr}) =~ /^\s*$/));

  return 0 if ($self -> is_last_ln);
  return 1;
}

#-------------------------------------------------------------------------------
# get_prev_non_empty_ln_number :
#-------------------------------------------------------------------------------
sub get_prev_non_empty_ln_number {
  my $self = shift;

  pp (&get_sub_name);

  return if ($self -> {ln_ptr} <= 1);
  # Seek for prev non empty line
  do {

    $self -> {ln_ptr}--;
    pp ("line: $self->{ln_ptr}")

  } while (($self -> {ln_ptr} >= 1) &&
    ($main::curbuf -> Get($self -> {ln_ptr}) =~ /^\s*$/));

  return 0 if ($self -> {ln_ptr} < 1);
  return 1;
}

#-------------------------------------------------------------------------------
# incr_decr_indent :
#-------------------------------------------------------------------------------
sub incr_decr_indent {
  my $self = shift;
  my $offset = shift;

  $offset = 0 unless (defined($offset));

  pp (&get_sub_name);
  pp ("indent: " . ($self -> {indent} + $offset));

  $self -> {indent} += $offset;
}

#-------------------------------------------------------------------------------
# skip_single_line_comment :
#-------------------------------------------------------------------------------
sub skip_single_line_comment {
  my $self = shift;

  pp (&get_sub_name);

  $self -> {delim_ptr} = $#{$self -> {delims}} + 1;
}

#-------------------------------------------------------------------------------
# skip_multiple_line_comment :
#-------------------------------------------------------------------------------
sub skip_multiple_line_comment {
  my $self = shift;

  pp (&get_sub_name);

  # Skip the code comment starting from /* to */
  while (!$self -> is_last_ln) {
    while (!$self -> is_last_keyword) {
      my $curr_keyword = $self -> get_offset_keyword ();
      if ($curr_keyword eq '*') {

        #$self -> get_next_keyword_ptr;
        my $next_keyword = $self -> get_offset_keyword (2 - 1); # KP FIX
        if (defined($next_keyword) && $next_keyword eq '/') {

          # Advance the pointer to next keyword
          $self -> get_next_keyword_ptr ();
          $self -> get_next_keyword_ptr ();
          return;
        }
      }
    }
    continue {
      $self -> get_next_keyword_ptr ();
    }
  }
  continue {

    $self -> get_next_non_empty_ln_number;
    $self -> get_ln_delimited_keywords ();
  }
}

#-------------------------------------------------------------------------------
# skip_string :
#-------------------------------------------------------------------------------
sub skip_string {
  my $self = shift;

  pp (&get_sub_name);

  # Skip the string between '"' & '"'
  while (!$self -> is_last_ln) {
    while (!$self -> is_last_keyword) {
      my $curr_keyword = $self -> get_offset_keyword ();
      if ($curr_keyword eq '"') {
        # Advance the pointer to next keyword and return
        $self -> get_next_keyword_ptr ();
        return;
      }
      $self -> get_next_keyword_ptr ();
    }
  }
  continue {

    $self -> get_next_non_empty_ln_number;
    $self -> get_ln_delimited_keywords ();
  }
}

#-------------------------------------------------------------------------------
# update_next_ln_indent_preserv_old :
#-------------------------------------------------------------------------------
sub update_next_ln_indent_preserv_old {
  my $self = shift;
  my $indent = shift;

  die ("Indent not provided...") if (!defined($indent));

  pp (&get_sub_name);

  my $indents = $self -> {next_ln_indents};
  my $old_indents = $self -> {old_indents};

  push (@$indents, $indent);

  # Save the old indent to be used later to restore the current indent
  push (@$old_indents, -$indent);
}

#-------------------------------------------------------------------------------
# update_next_ln_indent :
#-------------------------------------------------------------------------------
sub update_next_ln_indent {
  my $self = shift;
  my $indent = shift;
  die ("Indent not provided...") unless (defined($indent));

  pp (&get_sub_name);

  my $indents = $self -> {next_ln_indents};
  push (@$indents, $indent);
}

#-------------------------------------------------------------------------------
# indent_pair_keywords :
#-------------------------------------------------------------------------------
sub indent_pair_keywords {
  my $self = shift;
  my $keyword_ptrn = shift || die ("Please provide key of pair-key value...");

  pp (&get_sub_name);

  # As we have already advance the pointer keyword is in the previous location
  my $m2_keyword = $self -> get_offset_keyword (-2 - 1);
  my $p2_keyword = $self -> get_offset_keyword (2 - 1);
  my $curr_keyword = $self -> get_offset_keyword (-1);

  # skip for extern functions/tasks
  if ($curr_keyword eq 'function' || $curr_keyword eq 'task') {
    # extern function
    return if ($m2_keyword eq 'extern') || ($m2_keyword eq 'pure');

    # extern virtual function or extern static function
    my $m4_keyword = $self -> get_offset_keyword (-4 - 1);
    return if ($m4_keyword eq 'extern') || ($m4_keyword eq 'pure');
  }

  # virtual interface
  if ($curr_keyword eq 'interface') {
    return if ($m2_keyword eq 'virtual');
  }

  if ((defined($m2_keyword) && $m2_keyword eq 'assert') ||
      (defined($m2_keyword) && $m2_keyword eq 'disable') ||
      (defined($m2_keyword) && $m2_keyword eq 'typedef') ||
      (defined($m2_keyword) && $m2_keyword eq 'with') ||
      (defined($m2_keyword) && $m2_keyword eq 'wait') ||
      (defined($m2_keyword) && $m2_keyword eq 'wait') ||
      (defined($m2_keyword) && $m2_keyword eq 'else' && $curr_keyword eq 'if') ||
     (defined($p2_keyword) && $p2_keyword eq 'if' && $curr_keyword eq 'else')) {
    return;
  }

  if ($keyword_ptrn =~ /^ovm_\w+_begin$/) {
    $keyword_ptrn = 'ovm_\w+_begin';
  }

  my $end_paired_keyword_prtn;
  $end_paired_keyword_prtn = $paired_keywords{$keyword_ptrn} if (defined($paired_keywords{$keyword_ptrn}));

  $end_paired_keyword_prtn =~ s/\)|\}|\]/\\$&/g if defined($end_paired_keyword_prtn);

  my $any_paired_keyword_ptrn = join ("|", keys(%paired_keywords));
  $any_paired_keyword_ptrn =~ s/(\(|\{|\[)/\\$1/g;

  my $any_unpaired_keyword_ptrm = join ("|", @unpaired_keywords);
  $any_unpaired_keyword_ptrm =~ s/(\(|\{|\[)/\\$1/g;

  my $any_start_brace_char = join ("|", keys(%paired_braces));
  $any_start_brace_char =~ s/(\(|\{|\[)/\\$1/g;

  # Save the value of current line pointer
  my $start_ln = $self -> {ln_ptr};

  $self -> update_next_ln_indent_preserv_old ($shiftwidth);

  while (!$self -> is_last_ln) {

    while (!$self -> is_last_keyword) {
      my $curr_keyword = $self -> get_offset_keyword ();

      #------------------------------------------------------------
      # Skip comments & strings
      if ($curr_keyword eq '/') {
        $self -> get_next_keyword_ptr;
        my $next_keyword = $self -> get_offset_keyword ();

        # Skip multiple line comments /* to */
        if ($next_keyword eq '*') {
          $self -> get_next_keyword_ptr;
          $self -> skip_multiple_line_comment;
        }

        # Skip single line comment
        if ($next_keyword eq '/') {
          # Advance the pointer
          $self -> get_next_keyword_ptr;
          $self -> skip_single_line_comment;
        }

        # Check for new keyword
        next;
      }

      # Skip string between '"' & '"'
      if ($curr_keyword eq '"') {
        $self -> get_next_keyword_ptr;
        $self -> skip_string;
        next;
      }
      #------------------------------------------------------------

      #------------------------------------------------------------
      # Search for paired key (start of block)
      if ($curr_keyword =~ /^($any_paired_keyword_ptrn)$/) {

        my $paired_kw = $1;
        if ($curr_keyword =~ /^$any_start_brace_char$/) {
          my $n1_keyword = $self -> get_offset_keyword (1);
          my $n2_keyword = $self -> get_offset_keyword (2);
          my $brace_kw = $&;

          $self -> get_next_keyword_ptr ();

          # Get the logic how the indentation of braces should defined.
          if (!defined($n1_keyword) || (!defined($n2_keyword) && $n1_keyword =~ /^\s+$/)) {
            $self -> indent_pair_keywords ($brace_kw);
          }
          else {
            $self -> indent_braces($brace_kw);
          }
        }
        else {
          $self -> get_next_keyword_ptr ();
          $self -> indent_pair_keywords ($paired_kw);
        }
        next;
      }

      # Search for paired value (end of block)
      if (defined($end_paired_keyword_prtn) &&
          $curr_keyword =~ /^($end_paired_keyword_prtn)$/) {

        my $end_ln = $self -> {ln_ptr};
        # If paired value found in the same line where key is present then no effect on indent
        if ($start_ln == $end_ln) {
          pop (@{$self -> {next_ln_indents}});
          pop (@{$self -> {old_indents}});
        }
        elsif ($#{$self -> {old_indents}} != -1) {
          # Get the old indent
          my $curr_idx = $self -> {delim_ptr};
          # If the end keyword found
          if ($curr_idx == 0 || ($curr_idx == 1 && $self -> {delims}[0] eq '`')) {
            $self -> incr_decr_indent(pop (@{$self -> {old_indents}}));
          }
          else {
            $self -> update_next_ln_indent (pop (@{$self -> {old_indents}}));
          }
        }

        $self -> get_next_keyword_ptr;
        return;
      }
      #------------------------------------------------------------

      # Search for braces
      if ($curr_keyword =~ /^$any_start_brace_char$/) {
        $self -> get_next_keyword_ptr;
        $self -> indent_braces($&);
        next;
      }

      #------------------------------------------------------------
      # Check for unpaired keywords
      my $prev_keyword = $self -> get_offset_keyword (-1);
      if ($self -> {delim_ptr} == 0 || $prev_keyword ne '`') {
        if ($curr_keyword =~ /^($any_unpaired_keyword_ptrm)$/) {
          $self -> get_next_keyword_ptr;
          pp $self;
          $self -> indent_unpaired_keywords;
          pp $self;
          next;
        }
      }
      #------------------------------------------------------------

      # Advance the pointer of keywords
      $self -> get_next_keyword_ptr ();
    }

  }
  continue {

    last unless ($self -> get_next_non_empty_ln_number);

    # Get the indent level of next line
    while ($#{$self -> {next_ln_indents}} != -1) {
      $self -> incr_decr_indent(pop (@{$self -> {next_ln_indents}}));
    }

    $self -> get_ln_delimited_keywords ();
  }
}

#-------------------------------------------------------------------------------
# get_next_keyword :
#-------------------------------------------------------------------------------
sub get_next_keyword_ptr {
  my $self = shift;

  pp (&get_sub_name);

  $self -> {delim_ptr} ++;
}

#-------------------------------------------------------------------------------
# get_offset_keyword :
#-------------------------------------------------------------------------------
sub get_offset_keyword {
  my $self = shift;
  my $offset = shift;

  pp (&get_sub_name);

  $offset = 0 unless (defined($offset));

  return $self -> {delims} [$self -> {delim_ptr} + $offset];
}

#-------------------------------------------------------------------------------
# is_last_keyword :
#-------------------------------------------------------------------------------
sub is_last_keyword {
  my $self = shift;

  pp (&get_sub_name);

  $self -> {delim_ptr} > $#{$self -> {delims}};
}

#-------------------------------------------------------------------------------
# skip_braces :
#-------------------------------------------------------------------------------
sub skip_braces {
  my $self = shift;
  my $start_brace_char = shift; # (, [ or {

  pp (&get_sub_name);

  my $end_brace_char = $paired_braces{$start_brace_char};

  my $any_start_brace_char = join ("|", keys(%paired_braces));
  $any_start_brace_char =~ s/(\(|\{|\[)/\\$1/g;

  # Skip to the end of ')'
  while (!$self -> is_last_ln) {
    while (!$self -> is_last_keyword) {
      my $curr_keyword = $self -> get_offset_keyword ();

      #------------------------------------------------------------
      # Skip comments & strings
      if ($curr_keyword eq '/') {
        $self -> get_next_keyword_ptr;
        my $next_keyword = $self -> get_offset_keyword ();

        # Skip multiple line comments /* to */
        if ($next_keyword eq '*') {
          $self -> get_next_keyword_ptr;
          $self -> skip_multiple_line_comment;
        }

        # Skip single line comment
        if ($next_keyword eq '/') {
          # Advance the pointer
          $self -> get_next_keyword_ptr;
          $self -> skip_single_line_comment;
        }

        # Check for new keyword
        next;
      }

      # Skip string between '"' & '"'
      if ($curr_keyword eq '"') {
        $self -> get_next_keyword_ptr;
        $self -> skip_string;
        next;
      }
      #------------------------------------------------------------

      # Skip the inner braces...
      if ($curr_keyword =~ /^$any_start_brace_char$/) {
        $self -> get_next_keyword_ptr;
        $self -> skip_braces($&);
        next;
      }

      if ($curr_keyword eq $end_brace_char) {
          # Advance the pointer to next keyword
          $self -> get_next_keyword_ptr ();
          return;
      }
      $self -> get_next_keyword_ptr ();
    }
  }
  continue {

    last unless ($self -> get_next_non_empty_ln_number);

    # Get the indent level of next line
    while ($#{$self -> {next_ln_indents}} != -1) {
      $self -> incr_decr_indent(pop (@{$self -> {next_ln_indents}}));
    }

    $self -> get_ln_delimited_keywords ();
  }
}

#-------------------------------------------------------------------------------
# indent_braces :
#-------------------------------------------------------------------------------
sub indent_braces {
  my $self = shift;
  my $start_brace_char = shift; # (, [, {

  pp (&get_sub_name);

  my $end_brace_char = $paired_braces {$start_brace_char};

  my $any_start_brace_char = join ("|", keys(%paired_braces));
  $any_start_brace_char =~ s/(\(|\{|\[)/\\$1/g;

  # Save the current line pointer
  my $start_ln = $self -> {ln_ptr};

  #-------------------------------------------------------------------------------
  # Calculate the indent of next line by the column idx of '('
  my $indent = 0;
  for (my $i = 0; $i < $self -> {delim_ptr}; $i++) {
    $indent += length($self -> {delims} [$i]);
  }
  #------------------------------------------------------------
  # add to indent the column of next keyword after '('
  my $spaces = "";
  # || if ($self -> get_offset_keyword =~ /^\s+$/) {
  # ||   $spaces = $self -> get_offset_keyword;
  # ||   $indent += length($spaces);
  # || }
  #------------------------------------------------------------

  my $brace_idx = $indent;
  if ($#{$self -> {next_ln_indents}} != -1) {

    my $sum = 0;
    $sum += $self -> {next_ln_indents} [$_] for (0 .. ($#{$self -> {next_ln_indents}}));

    my $off_indent = $indent - $sum + 1;

    if ($self -> {next_ln_indents} [-1] == $shiftwidth) {
      $off_indent -= 1;
    }
    $self -> update_next_ln_indent_preserv_old($off_indent);
  }
  else {
    $self -> update_next_ln_indent_preserv_old($indent);
  }
  #-------------------------------------------------------------------------------

  while (!$self -> is_last_ln()) {

    while (!$self -> is_last_keyword ()) {
      my $curr_keyword = $self -> get_offset_keyword ();

      #------------------------------------------------------------
      # Skip comments & strings
      if ($curr_keyword eq '/') {
        $self -> get_next_keyword_ptr;
        my $next_keyword = $self -> get_offset_keyword ();

        # Skip multiple line comments /* to */
        if ($next_keyword eq '*') {
          $self -> get_next_keyword_ptr;
          $self -> skip_multiple_line_comment;
        }

        # Skip single line comment
        if ($next_keyword eq '/') {
          # Advance the pointer
          $self -> get_next_keyword_ptr;
          $self -> skip_single_line_comment;
        }

        # Check for new keyword
        next;
      }

      # Skip string between '"' & '"'
      if ($curr_keyword eq '"') {
        $self -> get_next_keyword_ptr;
        $self -> skip_string;
        next;
      }
      #------------------------------------------------------------

      # If end of braces found advance the keyword pointer and return
      if ($curr_keyword eq $end_brace_char) {

        my $end_ln = $self -> {ln_ptr};

        # Set indent of the line and get the old indent and return
        my $decr_curr_line = 0;
        # if ')' occurs at the start of the line then match to it's '('
        if ($self -> {delim_ptr} == 0 ||
          ($self -> {delim_ptr} == 1 && $self -> {delims} [0] =~ /^\s*$/)) {
          $decr_curr_line = 1;
        }
        else {
          $decr_curr_line = 0;
        }


        # set indent with the column value matching (
        if ($start_ln == $end_ln) {
          pop (@{$self -> {next_ln_indents}}) if ($#{$self -> {next_ln_indents}} != -1);
          pop (@{$self -> {old_indents}}) if ($#{$self -> {old_indents}} != -1);
        }
        else {
          if ($decr_curr_line == 1) {
            $self -> incr_decr_indent(length($spaces) - 1);
            $self -> update_next_ln_indent(1);
          }

          #------------------------------------------------------------
          # if multiple ')' found sequentially then adjust indent to the matching ')'
          my $p1_keyword = $self -> get_offset_keyword (-1);
          my $p2_keyword = $self -> get_offset_keyword (-2);
          if (defined($p1_keyword) && ($p1_keyword eq $end_brace_char) ||
              (defined($p1_keyword) && defined($p2_keyword) && ($p1_keyword =~ /^\s+$/) && ($p2_keyword eq $end_brace_char))) {
            if ($#{$self -> {old_indents}} != -1) {
              $brace_idx += VIM::Eval("indent($start_ln)");
              my $indent = $self -> {indent} - $brace_idx;
              $self -> incr_decr_indent(-$indent);
              $self -> update_next_ln_indent($indent);
            }
          }
          #------------------------------------------------------------

          if ($#{$self -> {next_ln_indents}} != -1 &&
              $self -> {next_ln_indents} [-1] < -$shiftwidth) {
            #alternate $self -> incr_decr_indent(pop (@{$self -> {next_ln_indents}}));
            $self -> update_next_ln_indent(pop (@{$self -> {next_ln_indents}}));
          }

          $self -> update_next_ln_indent(pop (@{$self -> {old_indents}})) if ($#{$self -> {old_indents}} != -1);
        }

        $self -> get_next_keyword_ptr;
        return;
      }

      if ($self -> {skip_indent_inner_braces} == 1) {
        
        # Skip the inner braces...
        if ($curr_keyword =~ /^($any_start_brace_char)$/) {
          $self -> get_next_keyword_ptr;
          $self -> skip_braces ($1);
          next;
        }

      }
      else {
        #------------------------------------------------------------
        # proper indent inner braces
        if ($curr_keyword =~ /^$any_start_brace_char$/) {
          my $n1_keyword = $self -> get_offset_keyword (1);
          my $n2_keyword = $self -> get_offset_keyword (2);
          my $brace_kw = $&;

          $self -> get_next_keyword_ptr ();

          # Get the logic how the indentation of braces should defined.
          if (!defined($n1_keyword) || (!defined($n2_keyword) && $n1_keyword =~ /^\s+$/)) {
            $self -> indent_pair_keywords ($brace_kw);
          }
          else {
            $self -> indent_braces($brace_kw);
          }
          next;
        }
        # cut
        #------------------------------------------------------------
      }

      $self -> get_next_keyword_ptr;
    }
  }
  continue {
    last unless ($self -> get_next_non_empty_ln_number);


    # Get the indent level of next line
    while ($#{$self -> {next_ln_indents}} != -1) {
      $self -> incr_decr_indent(pop (@{$self -> {next_ln_indents}}));
    }

    $self -> get_ln_delimited_keywords ();
  }
}

#-------------------------------------------------------------------------------
# indent_unpaired_keywords :
#-------------------------------------------------------------------------------
sub indent_unpaired_keywords {
  my $self = shift;
  pp (&get_sub_name);

  my $any_unpaired_keyword_ptrm = join ("|", @unpaired_keywords);
  $any_unpaired_keyword_ptrm =~ s/(\(|\{|\[)/\\$1/g;

  my $any_paired_keyword_ptrn = join ("|", keys(%paired_keywords));
  $any_paired_keyword_ptrn =~ s/(\(|\{|\[)/\\$1/g;

  my $any_start_brace_char = join ("|", keys(%paired_braces));
  $any_start_brace_char =~ s/(\(|\{|\[)/\\$1/g;

  # set to 1 if the unpaired keywords have begin-end with them
  my $is_begin_end = 0;

  # Save the current line pointer
  my $start_ln = $self -> {ln_ptr};

  while (!$self -> is_last_ln()) {
    while (!$self -> is_last_keyword ()) {
      my $curr_keyword = $self -> get_offset_keyword ();
      my $prev_keyword = $self -> get_offset_keyword (-1);

      if ($curr_keyword =~ /^\s*$/) {
        $self -> get_next_keyword_ptr;
        next;
      }

      #------------------------------------------------------------
      # Skip comments & strings
      if ($curr_keyword eq '/') {
        $self -> get_next_keyword_ptr;
        my $next_keyword = $self -> get_offset_keyword ();

        # Skip multiple line comments /* to */
        if ($next_keyword eq '*') {
          $self -> get_next_keyword_ptr;
          $self -> skip_multiple_line_comment;
        }

        # Skip single line comment
        if ($next_keyword eq '/') {
          # Advance the pointer
          $self -> get_next_keyword_ptr;
          $self -> skip_single_line_comment;
        }

        # Check for new keyword
        next;
      }

      # Skip string between '"' & '"'
      if ($curr_keyword eq '"') {
        $self -> get_next_keyword_ptr;
        $self -> skip_string;
        next;
      }
      #------------------------------------------------------------

      #------------------------------------------------------------
      # Search for paired keywords
      if ($curr_keyword =~ /^($any_paired_keyword_ptrn)$/) {
        my $paired_kw = $1;
        if ($curr_keyword =~ /^($any_start_brace_char)$/) {
          my $n1_keyword = $self -> get_offset_keyword (1);
          my $brace_kw = $1;

          $self -> get_next_keyword_ptr ();

          # Get the logic how the indentation of braces should defined.
          if (!defined($n1_keyword) || $n1_keyword =~ /^\s+$/) {
            $self -> indent_pair_keywords ($brace_kw);
          }
          else {
            $self -> indent_braces($brace_kw);
          }
        }
        else {
          $self -> get_next_keyword_ptr ();
          $self -> indent_pair_keywords ($paired_kw);
          return 1;
        }
        # handle the logic for the end of unpaired block by check parired keyword
        # FIX: Considering any paired keyword as part of begin-end fixed below indentation:
        #
        #        module counter;
        #          always begin
        #            if  
        #            case(state)
        #            endcase
        #              end
        #            endmodule
        #     
        #if ($curr_keyword =~ /^\{$|^begin$/) 
        #::: if ($curr_keyword =~ /^($any_paired_keyword_ptrn)$/)
        #::: {
        #:::   $self -> get_next_keyword_ptr;
        #:::   $is_begin_end = 1;
        #:::   return 1;
        #::: }
        next;
      }
      #------------------------------------------------------------

      # Search for braces
      if ($curr_keyword =~ /^$any_start_brace_char$/) {
        $self -> get_next_keyword_ptr;
        $self -> indent_braces($&);
        next;
      }

      # If unpaired keyword is not having any paired keyword i.e. having single line statement
      pp ("DEBUG: 1111: curr_keyword = $curr_keyword");
      if ($curr_keyword eq ';') {
      #if ($curr_keyword =~ /\w|;/) {
        if ($is_begin_end == 0) {
          my $end_ln = $self -> {ln_ptr};

          # If paired value found in the same line where key is present then no effect on indent
          if ($start_ln != $end_ln) {
            # Get the old indent
            $self -> incr_decr_indent($shiftwidth);
            $self -> update_next_ln_indent(-$shiftwidth);
          }

          $self -> get_next_keyword_ptr;
          return 1;
        }
      }

      # Check for unpaired keywords recursively
      if ($self -> {delim_ptr} == 0 || $prev_keyword ne '`') {
        if ($curr_keyword =~ /^($any_unpaired_keyword_ptrm)/) {
          my $m2_keyword = $self -> get_offset_keyword (-2);
          my $p2_keyword = $self -> get_offset_keyword (2);
          if ((defined($m2_keyword) && $m2_keyword eq 'else' && $curr_keyword eq 'if') ||
              (defined($p2_keyword) && $p2_keyword eq 'if' && $curr_keyword eq 'else') ||
              ($curr_keyword eq 'else') ) {
            $self -> get_next_keyword_ptr;
            next;
          }
          $self -> get_next_keyword_ptr;

          $self -> incr_decr_indent($shiftwidth);
          pp $self;
          my $return = $self -> indent_unpaired_keywords;
          pp $self;
          $self -> update_next_ln_indent(-$shiftwidth);
          return 1 if (defined($return) && $return == 1);
          next;
        }
      }

      # Check if any-paired keyword
      $self -> get_next_keyword_ptr;
    }
  }
  continue {
    last unless ($self -> get_next_non_empty_ln_number);


    # Get the indent level of next line
    while ($#{$self -> {next_ln_indents}} != -1) {
      $self -> incr_decr_indent(pop (@{$self -> {next_ln_indents}}));
    }

    $self -> get_ln_delimited_keywords ();
  }
}

#-------------------------------------------------------------------------------
# get_indent_level_of_line :
#-------------------------------------------------------------------------------
sub get_indent_level_of_line {
  my $self = shift;
  pp (&get_sub_name);

  my $any_paired_keyword_ptrn = join ("|", keys(%paired_keywords));
  $any_paired_keyword_ptrn =~ s/(\(|\{|\[)/\\$1/g;

  while (!$self -> is_last_ln()) {
    $self -> get_ln_delimited_keywords ();
    while (!$self -> is_last_keyword ()) {
      my $curr_keyword = $self -> get_offset_keyword ();

      #------------------------------------------------------------
      # Skip comments & strings
      if ($curr_keyword eq '/') {
        $self -> get_next_keyword_ptr;
        my $next_keyword = $self -> get_offset_keyword ();

        if (defined($next_keyword)) {
          # Skip multiple line comments /* to */
          if ($next_keyword eq '*') {
            $self -> get_next_keyword_ptr;
            $self -> skip_multiple_line_comment;
          }

          # Skip single line comment
          if ($next_keyword eq '/') {
            # Advance the pointer
            $self -> get_next_keyword_ptr;
            $self -> skip_single_line_comment;
          }
        }

        # Check for new keyword
        next;
      }

      # Skip string between '"' & '"'
      if ($curr_keyword eq '"') {
        $self -> get_next_keyword_ptr;
        $self -> skip_string;
        next;
      }
      #------------------------------------------------------------

      #------------------------------------------------------------
      # Search for any start of keyword
      if ($curr_keyword =~ /^($any_paired_keyword_ptrn)$/) {
        my $paired_kw = $1;

        my $any_start_brace_char = join ("|", keys(%paired_braces));
        $any_start_brace_char =~ s/(\(|\{|\[)/\\$1/g;

        if ($curr_keyword =~ /^($any_start_brace_char)$/) {
          my $n1_keyword = $self -> get_offset_keyword (1);
          my $n2_keyword = $self -> get_offset_keyword (2);
          my $brace_kw = $1;

          $self -> get_next_keyword_ptr ();

          # Get the logic how the indentation of braces should defined.
          if (!defined($n1_keyword) || (!defined($n2_keyword) && $n1_keyword =~ /^\s+$/)) {
            $self -> indent_pair_keywords ($brace_kw);
          }
          else {
            $self -> indent_braces($brace_kw);
          }
        }
        else {
          $self -> get_next_keyword_ptr ();
          $self -> indent_pair_keywords ($paired_kw);
        }
        next;
      }
      #------------------------------------------------------------

      $self -> get_next_keyword_ptr;
    }
  }
  continue {
    
    last unless ($self -> get_next_non_empty_ln_number);

    # Get the indent level of next line
    while ($#{$self -> {next_ln_indents}} != -1) {
      $self -> incr_decr_indent(pop (@{$self -> {next_ln_indents}}));
    }

  }
  return $self -> get_curr_indent_level;
}

