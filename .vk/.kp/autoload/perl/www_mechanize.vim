"-------------------------------------------------------------------------------
" _set_indent: Function
"-------------------------------------------------------------------------------
function! s:_set_indent(offset)
  return '=common#indent#imode_set_indent(' . a:offset . ')'
endfunction

"-------------------------------------------------------------------------------
" new: Function
"-------------------------------------------------------------------------------
function! perl#www_mechanize#new()
  let str = 'my $mech = WWW::Mechanize -> new (' .
         \  s:_set_indent(&shiftwidth) . "agent => 'Mozilla/5.0 (X11; Linux i686; rv:12.0) Gecko/20100101 Firefox/12.0'," .
         \  s:_set_indent(-&shiftwidth) . ');'

  return str
endfunction
