"-------------------------------------------------------------------------------
" start_php: Function
"-------------------------------------------------------------------------------
function! php#common#start_php()
  let str = '<?php
            \  maa
            \?>`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" expand_scalar_variable: Function
"-------------------------------------------------------------------------------
function! php#common#expand_scalar_variable()
  let col = col('.') - 1
  let char_m1 = getline(".")[l:col - 1]
  let char_m2 = getline(".")[l:col - 2]

  if (char_m1 == 'g')
    return 'lobal $'
  elseif (char_m1 == 's')
    return 'tatic $'
  elseif (char_m1 == 'v')
    return 'ar $'
  elseif (char_m2 == 'p' && char_m1 == 'u')
    return 'blic $'
  elseif (char_m2 == 'p' && char_m1 == 'r')
    return 'ivate $'
  else
    return '$maa = `aa'
  endif

endfunction

"-------------------------------------------------------------------------------
" expand_array_variable : Function
"-------------------------------------------------------------------------------
function! php#common#expand_array_variable()
  let col = col('.') - 1
  let char = getline(".")[l:col - 1]

  if (char == 'g')
    return 'lobal $'
  elseif (char == 's')
    return 'tatic $'
  elseif (char == 'l')
    return 's$maa = array()`aa'
  else
    return '$maa = array(
          \  mba
          \);`aa'
  endif

endfunction

"-------------------------------------------------------------------------------
" function : Function
"-------------------------------------------------------------------------------
function! php#common#function()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))
  let str = 'function ' . name . ' (mba) {
             \  maa
             \} // ' . name . '`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" if: Function
"-------------------------------------------------------------------------------
function! php#common#if()
  let str = 'if (maa) {
             \  
             \}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" elsif: Function
"-------------------------------------------------------------------------------
function! php#common#elsif()
  let str = 'elseif (maa) {
             \  
             \}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" else: Function
"-------------------------------------------------------------------------------
function! php#common#else()
  let str = 'else {
             \  maa
             \}`aa'
  return str
endfunction


"-------------------------------------------------------------------------------
" switch: Function
"-------------------------------------------------------------------------------
function! php#common#switch()
  let str = 'switch (maa) {
             \  mba
             \default:
             \  mca
             \}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" case: Function
"-------------------------------------------------------------------------------
function! php#common#case()
  let str = 'case maa:
             \  mba
             \break;`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" while: Function
"-------------------------------------------------------------------------------
function! php#common#while()
  let str = 'while (maa) {
            \  
            \}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" do_while: Function
"-------------------------------------------------------------------------------
function! php#common#do_while()
  let str = 'do {
            \  mba
            \} while (maa);`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" incfor: Function
"-------------------------------------------------------------------------------
function! php#common#incfor()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))
  let str = 'for ($' . var . ' = 0; $' . var . ' < maa; $' . var . '++) {
            \  
            \}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" decfor: Function
"-------------------------------------------------------------------------------
function! php#common#decfor()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))
  let str = 'for ($' . var . ' = maa; $' . var . ' > 0; $' . var . '--) {
            \  
            \}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" foreach_array: Function
"-------------------------------------------------------------------------------
function! php#common#foreach_array()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))
  let str = 'foreach (maa as $' . var . ') {
            \  
            \}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" foreach_hash: Function
"-------------------------------------------------------------------------------
function! php#common#foreach_hash()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ "^\s*$")
    let key = 'key'
    let val = 'val'
  else
    let key = var
    let val = key . "_val"
  endif
  let str = 'foreach (maa as $' . key . ' => $' . val . ') {
            \  
            \}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" class : Function
"-------------------------------------------------------------------------------
function! php#common#class()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))
  "let str = comments#block_comment#getComments("Class", "" . name)
  let str = 'class ' . name . ' {
             \  maa
             \function ' . name . '(mba) {
             \  mca
             \}
             \
             \} // ' . name . '`aa'
  return str
endfunction

