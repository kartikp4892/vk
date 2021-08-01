"-------------------------------------------------------------------------------
" s:GetTemplete: Function
"-------------------------------------------------------------------------------
function! s:GetTemplete(char, ...)
  return common#mov_thru_user_mark#get_template(a:char, a:000)
endfunction

"-------------------------------------------------------------------------------
" Global Variables
"-------------------------------------------------------------------------------
let sv#glob_var#sv_methodology = "UVM" " FIXME UVM TODO

let sv#glob_var#seq_item = s:GetTemplete('a', 'trans')
let sv#glob_var#m_seq_item = s:GetTemplete('a', 'm_trans')
let sv#glob_var#interface = s:GetTemplete('a', 'interface')
let sv#glob_var#m_interface = s:GetTemplete('a', 'm_interface')

"-------------------------------------------------------------------------------
" UVM Monitor
"-------------------------------------------------------------------------------
let sv#glob_var#mon_analysis_port = s:GetTemplete('a', 'mon_ap')





