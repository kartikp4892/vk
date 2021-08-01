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
" Function : object
"-------------------------------------------------------------------------------
function! scala#scala#object()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  let str = comments#block_comment#getComments('Object', name)
  let str .= printf('object %0s {', name) .
           \ s:_set_indent(&shiftwidth) . 'def main(args: Array[String]) {' .
           \ s:_set_indent(&shiftwidth) . 'maa' .
           \ s:_set_indent(0) . '}' .
           \ s:_set_indent(-&shiftwidth) . '}`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : function
"-------------------------------------------------------------------------------
function! scala#scala#function()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  let str = comments#block_comment#getComments('Method', var)
  let str .= printf('def %0s (maa) = {', var) .
           \ s:_set_indent(&shiftwidth) . '' .
            \ s:_set_indent(0) . '}`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : function_returns
"-------------------------------------------------------------------------------
function! scala#scala#function_returns()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  let str = comments#block_comment#getComments('Method', var)
  let str .= printf('def %0s (maa) : %0s = {', var, s:GetTemplete('a', 'returntype')) .
           \ s:_set_indent(&shiftwidth) . '' .
            \ s:_set_indent(0) . '}`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : package
"-------------------------------------------------------------------------------
function! scala#scala#package()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  let str = comments#block_comment#getComments('Method', var)
  let str .= printf('package %0s {', var) .
           \ s:_set_indent(&shiftwidth) . 'maa' .
            \ s:_set_indent(0) . '}`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : if
"-------------------------------------------------------------------------------
function! scala#scala#if()
  let str = 'if (maa) {' .
           \ s:_set_indent(&shiftwidth) . '' .
            \ s:_set_indent(0) . '}`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : else
"-------------------------------------------------------------------------------
function! scala#scala#else()
  let str = 'else {' .
           \ s:_set_indent(&shiftwidth) . 'maa' .
            \ s:_set_indent(0) . '}`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : elseif
"-------------------------------------------------------------------------------
function! scala#scala#elseif()
  let str = 'else if (maa) {' .
           \ s:_set_indent(&shiftwidth) . '' .
            \ s:_set_indent(0) . '}`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : while
"-------------------------------------------------------------------------------
function! scala#scala#while()
  let str = 'while (maa) {' .
           \ s:_set_indent(&shiftwidth) . '' .
            \ s:_set_indent(0) . '}`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : do_while
"-------------------------------------------------------------------------------
function! scala#scala#do_while()
  let str = 'do {' .
           \ s:_set_indent(&shiftwidth) . '' .
            \ s:_set_indent(0) . '} while (maa) `aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : for
"-------------------------------------------------------------------------------
function! scala#scala#for()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'var')
  endif
  let listname = s:GetTemplete('2', 'list')

  let str = printf('for (maa%0s <- %0s) {', var, listname).
           \ s:_set_indent(&shiftwidth) . '' .
            \ s:_set_indent(0) . '}`aa'

  return str
endfunction


