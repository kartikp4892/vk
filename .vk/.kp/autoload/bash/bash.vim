"-------------------------------------------------------------------------------
" lib: Function
"-------------------------------------------------------------------------------
function! bash#bash#lib()
  let str = '#!/bin/bash'
  let str .= 'set -xu'
  " --> let str = '#!/bin/sh'
  " --> let str = '#!/bin/csh'
  return str
endfunction

"-------------------------------------------------------------------------------
" if: Function
"-------------------------------------------------------------------------------
function! bash#bash#if()
  let str = 'if [[ maa ]] ; then
             \  
             \fi`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" elif: Function
"-------------------------------------------------------------------------------
function! bash#bash#elif()
  let str = 'elif [[ maa ]] ; then
             \  `aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" ifelse: Function
"-------------------------------------------------------------------------------
function! bash#bash#ifelse()
  let str = 'if [[ maa ]] ; then
             \  
             \else
             \  
             \fi`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" case: Function
"-------------------------------------------------------------------------------
function! bash#bash#case()
  let str = 'case maa in
            \  
            \esac`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" while: Function
"-------------------------------------------------------------------------------
function! bash#bash#while()
  let str = 'while (( maa )) ; do
             \  
             \done`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" until: Function
"-------------------------------------------------------------------------------
function! bash#bash#until()
  let str = 'until (( maa )) ; do
             \  
             \done`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" incfor: Function
"-------------------------------------------------------------------------------
function! bash#bash#incfor()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))
  let str = 'for ((' . var . ' = 0; ' . var . ' < maa; ' . var . '++)); do
            \  
            \done`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" decfor: Function
"-------------------------------------------------------------------------------
function! bash#bash#decfor()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))
  let str = 'for ((' . var . ' = maa; ' . var . ' > 0; ' . var . '--)); do
            \  
            \done`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" foreach: Function
"-------------------------------------------------------------------------------
function! bash#bash#foreach()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))
  let str = 'for ' . var . ' in maa
            \do
            \  
            \done`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" function: Function
"-------------------------------------------------------------------------------
function! bash#bash#function()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))
  let str = 'function ' . var . ' {
            \  maa
            \}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" select: Function
"-------------------------------------------------------------------------------
function! bash#bash#select()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))
  let str = "PS3='Please enter your choice: '"
  let str .= 'select ' . var . ' in maa
            \do
            \  
            \break
            \done`aa'
  return str
endfunction

