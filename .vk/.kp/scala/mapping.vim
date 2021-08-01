"-------------------------------------------------------------------------------
" s:GetTemplete: Function
"-------------------------------------------------------------------------------
function! s:GetTemplete(char, ...)
  return common#mov_thru_user_mark#get_template(a:char, a:000)
endfunction

"-------------------------------------------------------------------------------
" Exp_Map_Mf: Function
" In-build function
function! s:Exp_Map_Mf()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^p%[rintln]$')
    call expression_map#map#remove_map_word()
    return 'println ("maa");`aa'
  elseif (mword =~ '\v^p%[rint]f$')
    call expression_map#map#remove_map_word()
    return 'printf ("maa", );`aa'
  else
    return ''
  endif
endfunction
imap <M-f> =<SID>Exp_Map_Mf()
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
    return scala#oops#class()
  elseif (mword =~ '\v^d%[ef]$')
    call expression_map#map#remove_map_word()
    return scala#oops#function()
  else
    return ''
  endif
endfunction
imap <M-o> =<SID>Exp_Map_Mo()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Mj: Function
" OOPS
function! s:Exp_Map_Mj()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^o%[bject]$')
    call expression_map#map#remove_map_word()
    return scala#scala#object()
  elseif (mword =~ '\v^p%[ackage]$')
    call expression_map#map#remove_map_word()
    return scala#scala#package()
  elseif (mword =~ '\v^f%[unction]$')
    call expression_map#map#remove_map_word()
    return scala#scala#function()
  elseif (mword =~ '\v^f%[unction]r%[eturns]$')
    call expression_map#map#remove_map_word()
    return scala#scala#function_returns()
  elseif (mword =~ '\v^i%[f]$')
    call expression_map#map#remove_map_word()
    return scala#scala#if()
  elseif (mword =~ '\v^e%[lse]$')
    call expression_map#map#remove_map_word()
    return scala#scala#else()
  elseif (mword =~ '\v^e%[lse]%[i]f$')
    call expression_map#map#remove_map_word()
    return scala#scala#elseif()
  elseif (mword =~ '\v^w%[hile]$')
    call expression_map#map#remove_map_word()
    return scala#scala#while()
  elseif (mword =~ '\v^d%[o]w%[hile]$')
    call expression_map#map#remove_map_word()
    return scala#scala#do_while()
  elseif (mword =~ '\v^f%[or]$')
    call expression_map#map#remove_map_word()
    return scala#scala#for()
  else
    return ''
  endif
endfunction
imap <M-j> =<SID>Exp_Map_Mj()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_M4: Function
function! s:Exp_Map_M4()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^i%[nt]$')
    call expression_map#map#remove_map_word()
    return "var maa: Int`aa"
  elseif (mword =~ '\v^b%[oolean]$')
    call expression_map#map#remove_map_word()
    return "var maa: Boolean`aa"
  elseif (mword =~ '\v^u%[nit]$')
    call expression_map#map#remove_map_word()
    return "var maa: Unit`aa"
  elseif (mword =~ '\v^c%[har]$')
    call expression_map#map#remove_map_word()
    return "var maa: Char`aa"
  elseif (mword =~ '\v^d%[ouble]$')
    call expression_map#map#remove_map_word()
    return "var maa: Double`aa"
  elseif (mword =~ '\v^f%[loat]$')
    call expression_map#map#remove_map_word()
    return "var maa: Float`aa"
  elseif (mword =~ '\v^l%[ong]$')
    call expression_map#map#remove_map_word()
    return "var maa: Long`aa"
  elseif (mword =~ '\v^s%[tring]$')
    call expression_map#map#remove_map_word()
    return "var maa: String`aa"
  elseif (mword =~ '\v^s%[hort]$')
    call expression_map#map#remove_map_word()
    return "var maa: Short`aa"
  elseif (mword =~ '\v^b%[yte]$')
    call expression_map#map#remove_map_word()
    return "var maa: Byte`aa"
  elseif (mword =~ '\v^n%[ull]$')
    call expression_map#map#remove_map_word()
    return "var maa: Null`aa"
  elseif (mword =~ '\v^n%[othing]$')
    call expression_map#map#remove_map_word()
    return "var maa: Nothing`aa"
  elseif (mword =~ '\v^a%[ny]$')
    call expression_map#map#remove_map_word()
    return "var maa: Any`aa"
  elseif (mword =~ '\v^a%[ny]r%[ef]$')
    call expression_map#map#remove_map_word()
    return "var maa: AnyRef`aa"
  else
    return ''
  endif
endfunction
imap <M-4> =<SID>Exp_Map_M4()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_M2: Function
function! s:Exp_Map_M2()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^i%[nt]$')
    call expression_map#map#remove_map_word()
    return "var maa = Array[Int]()`aa"
  elseif (mword =~ '\v^b%[oolean]$')
    call expression_map#map#remove_map_word()
    return "var maa = Array[Boolean]()`aa"
  elseif (mword =~ '\v^u%[nit]$')
    call expression_map#map#remove_map_word()
    return "var maa = Array[Unit]()`aa"
  elseif (mword =~ '\v^c%[har]$')
    call expression_map#map#remove_map_word()
    return "var maa = Array[Char]()`aa"
  elseif (mword =~ '\v^d%[ouble]$')
    call expression_map#map#remove_map_word()
    return "var maa = Array[Double]()`aa"
  elseif (mword =~ '\v^f%[loat]$')
    call expression_map#map#remove_map_word()
    return "var maa = Array[Float]()`aa"
  elseif (mword =~ '\v^l%[ong]$')
    call expression_map#map#remove_map_word()
    return "var maa = Array[Long]()`aa"
  elseif (mword =~ '\v^s%[tring]$')
    call expression_map#map#remove_map_word()
    return "var maa = Array[String]()`aa"
  elseif (mword =~ '\v^s%[hort]$')
    call expression_map#map#remove_map_word()
    return "var maa = Array[Short]()`aa"
  elseif (mword =~ '\v^b%[yte]$')
    call expression_map#map#remove_map_word()
    return "var maa = Array[Byte]()`aa"
  elseif (mword =~ '\v^n%[ull]$')
    call expression_map#map#remove_map_word()
    return "var maa = Array[Null]()`aa"
  elseif (mword =~ '\v^n%[othing]$')
    call expression_map#map#remove_map_word()
    return "var maa = Array[Nothing]()`aa"
  elseif (mword =~ '\v^a%[ny]$')
    call expression_map#map#remove_map_word()
    return "var maa = Array[Any]()`aa"
  elseif (mword =~ '\v^a%[ny]r%[ef]$')
    call expression_map#map#remove_map_word()
    return "var maa = Array[AnyRef]()`aa"
  else
    return ''
  endif
endfunction
imap <M-2> =<SID>Exp_Map_M2()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Ml: Function
function! s:Exp_Map_Ml()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^%[spinal]h%[dl]$')
    call expression_map#map#remove_map_word()
    return 'import spinal.core._import spinal.lib._'
  elseif (mword =~ '\v^%[spinal]s%[im]$')
    call expression_map#map#remove_map_word()
    return 'import spinal.sim._import spinal.core._import spinal.core.sim._'
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

  if (mword =~ '\v^t%[his]$')
    call expression_map#map#remove_map_word()
    return 'this.'
  elseif (mword =~ '\v^i%[o]$')
    call expression_map#map#remove_map_word()
    return 'io.'
  else
    return 'this.' " FIXME
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





















