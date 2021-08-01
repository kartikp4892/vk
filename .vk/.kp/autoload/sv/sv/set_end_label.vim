let s:end_label_dict = {}
let s:begin_name_list = ['class', 'function', 'task']
"-------------------------------------------------------------------------------
" GetEnd: Function
"-------------------------------------------------------------------------------
function! sv#sv#set_end_label#GetEnd(begin_name)
  let label_name = ''
  if (search('^[[:alnum:]_ ]*\zs\<' . a:begin_name . '\>', 'W'))
    if (a:begin_name == 'class')
      let label_name = matchstr(getline("."), 'class\_s\+\zs\w\+')
    elseif (a:begin_name == 'function' || a:begin_name == 'task')
      " If function or task is extern then ignore
      if (getline(".") =~ '\<extern\>')
        return
      endif
      let save_pos = getpos(".")
      if (!search('\w\+\_s*('))
        call setpos(".", save_pos)
        return
      else
        let label_name = expand("<cword>")
      endif
      call setpos(".", save_pos)
    else
      " FIXME
      return
    endif
    if (label_name == '')
      return
    endif
    let skip_expr = '"[^"]\{-}\(\<' . a:begin_name . '\>\|\<end' . a:begin_name . '\>\)"'
    let skip_expr = escape(skip_expr, '\"')
    let ln = searchpair('^[[:alnum:]_ ]*\<' . a:begin_name . '\>', '', '^[[:alnum:]_ ]*\<end' . a:begin_name . '\>', 'nW',
                      \ 'getline(".") =~ "' . skip_expr . '"')
    if (ln == 0)
      echohl Error
      echo "Pair for " . a:begin_name . " not found"
      echohl None
    endif
    let line = getline(ln)
    let line = substitute(line, '\s*\/\/.*', '', 'g')
    let line = substitute(line, '\s*:.*', '', 'g')
    let line .= " : " . label_name
    let s:end_label_dict[ln] = line
  else
    return -1
  endif
endfunction

"-------------------------------------------------------------------------------
" GetAllEnd: Function
"-------------------------------------------------------------------------------
function! sv#sv#set_end_label#GetAllEnd(begin_name)
  0
  let s:end_label_dict = {}
  while sv#sv#set_end_label#GetEnd(a:begin_name) != -1
    call sv#sv#set_end_label#GetEnd(a:begin_name)
  endwhile
endfunction

"-------------------------------------------------------------------------------
" SetAllEnd: Function
"-------------------------------------------------------------------------------
function! sv#sv#set_end_label#SetAllEnd(begin_name)
  let save_view = winsaveview()
  call sv#sv#set_end_label#GetAllEnd(a:begin_name)
  for [ln, line] in items(s:end_label_dict)
    call setline(ln, line)
  endfor
  call winrestview(save_view)
endfunction

"-------------------------------------------------------------------------------
" SetAllListEnd: Function
"-------------------------------------------------------------------------------
function! sv#sv#set_end_label#SetListEnd(...)
  if (a:0 == 0)
    return
  endif
  
  if (a:1 == 'all')
    let begin_list = s:begin_name_list
  else
    let begin_list = a:000
  endif
  for l:i in begin_list
    call sv#sv#set_end_label#SetAllEnd(l:i)
  endfor
endfunction
