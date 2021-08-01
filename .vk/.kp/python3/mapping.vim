"-------------------------------------------------------------------------------
" s:GetTemplete: Function
"-------------------------------------------------------------------------------
function! s:GetTemplete(char, ...)
  return common#mov_thru_user_mark#get_template(a:char, a:000)
endfunction

"-------------------------------------------------------------------------------
" Exp_Map_Mj: Function
" General
function! s:Exp_Map_Mj()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^p%[rint]$')
    call expression_map#map#remove_map_word()
    return 'print ("maa")`aa'
  elseif (mword =~ '\v^f%[un]$|^d%[ef]$')
    call expression_map#map#remove_map_word()
    return python#python#function()
  elseif (mword =~ '\v^f%[or]$')
    call expression_map#map#remove_map_word()
    return python#python#foreach()
  elseif (mword =~ '\v^w%[hile]$')
    call expression_map#map#remove_map_word()
    return python#python#while()
  elseif (mword =~ '\v^i%[f]$')
    call expression_map#map#remove_map_word()
    return python#python#if()
  elseif (mword =~ '\v^e%[lse]%[i]f$')
    call expression_map#map#remove_map_word()
    return python#python#elif()
  elseif (mword =~ '\v^e%[lse]$')
    call expression_map#map#remove_map_word()
    return python#python#else()
  elseif (mword =~ '\v^t%[ry]e%[xcept]$')
    call expression_map#map#remove_map_word()
    return python#python#try_except()
  elseif (mword =~ '\v^l%[ambda]$')
    call expression_map#map#remove_map_word()
    return 'lambda maa:`aa'
  else
    return ''
  endif
endfunction
imap <M-j> =<SID>Exp_Map_Mj()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Ms: Function
" Sets
function! s:Exp_Map_Ms()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^i%[ntersection]$')
    call expression_map#map#remove_map_word()
    return 'intersection (maa)`aa'
  elseif (mword =~ '\v^s%[ymmetric_]d%[ifference]$')
    call expression_map#map#remove_map_word()
    return 'symmetric_difference (maa)`aa'
  elseif (mword =~ '\v^d%[ifference]$')
    call expression_map#map#remove_map_word()
    return 'difference (maa)`aa'
  elseif (mword =~ '\v^u%[nion]$')
    call expression_map#map#remove_map_word()
    return 'union (maa)`aa'
  else
    return 'set(maa)`aa'
  endif
endfunction
imap <M-s> =<SID>Exp_Map_Ms()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Ma: Function
" Array
function! s:Exp_Map_Ma()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^a%[ppend]$')
    call expression_map#map#remove_map_word()
    return 'append(maa)`aa'
  elseif (mword =~ '\v^c%[ount]$')
    call expression_map#map#remove_map_word()
    return 'count(maa)`aa'
  elseif (mword =~ '\v^i%[ndex]$')
    call expression_map#map#remove_map_word()
    return 'index(maa)`aa'
  elseif (mword =~ '\v^u%[pper]$')
    call expression_map#map#remove_map_word()
    return 'upper(maa)`aa'
  elseif (mword =~ '\v^l%[ower]$')
    call expression_map#map#remove_map_word()
    return 'lower(maa)`aa'
  elseif (mword =~ '\v^s%[tartswith]$')
    call expression_map#map#remove_map_word()
    return 'startswith(maa)`aa'
  elseif (mword =~ '\v^e%[ndswith]$')
    call expression_map#map#remove_map_word()
    return 'endswith(maa)`aa'
  elseif (mword =~ '\v^s%[plit]$')
    call expression_map#map#remove_map_word()
    return 'split(maa)`aa'
  elseif (mword =~ '\v^s%[orted]$')
    call expression_map#map#remove_map_word()
    return 'sorted(maa)`aa'
  elseif (mword =~ '\v^j%[oin]$')
    call expression_map#map#remove_map_word()
    return 'join(maa)`aa'
  else
    return ''
  endif
