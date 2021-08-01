function! alphanumero#cleanup#comments() range
  %pyfile $KP_VIM_HOME/python_lib/vim/lib/sv/alphanumero/parser/comment/cleanup.py
  silent! w!
endfunction

function! alphanumero#cleanup#uvm_info() range
  %pyfile $KP_VIM_HOME/python_lib/vim/lib/sv/alphanumero/parser/uvm_info/Combinators.py
  silent! w!
endfunction


function! alphanumero#cleanup#all() range
  %pyfile $KP_VIM_HOME/python_lib/vim/lib/sv/alphanumero/parser/uvm_info/Combinators.py
  %pyfile $KP_VIM_HOME/python_lib/vim/lib/sv/alphanumero/parser/comment/cleanup.py

  silent! w!
endfunction



