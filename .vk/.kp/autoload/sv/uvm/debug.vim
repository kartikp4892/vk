let s:uvm_info_count = 1

function! s:debug_string()
  let str = printf('###___DEBUG_%0s___###', s:uvm_info_count)
  let s:uvm_info_count += 1
  return str
endfunction

function! sv#uvm#debug#uvm_info()
  let debug_str = s:debug_string()
  let str = printf('`uvm_info("%0s", $psprintf("%0s: maa", ),UVM_LOW)`aa', debug_str, debug_str)
  return str
endfunction


