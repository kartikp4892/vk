
"-------------------------------------------------------------------------------
" Exp_Map_Mo: Function
" Monitor
function! s:Exp_Map_Mo()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^f%[unction]$')
    call expression_map#map#remove_map_word()
    return vim#oop#function()
  elseif (mword =~ '\v^n%[ew]$')
    call expression_map#map#remove_map_word()
    return vim#oop#new()
  else
    return ''
  endif
endfunction
imap <M-o> =<SID>Exp_Map_Mo()
"-------------------------------------------------------------------------------

