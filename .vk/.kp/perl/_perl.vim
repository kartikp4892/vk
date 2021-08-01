"-------------------------------------------------------------------------------
" Exp_Map_Mj: Function
"-------------------------------------------------------------------------------
function! s:Exp_Map_Mj()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^if?$')
    call expression_map#map#remove_map_word()
    return perl#perl#if()
  elseif (mword == 'ef')
    call expression_map#map#remove_map_word()
    return perl#perl#elsif()
  elseif (mword == 'el')
    call expression_map#map#remove_map_word()
    return perl#perl#else()
  elseif (mword =~ '\v^u%[nless]$')
    call expression_map#map#remove_map_word()
    return perl#perl#unless()
  elseif (mword == 'l')
    call expression_map#map#remove_map_word()
    return perl#perl#lib()
  elseif (mword =~ '\v^p%[rint]$')
    call expression_map#map#remove_map_word()
    return perl#perl#print()
  elseif (mword =~ '\v^w%[hile]$')
    call expression_map#map#remove_map_word()
    return perl#perl#while()
  elseif (mword =~ '\v^u%[ntil]$')
    call expression_map#map#remove_map_word()
    return perl#perl#until()
  elseif (mword =~ '\v^w%[hile]c%[ontinue]$')
    call expression_map#map#remove_map_word()
    return perl#perl#while_continue()
  elseif (mword =~ '\v^k%[ey]v%[alue]$')
    call expression_map#map#remove_map_word()
    return 'my ($key, $value) = each %'
  elseif (mword =~ '\v^s%[ub]$')
    call expression_map#map#remove_map_word()
    return perl#perl#sub()
  elseif (mword =~ '\v^s%[tdin]$')
    call expression_map#map#remove_map_word()
    return '<STDIN>'
  elseif (mword =~ '\v^a%[rgv]$')
    call expression_map#map#remove_map_word()
    return '@ARGV'
  elseif (mword =~ '\v^t%[ry]$')
    call expression_map#map#remove_map_word()
    return perl#perl#try()
  elseif (mword =~ '\v^o%[pen]$')
    call expression_map#map#remove_map_word()
    return perl#perl#open()
  elseif (mword =~ '\v^s%[ub]s%[hift]$') " Shift for sub
    call expression_map#map#remove_map_word()
    return perl#perl#sub_shift()
  elseif (mword =~ '\v^f%[or]i%[ncr]$') " increment for
    call expression_map#map#remove_map_word()
    return perl#perl#incfor()
  elseif (mword =~ '\v^f%[or]d%[ecr]$') " increment for
    call expression_map#map#remove_map_word()
    return perl#perl#decfor()
  elseif (mword =~ '\v^f%[or]e%[ach]$') " foreach
    call expression_map#map#remove_map_word()
    return perl#perl#foreach()
  elseif (mword =~ '\v^c%[homp]$') " chomp
    call expression_map#map#remove_map_word()
    return 'chop ($maa);`aa'
  elseif (mword =~ '\v^r%[e]f$') " regex find
    call expression_map#map#remove_map_word()
    return '=~ m{maa}`aa'
  elseif (mword =~ '\v^r%[e]s$') " regex substitute FIXME
    call expression_map#map#remove_map_word()
    return '=~ s{maa}{mba}`aa'
  else
    return ''
  endif
endfunction
imap <M-j> =<SID>Exp_Map_Mj()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_M4: Function
"-------------------------------------------------------------------------------
function! s:Exp_Map_M4()
  let mword = expression_map#map#get_map_word()

  if (mword == 'l')
    call expression_map#map#remove_map_word()
    return 'local $maa = `aa'
  elseif (mword == 'm')
    call expression_map#map#remove_map_word()
    return 'my $maa = `aa'
  elseif (mword == 'o')
    call expression_map#map#remove_map_word()
    return 'our $maa = `aa'
  else " default
    return 'my $maa = `aa'
  endif
