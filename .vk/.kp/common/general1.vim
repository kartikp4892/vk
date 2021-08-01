vmap / /<MiddleMouse><C-M>

"effective copy and paste by mouse
imap <C-LeftMouse> diwma<LeftMouse>"*yiw`aa*
imap <C-RightMouse> <Left><Right>ma<LeftMouse>"*yiw`aa*
imap <C-MiddleMouse> <Left><Right>ma<LeftMouse>"*yiW`aa*

imap <S-MiddleMouse> <Left><Right>ma<LeftMouse>"*ya(`aa*
"imap <S-LeftMouse> <Left><Right>ma<LeftMouse>"*yi(`aa*

" replace the current word with @*
nmap <M-8> ciw*

" replace the current word with @+
nmap <M-=> ciw+

"-------------------------------------------------------------------------------
" get_string_type: Function
function! s:Copy_text_within_str()
  let ln = getline('.')
  let idx = col('.') - 1
  while idx >= 0 && ln[idx] !~ '[''"]'
    let idx -= 1
  endwhile
  if (idx >= 0)
    exe 'normal "ayi' . ln[idx] . 'gia'
  else
    normal gi
  endif
endfunction

function! s:Copy_text_within_brace()
  let ln = getline('.')
  let idx = col('.') - 1
  while idx >= 0 && ln[idx] !~ '[({[]'
    let idx -= 1
  endwhile
  if (idx >= 0)
    exe 'normal "ayi' . ln[idx] . 'gia'
  else
    normal gi
  endif
endfunction

nmap <S-RightMouse> <LeftMouse>:call <SID>Copy_text_within_str()gi
imap <S-RightMouse> <LeftMouse>:call <SID>Copy_text_within_str()gi

nmap <S-LeftMouse> <LeftMouse>:call <SID>Copy_text_within_brace()gi
imap <S-LeftMouse> <LeftMouse>:call <SID>Copy_text_within_brace()gi
"-------------------------------------------------------------------------------

nmap \\ :echo 0x
imap <M-9> ()<Left>
imap <M-'> ''<Left>
imap <M-"> ""<Left>
" imap ç¹ (  ma)`a

"inser '' to the std_logic
nmap \' diwi'"'
nmap \" diwi"""
nmap \( diwi(")%
vmap \' s'*'
vmap \" s"*"
vmap \( s(*)
" add convert FIXME to *** FIXME ***
" nmap \* diwi *** " ***

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"to substitute the word under cursor(whole word) globally
nmap \s "*yiw:%s/\<<MiddleMouse>\>//gc<Left><Left><Left>

"to substitute the word under cursor(partially) globally
nmap \S "*yiW:%s/<MiddleMouse>//gc<Left><Left><Left>

"to substitute the hilited text in visual mode globally
vmap \s "*y:%s/<MiddleMouse>//gc<Left><Left><Left>
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"to globle the word under cursor(whole word) globally
nmap \g "*yiw:g/\<<MiddleMouse>\>/

"to globle the word under cursor(partially) globally
nmap \G "*yiW:g/<MiddleMouse>/

"to globle the hilited text in visual mode globally
vmap \g "*y:g/<MiddleMouse>/
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nmap <M-/> /<MiddleMouse><C-M>
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"to globle the word under cursor(whole word) globally with normal
nmap \n "*yiw:g/\<<MiddleMouse>\>/normal 

"to globle the word under cursor(partially) globally with normal
nmap \N "*yiW:g/<MiddleMouse>/normal 

"to globle the hilited text in visual mode globally with normal
vmap \n "*y:g/<MiddleMouse>/normal 
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" nmap \u ma"*yiwHmb :%s/\<<MiddleMouse>\>/\U&/g`bzt`a
" nmap \U ma"*yiWHmb :%s/<MiddleMouse>/\U&/g`bzt`a
" vmap \u ma"*yHmb :%s/<MiddleMouse>/\U&/g`bzt`a
" 
" nmap \l ma"*yiwHmb :%s/\<<MiddleMouse>\>/\L&/g`bzt`a
" nmap \L ma"*yiWHmb :%s/<MiddleMouse>/\L&/g`bzt`a
" vmap \l ma"*yHmb :%s/<MiddleMouse>/\L&/g`bzt`a
"=================================================================================

"-------------------------------------------------------------------------------
" Kp_ctrl_L: Function
"-------------------------------------------------------------------------------
function! s:Kp_ctrl_L()
  let [start, end, templete] = common#mov_thru_user_mark#get_cursor_mark()
  if (templete != "")
    let save_cursor = getpos(".")
    let pos1 = searchpos(templete, 'w')
    let pos2 = searchpos(templete, 'w')
    call setpos(".", save_cursor)

    " If found multiple matches
    if (pos1 != pos2)
      return ":%s/" . templete . "//gc\<Left>\<Left>\<Left>"
    else
      return common#mov_thru_user_mark#delete_cursor_mark()
    endif
  else
    return s:Kp_indent_up()
  endif
endfunction

"Get one indent level up
" if the current line is empty indent up else move the cursor to the end
fun! s:Kp_indent_up()
  if (getline(".") =~ '^\s*$')
    call setline(".", '')
    let l:indent = matchstr(getline(line(".") - 1), '^\s*')
    "let l:indent = strpart(l:indent, 0, strlen(l:indent) - strlen(getline(".")))
    return l:indent . "  "
  else
    return 'A'
  endif
endfun

imap  =<SID>Kp_ctrl_L()<C-M>
nmap  a=<SID>Kp_ctrl_L()<C-M>

