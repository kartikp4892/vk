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

function! cpp#exception#try_catch()
  let str = 'try {' .
          \ s:_set_indent(&shiftwidth) . 'maa' .
          \s:_set_indent(0) . '}' .
          \s:_set_indent(0) . 'catch (...) {' .
          \s:_set_indent(&shiftwidth) . '' .
          \s:_set_indent(0) . '}`aa'
  return str
endfunction


function! cpp#exception#catch()
  let str = 'catch (maa...) {' .
          \s:_set_indent(&shiftwidth) . '' .
          \s:_set_indent(0) . '}`aa'
  return str
endfunction

function! cpp#exception#exception()
  let name = matchstr(getline("."), '\w\+')
  call setline(line("."), repeat(" ", indent(".")))

  if (name == '')
    let name = s:GetTemplete('a', 'name')
  endif

  let str = printf('struct maa%0s : public exception {', name)
  let str .= s:_set_indent(&shiftwidth) . 'const char * what () const throw () {'
  let str .= s:_set_indent(&shiftwidth) . printf('return "%0s";', s:GetTemplete('a', 'C++ Exception'))
  let str .= s:_set_indent(-&shiftwidth) . '}'
  let str .= s:_set_indent(-&shiftwidth) . '};`aa'

  return str
endfunction












