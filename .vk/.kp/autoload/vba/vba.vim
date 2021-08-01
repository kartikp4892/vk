"-------------------------------------------------------------------------------
" function: Function
"-------------------------------------------------------------------------------
function! vba#vba#function()
  if (getline(".") =~ '^\s*\S\+\s*$')
    let l:name = matchstr(getline("."), '\S\+')
    call setline(line("."), substitute(getline("."), '\S\+\s*', '', ''))
  else
    let l:name = input("Function Name: ")
  endif
  let l:str = comments#block_comment#getComments("Function", l:name)
  let l:str .= 'function ' . l:name . '()'
  let l:str .= '  maa'
  let l:str .= 'end function`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" sub: Function
"-------------------------------------------------------------------------------
function! vba#vba#sub()
  if (getline(".") =~ '^\s*\S\+\s*$')
    let l:name = matchstr(getline("."), '\S\+')
    call setline(line("."), substitute(getline("."), '\S\+\s*', '', ''))
  else
    let l:name = input("Sub Name: ")
  endif
  let l:str = comments#block_comment#getComments("Sub", l:name)
  let l:str .= 'sub ' . l:name . '()'
  let l:str .= '  maa'
  let l:str .= 'end sub`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" if: Function
"-------------------------------------------------------------------------------
function! vba#vba#if()
  "let l:str  = 'if (maa) then'
  let l:str  = 'if maa then'
  let l:str .= '  mba'
  let l:str .= 'end if`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" else_if: Function
"-------------------------------------------------------------------------------
function! vba#vba#else_if()
  "let l:str  = 'else if (maa)`aa'
  let l:str  = 'else if '
  return l:str
endfunction

"-------------------------------------------------------------------------------
" for: Function
"-------------------------------------------------------------------------------
function! vba#vba#for()
  if (getline(".") =~ '^\s*\w\+\s*$')
    let l:name = matchstr(getline("."), '\w\+')
    call setline(line("."), substitute(getline("."), '\w\+\s*', '', ''))
  else
    let l:name = input("var name: ")
  endif
  let l:str  = 'for ' . l:name . ' = maa'
  let l:str .= '  mba'
  let l:str .= 'next ' . l:name . '`aa'
  return l:str
endfun

"-------------------------------------------------------------------------------
" for_each: Function
"-------------------------------------------------------------------------------
function! vba#vba#for_each()
  if (getline(".") =~ '^\s*\w\+\s*$')
    let l:name = matchstr(getline("."), '\w\+')
    call setline(line("."), substitute(getline("."), '\w\+\s*', '', ''))
  else
    let l:name = input("var name: ")
  endif
  let l:str  = 'for each ' . l:name . ' in maa'
  let l:str .= '  mba'
  let l:str .= 'next`aa'
  return l:str
endfun

"-------------------------------------------------------------------------------
" case: Function
"-------------------------------------------------------------------------------
function! vba#vba#case()
  if (getline(".") =~ '^\s*\w\+\s*$')
    let l:name = matchstr(getline("."), '\w\+')
    call setline(line("."), substitute(getline("."), '\w\+\s*', '', ''))
  else
    let l:name = input("var name: ")
  endif
  let l:str  = 'select case ' . l:name . ''
  let l:str .= '  case maa'
  let l:str .= 'end select`aa'
  return l:str
endfun

"-------------------------------------------------------------------------------
" with: Function
"-------------------------------------------------------------------------------
function! vba#vba#with()
  if (getline(".") =~ '^\s*\w\+\s*$')
    let l:name = matchstr(getline("."), '\w\+')
    call setline(line("."), substitute(getline("."), '\w\+\s*', '', ''))
  else
    let l:name = input("var name: ")
  endif
  let l:str  = 'with ' . l:name . ''
  let l:str .= '  maa'
  let l:str .= 'end with`aa'
  return l:str
endfun

"-------------------------------------------------------------------------------
" while: Function
"-------------------------------------------------------------------------------
function! vba#vba#while()
  "let l:str  = 'if (maa) then'
  let l:str  = 'do while maa'
  let l:str .= '  mba'
  let l:str .= 'loop`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" until: Function
"-------------------------------------------------------------------------------
function! vba#vba#until()
  "let l:str  = 'if (maa) then'
  let l:str  = 'do until maa'
  let l:str .= '  mba'
  let l:str .= 'loop`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" do_while: Function
"-------------------------------------------------------------------------------
function! vba#vba#do_while()
  "let l:str  = 'if (maa) then'
  let l:str  = 'do'
  let l:str .= '  mba'
  let l:str .= 'loop while '
  return l:str
endfunction

"-------------------------------------------------------------------------------
" do_until: Function
"-------------------------------------------------------------------------------
function! vba#vba#do_until()
  "let l:str  = 'if (maa) then'
  let l:str  = 'do'
  let l:str .= '  mba'
  let l:str .= 'loop until '
  return l:str
endfunction

"-------------------------------------------------------------------------------
" map: Function
" Description: Assign a shortcut key to a procedure
"-------------------------------------------------------------------------------
function! vba#vba#map()
  let l:str = 'Application.OnKey "maa", ""`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" msg: Function
" Description: Display Msg
"-------------------------------------------------------------------------------
function! vba#vba#msg()
  let l:str .= 'msgbox (maa)`aa'
  return l:str
endfunction

"-------------------------------------------------------------------------------
" inp: Function
" Description: Input
"-------------------------------------------------------------------------------
function! vba#vba#inp()
  let l:str .= 'input (maa)`aa'
  return l:str
endfunction

