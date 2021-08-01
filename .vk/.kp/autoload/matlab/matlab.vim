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
" get_default_name: Function
"-------------------------------------------------------------------------------
function! s:get_default_name()
  let name = expand('%:p:t')
  let name = substitute(name, '\v\.\w+$', '', '')
  return name
endfunction

" Insert text at the begning of the file if text is not found in the file.
function! s:_insert_if_not_exists(text)
  if (search(a:text, 'bn') == 0)
    let saveview = winsaveview()
    call append(0, a:text)
    " Added line so adjust lnum 
    let saveview['lnum'] += 1
    call winrestview(saveview)
  endif
endfunction

function! matlab#matlab#if()
  let str = 'if ( maa ) '
  let str .= s:_set_indent(&shiftwidth) . ''
  let str .= s:_set_indent(0) . 'end`aa'

  return str
endfunction

function! matlab#matlab#else()
  let str = 'else '
  let str .= s:_set_indent(&shiftwidth) . ''

  return str
endfunction

function! matlab#matlab#elseif()
  let str = 'elseif ( maa ) '
  let str .= s:_set_indent(&shiftwidth) . '`aa'

  return str
endfunction

function! matlab#matlab#switch()
  let str = 'switch ( maa ) '
  let str .= s:_set_indent(&shiftwidth) . printf('case %s,', s:GetTemplete('a', 'value'))
  let str .= s:_set_indent(&shiftwidth) . printf('mba%s', s:GetTemplete('a', 'stmt'))
  let str .= s:_set_indent(-&shiftwidth) . 'otherwise'
  let str .= s:_set_indent(&shiftwidth) . printf('mba%s', s:GetTemplete('a', 'defaultstmt'))
  let str .= s:_set_indent(-2 * &shiftwidth) . 'end`aa'

  return str
endfunction

function! matlab#matlab#for()
  let str = 'for ( maa ) '
  let str .= s:_set_indent(&shiftwidth) . ''
  let str .= s:_set_indent(0) . 'end`aa'

  return str
endfunction

function! matlab#matlab#while()
  let str = 'while ( maa ) '
  let str .= s:_set_indent(&shiftwidth) . ''
  let str .= s:_set_indent(0) . 'end`aa'

  return str
endfunction

function! matlab#matlab#try_catch()
  let str = 'try'
  let str .= s:_set_indent(&shiftwidth) . 'maa'
  let str .= s:_set_indent(0) . 'catch'
  let str .= s:_set_indent(&shiftwidth) . ''
  let str .= s:_set_indent(0) . 'end`aa'

  return str
endfunction

function! matlab#matlab#function()
  let name = matchstr(getline("."), '\w\+')
  call setline(line("."), repeat(" ", indent(".")))

  if (name == '')
    let name = s:get_default_name()
  endif

  let str = printf('function maa%s = %s(%s)', s:GetTemplete('a', 'outargs'), name, s:GetTemplete('a', 'inargs'))
  let str .= s:_set_indent(&shiftwidth) . printf('%% %s', name)
  let str .= s:_set_indent(0) . ''
  let str .= s:_set_indent(-&shiftwidth) . 'end`aa'

  return str
endfunction

function! matlab#matlab#anonymous_function()
  let name = matchstr(getline("."), '\w\+')
  call setline(line("."), repeat(" ", indent(".")))

  if (name == '')
    let name = s:GetTemplete('a', 'name')
  endif

  let str = printf('%s = @(maa%s) (%s)`aa', name, s:GetTemplete('a', 'inargs'), s:GetTemplete('a', 'expression'))

  return str
endfunction

function! matlab#matlab#block_comment()
  let str = '%**********************************************************************'
  let str .= s:_set_indent(0) . '% maa'
  let str .= s:_set_indent(0) . '%**********************************************************************`aa'

  return str
endfunction



