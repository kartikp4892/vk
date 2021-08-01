"-------------------------------------------------------------------------------
" s:GetTemplete: Function
"-------------------------------------------------------------------------------
function! s:GetTemplete(char, ...)
  return common#mov_thru_user_mark#get_template(a:char, a:000)
endfunction

"-------------------------------------------------------------------------------
" Exp_Map_Mv: Function
function! s:Exp_Map_Mv()
  let mword = expression_map#map#get_map_word()

  "-------------------------------------------------------------------------------
  " Input
  if (mword =~ '\v^i%[n]u%[int]$')
    call expression_map#map#remove_map_word()
    return "val maa = in UInt(8 bits)`aa"
  elseif (mword =~ '\v^i%[n]b%[oolean]$')
    call expression_map#map#remove_map_word()
    return "val maa = in Bool`aa"
  "-------------------------------------------------------------------------------

  "-------------------------------------------------------------------------------
  " Output
  elseif (mword =~ '\v^o%[out]u%[int]$')
    call expression_map#map#remove_map_word()
    return "val maa = out UInt(8 bits)`aa"
  elseif (mword =~ '\v^o%[ut]b%[oolean]$')
    call expression_map#map#remove_map_word()
    return "val maa = out Bool`aa"
  "-------------------------------------------------------------------------------

  "-------------------------------------------------------------------------------
  " Reg
  elseif (mword =~ '\v^r%[eg]b%[its]$')
    call expression_map#map#remove_map_word()
    return "val maa: Reg(Bits(8 bits))`aa"
  elseif (mword =~ '\v^r%[eg]b%[ool]$')
    call expression_map#map#remove_map_word()
    return "val maa: Reg(Bool)`aa"
  elseif (mword =~ '\v^r%[eg]u%[int]$')
    call expression_map#map#remove_map_word()
    return "val maa: Reg(UInt(8 bits))`aa"
  "-------------------------------------------------------------------------------

  "-------------------------------------------------------------------------------
  " Vector
  elseif (mword =~ '\v^v%[ec]b%[its]$')
    call expression_map#map#remove_map_word()
    return "val maa: Vec(Bits(8 bits))`aa"
  elseif (mword =~ '\v^v%[ec]b%[ool]$')
    call expression_map#map#remove_map_word()
    return "val maa: Vec(Bool)`aa"
  elseif (mword =~ '\v^v%[ec]u%[int]$')
    call expression_map#map#remove_map_word()
    return "val maa: Vec(UInt(8 bits))`aa"
  "-------------------------------------------------------------------------------

  else
    return ''
  endif
endfunction
imap <M-v> =<SID>Exp_Map_Mv()
"-------------------------------------------------------------------------------
"

"-------------------------------------------------------------------------------
" Exp_Map_MJ: Function
function! s:Exp_Map_MJ()
  let mword = expression_map#map#get_map_word()

  "-------------------------------------------------------------------------------
  if (mword =~ '\v^w%[hen]$')
    call expression_map#map#remove_map_word()
    return scala#spinalHDL#when()
  elseif (mword =~ '\v^e%[lse]w%[hen]$')
    call expression_map#map#remove_map_word()
    return scala#spinalHDL#elsewhen()
  elseif (mword =~ '\v^o%[ther]%[wise]$')
    call expression_map#map#remove_map_word()
    return scala#spinalHDL#otherwise()
  elseif (mword =~ '\v^s%[witch]$')
    call expression_map#map#remove_map_word()
    return scala#spinalHDL#switch()
  else
    return ''
  endif
endfunction
imap <M-J> =<SID>Exp_Map_MJ()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Others
"-------------------------------------------------------------------------------
imap <buffer> <M-;> <space>:=<space>





