endfunction
imap <M-a> =<SID>Exp_Map_Ma()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Mf: Function
" In-build function
function! s:Exp_Map_Mf()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^l%[en]$')
    call expression_map#map#remove_map_word()
    return 'len(maa)`aa'
  elseif (mword =~ '\v^p%[rint]$')
    call expression_map#map#remove_map_word()
    return 'print(maa)`aa'
  elseif (mword =~ '\v^x%[range]$')
    call expression_map#map#remove_map_word()
    return 'xrange(maa)`aa'
  elseif (mword =~ '\v^d%[ir]$')
    call expression_map#map#remove_map_word()
    return 'dir(maa)`aa'
  elseif (mword =~ '\v^t%[ype]$')
    call expression_map#map#remove_map_word()
    return 'type(maa)`aa'
  elseif (mword =~ '\v^h%[elp]$')
    call expression_map#map#remove_map_word()
    return 'help(maa)`aa'
  elseif (mword =~ '\v^h%[as]a%[ttr]$')
    call expression_map#map#remove_map_word()
    return 'hasattr(maa)`aa'
  elseif (mword =~ '\v^r%[epr]$')
    call expression_map#map#remove_map_word()
    return 'repr(maa)`aa'
  elseif (mword =~ '\v^c%[allable]$')
    call expression_map#map#remove_map_word()
    return 'callable(maa)`aa'
  elseif (mword =~ '\v^i%[s]s%[ub]c%[lass]$')
    call expression_map#map#remove_map_word()
    return 'issubclass(maa)`aa'
  elseif (mword =~ '\v^i%[s]i%[nstance]$')
    call expression_map#map#remove_map_word()
    return 'isinstance(maa)`aa'
  elseif (mword =~ '\v^l%[ottery]$')
    call expression_map#map#remove_map_word()
    return 'lottery()'
  else
    return ''
  endif
endfunction
imap <M-f> =<SID>Exp_Map_Mf()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Function : s:get_regex_str
"-------------------------------------------------------------------------------
function! s:get_regex_str(str)
  if (strpart(getline('.'), col('.') - 2) == '.')
    return a:str
  endif
  return 're.' . a:str
endfunction

