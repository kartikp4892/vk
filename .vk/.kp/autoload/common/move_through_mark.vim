let s:curr_mark = "'a"
let s:curr_pos = getpos(s:curr_mark)

fun! common#move_through_mark#next_mark(delay) " delay number of characters after mark
  if (char2nr(s:curr_mark[1]) < 122)
    let s:curr_mark = "'" . nr2char(char2nr(s:curr_mark[1]) + 1)
  else
    let s:curr_mark = "'a"
  endif

  let s:curr_pos = getpos(s:curr_mark)
  let s:curr_pos[2] += a:delay
  call setpos('.', s:curr_pos)
  return ''
endfun

fun! common#move_through_mark#prev_mark(delay)
  if (char2nr(s:curr_mark[1]) > 97)
    let s:curr_mark = "'" . nr2char(char2nr(s:curr_mark[1]) - 1)
  else
    let s:curr_mark = "'z"
  endif
  let s:curr_pos = getpos(s:curr_mark)
  let s:curr_pos[2] += a:delay
  call setpos('.', s:curr_pos)
  return ''
endfun

fun! common#move_through_mark#1st_mark(delay)
  let s:curr_mark = "'a"
  let s:curr_pos = getpos(s:curr_mark)
  let s:curr_pos[2] += a:delay
  call setpos('.', s:curr_pos)
  return ''
endfun

