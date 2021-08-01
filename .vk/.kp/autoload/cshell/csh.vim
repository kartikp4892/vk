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
" lib: Function
"-------------------------------------------------------------------------------
function! cshell#csh#lib()
  let str = '#!/bin/csh'
  return str
endfunction

"-------------------------------------------------------------------------------
" if: Function
"-------------------------------------------------------------------------------
function! cshell#csh#if()
  let str = 'if (maa) then' .
             \  s:_set_indent(&shiftwidth) . '' .
             \ s:_set_indent(0) . 'endif`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" elif: Function
"-------------------------------------------------------------------------------
function! cshell#csh#elif()
  let str = 'else if (maa) then' .
             \  s:_set_indent(&shiftwidth) . '`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" ifelse: Function
"-------------------------------------------------------------------------------
function! cshell#csh#ifelse()
  let str = 'if (maa) then' .
             \  s:_set_indent(&shiftwidth) . '' .
             \ s:_set_indent(0) . 'else' .
             \  s:_set_indent(&shiftwidth) . '' .
             \ s:_set_indent(0) . 'endif`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" foreach: Function
"-------------------------------------------------------------------------------
function! cshell#csh#foreach()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var == '')
    let var = s:GetTemplete('a', 'var')
  endif

  let str = 'foreach ' . var . ' (maa)' .
            \ s:_set_indent(&shiftwidth) . '' .
            \ s:_set_indent(0) . 'end`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" while: Function
"-------------------------------------------------------------------------------
function! cshell#csh#while()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var == '')
    let var = s:GetTemplete('a', 'var')
  endif

  let str = 'while ' . var . ' (maa)' .
            \ s:_set_indent(&shiftwidth) . '' .
            \ s:_set_indent(0) . 'end`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" case: Function
"-------------------------------------------------------------------------------
function! cshell#csh#case()
  let insidesw = searchpair('\v^\s*switch>', '', '\v^\s*endsw>', 'Wbn')
  if (insidesw > 0)
    let str = 'case maa:' .
    \ s:_set_indent(&shiftwidth) . '`aa'
  else
    let str = 'switch (maa)' .
              \ s:_set_indent(0) . printf('case %s:', s:GetTemplete('a', 'str')) .
              \ s:_set_indent(&shiftwidth) . '' .
              \ s:_set_indent(&shiftwidth) . 'breaksw' .
              \ s:_set_indent(-&shiftwidth) . 'default:' .
              \ s:_set_indent(&shiftwidth) . '' .
              \ s:_set_indent(&shiftwidth) . 'breaksw' .
              \ s:_set_indent(-&shiftwidth) . 'endsw`aa'
  endif

  return str
endfunction

"-------------------------------------------------------------------------------
" case: Function
"-------------------------------------------------------------------------------
function! cshell#csh#function()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (name == '')
    let name = s:GetTemplete('a', 'name')
  endif

  let str = printf('%s () {', name) .
            \ s:_set_indent(&shiftwidth) . 'maa' .
            \ s:_set_indent(0) . '}`aa'

  return str
endfunction


