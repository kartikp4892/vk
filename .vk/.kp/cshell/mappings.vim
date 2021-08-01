"-------------------------------------------------------------------------------
" Exp_Map_Mj: Function
"-------------------------------------------------------------------------------
function! s:Exp_Map_Mj()
  let mword = expression_map#map#get_map_word()

  if (mword == 'l')
    call expression_map#map#remove_map_word()
    return cshell#csh#lib()
  elseif (mword =~ '\v^i%[f]$') " If
    call expression_map#map#remove_map_word()
    return cshell#csh#if()
  elseif (mword =~ '\v^e%[l]i?f$') " else if
    call expression_map#map#remove_map_word()
    return cshell#csh#elif()
  elseif (mword =~ '\v^el%[se]$') " else
    call expression_map#map#remove_map_word()
    return 'else  '
  elseif (mword =~ '\v^i%[f]e%[lse]$') " If-Else block
    call expression_map#map#remove_map_word()
    return cshell#csh#ifelse()
  elseif (mword =~ '\v^c%[ase]$') " Case
    call expression_map#map#remove_map_word()
    return cshell#csh#case()
  elseif (mword =~ '\v^w%[hile]$') " While
    call expression_map#map#remove_map_word()
    return cshell#csh#while()
  elseif (mword =~ '\v^f%[or]i$') " For ++
    call expression_map#map#remove_map_word()
    return cshell#csh#incfor()
  elseif (mword =~ '\v^f%[or]d$') " For --
    call expression_map#map#remove_map_word()
    return cshell#csh#decfor()
  elseif (mword =~ '\v^f%[or]e%[ach]$') " For each
    call expression_map#map#remove_map_word()
    return cshell#csh#foreach()
  elseif (mword =~ '\v^f%[unction]$') " Until
    call expression_map#map#remove_map_word()
    return cshell#csh#function()
  elseif (mword =~ '\v^s%[elect]$') " Until
    call expression_map#map#remove_map_word()
    return cshell#csh#select()
  elseif (mword =~ '\v^e%[cho][i]?$') " Echo [ >&2]
    call expression_map#map#remove_map_word()
    return 'echo "maa"' . ((mword =~ 'i$') ? (' >&2') : ('')) . '`aa'
  elseif (mword =~ '\v^e%[cho]n[i]?$') " Echo -n [ >&2]
    call expression_map#map#remove_map_word()
    return 'echo -n "maa"' . ((mword =~ 'i$') ? (' >&2') : ('')) . '`aa'
  elseif (mword =~ '\v^e%[cho]e[i]?$') " Echo -e [ >&2]
    call expression_map#map#remove_map_word()
    return 'echo -e "maa"' . ((mword =~ 'i$') ? (' >&2') : ('')) . '`aa'
  elseif (mword =~ '\v^d%[eclare]i$') " declare -i
    call expression_map#map#remove_map_word()
    return 'declare -i '
  elseif (mword =~ '\v^d%[eclare]r$') " declare -r
    call expression_map#map#remove_map_word()
    return 'declare -r '
  elseif (mword =~ '\v^d%[eclare]f$') " declare -f
    call expression_map#map#remove_map_word()
    return 'declare -f '
  elseif (mword =~ '\v^d%[eclare]a$') " declare -a
    call expression_map#map#remove_map_word()
    return 'declare -a '
  elseif (mword =~ '\v^d%[eclare]x$') " declare -x
    call expression_map#map#remove_map_word()
    return 'declare -x '
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
    return 'local '
  elseif (mword =~ '\v^h%[ere]%[document]') " heredocument
    call expression_map#map#remove_map_word()
    return '<<EODmaaEOD`aa'
  else " default
    if (getline('.') =~ '^\s*$')
      return 'let "maa"`aa'
    else
      return '${maa}`aa'
    endif
  endif
endfunction
imap <M-4> =<SID>Exp_Map_M4()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Mk: Function
" Keywords
"-------------------------------------------------------------------------------
function! s:Exp_Map_Mk()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^b%[reak]')
    call expression_map#map#remove_map_word()
    return 'break 1'
  elseif (mword =~ '\v^c%[ontinue]')
    call expression_map#map#remove_map_word()
    return 'continue 1'
  else " default
    return ""
  endif
