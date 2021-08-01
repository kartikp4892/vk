"-------------------------------------------------------------------------------
" _set_indent: Function
"-------------------------------------------------------------------------------
function! s:_set_indent(offset)
  return '=common#indent#imode_set_indent(' . a:offset . ')'
endfunction

"-------------------------------------------------------------------------------
" s:GetTemplete: Function
"-------------------------------------------------------------------------------
function! s:GetTemplete(char, ...)
  return common#mov_thru_user_mark#get_template(a:char, a:000)
endfunction

"-------------------------------------------------------------------------------
" lib: Function
"-------------------------------------------------------------------------------
function! perl#perl#lib()
  let str = '#!/usr/bin/perl -w
            \use strict;
            \use warnings;'
  return str
endfunction

"-------------------------------------------------------------------------------
" print: Function
"-------------------------------------------------------------------------------
function! perl#perl#print()
  let str = 'print ("maa\n");`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" incfor: Function
"-------------------------------------------------------------------------------
function! perl#perl#incfor()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('a', 'var')
  endif

  let str = 'for (my $' . var . ' = 0; $' . var . ' < maa' . s:GetTemplete('b', 'max_val') . '; $' . var . '++) {' .
         \  s:_set_indent(&shiftwidth) . '' .
         \  s:_set_indent(0) . '}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" decfor: Function
"-------------------------------------------------------------------------------
function! perl#perl#decfor()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('a', 'var')
  endif

  let str = 'for (my $' . var . ' = maa' . s:GetTemplete('b', 'max_val') . '; $' . var . ' > 0; $' . var . '--) {' .
            \ s:_set_indent(&shiftwidth) . '' .
            \ s:_set_indent(0) . '}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" foreach: Function
"-------------------------------------------------------------------------------
function! perl#perl#foreach()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('a', 'var')
  endif

  let str = 'foreach my $' . var . ' (@{maa' . s:GetTemplete('b', 'array_var') . '}) {' .
            \ s:_set_indent(&shiftwidth) . '' .
            \ s:_set_indent(0) . '}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" while: Function
"-------------------------------------------------------------------------------
function! perl#perl#while()
  let str = 'while (maa) {' .
            \ s:_set_indent(&shiftwidth) .  '' .
            \ s:_set_indent(0) . '}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" while_continue: Function
"-------------------------------------------------------------------------------
function! perl#perl#while_continue()
  let str = 'while (maa) {' .
            \ s:_set_indent(&shiftwidth) .  '' .
            \ s:_set_indent(0) . '}' .
            \ s:_set_indent(0) . 'continue {' .
            \ s:_set_indent(&shiftwidth) .  '' .
            \ s:_set_indent(0) . '}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" if: Function
"-------------------------------------------------------------------------------
function! perl#perl#if()
  let str = 'if (maa) {' .
             \ s:_set_indent(&shiftwidth) .  '' .
             \ s:_set_indent(0) . '}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" elsif: Function
"-------------------------------------------------------------------------------
function! perl#perl#elsif()
  let str = 'elsif (maa) {' .
             \ s:_set_indent(&shiftwidth) . '' .
             \ s:_set_indent(0) . '}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" else: Function
"-------------------------------------------------------------------------------
function! perl#perl#else()
  let str = 'else {' .
             \ s:_set_indent(&shiftwidth) . 'maa' .
             \ s:_set_indent(0) . '}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" unless: Function
"-------------------------------------------------------------------------------
function! perl#perl#unless()
  let str = 'unless (maa) {' .
             \ s:_set_indent(&shiftwidth) . '' .
             \ s:_set_indent(0) . '}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" until: Function
"-------------------------------------------------------------------------------
function! perl#perl#until()
  let str = 'until (maa) {' .
             \ s:_set_indent(&shiftwidth) . '' .
             \ s:_set_indent(0) . '}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" sub: Function
"-------------------------------------------------------------------------------
function! perl#perl#sub()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))
  if (name !~ '^\s*$')
    let str = comments#block_comment#getComments('Sub', name)
  else
    let str = ""
  endif
  let str .= 'sub ' . name . ' {' .
             \ s:_set_indent(&shiftwidth) . 'maa' .
             \ s:_set_indent(0) . '}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" try: Function
"-------------------------------------------------------------------------------
function! perl#perl#try()
  call setline(".", repeat(' ', indent(".")))
  let str = 'try {' .
             \ s:_set_indent(&shiftwidth) . 'maa' .
             \ s:_set_indent(0) . '}' .
             \ s:_set_indent(0) . 'catch Error with {' .
             \ s:_set_indent(&shiftwidth) . 'mba' .
             \ s:_set_indent(0) . '};`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" open: Function
"-------------------------------------------------------------------------------
function! perl#perl#open()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (name =~ '^\s*$')
    let name = s:GetTemplete('a', 'fname')
  endif

  let str = 'open (my $maa, "' . s:GetTemplete('a', 'rw_mode/<') . '$' . name . '") or die ("Error: Couln''t open file $' . name . ' $!");`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" sub_shift: Function
"-------------------------------------------------------------------------------
function! perl#perl#sub_shift()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('a', 'var')
  endif

  let str = 'my $' . var . ' = shift;' . s:_set_indent(0) 
  return str
endfunction

