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
" get_default_name: Function
"-------------------------------------------------------------------------------
function! s:get_default_name()
  let name = expand('%:p:t')
  let name = substitute(name, '\v\.\w+$', '', '')
  return name
endfunction


function! matlab#oops#class()
  let name = matchstr(getline("."), '\w\+')
  call setline(line("."), repeat(" ", indent(".")))

  if (name == '')
    let name = s:get_default_name()
  endif

  let str = printf('classdef %0s < handle', name)
  let str .= s:_set_indent(&shiftwidth) . printf('%% %s', name)
  let str .= s:_set_indent(0) . 'properties'
  let str .= s:_set_indent(&shiftwidth) . 'Value % TODO: Update this logicmaa'
  let str .= s:_set_indent(-&shiftwidth) . 'end'
  let str .= s:_set_indent(0) . 'methods'
  let str .= s:_set_indent(&shiftwidth) . printf('function self = %s(Value)', name)
  let str .= s:_set_indent(&shiftwidth) . '% Constructor'
  let str .= s:_set_indent(0) . 'if narggin > 0'
  let str .= s:_set_indent(&shiftwidth) . 'if isnumeric(Value)'
  let str .= s:_set_indent(&shiftwidth) . 'self.Value = Value;'
  let str .= s:_set_indent(-&shiftwidth) . 'else'
  let str .= s:_set_indent(&shiftwidth) . "error('Value must be numeric')"
  let str .= s:_set_indent(-&shiftwidth) . 'end'
  let str .= s:_set_indent(-&shiftwidth) . 'end'
  let str .= s:_set_indent(-&shiftwidth) . 'end'
  let str .= s:_set_indent(-&shiftwidth) . 'end'
  let str .= s:_set_indent(-&shiftwidth) . 'end`aa'

  return str
endfunction


function! matlab#oops#function()
  let name = matchstr(getline("."), '\w\+')
  call setline(line("."), repeat(" ", indent(".")))

  if (name == '')
    let name = s:get_default_name()
  endif

  let str = printf('function maa%s = %s(self, %s)', s:GetTemplete('a', 'outargs'), name, s:GetTemplete('a', 'inargs'))
  let str .= s:_set_indent(&shiftwidth) . printf('%% %s', name)
  let str .= s:_set_indent(0) . ''
  let str .= s:_set_indent(-&shiftwidth) . 'end`aa'

  return str
endfunction

function! matlab#oops#enumeration_class()
  let name = matchstr(getline("."), '\w\+')
  call setline(line("."), repeat(" ", indent(".")))

  if (name == '')
    let name = s:get_default_name()
  endif

  let str = printf('classdef %0s < handle', name)
  let str .= s:_set_indent(&shiftwidth) . printf('%% %s', name)
  let str .= s:_set_indent(0) . 'properties'
  let str .= s:_set_indent(&shiftwidth) . 'Rmaa'
  let str .= s:_set_indent(0) . 'Gmaa'
  let str .= s:_set_indent(0) . 'Bmaa'
  let str .= s:_set_indent(-&shiftwidth) . 'end'
  let str .= s:_set_indent(0) . 'methods'
  let str .= s:_set_indent(&shiftwidth) . printf('function self = %s(r, g, b)', name)
  let str .= s:_set_indent(&shiftwidth) . '% Constructor'
  let str .= s:_set_indent(0) . 'c.R = r; c.G = g; c.B = b;'
  let str .= s:_set_indent(-&shiftwidth) . 'end'
  let str .= s:_set_indent(-&shiftwidth) . 'end'
  let str .= s:_set_indent(0) . 'enumeration'
  let str .= s:_set_indent(&shiftwidth) . 'Error (1, 0, 0)'
  let str .= s:_set_indent(0) . 'Comment (0, 1, 0)'
  let str .= s:_set_indent(0) . 'Keyword (0, 0, 1)'
  let str .= s:_set_indent(0) . 'String (1, 0, 1)'
  let str .= s:_set_indent(-&shiftwidth) . 'end'
  let str .= s:_set_indent(-&shiftwidth) . 'end`aa'

  return str
endfunction

function! matlab#oops#properties()

  let str = s:_set_indent(0) . 'properties'
  let str .= s:_set_indent(&shiftwidth) . 'maa'
  let str .= s:_set_indent(0) . 'end`aa'

  return str
endfunction





