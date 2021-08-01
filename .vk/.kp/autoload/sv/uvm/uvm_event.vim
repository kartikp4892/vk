"-------------------------------------------------------------------------------
" s:GetTemplete: Function
"-------------------------------------------------------------------------------
function! s:GetTemplete(char, ...)
  return common#mov_thru_user_mark#get_template(a:char, a:000)
endfunction

"-------------------------------------------------------------------------------
" wait_on: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_event#wait_on()
  let str = printf('wait_on(.delta(maa%s))`aa', s:GetTemplete('a', '/1''b0'))
  return str
endfunction

"-------------------------------------------------------------------------------
" wait_off: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_event#wait_off()
  let str = printf('wait_off(.delta(maa%s))`aa', s:GetTemplete('a', '/1''b0'))
  return str
endfunction

"-------------------------------------------------------------------------------
" wait_trigger: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_event#wait_trigger()
  let str = 'wait_trigger()'
  return str
endfunction

"-------------------------------------------------------------------------------
" reset: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_event#reset()
  let str = printf('reset(.wakeup(maa%s))`aa', s:GetTemplete('a', '/1''b0'))
  return str
endfunction

"-------------------------------------------------------------------------------
" trigger: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_event#trigger()
  let str = printf('trigger(.data(maa%s))`aa', s:GetTemplete('a', '/null'))
  return str
endfunction

"-------------------------------------------------------------------------------
" wait_ptrigger: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_event#wait_ptrigger()
  let str = 'wait_ptrigger()'
  return str
endfunction

"-------------------------------------------------------------------------------
" wait_trigger_data: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_event#wait_trigger_data()
  let str = printf('wait_trigger_data(.data(maa%s))`aa', s:GetTemplete('a', 'data'))
  return str
endfunction

"-------------------------------------------------------------------------------
" wait_ptrigger_data: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_event#wait_ptrigger_data()
  let str = printf('wait_ptrigger_data(.data(maa%s))`aa', s:GetTemplete('a', 'data'))
  return str
endfunction

"-------------------------------------------------------------------------------
" get_trigger_data: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_event#get_trigger_data()
  let str = 'get_trigger_data()'
  return str
endfunction

"-------------------------------------------------------------------------------
" get_trigger_time : Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_event#get_trigger_time()
  let str = 'get_trigger_time()'
  return str
endfunction

"-------------------------------------------------------------------------------
" add_callback : Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_event#add_callback()
  let str = printf('add_callback(.cb(maa%s), .append(%s))`aa', s:GetTemplete('a', 'uvm_event_callback'), s:GetTemplete('a', '/1''b1'))
  return str
endfunction

"-------------------------------------------------------------------------------
" delete_callback : Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_event#delete_callback()
  let str = printf('delete_callback(.cb(maa%s))`aa', s:GetTemplete('a', 'uvm_event_callback'))
  return str
endfunction

" ==============================================================================
" UVM_EVENT_POOL METHODS
" ==============================================================================