"-------------------------------------------------------------------------------
" Exp_Map_Mr: Function
" Regex
function! s:Exp_Map_Mr()
  let mword = expression_map#map#get_map_word()

  "Regex
  if (mword =~ '\v^r%[e]c%[ompile]$')
    call expression_map#map#remove_map_word()
    return 're.compile(maa)`aa'
  elseif (mword =~ '\v^r%[e]s%[earch]$')
    call expression_map#map#remove_map_word()
    return s:get_regex_str('search(maa)`aa')
  elseif (mword =~ '\v^r%[e]s%[plit]$')
    call expression_map#map#remove_map_word()
    return s:get_regex_str('split(maa)`aa')
  elseif (mword =~ '\v^r%[e]s%[ub]$')
    call expression_map#map#remove_map_word()
    return s:get_regex_str('sub(maa)`aa')
  elseif (mword =~ '\v^r%[e]s%[pan]$')
    call expression_map#map#remove_map_word()
    return s:get_regex_str('span(maa)`aa')
  elseif (mword =~ '\v^r%[e]s%[ub]n$')
    call expression_map#map#remove_map_word()
    return s:get_regex_str('subn(maa)`aa')
  elseif (mword =~ '\v^r%[e]e%[scape]$')
    call expression_map#map#remove_map_word()
    return s:get_regex_str('escape(maa)`aa')
  elseif (mword =~ '\v^r%[e]p%[urge]$')
    call expression_map#map#remove_map_word()
    return s:get_regex_str('purge(maa)`aa')
  elseif (mword =~ '\v^r%[e]g%[roup]$')
    call expression_map#map#remove_map_word()
    return s:get_regex_str('group(maa)`aa')
  elseif (mword =~ '\v^r%[e]g%[roup]s$')
    call expression_map#map#remove_map_word()
    return s:get_regex_str('groups(maa)`aa')
  elseif (mword =~ '\v^r%[e]g%[roup]d%[ict]$')
    call expression_map#map#remove_map_word()
    return s:get_regex_str('groupdict(maa)`aa')
  elseif (mword =~ '\v^r%[e]s%[tart]$')
    call expression_map#map#remove_map_word()
    return s:get_regex_str('start(maa)`aa')
  elseif (mword =~ '\v^r%[e]e%[nd]$')
    call expression_map#map#remove_map_word()
    return s:get_regex_str('end(maa)`aa')
  elseif (mword =~ '\v^r%[e]f%[ind]a%[ll]$')
    call expression_map#map#remove_map_word()
    return s:get_regex_str('findall(maa)`aa')
  elseif (mword =~ '\v^r%[e]f%[ind]i%[ter]$')
    call expression_map#map#remove_map_word()
    return s:get_regex_str('finditer(maa)`aa')
  elseif (mword =~ '\v^r%[e]m%[atch]$')
    call expression_map#map#remove_map_word()
    return s:get_regex_str('match(maa)`aa')
  elseif (mword =~ '\v^r%[e]D%[EBUG]$')
    call expression_map#map#remove_map_word()
    return 're.DEBUG'
  elseif (mword =~ '\v^r%[e]I%[GNORE]$')
    call expression_map#map#remove_map_word()
    return 're.IGNORE'
  elseif (mword =~ '\v^r%[e]L%[OCALE]$')
    call expression_map#map#remove_map_word()
    return 're.LOCALE'
  elseif (mword =~ '\v^r%[e]M%[ULTILINE]$')
    call expression_map#map#remove_map_word()
    return 're.MULTILINE'
  elseif (mword =~ '\v^r%[e]S$\|^r%[e]D%[OTALL]$')
    call expression_map#map#remove_map_word()
    return 're.DOTALL'
  elseif (mword =~ '\v^r%[e]U$\|^r%[e]U%[NICODE]$')
    call expression_map#map#remove_map_word()
    return 're.UNICODE'
  elseif (mword =~ '\v^r%[e]X$\|^r%[e]V%[ERBOSE]$')
    call expression_map#map#remove_map_word()
    return 're.VERBOSE'
  else
    return ''
  endif
endfunction
imap <M-r> =<SID>Exp_Map_Mr()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Mk: Function
" In-build function
function! s:Exp_Map_Mk()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^b%[reak]$')
    call expression_map#map#remove_map_word()
    return 'break'
  elseif (mword =~ '\v^c%[ontinue]$')
    call expression_map#map#remove_map_word()
    return 'continue'
  elseif (mword =~ '\v^r%[eturn]$')
    call expression_map#map#remove_map_word()
    return 'return'
  elseif (mword =~ '\v^y%[ield]$')
    call expression_map#map#remove_map_word()
    return 'yield '
  elseif (mword =~ '\v^l%[ambda]$')
    call expression_map#map#remove_map_word()
    return 'lambda maa:`aa'
  else
    return ''
  endif
endfunction
imap <M-k> =<SID>Exp_Map_Mk()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Mo: Function
" OOPS
function! s:Exp_Map_Mo()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^c%[lass]$')
    call expression_map#map#remove_map_word()
    return python#oops#class()
  elseif (mword =~ '\v^c%[lass]s%[ingleton]$')
    call expression_map#map#remove_map_word()
    return python#oops#class_singleton()
  elseif (mword =~ '\v^c%[lass]m%[eta]$')
    call expression_map#map#remove_map_word()
    return python#oops#class_meta()
  elseif (mword =~ '\v^c%[lass]a%[bstract]$')
    call expression_map#map#remove_map_word()
    return python#oops#abstract_class()
  elseif (mword =~ '\v^d%[ef]$')
    call expression_map#map#remove_map_word()
    return python#oops#function()
  elseif (mword =~ '\v^d%[ef]a%[bstract]$')
    call expression_map#map#remove_map_word()
    return python#oops#abstract_function()
  elseif (mword =~ '\v^d%[ef]s%[tatic]$')
    call expression_map#map#remove_map_word()
    return python#oops#static_function()
  elseif (mword =~ '\v^d%[ef]c%[lass]$')
    call expression_map#map#remove_map_word()
    return python#oops#class_function()
  elseif (mword =~ '\v^i%[nit]$')
    call expression_map#map#remove_map_word()
    return python#oops#init()
  " Meta Class starts here
  elseif (mword =~ '\v^m%[eta]$')
    call expression_map#map#remove_map_word()
    return python#oops#metaclass()
  elseif (mword =~ '\v^m%[eta]i%[nit]$')
    call expression_map#map#remove_map_word()
    return python#oops#metaclass_init()
  elseif (mword =~ '\v^m%[eta]n%[ew]$')
    call expression_map#map#remove_map_word()
    return python#oops#metaclass_new()
  elseif (mword =~ '\v^m%[eta]c%[all]$')
    call expression_map#map#remove_map_word()
    return python#oops#metaclass_call()
  " Descriptor classes start from here
  elseif (mword =~ '\v^c%[lass]d%[escriptor]$')
    call expression_map#map#remove_map_word()
    return python#oops#descriptor_class()
  else
    return ''
  endif
