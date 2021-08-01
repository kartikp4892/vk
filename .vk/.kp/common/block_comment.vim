"-------------------------------------------------------------------------------
" Exp_Map_Mc: Function
" Line or Block Comments
function! s:Exp_Map_Mc()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^l%[ine]$')
    call expression_map#map#remove_map_word()
    return '/* maa */`aa'
  elseif (mword =~ '\v^%[block]$')
    call expression_map#map#remove_map_word()
    return comments#block_comment#emptyComment()
  else
    return ''
  endif
endfunction
imap <M-c> =<SID>Exp_Map_Mc()
"-------------------------------------------------------------------------------

" <C-M-C>
imap <C-M-c> =comments#block_comment#midEnd()
"----------------------------------------------------------------------------
