"-------------------------------------------------------------------------------
" fopen: Function
"-------------------------------------------------------------------------------
function! php#filesystem#fopen()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))
  let str = '$maa = fopen ($' . name . ', "r") or die ("Error: Couln''t fopen file $' . name . '");`aa'
  return str
endfunction

