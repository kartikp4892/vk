" Variable to store the variable name used in for, foreach, while loop
let _ = []


"-------------------------------------------------------------------------------
" Mappings for accessing the variables
" _ Var
"-------------------------------------------------------------------------------
" Exp_Map_M_: Function
function! s:Exp_Map_M_()
  let mword = expression_map#map#get_map_word()

  if (mword !~ '\v^\d+$' && mword != '')
    return ''
  endif

  let space = ''
  if (getline('.') =~ '^\s*' . mword . '$' &&
     \ get(g:_, mword, '') != '' &&
     \ get(g:_, mword, '') !~ '[[:cntrl:]]')
    let space = ' '
  endif

  if (mword <= 0)
    call expression_map#map#remove_map_word()
    return '=get(_, 0, "") . "' . space . '"'
  else
    call expression_map#map#remove_map_word()
    return '=get(_, ' . mword . ', "") . "' . space . '"'
  endif
endfunction
imap <M--> =<SID>Exp_Map_M_()
"-------------------------------------------------------------------------------
"-------------------------------------------------------------------------------
