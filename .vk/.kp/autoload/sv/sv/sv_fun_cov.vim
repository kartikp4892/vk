
"-------------------------------------------------------------------------------
" get_mark: Function
" Arg1 : mark character
" Arg2 : Message
"-------------------------------------------------------------------------------
function! s:get_mark(...)
  if (exists('a:2'))
    let a2 = a:2
  else
    let a2 = ''
  endif
  return common#mov_thru_user_mark#imap_alt_m(a:1, a2)
endfunction

"-------------------------------------------------------------------------------
" covergroup_event: Function
"-------------------------------------------------------------------------------
function! sv#sv#sv_fun_cov#covergroup_event()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  let name = 'cg_' . name

  call setline(".", repeat(' ', indent(".")))
  let str = comments#block_comment#getComments('Covergroup', '' . name)

  " common#mov_thru_user_mark#imap_alt_m --> return the mark templete

  let str .= 'covergroup ' . name . ' @(maa);
            \  ' . s:get_mark('a', 'Coverage Points') . '
            \endgroup : ' . name . '`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" covergroup: Function
"-------------------------------------------------------------------------------
function! sv#sv#sv_fun_cov#covergroup()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  let name = 'cg_' . name

  call setline(".", repeat(' ', indent(".")))
  let str = comments#block_comment#getComments('Covergroup', '' . name)

  " common#mov_thru_user_mark#imap_alt_m --> return the mark templete

  let str .= 'covergroup ' . name . ';
            \  maa' . s:get_mark('a', 'Coverage Points') . '
            \endgroup : ' . name . '`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" coverpoint: Function
"-------------------------------------------------------------------------------
function! sv#sv#sv_fun_cov#coverpoint()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))
  " let str = comments#block_comment#getComments('Coverpoint', '' . name)

  let str = 'cp_' . name . ' : coverpoint maa' . s:get_mark('1', 'Point') . ' {
            \  ' . s:get_mark('2', 'Bins') . '
            \}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" coverpoint_iff: Function
"-------------------------------------------------------------------------------
function! sv#sv#sv_fun_cov#coverpoint_iff()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))
  " let str = comments#block_comment#getComments('Coverpoint', '' . name)

  let str = 'cp_' . name . ' : coverpoint maa' . s:get_mark('1', 'Point') . ' iff (' . s:get_mark('2') . ') {
            \  ' . s:get_mark('3', 'Bins') . '
            \}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" bins: Function
"-------------------------------------------------------------------------------
function! sv#sv#sv_fun_cov#bins()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))
  " let str = comments#block_comment#getComments('Coverpoint', '' . name)

  let str = 'bins ' . name . ' = {maa};`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" wildcard_bins: Function
"-------------------------------------------------------------------------------
function! sv#sv#sv_fun_cov#wildcard_bins()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))
  " let str = comments#block_comment#getComments('Coverpoint', '' . name)

  let str = 'wildcard bins ' . name . ' = {maa};`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" bins_default: Function
"-------------------------------------------------------------------------------
function! sv#sv#sv_fun_cov#bins_default()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))
  " let str = comments#block_comment#getComments('Coverpoint', '' . name)

  let str = 'bins ' . name . ' = default;'
  return str
endfunction

"-------------------------------------------------------------------------------
" cross_block: Function
"-------------------------------------------------------------------------------
function! sv#sv#sv_fun_cov#cross_block()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))
  " let str = comments#block_comment#getComments('Coverpoint', '' . name)

  let str = 'cs_' . name . ' : cross maa' . s:get_mark('1', 'Cross Points') . ' {
            \  ' . s:get_mark('2', 'Ignore_Bins') . '
            \}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" cross: Function
"-------------------------------------------------------------------------------
function! sv#sv#sv_fun_cov#cross()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))
  " let str = comments#block_comment#getComments('Coverpoint', '' . name)

  let str = 'cs_' . name . ' : cross maa' . s:get_mark('1', 'Cross Points') . ';`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" ignore_bins: Function
"-------------------------------------------------------------------------------
function! sv#sv#sv_fun_cov#ignore_bins()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))
  " let str = comments#block_comment#getComments('Coverpoint', '' . name)

  let str = 'ignore_bins' . name . ' = '
  return str
endfunction

"-------------------------------------------------------------------------------
" illegal_bins: Function
"-------------------------------------------------------------------------------
function! sv#sv#sv_fun_cov#illegal_bins()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))
  " let str = comments#block_comment#getComments('Coverpoint', '' . name)

  let str = 'illegal_bins' . name . ' = '
  return str
endfunction

