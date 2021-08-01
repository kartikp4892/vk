"-------------------------------------------------------------------------------
" s:GetTemplete: Function
"-------------------------------------------------------------------------------
function! s:GetTemplete(char, ...)
  return common#mov_thru_user_mark#get_template(a:char, a:000)
endfunction

"-------------------------------------------------------------------------------
" _set_indent: Function
"-------------------------------------------------------------------------------
function! s:_set_indent(offset)
  return '=common#indent#imode_set_indent(' . a:offset . ')'
endfunction

"-------------------------------------------------------------------------------
" Function : s:get_current_class_name
"-------------------------------------------------------------------------------
function! s:get_current_class_name()
  let ln = search('\v^\s*class\s+\w+', 'bn')
  let class_name = matchstr(getline(ln), '\v^\s*class\s+\zs\w+')
  return class_name
endfunction


"-------------------------------------------------------------------------------
" Function : class
"-------------------------------------------------------------------------------
function! scala#oops#class()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  let str = comments#block_comment#getComments('Class', name)
  let str .= printf('class %0s(maa) {', name) .
           \ s:_set_indent(&shiftwidth) . '' .
           \ s:_set_indent(0) . '}`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : class_extends
"-------------------------------------------------------------------------------
function! scala#oops#class_extends()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  let str = comments#block_comment#getComments('Class', name)
  let str .= printf('class %0s(maa) extends %0s() {', name, s:GetTemplete('a', 'parent')) .
           \ s:_set_indent(&shiftwidth) . '' .
           \ s:_set_indent(0) . '}`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : function
"-------------------------------------------------------------------------------
function! scala#oops#function()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  let str = comments#block_comment#getComments('Method', var)
  let str .= printf('def %0s (maa) = {', var) .
           \ s:_set_indent(&shiftwidth) . '' .
            \ s:_set_indent(0) . '}`aa'

  return str
endfunction



