if (!has('gui_running'))
  finish
endif

" ###########################################################################
" Copy and paste
" ###########################################################################
set ballooneval
set balloonexpr=''
set balloondelay=0

let s:save_col = ''
let s:save_lnum = ''
let s:save_winnr = ''
let s:save_line = ''
let s:line_start = ''

" ###########################################################################
" copy from mouse
" ###########################################################################
fun! s:Kp_get_keyword()
  
  if (&filetype == 'perl')
    let s:keyword1 = '\v%(\w|%([@$%]%(\w)@=)|%(\w@<=-\>)|%(-\>)@<=[[{(])'
    let s:non_keyword1 = '\v%(%(\w|%([@$%]%(\w)@=)|%(\w@<=-\>)|%(-\>)@<=[[{(])@!.)'
    let s:keyword2 = '\v[^ ]'
    let s:non_keyword2 = '\v\s'
  elseif (&filetype == 'sv')
    let s:keyword1 = '\v%(\w|%([$`]%(\w)@=)|%(\d@<=''\w))'
    let s:non_keyword1 = '\v%(%(\w|%([$`]%(\w)@=)|%(\d@<=''\w))@!.)'
    let s:keyword2 = '\v[^ ]'
    let s:non_keyword2 = '\v\s'
  elseif (&filetype == 'vim')
    let s:keyword1 = '\v[[:alnum:]_:]'
    let s:non_keyword1 = '\v[^[:alnum:]_:]'
    let s:keyword2 = '\v[^ ]'
    let s:non_keyword2 = '\v\s'
  elseif (&filetype == 'php')
    let s:keyword1 = '\v%(\w|%([$]%(\w)@=))'
    let s:non_keyword1 = '\v%(%(\w|%([@$%]%(\w)@=))@!.)'
    let s:keyword2 = '\v[^ ]'
    let s:non_keyword2 = '\v\s'
  elseif (&filetype == 'tcsh' || &filetype == 'sh')
    let s:keyword1 = '\v%(\w|%([$]%(\w|\{)@=)|%([$]@<=\{)|%(%(\$\{[[:alnum:]:-=]+)@<=\})|%(%(\$\{[[:alnum:]]+)@<=[:])|%(%(\$\{[[:alnum:]:]+)@<=[-=]))'
    let s:non_keyword1 = '\v%(%(\w|%([$]%(\w|\{)@=)|%([$]@<=\{)|%(%(\$\{[[:alnum:]:-=]+)@<=\})|%(%(\$\{[[:alnum:]]+)@<=[:])|%(%(\$\{[[:alnum:]:]+)@<=[-=]))@!.)'
    let s:keyword2 = '\v[^ ]'
    let s:non_keyword2 = '\v\s'
  else " Default
    let s:keyword1 = '\v\w'
    let s:non_keyword1 = '\v\W'
    let s:keyword2 = '\v[^ ]'
    let s:non_keyword2 = '\v\s'
  endif

  let s:word_expr = s:keyword1
  let s:non_word_expr = s:non_keyword1

  let s:Word_expr = s:keyword2
  let s:non_Word_expr = s:non_keyword2

endfun

fun! s:Kp_copy_expr_under_mouse(type) " type : 'w'/'W'
  
  let l:save_ic = &ic
  set noic
  call s:Kp_get_keyword()

  let l:mouse_col = v:beval_col
  let l:mouse_lnum = v:beval_lnum
  let l:mouse_winnr = v:beval_winnr + 1

  let l:bufnum = winbufnr(l:mouse_winnr)

  let l:old_win = winnr()
  let l:old_pos = getpos('.')

  " exe l:mouse_winnr . 'wincmd w'
  
  if (l:mouse_col != s:save_col) ||
    \(l:mouse_lnum != s:save_lnum) ||
    \(l:mouse_winnr != s:save_winnr)
    let s:save_line = s:Kp_getline(l:bufnum, l:mouse_lnum, l:mouse_col, a:type)
  endif
  if (a:type == 'w')
    if (match(s:save_line, s:word_expr) == 0)
      let l:ret_val = matchstr(s:save_line, s:word_expr . '+\s*')
    else
      let l:ret_val = matchstr(s:save_line, s:non_word_expr . '+\s*')
    endif
  elseif (a:type == 'W')
    if (match(s:save_line, s:non_Word_expr) == 0)
      let l:ret_val = matchstr(s:save_line, s:non_Word_expr . '+\s*')
    else
      let l:ret_val = matchstr(s:save_line, s:Word_expr . '+\s*')
    endif
  else
    return ''
  endif
  let s:save_line = s:Kp_strpart(s:save_line, l:ret_val)
  
  " exe l:old_win . 'wincmd w'
  " call setpos('.', l:old_pos)
  
  let s:save_col = l:mouse_col
  let s:save_lnum = l:mouse_lnum
  let s:save_winnr = l:mouse_winnr
  let &ic = l:save_ic

  return l:ret_val