endfunction
imap <M-4> =<SID>Exp_Map_M4()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Mg: Function
" Perl Functions Mapping
"-------------------------------------------------------------------------------
function! s:Exp_Map_Mg()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^m%[ap]$')
    call expression_map#map#remove_map_word()
    return 'map {maa} @{}`aa'
  elseif (mword =~ '\v^u%[nshift]$')
    call expression_map#map#remove_map_word()
    return 'unshift (@{maa}, mba)`aa'
  elseif (mword =~ '\v^s%[hift]$')
    call expression_map#map#remove_map_word()
    return 'shift (@{maa})`aa'
  elseif (mword =~ '\v^p%[op]$')
    call expression_map#map#remove_map_word()
    return 'pop (@{maa})`aa'
  elseif (mword =~ '\v^p%[ush]$')
    call expression_map#map#remove_map_word()
    return 'push (@{maa}, mba)`aa'
  elseif (mword =~ '\v^j%[oin]$')
    call expression_map#map#remove_map_word()
    return 'join ("maa", @{mba})`aa'
  elseif (mword =~ '\v^s%[plit]$')
    call expression_map#map#remove_map_word()
    return 'split (/maa/, mba)`aa'
  elseif (mword =~ '\v^g%[rep]$')
    call expression_map#map#remove_map_word()
    return 'grep (/maa/, mba)`aa'
  elseif (mword =~ '\v^s%[print]f$')
    call expression_map#map#remove_map_word()
    return 'sprintf ("maa", mba);`aa'
  elseif (mword =~ '\v^p%[rint]f$')
    call expression_map#map#remove_map_word()
    return 'printf ("maa");`aa'
  elseif (mword =~ '\v^r%[eturn]$')
    call expression_map#map#remove_map_word()
    return 'return '
  elseif (mword =~ '\v^p%[ackage]$')
    call expression_map#map#remove_map_word()
    return 'package '
  elseif (mword =~ '\v^t%[ie]$') " tie
    call expression_map#map#remove_map_word()
    return 'tie @{maa}, "Tie::File", ' . common#mov_thru_user_mark#imap_alt_m('a', 'FILE_NAME') . ';`aa' 
  elseif (mword =~ '\v^u%[n]%[tie]$') " untie
    call expression_map#map#remove_map_word()
    return 'untie @{maa};`aa' 
  else " default
    return ''
  endif
endfunction
imap <M-g> =<SID>Exp_Map_Mg()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_M2: Function
"-------------------------------------------------------------------------------
function! s:Exp_Map_M2()
  let mword = expression_map#map#get_map_word()

  if (mword == 'l')
    call expression_map#map#remove_map_word()
    return 'local @maa = `aa'
  elseif (mword == 'm')
    call expression_map#map#remove_map_word()
    return 'my @maa = `aa'
  elseif (mword == 'o')
    call expression_map#map#remove_map_word()
    return 'our @maa = `aa'
  else " default
    return 'my @maa = `aa'
  endif
endfunction
imap <M-2> =<SID>Exp_Map_M2()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_M5: Function
"-------------------------------------------------------------------------------
function! s:Exp_Map_M5()
  let mword = expression_map#map#get_map_word()

  if (mword == 'l')
    call expression_map#map#remove_map_word()
    return 'local %maa = `aa'
  elseif (mword == 'm')
    call expression_map#map#remove_map_word()
    return 'my %maa = `aa'
  elseif (mword == 'o')
    call expression_map#map#remove_map_word()
    return 'our %maa = `aa'
  else " default
    return 'my %maa = `aa'
  endif
endfunction
imap <M-5> =<SID>Exp_Map_M5()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Mo: Function
" OOPS Perl
"-------------------------------------------------------------------------------
function! s:Exp_Map_Mo()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^n%[ew]$')
    call expression_map#map#remove_map_word()
    return perl#oop#new()
  elseif (mword =~ '\v^p%[ackage]$')
    call expression_map#map#remove_map_word()
    return perl#oop#package()
  elseif (mword =~ '\v^s%[ub]$')
    call expression_map#map#remove_map_word()
    return perl#oop#sub()
  elseif (mword =~ '\v^i%[sa]$') " @ISA
    call expression_map#map#remove_map_word()
    return 'our @ISA = qw(maa);`aa'
  elseif (mword =~ '\v^S%[uper]$') " SUPER
    call expression_map#map#remove_map_word()
    return '$self -> SUPER::'
  else " default
    return ''
  endif
endfunction
imap <M-o> =<SID>Exp_Map_Mo()
"-------------------------------------------------------------------------------

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" paranthesis
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
imap <buffer> <M-,> <><Left>
imap <buffer> <M-{> {}<Left>
imap <buffer> <M-}> {
                   \  maa
                   \}`aa
imap <buffer> <M-[> []<Left>
imap <buffer> <M-]> [
                   \  maa
                   \]`aa
imap <buffer> <M-0> (
                   \  maa
                   \)`aa
imap <buffer> <M-=> <Space>= 
imap <buffer> <M-.> -> 
imap <buffer> <M-/> f"a, 
imap <buffer> <C-CR> A;
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

