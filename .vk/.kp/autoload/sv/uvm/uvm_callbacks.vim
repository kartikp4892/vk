"-------------------------------------------------------------------------------
" s:GetTemplete: Function
"-------------------------------------------------------------------------------
function! s:GetTemplete(char, ...)
  return common#mov_thru_user_mark#get_template(a:char, a:000)
endfunction

"-------------------------------------------------------------------------------
" Function : ifndef
"-------------------------------------------------------------------------------
function! s:ifndef()
  if (line('.') == 1)
    let name = expand('%:t')
    let name = substitute(name, '\.', '_', 'g')
    return sv#sv#sv#ifndef(name)
  endif
  return ""
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

"-------------------------------------------------------------------------------
" monitor: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_callbacks#callback()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = s:get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  let str = s:ifndef()

  let str .=  s:_set_indent(0) . printf ('// TODO: 1. Register callback `%0s` with DRIVER using `uvm_register_cb', name) .
            \ s:_set_indent(0) .         '//       2. Perform `uvm_do_callbacks before or after driving packet' .
            \ s:_set_indent(0) . printf ('//       3. Extend %0s class to overrite virtual method %0s', name, s:GetTemplete('a', 'cb_method_name'))  .
            \ s:_set_indent(0) .         '//       4. Create object of extended class in top level component'  .
            \ s:_set_indent(0) .         '//       5. Add callback with callback object and driver object as shown below' .
            \ s:_set_indent(0) . printf ('//          uvm_callbacks #(DRIVER, %0s) :: add (m_drv, m_cb);', s:GetTemplete('a', 'cb_method_name'))

  let str .= comments#block_comment#getComments("Callback", "" . name )
  let str .= 'class ' . name . ' #(type DRIVER = uvm_driver, type ITEM = uvm_sequence_item) extends uvm_callback;' .
    \ s:_set_indent(&shiftwidth) . '`uvm_object_utils (' . name . ')' .
    \ s:_set_indent(0) . comments#block_comment#getComments("Function", "new") .
    \ s:_set_indent(0) . printf('function new(string name = "%0s");', name) .
    \ s:_set_indent(&shiftwidth) . 'super.new(name);' .
    \ s:_set_indent(-&shiftwidth) . 'endfunction : new' .
    \
    \ s:_set_indent(0) . comments#block_comment#getComments("Task", s:GetTemplete('a', 'cb_method_name')) .
    \ printf('virtual task %0s(DRIVER m_driver, ITEM m_item);', s:GetTemplete('a', 'cb_method_name')) .
    \ s:_set_indent(&shiftwidth) . 'maa' .
    \ s:_set_indent(0) . printf('endtask : %0s', s:GetTemplete('a', 'cb_method_name')) .
    \
    \ s:_set_indent(-&shiftwidth) . 'endclass : ' . name . '`aa'


  return str
endfunction

function! sv#uvm#uvm_callbacks#uvm_register_cb()
  let l:component = matchstr(getline(search('\v^[[:alnum:]_ ]*<class>', 'bn')), 'class\s\+\zs\w\+')
  let str = printf('`uvm_register_cb(%0s, maa%0s)`aa', l:component , s:GetTemplete('a', 'cb_type'))
  return str
endfunction

function! sv#uvm#uvm_callbacks#uvm_do_callbacks()
  let l:component = matchstr(getline(search('\v^[[:alnum:]_ ]*<class>', 'bn')), 'class\s\+\zs\w\+')
  let str = printf('`uvm_do_callbacks(%0s, maa%0s, %0s)`aa', l:component , s:GetTemplete('a', 'cb_type'), s:GetTemplete('a', 'cb_method_name'))
  return str
endfunction

function! sv#uvm#uvm_callbacks#uvm_callbacks_add()
  let l:component = matchstr(getline(search('\v^[[:alnum:]_ ]*<class>', 'bn')), 'class\s\+\zs\w\+')
  let str = printf('uvm_callbacks #(%0s, %0s) :: add (%0s, %0s)', s:GetTemplete('a', 'drv_type') , s:GetTemplete('a', 'cb_type'), s:GetTemplete('a', 'm_drv'), s:GetTemplete('a', 'm_cb'))
  return str
endfunction

function! sv#uvm#uvm_callbacks#uvm_callbacks_delete()
  let l:component = matchstr(getline(search('\v^[[:alnum:]_ ]*<class>', 'bn')), 'class\s\+\zs\w\+')
  let str = printf('uvm_callbacks #(%0s, %0s) :: delete (%0s, %0s)', s:GetTemplete('a', 'drv_type') , s:GetTemplete('a', 'cb_type'), s:GetTemplete('a', 'm_drv'), s:GetTemplete('a', 'm_cb'))
  return str
endfunction