endfunction
imap <M-k> =<SID>Exp_Map_Mk()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Mr: Function
" Regular Expression
"-------------------------------------------------------------------------------
function! s:Exp_Map_Mr()
  let mword = expression_map#map#get_map_word()

  " Character Classes
  if (mword =~ '\v^d%[igit]$')
    call expression_map#map#remove_map_word()
    return '[:digit:]'
  elseif (mword =~ '\v^a%[l]%[num]$')
    call expression_map#map#remove_map_word()
    return '[:alnum:]'
  elseif (mword =~ '\v^a%[l]%[pha]$')
    call expression_map#map#remove_map_word()
    return '[:alpha:]'
  elseif (mword =~ '\v^b%[lank]$')
    call expression_map#map#remove_map_word()
    return '[:alpha:]'
  elseif (mword =~ '\v^c%[ntrl]$')
    call expression_map#map#remove_map_word()
    return '[:cntrl:]'
  elseif (mword =~ '\v^g%[raph]$')
    call expression_map#map#remove_map_word()
    return '[:graph:]'
  elseif (mword =~ '\v^l%[ower]$')
    call expression_map#map#remove_map_word()
    return '[:lower:]'
  elseif (mword =~ '\v^p%[rint]$')
    call expression_map#map#remove_map_word()
    return '[:print:]'
  elseif (mword =~ '\v^p%[unct]$')
    call expression_map#map#remove_map_word()
    return '[:punct:]'
  elseif (mword =~ '\v^s%[pace]$')
    call expression_map#map#remove_map_word()
    return '[:space:]'
  elseif (mword =~ '\v^u%[pper]$')
    call expression_map#map#remove_map_word()
    return '[:upper:]'
  elseif (mword =~ '\v^x%[digit]$')
    call expression_map#map#remove_map_word()
    return '[:xdigit:]'
  else " default
    return ""
  endif
endfunction
imap <M-r> =<SID>Exp_Map_Mr()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_MR: Function
" Regular Expression
"-------------------------------------------------------------------------------
function! s:Exp_Map_MR()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^d%[igit]$')
    call expression_map#map#remove_map_word()
    return '[0-9]'
  elseif (mword =~ '\v^w%[ord]$')
    call expression_map#map#remove_map_word()
    return '[0-9A-Za-z_]'
  elseif (mword =~ '\v^l%[ower]$')
    call expression_map#map#remove_map_word()
    return '[a-z]'
  elseif (mword =~ '\v^u%[pper]$')
    call expression_map#map#remove_map_word()
    return '[A-Z]'
  else " default
    return ""
  endif
endfunction
imap <M-R> =<SID>Exp_Map_MR()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Mt: Function
"-------------------------------------------------------------------------------
function! s:Exp_Map_Mt()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^e%[xpr]m%[atch]$') " match
    call expression_map#map#remove_map_word()
    return 'expr match "maa" ''\(mba\)''`aa'
  elseif (mword =~ '\v^e%[xpr]i%[ndex]$') " index
    call expression_map#map#remove_map_word()
    return 'expr index "maa" `aa'
  elseif (mword =~ '\v^e%[xpr]l%[ength]$') " length
    call expression_map#map#remove_map_word()
    return 'expr length "maa" `aa'
  elseif (mword =~ '\v^e%[xpr]s%[ubstr]$') " substr
    call expression_map#map#remove_map_word()
    return 'expr substr "maa" `aa'
  else " default
    return ''
  endif
