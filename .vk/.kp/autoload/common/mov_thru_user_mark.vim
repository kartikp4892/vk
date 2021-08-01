
let s:markbegin = '<+'
let s:markend = '+>'
let s:last_mark = '.'

exe 'match Search "' . s:markbegin . '\w+.\{-}' . s:markend . '"'

" If the current cursor is within the templete format ##SOME TEXT##
" let s:templete_ptrn = '\v(##[A-Z ]*%#[A-Z ]*##)'

let s:comment_begin = comments#variables#comment_begin

"-------------------------------------------------------------------------------
" get_template: Function
" get_template(char, ?text)
"-------------------------------------------------------------------------------
function! common#mov_thru_user_mark#get_template(char, ...)

  let text = ''
  if (a:0 != 0)
    if (type(a:1) == type([]))
      if (!empty(a:1))
        let text = a:1[0]
      endif
    else
      let text = a:1
    endif
  endif

  return s:markbegin . a:char . '+' . text . s:markend
endfunction

"-------------------------------------------------------------------------------
" delete_mark: Function
" Delete the mark if exists
"-------------------------------------------------------------------------------
function! common#mov_thru_user_mark#delete_mark(char)
  let markptrn = s:markbegin . a:char . '+.\{-}' . s:markend
  let save_pos = getpos('.')
  while (search(markptrn))
    if (line('.') < save_pos[1])
      let save_pos[1] -= 1
    endif
    d
  endwhile
  call setpos('.', save_pos)
endfunction

"-------------------------------------------------------------------------------
" set_mark: Function
" Appent mark to the above line
"-------------------------------------------------------------------------------
function! common#mov_thru_user_mark#set_mark(char)
  let markname = common#mov_thru_user_mark#get_template(a:char)

  let markline = repeat(' ', indent(line('.'))) . s:comment_begin . ' ' . markname
  call append(line('.') - 1, markline)

  call common#mov_thru_user_mark#go_to_mark(a:char)
endfunction

"-------------------------------------------------------------------------------
" go_to_mark: Function
" Mark <M-`> refers to the last executed mark used by go_to_mark
"-------------------------------------------------------------------------------
function! common#mov_thru_user_mark#go_to_mark(char)
  if (a:char == "\<M-`>")
    let char = s:last_mark
  else
    let char = a:char
    let s:last_mark = char
  endif
  let markptrn = s:markbegin . char . '+.\{-}' . s:markend
  if (search(markptrn) == 0)
    echohl Error
    echo markptrn . " Mark not found!!!"
    echohl None
  endif
endfunction

"-------------------------------------------------------------------------------
" nmap_alt_m: Function
" Argument: #1: mark character
"-------------------------------------------------------------------------------
function! common#mov_thru_user_mark#nmap_alt_m(...)
  if (exists('a:1'))
    let char = a:1
  else
    echo "Mark Name:"
    let char = nr2char(getchar())
  endif
  if (char =~ '[^a-zA-Z0-9_]')
    echohl Error
    echo "Invalid mark!!!"
    echohl None
    return
  endif

  " delete the old mark if exists
  " call common#mov_thru_user_mark#delete_mark(char)

  call common#mov_thru_user_mark#set_mark(char)
endfunction

"-------------------------------------------------------------------------------
" imap_alt_m: Function
" Argument: #1: mark character
" Argument: #2: message
"-------------------------------------------------------------------------------
function! common#mov_thru_user_mark#imap_alt_m(...)
  if (exists('a:1'))
    let char = a:1
  else
    echo "Mark Name:"
    let char = nr2char(getchar())
  endif

  if (char =~ '[^a-zA-Z0-9_]')
    echohl Error
    echo "Invalid mark!!!"
    echohl None
    return ''
  endif

  if (exists('a:2'))
    let msg = a:2
  else
    let msg = ""
  endif

  let markname = common#mov_thru_user_mark#get_template(char, msg)

  return markname
endfunction

"-------------------------------------------------------------------------------
" get_cursor_mark: Function
" Get the mark templete with format of <+a+text> where a is the mark character
" within current position
"-------------------------------------------------------------------------------
function! common#mov_thru_user_mark#get_cursor_mark()
  let l:line = getline('.')
  let l:start = col('.') - 1
  let l:end = col('.')
  let mapword = ""

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " templete start
  while l:start > 0 &&
       \l:line[l:start : (l:start + 2)] !~ s:markbegin
       " \l:line[(l:start -1)] =~ '["#A-Z ]' " Valid templete words contains --> A-Z, <Space>, double-quote, #

    " If end templete occurs then this is the end of another templete so return
    if (l:line[(l:start - 1) : (l:start + 1)] =~ s:markend &&
       \(col('.') - l:start) > 3)
      let l:start = 0
      break
    endif

    let mapword = l:line[l:start - 1] . mapword
    let l:start -= 1

  endwhile

  if (l:start <= 0 || l:line[l:start : (l:start + 2)] !~ s:markbegin)
    return [0, 0, ""]
  endif
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " templete end
  while l:end <= col('$') + 1 &&
       \l:line[(l:end - 4) : (l:end - 2)] !~ s:markend
       " \l:line[(l:end -1)] =~ '["#A-Z ]'

    " If start templete occurs then this is the start of another templete so return
    if (l:line[(l:end - 3) : (l:end - 1)] =~ s:markbegin && 
       \(l:end - col('.')) > 3)
      let l:end = col('$') + 2
      break
    endif

    let mapword =  mapword . l:line[l:end - 1]
    let l:end += 1

  endwhile

  if (l:end >= col('$') + 2 || l:line[(l:end - 4) : (l:end - 2)] !~ s:markend)
    return [0, 0, ""]
  endif
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  return [l:start + 1, l:end, mapword]
endfunction

"-------------------------------------------------------------------------------
" delete_cursor_mark: Function
"-------------------------------------------------------------------------------
function! common#mov_thru_user_mark#delete_cursor_mark()
  let [start, end, templete] = common#mov_thru_user_mark#get_cursor_mark()

  if (start == 0)
    return ""
  endif

  let save_cursor = getpos('.')
  exe 's/\v%' .  start . 'c.*%' . end . 'c//'

  " Update cursor column
  let save_cursor[2] = end
  let save_cursor[2] -= strlen(templete)
  call setpos(".", save_cursor)
  return ""
endfunction

"<M-`>
"-------------------------------------------------------------------------------
" nmap_alt_tick: Function
"-------------------------------------------------------------------------------
function! common#mov_thru_user_mark#nmap_alt_tick()
  echo "Mark Name:"
  let char = nr2char(getchar())

  if !(char =~ "\\v\\w|\<M-`>|\.")
    echohl Error
    echo "Invalid mark!!!"
    echohl None
    return ''
  endif
  call common#mov_thru_user_mark#go_to_mark(char)

endfunction

"-------------------------------------------------------------------------------
" imap_alt_tick: Function
"-------------------------------------------------------------------------------
function! common#mov_thru_user_mark#imap_alt_tick()
  call common#mov_thru_user_mark#nmap_alt_tick()

  let [start, end, templete] = common#mov_thru_user_mark#get_cursor_mark()
  if (templete == "")
    return ""
  endif

  if (getline(".") =~ '^\s*' . escape(s:comment_begin, '/'))
    let indent = indent(line('.'))
    call append(line('.'), repeat(' ', indent))
    call cursor(line('.') + 1, col('$'))
  else
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
  endif


endfunction



