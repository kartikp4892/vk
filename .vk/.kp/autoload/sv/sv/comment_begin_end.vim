" TODO: don't hang if begin-end pair do not found
set lz
" line => [comment1, ...]
let s:end_comments = {}

let s:keyword_list = ['if', 'else', 'else if', 'for', 'while', 'foreach', 'forever']

" Configure comment type
let s:multiple_comment_line = 0
let s:delete_next_line_coment = 0
let s:add_condition_to_else = 1
let s:add_blank_ln_after_end_comment = 0
" use label instead of condition if exist
let s:use_label_if_exist = 0

let s:if_keyword = '\(else\s\+\)\@<!if'
let s:else_keyword = '\<else\(\s\+if\)\@!'

"-------------------------------------------------------------------------------
" SearchBegin: Function
"-------------------------------------------------------------------------------
" @param keyword: keyword for which to search start of pair. Eg. for () begin -> keyword is 'for'
function! sv#sv#comment_begin_end#SearchBegin(keyword)

  if (a:keyword == 'for')
    let l:start_begin = search('\<' . a:keyword . '\>\s*(\_.\{-})\_s*\<begin\>', 'W')
    let l:begin_ptrn = '\>\s*(\_.\{-})\_s*\<begin\>'
  else
    let l:start_begin = search('\<' . a:keyword . '\>\_[^;{]\{-1,}\<begin\>', 'W')
    let l:begin_ptrn = '\>\_[^;]\{-1,}\<begin\>'
  endif

  if (l:start_begin == 0)
    return 1
  endif

  let l:start_end = search('\<begin\>', 'nW')
  let l:lines = getline(l:start_begin , l:start_end)
  call map(l:lines , 'substitute(v:val, "\\/\\/.*", "", "g")')
  let l:line = join(l:lines , "\n")
  if (l:line =~ '\<' . a:keyword . l:begin_ptrn)
    if (l:line =~ '\<end\>')
      " If begin-end are at same line
      return 0
    endif
    call map(l:lines, 'substitute(v:val, "\\<begin\\>", "", "g")')
    call map(l:lines, 'substitute(v:val, "^\\s\\+\\|\\s\\+$", "", "g")')

    if (s:use_label_if_exist == 1)
      if (l:lines[0] =~ '\w\+\s*:\s*' . a:keyword)
        let l:lines[0] = matchstr(l:lines[0], '\w\+\ze\s*:')
      else
        " use label instead of condition
        let l:lines[0] = substitute(l:lines[0] , '.\{-}\ze\<' . a:keyword . '\>', '', '')
      endif
    else
      " use condition instead of label
      let l:lines[0] = substitute(l:lines[0] , '.\{-}\ze\<' . a:keyword . '\>', '', 'g')
    endif

    if (s:add_condition_to_else == 1)
      " if "else" keyword than add the condition for "if" for which "else" belongs to
      if (a:keyword == s:else_keyword)
        let l:lines[0] .= sv#sv#comment_begin_end#GetElseCondition()
      endif
    endif

    " Search for pair
    call search('\<begin\>', 'W')
    let l:end = searchpair('\v%(\/\/.*)@<!<begin>', '', '\v%(\/\/.*)@<!<end>', 'nW', 'getline(".") =~ "\".\\{-}\\%(\\<begin\\>\\|\\<end\\>\\)\""')
    if (l:end == 0)
      return 0
    else
      let l:end_line = substitute(getline(l:end), '\s*\/\/.*', '', '')
      let l:end_line = substitute(l:end_line , '^\s\+\|\s\+$', '', 'g')
      if (l:end_line != 'end')
        return 0
      endif
    endif
    let s:end_comments[l:end] = l:lines
  endif
  return 0
endfunction

"-------------------------------------------------------------------------------
" GetBeginEndPairs: Function
"-------------------------------------------------------------------------------
" @param a:1 : keywords list
function! sv#sv#comment_begin_end#GetBeginEndPairs(...)
  let l:save_view = winsaveview()
  if (a:0 == 0)
    return
  elseif a:1[0] == 'all'
    let l:keyword_list = s:keyword_list
  else
    let l:keyword_list = deepcopy(a:1)
  endif

  " If user wants if to be commented
  let l:idx = index(l:keyword_list, 'if')
  if (l:idx != -1)
    let l:keyword_list[l:idx] = s:if_keyword
  endif

  " If user wants else to be commented
  let l:idx = index(l:keyword_list, 'else')
  if (l:idx != -1)
    let l:keyword_list[l:idx] = s:else_keyword
  endif

  let s:end_comments = {}
  for l:i in l:keyword_list
    0
    let l:is_last = 0
    while line(".") <= line("$") && l:is_last == 0
      let l:is_last = sv#sv#comment_begin_end#SearchBegin(l:i)
    endwhile
  endfor
  call winrestview(l:save_view)
endfunction

