"------------------------------------------------------------
" User config
let s:skip_indent_inner_braces = 0
"------------------------------------------------------------

"-------------------------------------------------------------------------------
" sv#sv#cleanup_indent: Function
" @arg 1 = start line
" @arg 2 = endline line
"-------------------------------------------------------------------------------
function! sv#sv#indent_cleanup#cleanup_indent(...)

  let save_view = winsaveview()

  if (exists("a:1"))
    let l:first_line = a:1
  else
    let l:first_line = 1
  endif

  if (exists("a:2"))
    let l:last_line = a:2
  else
    let l:last_line ='$' 
  endif

  exe l:first_line . "," . l:last_line ' call sv#sv#indent_cleanup#cleanup_indent_perl()'

  call winrestview(save_view)

endfunction

function! sv#sv#indent_cleanup#cleanup_indent_perl() range

  if (a:firstline == 1)
    let start_indent = 0
  else
    let start_indent = indent (prevnonblank (a:firstline - 1))
  endif

perl <<EOF
#!/usr/bin/perl -w
  use strict;
  use warnings;
  use lib "$ENV{KP_VIM_HOME}/perl_lib";
  use SV::SetIndent;

  my $firstline = VIM::Eval('a:firstline');
  my $lastline = VIM::Eval('a:lastline');
  my $start_indent = VIM::Eval("l:start_indent");

  my $skip_indent_inner_braces = VIM::Eval("s:skip_indent_inner_braces");

  my $sv = SV::SetIndent -> new($firstline, $lastline, $start_indent, $skip_indent_inner_braces);
  my $indent = $sv -> get_indent_level_of_line;
EOF

endfunction

