"===============================================================================
" Default port map of signals
"===============================================================================
function! Kp_port_map() range
  let l:port_list = []
  for l:str in getline(a:firstline, a:lastline)
    if l:str =~ '^\s*\w\+\s*:'
      call add(l:port_list, matchstr(l:str, '\s*\zs\w\+\ze\s*:'))
    endif
  endfor
  call map(l:port_list, 'v:val . " => " . v:val . ","')
  let l:line = join(l:port_list, "\n") . "\n"
  let @a = l:line
endfunction

" <M-M>
vmap í :call Kp_port_map()
imap í a
nmap í "a[p
"===============================================================================
"===============================================================================
