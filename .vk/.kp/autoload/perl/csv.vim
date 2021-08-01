"-------------------------------------------------------------------------------
" s:GetTemplete: Function
"-------------------------------------------------------------------------------
function! s:GetTemplete(char, ...)
  return common#mov_thru_user_mark#get_template(a:char, a:000)
endfunction

"-------------------------------------------------------------------------------
" open: Function
"-------------------------------------------------------------------------------
function! perl#csv#open()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (name =~ '^\s*$')
    let name = s:GetTemplete('a', 'fname')
  endif

  let str = 'open (my $maa, "' . s:GetTemplete('a', 'rw_mode/<') . ':encoding(utf8)", "$' . name . '") or die ("Error: Couln''t open file $' . name . ' $!");`aa'
  return str
endfunction