endfunction
imap <M-o> =<SID>Exp_Map_Mo()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Md: Function
" Dictionary
function! s:Exp_Map_Md()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^i%[ter]%[items]$')
    call expression_map#map#remove_map_word()
    return 'iteritems()'
  elseif (mword =~ '\v^p%[op]$')
    call expression_map#map#remove_map_word()
    return 'pop(maa)`aa'
  elseif (mword =~ '\v^d%[el]$')
    call expression_map#map#remove_map_word()
    return 'del '
  else
    return ''
  endif
endfunction
imap <M-d> =<SID>Exp_Map_Md()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Ml: Function
" Import
function! s:Exp_Map_Ml()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^p%[ath]$')
    call expression_map#map#remove_map_word()
    return '#!/usr/bin/env python'
  elseif (mword =~ '\v^u%[rl]%[lib]$')
    call expression_map#map#remove_map_word()
    return 'import urllib'
  elseif (mword =~ '\v^c%[sv]$')
    call expression_map#map#remove_map_word()
    return 'import csv'
  elseif (mword =~ '\v^r%[e]$')
    call expression_map#map#remove_map_word()
    return 'import re'
  elseif (mword =~ '\v^r%[andom]$')
    call expression_map#map#remove_map_word()
    return 'import random'
  elseif (mword =~ '\v^t%[ypes]$')
    call expression_map#map#remove_map_word()
    return 'import types'
  elseif (mword =~ '\v^j%[son]$')
    call expression_map#map#remove_map_word()
    return 'import json'
  elseif (mword =~ '\v^f%[unctools]p%[artial]$')
    call expression_map#map#remove_map_word()
    return 'import functools.partial'
  "External start from here
  elseif (mword =~ '\v^m%[echanize]$')
    call expression_map#map#remove_map_word()
    return 'import mechanize'
  elseif (mword =~ '\v^b%[eauitful]s%[oup]$')
    call expression_map#map#remove_map_word()
    return 'from bs4 import BeautifulSoup'
  elseif (mword =~ '\v^x%[l]r%[d]$')
    call expression_map#map#remove_map_word()
    return 'import xlrd'
  elseif (mword =~ '\v^$')
    call expression_map#map#remove_map_word()
    return 'import '
  else
    return ''
  endif
endfunction
imap <M-l> =<SID>Exp_Map_Ml()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Others
"-------------------------------------------------------------------------------
"-------------------------------------------------------------------------------
" Exp_Map_Mdot: Function
" Import
function! s:Exp_Map_Mdot()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^s%[elf]$')
    call expression_map#map#remove_map_word()
    return 'self.'
  else
    return 'self.' " FIXME
  endif
endfunction
imap <M-.> =<SID>Exp_Map_Mdot()
"-------------------------------------------------------------------------------
imap <buffer> <M-/> f"a,
imap <buffer> <M-[> []<Left>
imap <buffer> <M-{> {}<Left>
imap <buffer> <M-=> <space>=
imap <buffer> <C-CR> o
imap <buffer> <M-5> f"a % 





