endfunction
imap <M-t> =<SID>Exp_Map_Mt()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Mi: Function
"-------------------------------------------------------------------------------
function! s:Exp_Map_Mi()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^b%[ash]$') " $BASH
    call expression_map#map#remove_map_word()
    return '$BASH'
  elseif (mword =~ '\v^b%[ash]p%[id]$') " $BASHPID
    call expression_map#map#remove_map_word()
    return '$BASHPID'
  elseif (mword =~ '\v^b%[ash]e%[nv]$') " $BASH_ENV
    call expression_map#map#remove_map_word()
    return '$BASH_ENV'
  elseif (mword =~ '\v^b%[ash]s%[ub]%[shell]$') " $BASH_SUBSHELL
    call expression_map#map#remove_map_word()
    return '$BASH_SUBSHELL'
  elseif (mword =~ '\v^b%[ash]v%[ersion]$') " $BASH_VERSION
    call expression_map#map#remove_map_word()
    return '$BASH_VERSION'
  elseif (mword =~ '\v^c%[d]p%[ath]$') " $CDPATH
    call expression_map#map#remove_map_word()
    return '$CDPATH'
  elseif (mword =~ '\v^d%[ir]s%[tack]$') " $DIRSTACK
    call expression_map#map#remove_map_word()
    return '$DIRSTACK'
  elseif (mword =~ '\v^e%[ditor]$') " $EDITOR
    call expression_map#map#remove_map_word()
    return '$EDITOR'
  elseif (mword =~ '\v^e%[uid]$') " $EUID
    call expression_map#map#remove_map_word()
    return '$EUID'
  elseif (mword =~ '\v^f%[unc]n%[ame]$') " $FUNCNAME
    call expression_map#map#remove_map_word()
    return '$FUNCNAME'
  elseif (mword =~ '\v^g%[lob]i%[gnore]$') " $GLOBIGNORE
    call expression_map#map#remove_map_word()
    return '$GLOBIGNORE'
  elseif (mword =~ '\v^gr%[oups]$') " $GROUPS
    call expression_map#map#remove_map_word()
    return '$GROUPS'
  elseif (mword =~ '\v^h%[ome]$') " $HOME
    call expression_map#map#remove_map_word()
    return '$HOME'
  elseif (mword =~ '\v^h%[ost]n%[ame]$') " $HOSTNAME
    call expression_map#map#remove_map_word()
    return '$HOSTNAME'
  elseif (mword =~ '\v^h%[ost]t%[ype]$') " $HOSTTYPE
    call expression_map#map#remove_map_word()
    return '$HOSTTYPE'
  elseif (mword =~ '\v^i%[fs]$') " $IFS
    call expression_map#map#remove_map_word()
    return '$IFS'
  elseif (mword =~ '\v^i%[gnore]e%[of]$') " $IGNOREEOF
    call expression_map#map#remove_map_word()
    return '$IGNOREEOF'
  elseif (mword =~ '\v^l%[c]c%[ollate]$') " $LC_COLLATE
    call expression_map#map#remove_map_word()
    return '$LC_COLLATE'
  elseif (mword =~ '\v^l%[c]c%[type]$') " $LC_COLLATE
    call expression_map#map#remove_map_word()
    return '$LC_COLLATE'
  elseif (mword =~ '\v^l%[ine]n%[o]$') " $LINENO
    call expression_map#map#remove_map_word()
    return '$LINENO'
  elseif (mword =~ '\v^m%[atch]t%[ype]$') " $MACHTYPE
    call expression_map#map#remove_map_word()
    return '$MACHTYPE'
  elseif (mword =~ '\v^o%[ld]p%[wd]$') " $OLDPWD
    call expression_map#map#remove_map_word()
    return '$OLDPWD'
  elseif (mword =~ '\v^o%[s]t%[ype]$') " $OSTYPE
    call expression_map#map#remove_map_word()
    return '$OSTYPE'
  elseif (mword =~ '\v^p%[ath]$') " $PATH
    call expression_map#map#remove_map_word()
    return '$PATH'
  elseif (mword =~ '\v^p%[ipe]s%[tatus]$') " $PIPESTATUS
    call expression_map#map#remove_map_word()
    return '$PIPESTATUS'
  elseif (mword =~ '\v^pp%[id]$') " $PPID
    call expression_map#map#remove_map_word()
    return '$PPID'
  elseif (mword =~ '\v^p%[rompt]c%[ommand]$') " $PROMPT_COMMAND
    call expression_map#map#remove_map_word()
    return '$PROMPT_COMMAND'
  elseif (mword =~ '\v^p%[s1]$') " $PS1
    call expression_map#map#remove_map_word()
    return '$PS1'
  elseif (mword =~ '\v^p%[s2]$') " $PS2
    call expression_map#map#remove_map_word()
    return '$PS2'
  elseif (mword =~ '\v^p%[s3]$') " $PS3
    call expression_map#map#remove_map_word()
    return '$PS3'
  elseif (mword =~ '\v^p%[s4]$') " $PS4
    call expression_map#map#remove_map_word()
    return '$PS4'
  elseif (mword =~ '\v^p%[wd]$') " $PWD
    call expression_map#map#remove_map_word()
    return '$PWD'
  elseif (mword =~ '\v^r%[eply]$') " $REPLY
    call expression_map#map#remove_map_word()
    return '$REPLY'
  elseif (mword =~ '\v^s%[econds]$') " $SECONDS
    call expression_map#map#remove_map_word()
    return '$SECONDS'
  elseif (mword =~ '\v^s%[hell]o%[pts]$') " $SHELLOPTS
    call expression_map#map#remove_map_word()
    return '$SHELLOPTS'
  elseif (mword =~ '\v^s%[hlvl]$') " $SHLVL
    call expression_map#map#remove_map_word()
    return '$SHLVL'
  elseif (mword =~ '\v^t%[mout]$') " $TMOUT
    call expression_map#map#remove_map_word()
    return '$TMOUT'
  elseif (mword =~ '\v^u%[id]$') " $UID
    call expression_map#map#remove_map_word()
    return '$UID'
  "-------------------------------------------------------------------------------
  " BASH Function Start from here
  elseif (mword =~ '\v^r%[andom]$') " $RANDOM
    call expression_map#map#remove_map_word()
    return '$RANDOM'
  else " default
    return ''
  endif
endfunction
imap <M-i> =<SID>Exp_Map_Mi()
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
imap <buffer> <M-]> [[ maa ]]`aa
imap <buffer> <M-0> (( maa ))`aa
" --> imap <buffer> <M-]> [
" -->                    \  maa
" -->                    \]`aa
" --> imap <buffer> <M-0> (
" -->                    \  maa
" -->                    \)`aa
imap <buffer> <M-=> <Space>= 
imap <buffer> <M-.> -> 
imap <buffer> <M-/> f"a, 
imap <buffer> <C-CR> o
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