"-------------------------------------------------------------------------------
" SetBeginEndPairs: Function
"-------------------------------------------------------------------------------
" @param a:1, a:2, ... : keywords list
function! sv#sv#comment_begin_end#SetBeginEndPairs(...)
  " Get comments to end for begin-end pair
  call sv#sv#comment_begin_end#GetBeginEndPairs(a:000)
  let l:save_view = winsaveview()
  let l:offset = 0

  " sort after adding padding zeros for correct sorting and remove padding zero from sorted array
  let l:sort_keys = map(sort(map(keys(s:end_comments), 'printf("%06d", v:val)')), 'substitute(v:val, "^0\\+", "", "")')

  for l:ln in l:sort_keys
    let l:act_ln = l:ln + l:offset
    let l:line = getline(l:act_ln)
    let l:pre_indent = match(l:line, '//')
    let l:tmp_ln = l:act_ln + 1

    if (s:delete_next_line_coment == 1)
      while getline(l:tmp_ln) =~ '^\s*//'
        if (indent(l:tmp_ln) != l:pre_indent)
          break
        else
          exe l:tmp_ln . 'd'
          let l:offset -= 1
        endif
      endwhile
    endif

    let l:line = substitute(l:line , '\s*\/\/.*\|\s\+$', '', 'g')
    let l:comments = deepcopy(s:end_comments)[l:ln]
    " remove commented line within the condition
    call filter(l:comments, 'v:val !~ "^\\s*\\$"')
    " remove blank lines within the condition
    call filter(l:comments, 'v:val !~ "^\\s*$"')
    let l:cur_comment = remove(l:comments, 0)

    " If only one line of condition is used then remove use only single space in comment
    if (s:multiple_comment_line == 0)
      let l:cur_comment = substitute(l:cur_comment , '\s\+', ' ', 'g')
    endif

    " The index of start of condition of if
    let l:condition_off = match(l:cur_comment , 'if\s*\zs')
    call setline(l:act_ln, l:line . ' // ' . l:cur_comment)
    let l:tmp_ln = l:act_ln

    if (s:multiple_comment_line == 1)
      while len(l:comments)
        let l:cur_comment = remove(l:comments, 0)
        let l:pre_indent = match(getline(l:act_ln), '//')
        call append(l:tmp_ln, repeat(" ", l:pre_indent) . '// ' . repeat(" ", l:condition_off + 1) . l:cur_comment)
        let l:tmp_ln += 1
        let l:offset += 1
      endwhile
    else
      if (len(l:comments) >= 1)
        call setline(l:act_ln, getline(l:act_ln) . '...')
      endif
    endif

    if (s:add_blank_ln_after_end_comment == 1)
      " add blank line after comment if not present
      if (getline(l:tmp_ln + 1) !~ '^\s*$')
        call append(l:tmp_ln, '')
        let l:offset += 1
      endif
    endif

  endfor
  call winrestview(l:save_view)
endfunction

"-------------------------------------------------------------------------------
" GetElseCondition: Function
"-------------------------------------------------------------------------------
function! sv#sv#comment_begin_end#GetElseCondition()
  let l:save_cursor = getpos(".")
  let l:found_if = 0
  let l:if_condition = ''
  while l:found_if == 0 && line(".") > 1
    exe line(".") - 1
    let l:line = getline(".")
    " Remove comment from line
    let l:line = substitute(l:line , '\/\/.*', '', 'g')
    if (l:line =~ '\v<end>')
      let l:col_no = match(l:line, '\<end\>') + 1
      exe 'normal ' . l:col_no . '|'
      if searchpair('\v%(\/\/.*)@<!<begin>', '', '\v%(\/\/.*)@<!<end>', 'bW', 'getline(".") =~ "\".\\{-}\\%(\\<begin\\>\\|\\<end\\>\\)\""') == 0
        "let l:if_condition = 'FIXME'
        break
      endif
      exe line(".") + 1
    elseif (l:line =~ '\v%(\/\/.*|else\s+)@<!<if>')
      let l:found_if = 1
      let l:if_condition = matchstr(l:line, '\v%(else\s+)@<!<if>\s*\zs.*')
      if (l:if_condition =~ '\s*\<begin\>.*')
        let l:if_condition = substitute(l:if_condition, '\s*\<begin\>.*', '', '')
      else
        let l:is_if_wid_beg = search('\%' . line(".") . 'l\%' . col(".") . 'c\<if\>\_[^;]\{-1,}\<begin\>')
        let l:if_condition = substitute(l:if_condition, '\s\+$', '', '')
        if (l:is_if_wid_beg != 0)
          let l:if_condition .= "..."
        endif
      endif
    endif
  endwhile
  call setpos(".", l:save_cursor)
  let l:if_condition = substitute(l:if_condition , '\s\+', ' ', 'g')
  let l:if_condition = " " . l:if_condition
  return l:if_condition
endfunction
