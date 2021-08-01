fun! vim#vim#function()
  if (getline(".") =~ '^\s*\S\+\s*$')
    let l:name = matchstr(getline("."), '\S\+')
    call setline(line("."), substitute(getline("."), '\S\+\s*', '', ''))
  else
    let l:name = input("Function Name: ")
  endif
  let l:str = comments#block_comment#getComments("Function", l:name)
  let l:str .= 'function! ' . l:name . '()'
  let l:str .= '  maa'
  let l:str .= 'endfunction`aa'
  return l:str
endfun

fun! vim#vim#if()
  let l:str  = 'if (maa)'
  let l:str .= '  mba'
  let l:str .= 'endif`aa'
  return l:str
endfun

fun! vim#vim#for()
  if (getline(".") =~ '^\s*\w\+\s*$')
    let l:name = matchstr(getline("."), '\w\+')
    call setline(line("."), substitute(getline("."), '\w\+\s*', '', ''))
  else
    let l:name = input("var name: ")
  endif
  let l:str  = 'for l:' . l:name . ' in maa'
  let l:str .= '  mba'
  let l:str .= 'endfor`aa'
  return l:str
endfun

fun! vim#vim#while()
  let l:str  = 'while maa'
  let l:str .= '  mba'
  let l:str .= 'endwhile`aa'
  return l:str
endfun
