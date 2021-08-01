"-------------------------------------------------------------------------------
" s:GetTemplete: Function
"-------------------------------------------------------------------------------
function! s:GetTemplete(char, ...)
  return common#mov_thru_user_mark#get_template(a:char, a:000)
endfunction

"-------------------------------------------------------------------------------
" _set_indent: Function
"-------------------------------------------------------------------------------
function! s:_set_indent(offset)
  return '=common#indent#imode_set_indent(' . a:offset . ')'
endfunction

"-------------------------------------------------------------------------------
" Function : foreach
"-------------------------------------------------------------------------------
function! python#python#foreach()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'var')
  endif
  let listname = s:GetTemplete('2', 'list')

  let str = 'for ' . var . ' in maa' . listname . ':' .
           \ s:_set_indent(&shiftwidth) . '`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : function
"-------------------------------------------------------------------------------
function! python#python#function()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  let str = 'def ' . var . ' (maa):' .
           \ s:_set_indent(&shiftwidth) . '`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : while
"-------------------------------------------------------------------------------
function! python#python#while()

  let str = 'while maa:' .
           \ s:_set_indent(&shiftwidth) . '`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : if
"-------------------------------------------------------------------------------
function! python#python#if()
  let str = 'if maa:' .
    \ s:_set_indent(&shiftwidth) . '`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : elif
"-------------------------------------------------------------------------------
function! python#python#elif()
  let str = 'elif maa:' .
    \ s:_set_indent(&shiftwidth) . '`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : else
"-------------------------------------------------------------------------------
function! python#python#else()
  let str = 'else:' .
    \ s:_set_indent(&shiftwidth)

  return str
endfunction


"-------------------------------------------------------------------------------
" Function : try_except
"-------------------------------------------------------------------------------
function! python#python#try_except()
  let str = 'try:' .
    \ s:_set_indent(&shiftwidth) . 'maa' .
    \ s:_set_indent(-&shiftwidth) . 'except Error:' .
    \ s:_set_indent(&shiftwidth) . s:GetTemplete('a', 'mark') . '`aa'

  return str
endfunction




