let s:c_start = comments#variables#comment_begin

let s:c_mid = '-'
let s:c_end = '-'

"-------------------------------------------------------------------------------
" _set_indent: Function
"-------------------------------------------------------------------------------
function! s:_set_indent(offset)
  return '=common#indent#imode_set_indent(' . a:offset . ')'
endfunction

" Globle function
" @param a:0000 - Additional comments
fun! comments#block_comment#getComments(type, name, ...)
  if (g:comments#variables#enable_comment == 0)
    return ''
  endif

  " Check if user defined function exists which return the block comment string
  if (g:comments#variables#user_getComments != "")
    let arglist = [a:type] + [a:name] + a:000
    let usr_cmt = call(g:comments#variables#user_getComments, arglist)
    if (usr_cmt != -1)
      return usr_cmt
    endif
  endif

  let l:blk_comment = s:c_start . s:c_mid . repeat(s:c_end, 78) . ""
  if (a:type != '' && a:name != '')
    let l:blk_comment .= s:c_start . " " . a:type . " : " . a:name . ""
  endif
  for l:cmt in a:000
    let l:blk_comment .= s:c_start . " " . l:cmt . ""
  endfor
  let l:blk_comment .= s:c_start . s:c_mid . repeat(s:c_end, 78) . ""
  return l:blk_comment
endfun

fun! comments#block_comment#emptyComment()

  " Check if user defined function exists which return the comment string
  if (g:comments#variables#user_emptyComment != "")
    let usr_cmt = call(g:comments#variables#user_emptyComment, [])
    if (usr_cmt != -1)
      return usr_cmt
    endif
  endif

  let l:comment1 = s:c_start . s:c_mid . repeat(s:c_end, 78) . ''
  let l:comment2 = s:c_start . ' maa'
  let l:comment3 = s:c_start . s:c_mid . repeat(s:c_end, 78) . '`aa'
  return l:comment1 . l:comment2 . l:comment3
endfun

fun! comments#block_comment#midEnd()
  " Check if user defined function exists which return the comment string
  if (g:comments#variables#user_midEnd != "")
    let usr_cmt = call(g:comments#variables#user_midEnd, [])
    if (usr_cmt != -1)
      return usr_cmt
    endif
  endif

  echo "comment mid : "
  let s:c_mid = nr2char(getchar())
  echo "comment end : "
  let s:c_end = nr2char(getchar())
  return ''
endfun

"-------------------------------------------------------------------------------
" Other general block comment style
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" synp_comments: Function
" type = comments type
" type = comments name
" a:000 = Additional comments in array of each line
"-------------------------------------------------------------------------------
function! comments#block_comment#synp_comments(type, name, ...)
  if (g:comments#variables#enable_comment == 0)
    return ''
  endif

  " Systemverilog
  if (&filetype =~ '\v(sv$)|(v$)')
    return -1 " FIXME: Remove this line

    let arglist = [a:type] + [a:name] + a:000
    return call ('comments#block_comment#sv_synp_comments', arglist)
  " C/C++
  elseif (&filetype =~ '\v(([ch]pp|[ch])$)') 
    let arglist = [a:type] + [a:name] + a:000
    return call ('comments#block_comment#sv_synp_comments', arglist)
  else
    return -1
  endif
endfunction

"-------------------------------------------------------------------------------
" sv_synp_comments: Function
" type = comments type
" type = comments name
" a:000 = Additional comments in array of each line
"-------------------------------------------------------------------------------
function! comments#block_comment#sv_synp_comments(type, name, ...)
  let type = substitute(a:type, '.*', '\U\0', 'g')
  let extra_cmt = ''
  for l:cmt in a:000
    let extra_cmt .= s:_set_indent(0) . '* ' . l:cmt . ""
  endfor

  let str = '/**' .
          \ s:_set_indent(1) . '* ' . a:name . " " . a:type . ' ' .
          \ extra_cmt .
          \ s:_set_indent(0) . '*/' .
          \ s:_set_indent(-1)

  return str
endfunction


"-------------------------------------------------------------------------------
" Function : synp_emptyComment
"-------------------------------------------------------------------------------
function! comments#block_comment#synp_emptyComment()
  if (&filetype =~ '\v(sv$)|(v$)')
    return -1 " FIXME: Remove this line
    return comments#block_comment#sv_synp_emptyComment()
  elseif (&filetype =~ '\v(([ch]pp|[ch])$)') 
    return comments#block_comment#sv_synp_emptyComment()
  else
    return -1
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : synp_emptyComment
"-------------------------------------------------------------------------------
function! comments#block_comment#sv_synp_emptyComment()
  let str = '/**' .
          \ s:_set_indent(1) . '* maa' .
          \ s:_set_indent(0) . '*/' .
          \ s:_set_indent(-1) . '`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : synp_inlineComment
"-------------------------------------------------------------------------------
function! comments#block_comment#synp_inlineComment()
  if (&filetype =~ '\v(sv$)|(v$)')
    return comments#block_comment#sv_synp_inlineComment()
  else
    return -1
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : sv_synp_inlineComment
"-------------------------------------------------------------------------------
function! comments#block_comment#sv_synp_inlineComment()
  return '/** maa */`aa'
endfunction