endfun

fun! s:Kp_getline(bufnum, line, col, type)
  let l:ret_val = ''
  let l:pos = a:col
  let l:line = getbufline(a:bufnum, a:line)[0]
  " call cursor(a:line, a:col)
  if (a:type == 'w')
    if (match(l:line, s:word_expr, l:pos - 1) == l:pos - 1)
      while (match(l:line, s:word_expr, l:pos - 1) == l:pos - 1)
        let l:pos -= 1
      endwhile
    else
      while (match(l:line, s:non_word_expr, l:pos - 1) == l:pos - 1)
        let l:pos -= 1
      endwhile
    endif
  elseif (a:type == 'W')
    if (match(l:line, s:non_Word_expr, l:pos - 1) == l:pos - 1)
      while (match(l:line, s:non_Word_expr, l:pos - 1) == l:pos - 1)
        let l:pos -= 1
      endwhile
    else
      while (match(l:line, s:Word_expr, l:pos - 1) == l:pos - 1)
        let l:pos -= 1
      endwhile
    endif
  else
   return ''
  endif
  if (l:pos == 0)
    let l:ret_val = l:line
  elseif (l:pos > 0)
    let l:ret_val = matchstr(l:line, '.*', l:pos)
  endif
  return l:ret_val
endfun

fun! s:Kp_strpart(str, expr)
  "return strpart(a:str, matchend(a:str, a:expr))
  return strpart(a:str, strlen(a:expr))
endfun

fun! s:Kp_copy_line_under_mouse(type)
  let l:mouse_col = v:beval_col
  let l:mouse_lnum = v:beval_lnum
  let l:mouse_winnr = v:beval_winnr + 1
  let l:bufnum = winbufnr(l:mouse_winnr)
  let l:line = ''

  let s:old_winnr = winnr()
  let s:old_pos = getpos(".")
  
  " exe l:mouse_winnr . "wincmd w"

  " A Line
  if (a:type == 'l')
    
    let l:line = substitute(getbufline(l:bufnum, l:mouse_lnum)[0], '^\s*', '', '')

  " current column to the end of the line
  elseif (a:type == '$')

    let l:line = matchstr(getbufline(l:bufnum, l:mouse_lnum)[0], '.*$', l:mouse_col - 1)

  endif

  " exe s:old_winnr . "wincmd w"
  " call setpos(".", s:old_pos)

  return l:line

endfun

fun! s:Kp_copy_lines_under_mouse()
  
  let l:mouse_col = v:beval_col
  let l:mouse_lnum = v:beval_lnum
  let l:mouse_winnr = v:beval_winnr + 1

  let l:old_win = winnr()
  let l:old_pos = getpos('.')

  exe l:mouse_winnr . 'wincmd w'
  
  if (l:mouse_col != s:save_col) ||
    \(l:mouse_lnum != s:save_lnum) ||
    \(l:mouse_winnr != s:save_winnr)
    let s:line_start = l:mouse_lnum
  endif

  let l:ret_val = substitute(getline(s:line_start), '^\s*', '', '') . ''
  let s:line_start = s:line_start + 1

  exe l:old_win . 'wincmd w'
  call setpos('.', l:old_pos)
  
  let s:save_col = l:mouse_col
  let s:save_lnum = l:mouse_lnum
  let s:save_winnr = l:mouse_winnr

  return l:ret_val
