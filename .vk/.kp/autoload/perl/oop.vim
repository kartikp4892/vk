"-------------------------------------------------------------------------------
" _set_indent: Function
"-------------------------------------------------------------------------------
function! s:_set_indent(offset)
  return '=common#indent#imode_set_indent(' . a:offset . ')'
endfunction

"-------------------------------------------------------------------------------
" new: Function
"-------------------------------------------------------------------------------
function! perl#oop#new()
  let str = 'sub new {' .
          \ s:_set_indent(&shiftwidth) . 'my $class = shift;' .
          \ s:_set_indent(0) . 'my $self = {' .
          \ s:_set_indent(&shiftwidth) . 'maa' .
          \ s:_set_indent(0) . '};' .
          \ s:_set_indent(0) . '$self = bless $self, $class;' .
          \ s:_set_indent(0) . 'return $self;' .
          \ s:_set_indent(-&shiftwidth) . '}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" package: Function
"-------------------------------------------------------------------------------
function! perl#oop#package()
  let name = matchstr(getline("."), '\v^\s*\zs[[:graph:]]+')
  call setline(".", repeat(' ', indent(".")))

  let str = 'package ' . name . ';' .
           \'use strict;' .
           \'use warnings;'
  let str .= perl#oop#new()
  return str
endfunction

"-------------------------------------------------------------------------------
" sub: Function
"-------------------------------------------------------------------------------
function! perl#oop#sub()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))
  let str = ""
  if (name !~ "^\s*$")
    let str = comments#block_comment#getComments("Sub", "" . name ) . s:_set_indent(0)
  else
    let name = ""
  endif
  let str .= 'sub ' . name . ' {' .
          \ s:_set_indent(&shiftwidth) . 'my $self = shift;' .
          \ s:_set_indent(0) .  'maa' .
          \ s:_set_indent(-&shiftwidth) . '}`aa'
  return str
endfunction

