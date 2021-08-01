"-------------------------------------------------------------------------------
" html: Function
"-------------------------------------------------------------------------------
function! html#htags#paired(tag, attr)
  let l:attr = a:attr
  if (a:attr != '')
    let l:attr = ' ' . l:attr
  endif

  let str = '<' . a:tag . l:attr . '>'
  let str .= "  \<Left>\<Right>maa"
  let str .= '</' . a:tag . '>`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" html: Function
"-------------------------------------------------------------------------------
function! html#htags#single(tag, attr)
  let l:attr = a:attr
  if (a:attr != '')
    let l:attr = ' ' . l:attr
  endif

  let str = '<' . a:tag . l:attr . '>'
  return str
endfunction

"-------------------------------------------------------------------------------
" doctype_html: Function
"-------------------------------------------------------------------------------
function! html#htags#doctype_html()
  let str = '<!DOCTYPE html>'
  let str .= html#htags#paired('html', '')
  let str .= html#htags#paired('body', '')
  return str
endfunction

"-------------------------------------------------------------------------------
" create_tab_multi_line: Function
"-------------------------------------------------------------------------------
function! html#htags#create_tab_multi_line()
  let line_before = strpart(getline("."), 0, col(".") - 1)
  let col_curr = match(line_before, '\w\+\s*$')
  let name = matchstr(line_before, '\w\+\ze\s*$')

  if (col_curr == -1)
    return
  endif
  let col_curr += 1

  let line_after = strpart(getline("."), col("."))
  let line_before = substitute(line_before, '\w\+\s*$', '', '')
  exe 's/\w\+\s*\%' . col('.') . 'c//'
  exe 'normal ' . col_curr . '|'

  let str = html#htags#paired(name, '')
  return str
endfunction

"-------------------------------------------------------------------------------
" create_tab_single_line: Function
"-------------------------------------------------------------------------------
function! html#htags#create_tab_single_line()
  let line_before = strpart(getline("."), 0, col(".") - 1)
  let col_curr = match(line_before, '\w\+\s*$')
  let name = matchstr(line_before, '\w\+\ze\s*$')

  if (col_curr == -1)
    return
  endif
  let col_curr += 1

  let line_after = strpart(getline("."), col("."))
  let line_before = substitute(line_before, '\w\+\s*$', '', '')
  exe 's/\w\+\s*\%' . col('.') . 'c//'
  exe 'normal ' . col_curr . '|'

  let str = '<' . name . '> maa </' . name . '>`aa'
  return str
endfunction