endfun

" ###########################################################################
" Copy from keyboard
" ###########################################################################
" ----------------------------------------------------------------------

fun! s:Kp_blank(expr)
  return substitute(a:expr, '.', " ", "g")
endfun

fun! s:Kp_get_word(expr, line, col, blank)
  let l:word = matchstr(getline(a:line), a:expr , a:col)
  if (a:blank == 1)
    let l:word = s:Kp_blank(l:word)
  endif
  return l:word
endfun

fun! s:Kp_copy_from_above(blank, ...)
  if (a:0 != 0 && a:1 == "line")
    return s:Kp_get_word('.*', line(".") - 1, col(".") - 1, a:blank)
  endif

  if (a:0 == 0)
    let expr = 'word'
  else
    let expr = a:1
  endif

  if (expr == 'word')
    if (s:Kp_get_word(".", line(".") - 1, col(".") - 1, 0) =~ '\s')
      return s:Kp_get_word('\v\s+', line(".") - 1, col(".") - 1, a:blank)
    elseif (s:Kp_get_word(".", line(".") - 1, col(".") - 1, 0) =~ '\W')
      return s:Kp_get_word('\v\W+\s*', line(".") - 1, col(".") - 1, a:blank)
    else
      return s:Kp_get_word('\v\w+\s*', line(".") - 1, col(".") - 1, a:blank)
    endif
  elseif (expr == 'Word')
    if (s:Kp_get_word(".", line(".") - 1, col(".") - 1, 0) =~ ' ')
      return s:Kp_get_word('\v\s+', line(".") - 1, col(".") - 1, a:blank)
    else
      return s:Kp_get_word('\v[^ ]+\s*', line(".") - 1, col(".") - 1, a:blank)
    endif
  elseif (expr == "line")
    return s:Kp_get_word('.*', line(".") - 1, col(".") - 1, a:blank)
  endif
endfun
" ----------------------------------------------------------------------

" ======================================================================

"-------------------------------------------------------------------------------
" s:VisualMap: Function
"-------------------------------------------------------------------------------
function! s:VisualMap()
  if (mode() =~ "s\|S\|\<c-s>")
    normal s
  else
    normal s
  endif
endfunction

"----------------------------------------------------------------------------
" initially mapping are using keyboard
imap  =<SID>Kp_copy_expr_under_mouse('w')
imap  =<SID>Kp_copy_expr_under_mouse('W')
inoremap  =<SID>Kp_copy_line_under_mouse("$")
inoremap  =<SID>Kp_copy_line_under_mouse('l')
" Command line mapping
cmap  =<SID>Kp_copy_expr_under_mouse('w')
cmap  =<SID>Kp_copy_expr_under_mouse('W')
cnoremap  =<SID>Kp_copy_line_under_mouse("$")
cnoremap  =<SID>Kp_copy_line_under_mouse('l')
" Visual mapping
vmap  gvs=<SID>Kp_copy_expr_under_mouse('w')
vmap  gvs=<SID>Kp_copy_expr_under_mouse('W')
vnoremap  gvs=<SID>Kp_copy_line_under_mouse("$")
vnoremap  gvs=<SID>Kp_copy_line_under_mouse('l')
" ===================
nnoremap  a=<SID>Kp_copy_from_above(0)
nnoremap  a=<SID>Kp_copy_from_above(1)
nnoremap  a=<SID>Kp_copy_from_above(0, "line")
inoremap <C-M-z> =<SID>Kp_copy_from_above(0)
inoremap <C-M-s> =<SID>Kp_copy_from_above(0, "Word")
"----------------------------------------------------------------------------

vnoremap <C-RightMouse> ygi"
inoremap  =<SID>Kp_copy_lines_under_mouse()


" ###########################################################################
" Remove leading White Spaces
" ###########################################################################
fun! Kp_remove_leading_spaces()
  perldo $_ =~ s/\s+$//
endfun

imap  :call Kp_remove_leading_spaces()a
