
"-------------------------------------------------------------------------------
" _set_indent: Function
"-------------------------------------------------------------------------------
function! s:_set_indent(offset)
  return '=common#indent#imode_set_indent(' . a:offset . ')'
endfunction

fun! vim#oop#function()
  if (getline(".") =~ '^\s*\S\+\s*$')
    let l:name = matchstr(getline("."), '\S\+')
    call setline(line("."), substitute(getline("."), '\S\+\s*', '', ''))
  else
    let l:name = input("Function Name: ")
  endif
  
  let fun_name = matchstr(l:name, '\v\.\zs\w+')

  let l:str = comments#block_comment#getComments("Function", l:name)
  let l:str .= 'function! ' . l:name . '() dict'
  let l:str .= s:_set_indent(&shiftwidth) . 'call debug#debug#log(printf("' . l:name . ' == %s", string(self.' . fun_name . ')))'
  let l:str .= s:_set_indent(0) . 'maa' 
  let l:str .= s:_set_indent(-&shiftwidth) . 'endfunction`aa'
  return l:str
endfun

fun! vim#oop#new()
  if (getline(".") =~ '^\s*\S\+\s*$')
    let l:name = matchstr(getline("."), '\S\+')
    call setline(line("."), substitute(getline("."), '\S\+\s*', '', ''))
  else
    let l:name = input("Function Name: ")
  endif

  let l:name = l:name . '.new'
  
  let fun_name = matchstr(l:name, '\v\.\zs\w+')

  let l:str = comments#block_comment#getComments("Function", l:name)
  let l:str .= 'function! ' . l:name . '() dict'
  let l:str .= s:_set_indent(&shiftwidth) . 'call debug#debug#log(printf("' . l:name . ' == %s", string(self.' . fun_name . ')))'
  let l:str .= s:_set_indent(0) . 'let this = deepcopy(self)'
  let l:str .= s:_set_indent(0) . 'maa' 
  let l:str .= s:_set_indent(-&shiftwidth) . 'endfunction`aa'
  return l:str
endfun

