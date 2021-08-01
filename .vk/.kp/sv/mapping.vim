
"-------------------------------------------------------------------------------
" Exp_Map_SMm: Function
" Monitor
function! s:Exp_Map_SMm()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^u$')
    call expression_map#map#remove_map_word()
    return sv#uvm#mapping#monitor()
  else
    return ''
  endif
endfunction
imap <S-M-m> =<SID>Exp_Map_SMm()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Ml: Function
" Monitor
function! s:Exp_Map_Ml()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^u%[vm]$')
    call expression_map#map#remove_map_word()
    return 'import uvm_pkg::*;`include "uvm_macros.svh"'
  else
    return ''
  endif
endfunction
imap <M-l> =<SID>Exp_Map_Ml()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Me: Function
" UVM Event
function! s:Exp_Map_Me()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^u%[vm]e%[vent]$') " 
    call expression_map#map#remove_map_word()
    return 'uvm_event '
  elseif (mword =~ '\v^w%[ait]o%[n]$') " wait_on
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_event#wait_on()
  elseif (mword =~ '\v^w%[ait]o%[ff]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_event#wait_off()
  elseif (mword =~ '\v^w%[ait]t%[rigger]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_event#wait_trigger()
  elseif (mword =~ '\v^w%[ait]p%[trigger]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_event#wait_ptrigger()
  elseif (mword =~ '\v^w%[ait]t%[rigger]d%[ata]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_event#wait_trigger_data()
  elseif (mword =~ '\v^w%[ait]p%[trigger]d%[ata]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_event#wait_ptrigger_data()
  elseif (mword =~ '\v^t%[rigger]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_event#trigger()
  elseif (mword =~ '\v^g%[et]t%[rigger]d%[ata]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_event#get_trigger_data()
  elseif (mword =~ '\v^g%[et]t%[rigger]t%[ime]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_event#get_trigger_time()
  elseif (mword =~ '\v^i%[s]o%[n]$')
    call expression_map#map#remove_map_word()
    return 'is_on()'
  elseif (mword =~ '\v^i%[s]o%[ff]$')
    call expression_map#map#remove_map_word()
    return 'is_off()'
  elseif (mword =~ '\v^r%[eset]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_event#reset()
  elseif (mword =~ '\v^a%[dd]c%[all]%[back]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_event#add_callback()
  elseif (mword =~ '\v^d%[elete]c%[all]%[back]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_event#delete_callback()
  elseif (mword =~ '\v^c%[ancel]$')
    call expression_map#map#remove_map_word()
    return 'cancel()'
  elseif (mword =~ '\v^g%[et]n%[um]w%[aiters]$')
    call expression_map#map#remove_map_word()
    return 'get_num_waiters()'
  "-------------------------------------------------------------------------------
  " UVM_EVENT_POOL METHODS START FROM HERE
  elseif (mword =~ '\v^u%[vm]e%[vent]p%[ool]$')
    call expression_map#map#remove_map_word()
    return 'uvm_event_pool '
  elseif (mword =~ '\v^g%[et]g%[lobal]p%[ool]$')
    call expression_map#map#remove_map_word()
    return 'get_global_pool()'
  else
    return ''
  endif
endfunction
imap <M-e> =<SID>Exp_Map_Me()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Mr: Function
" Monitor
function! s:Exp_Map_Mr()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^s%[td]r%[andomize]$') " std::randomize()
    call expression_map#map#remove_map_word()
    return sv#sv#sv#std_randomize()
  elseif (mword =~ '\v^r%[andomize]$')
    call expression_map#map#remove_map_word()
    return sv#sv#sv#complete('sv#sv#sv#randomize', -1)
  elseif (mword =~ '\v^f%[or]e%[ach]$')
    call expression_map#map#remove_map_word()
    return sv#sv#sv#cforeach()
  elseif (mword =~ '\v^i%[f]$')
    call expression_map#map#remove_map_word()
    return sv#sv#sv#cif()
  elseif (mword =~ '\v^e%[lse]%[i]f$')
    call expression_map#map#remove_map_word()
    return sv#sv#sv#celseif()
  elseif (mword =~ '\v^e%[lse]$')
    call expression_map#map#remove_map_word()
    return sv#sv#sv#celse()
  elseif (mword =~ '\v^c%[onstraint]$')
    call expression_map#map#remove_map_word()
    return 'constraint c_maa {  }`aa'
  elseif (mword =~ '\v^s%[olve]b%[efore]$')
    call expression_map#map#remove_map_word()
    return 'solve maa before `aa'
  elseif (mword =~ '\v^p%[re]r%[andomize]$')
    call expression_map#map#remove_map_word()
    return sv#sv#sv#pre_randomize()
  elseif (mword =~ '\v^p%[ost]r%[andomize]$')
    call expression_map#map#remove_map_word()
    return sv#sv#sv#post_randomize()
  elseif (mword =~ '\v^c%[onstraint_]m%[ode]$')
    call expression_map#map#remove_map_word()
    return "constraint_mode (maa);`aa"
  elseif (mword =~ '\v^r%[and_]m%[ode]$')
    call expression_map#map#remove_map_word()
    return "rand_mode (maa);`aa"
  else
    return ''
  endif
endfunction
imap <M-r> =<SID>Exp_Map_Mr()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Ma: Function
" Register Adaptor
function! s:Exp_Map_Ma()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^%[uvm]r%[eg]$') " uvm_reg
    call expression_map#map#remove_map_word()
    return sv#uvm#register_adaptor#uvm_reg()
  elseif (mword =~ '\v^%[uvm]m%[em]$') " uvm_reg
    call expression_map#map#remove_map_word()
    return sv#uvm#register_adaptor#uvm_mem()
  elseif (mword =~ '\v^%[uvm]%[reg]b%[lock]$') " uvm_reg
    call expression_map#map#remove_map_word()
    return sv#uvm#register_adaptor#uvm_reg_block()
  elseif (mword =~ '\v^%[uvm]%[register]a%[daptor]$') " uvm_register_adaptor
    call expression_map#map#remove_map_word()
    return sv#uvm#register_adaptor#register_adaptor()
  elseif (mword =~ '\v^%[uvm]%[register]%[adaptor]r%[eg]%[2]b%[us]$') " uvm_register_adaptor::reg2bus
    call expression_map#map#remove_map_word()
    return sv#uvm#register_adaptor#reg2bus()
  elseif (mword =~ '\v^%[uvm]%[register]%[adaptor]b%[us]%[2]r%[eg]$') " uvm_register_adaptor::reg2bus
    call expression_map#map#remove_map_word()
    return sv#uvm#register_adaptor#bus2reg()
  elseif (mword =~ '\v^%[uvm]%[reg]c%[onfigure]$') " uvm_reg_field::configure
    call expression_map#map#remove_map_word()
    return sv#uvm#register_adaptor#uvm_reg_configure()
  elseif (mword =~ '\v^%[uvm]%[reg]p%[redictor]$') " uvm_reg_predictor
    call expression_map#map#remove_map_word()
    return sv#uvm#register_adaptor#uvm_reg_predictor()
  elseif (mword =~ '\v^%[uvm]%[reg]s%[equence]$') " uvm_reg_sequence
    call expression_map#map#remove_map_word()
    return sv#uvm#register_adaptor#uvm_reg_sequence()
  elseif (mword =~ '\v^%[uvm]%[reg]s%[equence]w%[rite_]r%[reg]$') " uvm_reg_sequence::write_reg
    call expression_map#map#remove_map_word()
    return sv#uvm#register_adaptor#uvm_reg_sequence_write_reg()
  elseif (mword =~ '\v^%[uvm]%[reg]s%[equence]r%[ead_]r%[reg]$') " uvm_reg_sequence::write_reg
    call expression_map#map#remove_map_word()
    return sv#uvm#register_adaptor#uvm_reg_sequence_read_reg()
  elseif (mword =~ '\v^%[uvm]%[reg]%[field]c%[onfigure]$') " uvm_reg_field::configure
    call expression_map#map#remove_map_word()
    return sv#uvm#register_adaptor#uvm_reg_field_configure()
  elseif (mword =~ '\v^%[uvm]%[reg]%[block]c%[reate]m%[ap]$') " uvm_reg_block::create::map
    call expression_map#map#remove_map_word()
    return sv#uvm#register_adaptor#uvm_reg_block_create_map()
  elseif (mword =~ '\v^%[uvm]%[reg]%[map]a%[dd]r%[eg]$') " uvm_reg_map::add_reg
    call expression_map#map#remove_map_word()
    return sv#uvm#register_adaptor#uvm_reg_map_add_reg()
  elseif (mword =~ '\v^%[uvm]%[reg]%[map]a%[dd]m%[em]$') " uvm_reg_map::add_mem
    call expression_map#map#remove_map_word()
    return sv#uvm#register_adaptor#uvm_reg_map_add_mem()
  elseif (mword =~ '\v^%[uvm]%[reg]%[map]s%[et]s%[equencer]$') " uvm_reg_map::set_sequencer
    call expression_map#map#remove_map_word()
    return sv#uvm#register_adaptor#reg_map_set_sequencer()
  elseif (mword =~ '\v^%[uvm]%[reg]%[map]s%[et]a%[uto]p%[redict]$') " uvm_reg_map::set_auto_predict
    call expression_map#map#remove_map_word()
    return sv#uvm#register_adaptor#reg_map_set_auto_predict()
  else
    return ''
  endif
endfunction
imap <M-a> =<SID>Exp_Map_Ma()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" s:GetTemplete: Function
"-------------------------------------------------------------------------------
function! s:GetTemplete(char, ...)
  return common#mov_thru_user_mark#get_template(a:char, a:000)
endfunction

"-------------------------------------------------------------------------------
" Exp_Map_Cd: Function
" Driver & Monitor
function! s:Exp_Map_Cd()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^u?$')
    call expression_map#map#remove_map_word()
    return sv#uvm#mapping#driver()
  elseif (mword =~ '\v^g%[et_]n%[ext_]i%[tem]$')
    call expression_map#map#remove_map_word()
    return printf('seq_item_port.get_next_item(maa%s);' , s:GetTemplete('b', 'trans')).
           \'  ' .
           \'seq_item_port.item_done();`aa'
  else
    return ''
  endif
endfunction
imap <S-M-d> =<SID>Exp_Map_Cd()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Mt: Function
" TLM
function! s:Exp_Map_Mt()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^u%[vm_]b%[locking_]p%[ut_]p%[ort]?$')
    call expression_map#map#remove_map_word()
    return printf('uvm_blocking_put_port#(%s) put_port;' , s:GetTemplete('b', 'trans'))
  elseif (mword =~ '\v^u%[vm_]b%[locking_]p%[ut_]i%[mp]?$')
    call expression_map#map#remove_map_word()
    return sv#uvm#mapping#uvm_blocking_put_imp()
  elseif (mword =~ '\v^u%[vm_]n%[onblocking_]p%[ut_]p%[ort]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_nonblocking_put_port #(%s) %s', s:GetTemplete('a', 'trans'), s:GetTemplete('b', 'this') )
  elseif (mword =~ '\v^u%[vm_]p%[ut_]p%[ort]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_put_port #(%s) %s', s:GetTemplete('a', 'trans'), s:GetTemplete('b', 'this') )
  elseif (mword =~ '\v^u%[vm_]b%[locking_]g%[et_]p%[ort]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_blocking_get_port #(maa%s) %s`aa', s:GetTemplete('a', 'trans'), s:GetTemplete('b', 'this') )
  elseif (mword =~ '\v^u%[vm_]n%[onblocking_]g%[et_]p%[ort]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_nonblocking_get_port #(maa%s) %s`aa', s:GetTemplete('a', 'trans'), s:GetTemplete('b', 'this') )
  elseif (mword =~ '\v^u%[vm_]g%[et_]p%[ort]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_get_port #(maa%s) %s`aa', s:GetTemplete('a', 'trans'), s:GetTemplete('b', 'this') )
  elseif (mword =~ '\v^u%[vm_]b%[locking]p%[eek]p%[ort]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_blocking_peek_port #(%s) %s', s:GetTemplete('a', 'trans'), s:GetTemplete('b', 'this') )
  elseif (mword =~ '\v^u%[vm_]n%[onblocking]p%[eek]p%[ort]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_nonblocking_peek_port #(%s) %s', s:GetTemplete('a', 'trans'), s:GetTemplete('b', 'this') )
  elseif (mword =~ '\v^u%[vm_]p%[eek]p%[ort]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_peek_port #(%s) %s', s:GetTemplete('a', 'trans'), s:GetTemplete('b', 'this') )
  elseif (mword =~ '\v^u%[vm_]b%[locking]g%[et]p%[eek]p%[ort]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_blocking_get_peek_port #(%s) %s', s:GetTemplete('a', 'trans'), s:GetTemplete('b', 'this') )
  elseif (mword =~ '\v^u%[vm_]n%[onblocking]g%[et]p%[eek]p%[ort]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_nonblocking_get_peek_port #(%s) %s', s:GetTemplete('a', 'trans'), s:GetTemplete('b', 'this') )
  elseif (mword =~ '\v^u%[vm_]g%[et]p%[eek]p%[ort]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_get_peek_port #(%s) %s', s:GetTemplete('a', 'trans'), s:GetTemplete('b', 'this') )
  elseif (mword =~ '\v^u%[vm_]a%[nalysis]p%[ort]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_analysis_port #(maa%s) %s`aa', s:GetTemplete('a', 'trans'), s:GetTemplete('b', 'this') )
  elseif (mword =~ '\v^u%[vm_]t%[ransport]p%[ort]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_transport_port #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('b', 'obj') )
  elseif (mword =~ '\v^u%[vm_]b%[locking]t%[ransport]p%[ort]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_blocking_transport_port #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('b', 'obj') )
  elseif (mword =~ '\v^u%[vm_]n%[nonblocking]t%[ransport]p%[ort]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_nonblocking_transport_port #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('b', 'obj') )
  elseif (mword =~ '\v^u%[vm_]m%[aster]p%[ort]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_master_port #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('b', 'obj') )
  elseif (mword =~ '\v^u%[vm_]b%[locking]m%[aster]p%[ort]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_blocking_master_port #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('b', 'obj') )
  elseif (mword =~ '\v^u%[vm_]n%[onblocking]m%[aster]p%[ort]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_nonblocking_master_port #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('b', 'obj') )
  elseif (mword =~ '\v^u%[vm_]s%[lave]p%[ort]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_slave_port #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('b', 'obj') )
  elseif (mword =~ '\v^u%[vm_]b%[locking]s%[lave]p%[ort]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_blocking_slave_port #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('b', 'obj') )
  elseif (mword =~ '\v^u%[vm_]n%[onblocking]s%[lave]p%[ort]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_nonblocking_slave_port #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('b', 'obj') )
  elseif (mword =~ '\v^u%[vm_]p%[ut]e%[xport]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_put_export #(%s) %s', s:GetTemplete('a', 'trans'), s:GetTemplete('b', 'obj') )
  elseif (mword =~ '\v^u%[vm_]b%[locking]p%[ut]e%[xport]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_blocking_put_export #(%s) %s', s:GetTemplete('a', 'trans'), s:GetTemplete('b', 'obj') )
  elseif (mword =~ '\v^u%[vm_]n%[onblocking]p%[ut]e%[xport]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_nonblocking_put_export #(%s) %s', s:GetTemplete('a', 'trans'), s:GetTemplete('b', 'obj') )
  elseif (mword =~ '\v^u%[vm_]g%[et]e%[xport]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_get_export #(%s) %s', s:GetTemplete('a', 'trans'), s:GetTemplete('b', 'obj') )
  elseif (mword =~ '\v^u%[vm_]b%[locking]g%[et]e%[xport]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_blocking_get_export #(%s) %s', s:GetTemplete('a', 'trans'), s:GetTemplete('b', 'obj') )
  elseif (mword =~ '\v^u%[vm_]n%[onblocking]g%[et]e%[xport]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_nonblocking_get_export #(%s) %s', s:GetTemplete('a', 'trans'), s:GetTemplete('b', 'obj') )
  elseif (mword =~ '\v^u%[vm_]p%[eek]e%[xport]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_peek_export #(%s) %s', s:GetTemplete('a', 'trans'), s:GetTemplete('b', 'obj') )
  elseif (mword =~ '\v^u%[vm_]b%[locking]p%[eek]e%[xport]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_blocking_peek_export #(%s) %s', s:GetTemplete('a', 'trans'), s:GetTemplete('b', 'obj') )
  elseif (mword =~ '\v^u%[vm_]n%[onblocking]p%[eek]e%[xport]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_nonblocking_peek_export #(%s) %s', s:GetTemplete('a', 'trans'), s:GetTemplete('b', 'obj') )
  elseif (mword =~ '\v^u%[vm_]g%[et]p%[eek]e%[xport]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_get_peek_export #(%s) %s', s:GetTemplete('a', 'trans'), s:GetTemplete('b', 'obj') )
  elseif (mword =~ '\v^u%[vm_]b%[locking]g%[et]p%[eek]e%[xport]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_blocking_get_peek_export #(%s) %s', s:GetTemplete('a', 'trans'), s:GetTemplete('b', 'obj') )
  elseif (mword =~ '\v^u%[vm_]n%[onblocking]g%[et]p%[eek]e%[xport]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_nonblocking_get_peek_export #(%s) %s', s:GetTemplete('a', 'trans'), s:GetTemplete('b', 'obj') )
  elseif (mword =~ '\v^u%[vm_]a%[nalysis]e%[xport]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_analysis_export #(maa%s) %s`aa', s:GetTemplete('a', 'trans'), s:GetTemplete('b', 'obj') )
  elseif (mword =~ '\v^u%[vm_]t%[ransport]e%[xport]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_transport_export #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj') )
  elseif (mword =~ '\v^u%[vm_]n%[onblocking]t%[ransport]e%[xport]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_nonblocking_transport_export #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj') )
  elseif (mword =~ '\v^u%[vm_]m%[aster]e%[xport]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_master_export #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj') )
  elseif (mword =~ '\v^u%[vm_]b%[locking]m%[aster]e%[xport]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_blocking_master_export #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj') )
  elseif (mword =~ '\v^u%[vm_]n%[onblocking]m%[aster]e%[xport]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_nonblocking_master_export #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj') )
  elseif (mword =~ '\v^u%[vm_]s%[lave]e%[xport]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_slave_export #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj') )
  elseif (mword =~ '\v^u%[vm_]b%[locking]s%[lave]e%[xport]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_blocking_slave_export #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj') )
  elseif (mword =~ '\v^u%[vm_]n%[onblocking]s%[lave]e%[xport]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_nonblocking_slave_export #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj') )
  elseif (mword =~ '\v^u%[vm_]p%[ut]i%[mp]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_put_imp #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj') )
  elseif (mword =~ '\v^u%[vm_]b%[locking]p%[ut]i%[mp]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_blocking_put_imp #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj') )
  elseif (mword =~ '\v^u%[vm_]n%[onblocking]p%[ut]i%[mp]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_nonblocking_put_imp #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj') )
  elseif (mword =~ '\v^u%[vm_]g%[et]i%[mp]?$')
    call expression_map#map#remove_map_word()
    return sv#uvm#mapping#uvm_get_imp()
  elseif (mword =~ '\v^u%[vm_]b%[locking]g%[et]i%[mp]?$')
    call expression_map#map#remove_map_word()
    return sv#uvm#mapping#uvm_blocking_get_imp()
  elseif (mword =~ '\v^u%[vm_]n%[onblocking]g%[et]i%[mp]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_nonblocking_get_imp #(maa%s, %s) %s`aa', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj') )
  elseif (mword =~ '\v^u%[vm_]p%[eek]i%[mp]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_peek_imp #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj') )
  elseif (mword =~ '\v^u%[vm_]b%[locking]p%[eek]i%[mp]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_blocking_peek_imp #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj') )
  elseif (mword =~ '\v^u%[vm_]n%[onblocking]p%[eek]i%[mp]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_nonblocking_peek_imp #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj') )
  elseif (mword =~ '\v^u%[vm_]g%[et]p%[eek]i%[mp]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_get_peek_imp #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj') )
  elseif (mword =~ '\v^u%[vm_]b%[locking]g%[et]p%[eek]i%[mp]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_blocking_get_peek_imp #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj') )
  elseif (mword =~ '\v^u%[vm_]n%[onblocking]g%[et]p%[eek]i%[mp]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_nonblocking_get_peek_imp #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj') )
  elseif (mword =~ '\v^u%[vm_]a%[nalysis]i%[mp]?$')
    call expression_map#map#remove_map_word()
    return sv#uvm#mapping#uvm_analysis_imp()
  elseif (mword =~ '\v^u%[vm_]t%[ransport]i%[mp]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_transport_imp #(%s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj') )
  elseif (mword =~ '\v^u%[vm_]b%[locking]t%[ransport]i%[mp]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_blocking_transport_imp #(%s, %s, %s, %s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj'), s:GetTemplete('a', 'req') )
  elseif (mword =~ '\v^u%[vm_]n%[onblocking]t%[ransport]i%[mp]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_nonblocking_transport_imp #(%s, %s, %s, %s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj'), s:GetTemplete('a', 'req') )
  elseif (mword =~ '\v^u%[vm_]m%[aster]i%[mp]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_master_imp #(%s, %s, %s, %s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj'), s:GetTemplete('a', 'req') )
  elseif (mword =~ '\v^u%[vm_]b%[locking]m%[aster]i%[mp]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_blocking_master_imp #(%s, %s, %s, %s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj'), s:GetTemplete('a', 'req') )
  elseif (mword =~ '\v^u%[vm_]n%[onblocking]m%[aster]i%[mp]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_nonblocking_master_imp #(%s, %s, %s, %s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj'), s:GetTemplete('a', 'req') )
  elseif (mword =~ '\v^u%[vm_]s%[lave]i%[mp]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_slave_imp #(%s, %s, %s, %s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj'), s:GetTemplete('a', 'req') )
  elseif (mword =~ '\v^u%[vm_]b%[locking]s%[lave]i%[mp]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_blocking_slave_imp #(%s, %s, %s, %s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj'), s:GetTemplete('a', 'req') )
  elseif (mword =~ '\v^u%[vm_]n%[onblocking]s%[lave]i%[mp]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_nonblocking_slave_imp #(%s, %s, %s, %s, %s) %s', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj'), s:GetTemplete('b', 'rsp'), s:GetTemplete('c', 'obj'), s:GetTemplete('a', 'req') )
  elseif (mword =~ '\v^u%[vm_]t%[lm]r%[eq]r%[sp]c%[hannel]?$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_tlm_req_rsp_channel #(maa%s, %s) `aa', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp') )
  elseif (mword =~ '\v^u%[vm_]t%[lm]a%[nalysis]f%[ifo]$')
    call expression_map#map#remove_map_word()
    return printf( 'uvm_tlm_analysis_fifo #(maa%s) %s;`aa', s:GetTemplete('a', 'req'), s:GetTemplete('b', 'rsp') )
  "############################################################################
  " TLM Macros from here
  elseif (mword =~ '\v^u%[vm_]a%[nalysis]i%[mp]d%[ecl]?$')
    call expression_map#map#remove_map_word()
    return printf( '`uvm_analysis_imp_decl (maa%s)`aa', s:GetTemplete('a', 'PORT_NAME') )
  else
    return ''
  endif
endfunction
imap <M-t> =<SID>Exp_Map_Mt()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Mp: Function
" Phases
function! s:Exp_Map_Mp()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^b%[uild]p%[hase]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_phases#build_phase()
  elseif (mword =~ '\v^c%[onnect]p%[hase]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_phases#connect_phase()
  elseif (mword =~ '\v^s%[tart]%[of]%[simulation]p%[hase]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_phases#start_of_simulation_phase()
  elseif (mword =~ '\v^e%[nd]%[of]e%[laboration]p%[hase]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_phases#end_of_elaboration_phase()
  elseif (mword =~ '\v^r%[un]p%[hase]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_phases#run_phase()
  elseif (mword =~ '\v^c%[heck]p%[hase]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_phases#check_phase()
  elseif (mword =~ '\v^r%[eport]p%[hase]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_phases#report_phase()
  elseif (mword =~ '\v^e%[xtract]p%[hase]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_phases#extract_phase()
  elseif (mword =~ '\v^f%[inal]p%[hase]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_phases#final_phase()
  elseif (mword =~ '\v^b%[uild]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_phases#build()
  elseif (mword =~ '\v^c%[onnect]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_phases#connect()
  elseif (mword =~ '\v^r%[un]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_phases#run()
  elseif (mword =~ '\v^r%[eset_]p%[hase]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_phases#reset_phase()
  elseif (mword =~ '\v^c%[onfigure_]p%[hase]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_phases#configure_phase()
  elseif (mword =~ '\v^m%[ain_]p%[hase]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_phases#main_phase()
  elseif (mword =~ '\v^r%[aise]o%[bjection]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_phases#raise_objection()
  elseif (mword =~ '\v^s%[et]d%[rain]t%[ime]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_phases#set_drain_time()
  " Sequence Item User-Defined Hooks
  elseif (mword =~ '\v^d%[o_]p%[rint]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_phases#do_print()
  elseif (mword =~ '\v^d%[o_]c%[ompare]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_phases#do_compare()
  elseif (mword =~ '\v^d%[o_]c%[opy]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_phases#do_copy()
  elseif (mword =~ '\v^d%[o_]p%[ack]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_phases#do_pack()
  elseif (mword =~ '\v^c%[onvert]2%[string]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_phases#convert2string()
  elseif (mword =~ '\v^d%[o_]u%[n]p%[ack]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_phases#do_unpack()
  elseif (mword =~ '\v^d%[o_]r%[ecorder]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_phases#do_record()
  " Sequence body, pre_body, post_body
  elseif (mword =~ '\v^p%[re_]b%[ody]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_phases#pre_body()
  elseif (mword =~ '\v^p%[ost_]b%[ody]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#uvm_phases#post_body()
  else
    return ''
  endif
endfunction
imap <M-p> =<SID>Exp_Map_Mp()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Mf: Function
" Factory
function! s:Exp_Map_Mf()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^t%[ypeid]c%[reate]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#mapping#type_id_create()
  elseif (mword =~ '\v^t%[ypeid]s%[et_]%[type_]%[override]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#mapping#type_id_set_type_override()
  elseif (mword =~ '\v^t%[ypeid]s%[et_]%[inst_]%[override]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#mapping#type_id_set_inst_override()
  elseif (mword =~ '\v^u%[vm_]%[config_]%[db]s%[et]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#mapping#uvm_config_db_set()
  elseif (mword =~ '\v^%[vm_]d%[efault]s%[equence]%[set]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#mapping#default_sequence_set()
  elseif (mword =~ '\v^u%[vm_]%[config_]%[db]g%[et]$')
    call expression_map#map#remove_map_word()
    return sv#uvm#mapping#uvm_config_db_get()
  else
    return ''
  endif
endfunction
imap <M-f> =<SID>Exp_Map_Mf()
"-------------------------------------------------------------------------------
"-------------------------------------------------------------------------------
" Exp_Map_Mg: Function
function! s:Exp_Map_Mg()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^if?$')
    call expression_map#map#remove_map_word()
    return sv#sv#sv#if()
  elseif (mword == 'ef')
    call expression_map#map#remove_map_word()
    return sv#sv#sv#elseif()
  elseif (mword == 'el')
    call expression_map#map#remove_map_word()
    return sv#sv#sv#else()
  elseif (mword =~ '\v^cif?$')
    call expression_map#map#remove_map_word()
    return sv#sv#sv#cif()
  elseif (mword == 'cef')
    call expression_map#map#remove_map_word()
    return sv#sv#sv#celseif()
  elseif (mword == 'cel')
    call expression_map#map#remove_map_word()
    return sv#sv#sv#celse()
  elseif (mword =~ '\v^c%[ase]$') " case
    call expression_map#map#remove_map_word()
    return sv#sv#sv#case()
  else
    return ''
  endif
endfunction
imap <M-g> =<SID>Exp_Map_Mg()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Mv: Function
" Mapping for Functional Coverage
function! s:Exp_Map_Mv()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^%[cover]g%[roup]e%[vent]$') " Cover Group with Event
    call expression_map#map#remove_map_word()
    return sv#sv#sv_fun_cov#covergroup_event()
  elseif (mword =~ '\v^%[cover]g%[roup]$') " Cover Group
    call expression_map#map#remove_map_word()
    return sv#sv#sv_fun_cov#covergroup()
  elseif (mword =~ '\v^%[cover]p%[oint]$') " Cover Point
    call expression_map#map#remove_map_word()
    return sv#sv#sv_fun_cov#coverpoint()
  elseif (mword =~ '\v^%[cover]p%[oint]i%[ff]$') " Cover Point iff
    call expression_map#map#remove_map_word()
    return sv#sv#sv_fun_cov#coverpoint_iff()
  elseif (mword =~ '\v^%[cover]b%[ins]$') " Cover bins
    call expression_map#map#remove_map_word()
    return sv#sv#sv_fun_cov#bins()
  elseif (mword =~ '\v^%[cover]b%[ins]d%[efault]$') " Cover bins default
    call expression_map#map#remove_map_word()
    return sv#sv#sv_fun_cov#bins_default()
  elseif (mword =~ '\v^b%[lock]c%[ross]$') " Cross Coverage block --> cross .. { ignore_bins ... }
    call expression_map#map#remove_map_word()
    return sv#sv#sv_fun_cov#cross_block()
  elseif (mword =~ '\v^c%[ross]$') " Cross Coverage --> cross ..;
    call expression_map#map#remove_map_word()
    return sv#sv#sv_fun_cov#cross()
  elseif (mword =~ '\v^w%[ildcard]b%[ins]$') " Wildcard bins
    call expression_map#map#remove_map_word()
    return sv#sv#sv_fun_cov#wildcard_bins()
  elseif (mword =~ '\v^w%[ildcard]$') " Wildcard
    call expression_map#map#remove_map_word()
    return 'wildcard '
  elseif (mword =~ '\v^i%[gnore]b%[ins]$') " ignore bins
    call expression_map#map#remove_map_word()
    return sv#sv#sv_fun_cov#ignore_bins()
  elseif (mword =~ '\v^i%[llegal]b%[ins]$') " illegal bins
    call expression_map#map#remove_map_word()
    return sv#sv#sv_fun_cov#illegal_bins()
  elseif (mword =~ '\v^%[option]w%[eight]$') " option.weight
    call expression_map#map#remove_map_word()
    return 'option.weight = '
  elseif (mword =~ '\v^%[option]p%[er]%[instance]$') " option.per_instance
    call expression_map#map#remove_map_word()
    return 'option.per_instance = '
  elseif (mword =~ '\v^%[option]g%[et]%[inst]%[coverage]$') " option.get_inst_coverage
    call expression_map#map#remove_map_word()
    return 'option.get_inst_coverage = '
  elseif (mword =~ '\v^%[method]s%[ample]$') " method .sample()
    call expression_map#map#remove_map_word()
    return 'sample()'
  elseif (mword =~ '\v^%[method]g%[et]%[coverage]$') " method .get_coverage()
    call expression_map#map#remove_map_word()
    return 'get_coverage()'
  elseif (mword =~ '\v^%[method]g%[et]%[inst]%[coverage]$') " method .get_inst_coverage()
    call expression_map#map#remove_map_word()
    return 'get_inst_coverage()'
  elseif (mword =~ '\v^%[method]s%[et]%[inst]%[name]$') " method .set_inst_name()
    call expression_map#map#remove_map_word()
    return 'set_inst_name()'
  elseif (mword =~ '\v^%[method]s%[tart]$') " method .start()
    call expression_map#map#remove_map_word()
    return 'start()'
  elseif (mword =~ '\v^%[method]s%[top]$') " method .stop()
    call expression_map#map#remove_map_word()
    return 'stop()'
  elseif (mword =~ '\v^%[task]s%[et]%[coverage]%[db]%[name]$') " system task $set_coverage_db_name()
    call expression_map#map#remove_map_word()
    return '$set_coverage_db_name(maa)`aa'
  elseif (mword =~ '\v^%[task]l%[oad]%[coverage]%[db]$') " system task $load_coverage_db()
    call expression_map#map#remove_map_word()
    return '$load_coverage_db(maa)`aa'
  elseif (mword =~ '\v^%[task]g%[et]%[coverage]$') " system task $get_coverage()
    call expression_map#map#remove_map_word()
    return '$get_coverage()'
  else
    return ''
  endif
endfunction
imap <M-v> =<SID>Exp_Map_Mv()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_Mj: Function
function! s:Exp_Map_Mj()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^p%[rogram]$') " Program
    call expression_map#map#remove_map_word()
    return sv#sv#sv#complete('sv#sv#sv#program', -1)
  elseif (mword =~ '\v^p%[ackage]$')
    call expression_map#map#remove_map_word()
    return sv#sv#sv#package()
  elseif (mword =~ '\v^m%[odule]$') " module
    call expression_map#map#remove_map_word()
    return sv#sv#sv#module()
  elseif (mword =~ '\v^c%[lass]$') " Class
    call expression_map#map#remove_map_word()
    return sv#sv#sv#class()
  elseif (mword =~ '\v^s%[truct]$') " Class
    call expression_map#map#remove_map_word()
    return sv#sv#sv#struct()
  elseif (mword =~ '\v^c%[lass]e%[xtends]$') " Extended class
    call expression_map#map#remove_map_word()
    return sv#sv#sv#class_extended()
  elseif (mword =~ '\v^i%[nter]f%[ace]') " interface
    call expression_map#map#remove_map_word()
    return sv#sv#sv#complete('sv#sv#sv#interface', -1)
  elseif (mword =~ '\v^%[interface]c%[locking]b%[lock]') " interface::clocking_block
    call expression_map#map#remove_map_word()
    return sv#sv#sv#clocking_block()
  elseif (mword =~ '\v^%[interface]m%[od]p%[port]') " interface::modport
    call expression_map#map#remove_map_word()
    return sv#sv#sv#modport()
  elseif (mword =~ '\v^t%[sk]$') " task virtual
    call expression_map#map#remove_map_word()
    return sv#sv#sv#complete('sv#sv#sv#task', -1, "virtual", '',"Task" , matchstr(getline("."), '\w\+'))
  elseif (mword =~ '\v^f%[unction]$') " function virtual
    call expression_map#map#remove_map_word()
    return sv#sv#sv#complete('sv#sv#sv#function', -1, "virtual", 'void', '', "Function" , matchstr(getline("."), '\w\+'))
  elseif (mword =~ '\v^b%[egin]e%[nd]$') " begin-end
    call expression_map#map#remove_map_word()
    return sv#sv#sv#beginEnd()
  elseif (mword =~ '\v^f%[orever]b%[egin]e%[nd]$') " forever begin-end
    call expression_map#map#remove_map_word()
    return printf('forever %s', sv#sv#sv#beginEnd())
  elseif (mword =~ '\v^a%[lways]b%[egin]e%[nd]$') " always begin-end
    call expression_map#map#remove_map_word()
    return sv#sv#sv#always_beginEnd()
  elseif (mword =~ '\v^f%[ork]j%[oin]$') " fork-join
    call expression_map#map#remove_map_word()
    return sv#sv#sv#forkJoin()
  elseif (mword =~ '\v^f%[ork]j%[oin]a%[ny]$') " fork-join_any
    call expression_map#map#remove_map_word()
    return sv#sv#sv#forkJoinAny()
  elseif (mword =~ '\v^f%[ork]j%[oin]n%[one]$') " fork-join_none
    call expression_map#map#remove_map_word()
    return sv#sv#sv#forkJoinNone()
  elseif (mword =~ '\v^f%[or]e%[ach]$') " foreach
    call expression_map#map#remove_map_word()
    return sv#sv#sv#foreach()
  elseif (mword == 'cfe') " constaint foreach
    call expression_map#map#remove_map_word()
    return sv#sv#sv#cforeach()
  elseif (mword =~ '\v^w%[hile]$') " while
    call expression_map#map#remove_map_word()
    return sv#sv#sv#while()
  elseif (mword =~ '\v^dw%[hile]$') " do-while
    call expression_map#map#remove_map_word()
    return sv#sv#sv#do_while()
  elseif (mword == 'fi') " increment for loop
    call expression_map#map#remove_map_word()
    return sv#sv#sv#complete('sv#sv#sv#for', -1, 1)
  elseif (mword == 'fd') " decrement for loop
    call expression_map#map#remove_map_word()
    return sv#sv#sv#complete('sv#sv#sv#for', -1, 0)
  elseif (mword =~ '\v^re%[peat]$') " repeat loop
    call expression_map#map#remove_map_word()
    return sv#sv#sv#repeat()
  elseif (mword =~ '\v^rn%[d]$') " randomize
    call expression_map#map#remove_map_word()
    return sv#sv#sv#complete('sv#sv#sv#randomize', -1)
  else
    return ''
  endif
endfunction
imap <M-j> =<SID>Exp_Map_Mj()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" s:Exp_Map_Md: Function
" System Functions
"-------------------------------------------------------------------------------
function! s:Exp_Map_Md()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^d%[isplay]$') " $display
    call expression_map#map#remove_map_word()
    return '$display ("maa");`aa'
  elseif (mword =~ '\v^d%[isplay]t$') " $display with $time
    call expression_map#map#remove_map_word()
    return '$display ("[@%0t]: maa", $time);`aa'
  elseif (mword =~ '\v^m%[onitor]$') " $monitor
    call expression_map#map#remove_map_word()
    return '$monitor ("[@%0t]: maa", $time);`aa'
  elseif (mword =~ '\v^d%[isplay]b$') " $display binary
    call expression_map#map#remove_map_word()
    return '$displayb (maa);`aa'
  elseif (mword =~ '\v^d%[isplay]h$') " $display hex
    call expression_map#map#remove_map_word()
    return '$displayh (maa);`aa'
  elseif (mword =~ '\v^w%[rite]$') " $write
    call expression_map#map#remove_map_word()
    return '$write ("maa");`aa'
  elseif (mword =~ '\v^sw%[rite]%[h]$') " $swriteh
    call expression_map#map#remove_map_word()
    return '$swriteh (maa, "mba");`aa'
  elseif (mword =~ '\v^s%[format]$') " $sformat
    call expression_map#map#remove_map_word()
    return '$sformat (maa,"");`aa'
  elseif (mword =~ '\v^p%[sprint]f?$') " $psprintf
    call expression_map#map#remove_map_word()
    if (getline('.')[col('.') - 1] == '"')
      let str = 'f"vf"s$psprintf (", maa)`aa'
    else
      let str = '$psprintf ("maa", )`aa'
    endif
    return str
  elseif (mword =~ '\v^i%[s]u%[nknown]$') " $isunknown
    call expression_map#map#remove_map_word()
    return '$isunknown (maa)`aa'
  elseif (mword =~ '\v^s%[ize]$') " $size
    call expression_map#map#remove_map_word()
    return '$size (maa)`aa'
  elseif (mword =~ '\v^fo%[pen]$') " $fopen
    call expression_map#map#remove_map_word()
    return '$fopen ("maa", "r")`aa'
  elseif (mword =~ '\v^fc%[lose]$') " $fclose
    call expression_map#map#remove_map_word()
    return '$fclose (maa)`aa'
  elseif (mword =~ '\v^fe%[of]$') " $feof
    call expression_map#map#remove_map_word()
    return '$feof (maa)`aa'
  elseif (mword =~ '\v^fs%[canf]$') " $fscanf
    call expression_map#map#remove_map_word()
    return 'void'($fscanf (maa,"mba", ))`aa'
  elseif (mword =~ '\v^r%[andom]$') " $random
    call expression_map#map#remove_map_word()
    return '$random (maa)`aa'
  elseif (mword =~ '\v^ur%[andom]$') " $urandom
    call expression_map#map#remove_map_word()
    return '$urandom ()'
  elseif (mword =~ '\v^ur%[andom_]r%[ange]$') " $urandom_range
    call expression_map#map#remove_map_word()
    return '$urandom_range ()'
  elseif (mword =~ '\v^d%[ist_]e%[xponential]$') " $dist_exponential
    call expression_map#map#remove_map_word()
    return '$dist_exponential (maa)`aa'
  elseif (mword =~ '\v^d%[ist_]n%[ormal]$') " $dist_normal
    call expression_map#map#remove_map_word()
    return '$dist_normal (maa)`aa'
  elseif (mword =~ '\v^d%[ist_]p%[oisson]$') " $dist_poisson
    call expression_map#map#remove_map_word()
    return '$dist_poisson (maa)`aa'
  elseif (mword =~ '\v^d%[ist_]u%[niform]$') " $dist_uniform
    call expression_map#map#remove_map_word()
    return '$dist_uniform (maa)`aa'
  elseif (mword =~ '\v^t%[ime]$') " $time
    call expression_map#map#remove_map_word()
    return '$time'
  elseif (mword =~ '\v^c%[ast]$') " $cast
    call expression_map#map#remove_map_word()
    return 'assert($cast (maa))`aa'
  elseif (mword =~ '\v^c%[ount]o%[nes]$') " $countones
    call expression_map#map#remove_map_word()
    return '$countones (maa)`aa'
  else
    return ''
  endif
endfunction
imap <M-d> =<SID>Exp_Map_Md()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_M4: Function
function! s:Exp_Map_M4()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^i%[nteger]$')
    call expression_map#map#remove_map_word()
    return "integer "
  elseif (mword =~ '\v^t%[ime]$')
    call expression_map#map#remove_map_word()
    return "time "
  elseif (mword =~ '\v^i%[nteger]u%[nsigned]$')
    call expression_map#map#remove_map_word()
    return "integer unsigned "
  elseif (mword =~ '\v^t%[ypedef]i%[nteger]$')
    call expression_map#map#remove_map_word()
    return "typedef integer "
  elseif (mword =~ '\v^t%[ypedef]i%[nteger]u%[nsigned]$')
    call expression_map#map#remove_map_word()
    return "typedef integer unsigned "
  elseif (mword =~ '\v^i%[nt]$')
    call expression_map#map#remove_map_word()
    return "int "
  elseif (mword =~ '\v^l%[ongint]$')
    call expression_map#map#remove_map_word()
    return "longint "
  elseif (mword =~ '\v^s%[tring]$')
    call expression_map#map#remove_map_word()
    return "string "
  elseif (mword =~ '\v^s%[hortint]$')
    call expression_map#map#remove_map_word()
    return "shortint "
  elseif (mword =~ '\v^b%[yte]$')
    call expression_map#map#remove_map_word()
    return "byte "
  elseif (mword =~ '\v^i%[nt]u%[nsigned]$')
    call expression_map#map#remove_map_word()
    return "int unsigned "
  elseif (mword =~ '\v^l%[ongint]u%[nsigned]$')
    call expression_map#map#remove_map_word()
    return "longint unsigned "
  elseif (mword =~ '\v^s%[hortint]u%[nsigned]$')
    call expression_map#map#remove_map_word()
    return "shortint unsigned "
  elseif (mword =~ '\v^b%[yte]u%[nsigned]$')
    call expression_map#map#remove_map_word()
    return "byte unsigned "
  elseif (mword =~ '\v^t%[ypedef]i%[nt]$')
    call expression_map#map#remove_map_word()
    return "typedef int "
  elseif (mword =~ '\v^t%[ypedef]l%[ongint]$')
    call expression_map#map#remove_map_word()
    return "typedef longint "
  elseif (mword =~ '\v^t%[ypedef]s%[hortint]$')
    call expression_map#map#remove_map_word()
    return "typedef shortint "
  elseif (mword =~ '\v^t%[ypedef]b%[yte]$')
    call expression_map#map#remove_map_word()
    return "typedef byte "
  elseif (mword =~ '\v^t%[ypedef]i%[nt]u%[nsigned]$')
    call expression_map#map#remove_map_word()
    return "typedef int unsigned "
  elseif (mword =~ '\v^t%[ypedef]l%[ongint]u%[nsigned]$')
    call expression_map#map#remove_map_word()
    return "typedef longint unsigned "
  elseif (mword =~ '\v^t%[ypedef]s%[hortint]u%[nsigned]$')
    call expression_map#map#remove_map_word()
    return "typedef shortint unsigned "
  elseif (mword =~ '\v^t%[ypedef]b%[yte]u%[nsigned]$')
    call expression_map#map#remove_map_word()
    return "typedef byte unsigned "
  elseif (mword =~ '\v^c%[onst]i%[nt]$')
    call expression_map#map#remove_map_word()
    return "const int "
  elseif (mword =~ '\v^c%[onst]l%[ongint]$')
    call expression_map#map#remove_map_word()
    return "const longint "
  elseif (mword =~ '\v^c%[onst]s%[hortint]$')
    call expression_map#map#remove_map_word()
    return "const shortint "
  elseif (mword =~ '\v^c%[onst]b%[yte]$')
    call expression_map#map#remove_map_word()
    return "const byte "
  elseif (mword =~ '\v^c%[onst]i%[nt]u%[nsigned]$')
    call expression_map#map#remove_map_word()
    return "const int unsigned "
  elseif (mword =~ '\v^c%[onst]l%[ongint]u%[nsigned]$')
    call expression_map#map#remove_map_word()
    return "const longint unsigned "
  elseif (mword =~ '\v^c%[onst]s%[hortint]u%[nsigned]$')
    call expression_map#map#remove_map_word()
    return "const shortint unsigned "
  elseif (mword =~ '\v^c%[onst]b%[yte]u%[nsigned]$')
    call expression_map#map#remove_map_word()
    return "const byte unsigned "
  elseif (mword =~ '\v^r%[and]i%[nt]$')
    call expression_map#map#remove_map_word()
    return "const int unsigned "
  elseif (mword =~ '\v^r%[and]l%[ongint]$')
    call expression_map#map#remove_map_word()
    return "rand longint "
  elseif (mword =~ '\v^r%[and]s%[hortint]$')
    call expression_map#map#remove_map_word()
    return "rand shortint "
  elseif (mword =~ '\v^r%[and]b%[yte]$')
    call expression_map#map#remove_map_word()
    return "rand byte "
  elseif (mword =~ '\v^r%[and]i%[nt]u%[nsigned]$')
    call expression_map#map#remove_map_word()
    return "rand int unsigned "
  elseif (mword =~ '\v^r%[and]l%[ongint]u%[nsigned]$')
    call expression_map#map#remove_map_word()
    return "rand longint unsigned "
  elseif (mword =~ '\v^r%[and]s%[hortint]u%[nsigned]$')
    call expression_map#map#remove_map_word()
    return "rand shortint unsigned "
  elseif (mword =~ '\v^r%[and]b%[yte]u%[nsigned]$')
    call expression_map#map#remove_map_word()
    return "rand byte unsigned "
  else
    return ''
  endif
endfunction
imap <M-4> =<SID>Exp_Map_M4()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Exp_Map_M2: Function
" Packed array 4-state & 2-state
function! s:Exp_Map_M2()
  let mword = expression_map#map#get_map_word()

  if (mword == '4l')
    call expression_map#map#remove_map_word()
    return "logic [63:0] "
  elseif (mword == '4i')
    call expression_map#map#remove_map_word()
    return "logic [31:0] "
  elseif (mword == '4s')
    call expression_map#map#remove_map_word()
    return "logic [15:0] "
  elseif (mword == '4b')
    call expression_map#map#remove_map_word()
    return "logic [7:0] "
  elseif (mword == '4n')
    call expression_map#map#remove_map_word()
    return "logic [3:0] "
  elseif (mword == '4')
    call expression_map#map#remove_map_word()
    return "logic [maa:0] `aa"
  elseif (mword == '4tl')
    call expression_map#map#remove_map_word()
    return "typedef logic [63:0] "
  elseif (mword == '4ti')
    call expression_map#map#remove_map_word()
    return "typedef logic [31:0] "
  elseif (mword == '4ts')
    call expression_map#map#remove_map_word()
    return "typedef logic [15:0] "
  elseif (mword == '4tb')
    call expression_map#map#remove_map_word()
    return "typedef logic [7:0] "
  elseif (mword == '4tn')
    call expression_map#map#remove_map_word()
    return "typedef logic [3:0] "
  elseif (mword == '4t')
    call expression_map#map#remove_map_word()
    return "typedef logic [maa:0] `aa"
  elseif (mword == 'l')
    call expression_map#map#remove_map_word()
    return "bit [63:0] "
  elseif (mword == 'i')
    call expression_map#map#remove_map_word()
    return "bit [31:0] "
  elseif (mword == 's')
    call expression_map#map#remove_map_word()
    return "bit [15:0] "
  elseif (mword == 'b')
    call expression_map#map#remove_map_word()
    return "bit [7:0] "
  elseif (mword == 'n')
    call expression_map#map#remove_map_word()
    return "bit [3:0] "
  elseif (mword == 'tl')
    call expression_map#map#remove_map_word()
    return "typedef bit [63:0] "
  elseif (mword == 'ti')
    call expression_map#map#remove_map_word()
    return "typedef bit [31:0] "
  elseif (mword == 'ts')
    call expression_map#map#remove_map_word()
    return "typedef bit [15:0] "
  elseif (mword == 'tb')
    call expression_map#map#remove_map_word()
    return "typedef bit [7:0] "
  elseif (mword == 'tn')
    call expression_map#map#remove_map_word()
    return "typedef bit [3:0] "
  elseif (mword == 't')
    call expression_map#map#remove_map_word()
    return "typedef bit [maa:0] `aa"
  elseif (mword == 'cl')
    call expression_map#map#remove_map_word()
    return "const bit [63:0] "
  elseif (mword == 'ci')
    call expression_map#map#remove_map_word()
    return "const bit [31:0] "
  elseif (mword == 'cs')
    call expression_map#map#remove_map_word()
    return "const bit [15:0] "
  elseif (mword == 'cb')
    call expression_map#map#remove_map_word()
    return "const bit [7:0] "
  elseif (mword == 'cn')
    call expression_map#map#remove_map_word()
    return "const bit [3:0] "
  elseif (mword == 'c')
    call expression_map#map#remove_map_word()
    return "const bit [maa:0] `aa"
  elseif (mword == 'e')
    call expression_map#map#remove_map_word()
    return "enum {maa:0};`aa"
  elseif (mword == 'ce')
    call expression_map#map#remove_map_word()
    return "const enum {maa:0};`aa"
  elseif (mword == 'rl')
    call expression_map#map#remove_map_word()
    return "rand bit [63:0] "
  elseif (mword == 'ri')
    call expression_map#map#remove_map_word()
    return "rand bit [31:0] "
  elseif (mword == 'rs')
    call expression_map#map#remove_map_word()
    return "rand bit [15:0] "
  elseif (mword == 'rb')
    call expression_map#map#remove_map_word()
    return "rand bit [7:0] "
  elseif (mword == 'rn')
    call expression_map#map#remove_map_word()
    return "rand bit [3:0] "
  elseif (mword == 're')
    call expression_map#map#remove_map_word()
    return "rand enum [3:0] "
  elseif (mword == 'r')
    call expression_map#map#remove_map_word()
    return "rand bit [maa :0]`aa"
  elseif (mword == '')
    return 'bit [maa :0] `aa' " default
  else
    return ''
  endif
endfunction
imap <M-2> =<SID>Exp_Map_M2()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" s:Exp_Map_Mk: Function
"-------------------------------------------------------------------------------
function! s:Exp_Map_Mk()
  let mword = expression_map#map#get_map_word()

  if (mword =~ '\v^r%[and]c$')
    call expression_map#map#remove_map_word()
    return "randc "
  elseif (mword =~ '\v^t%[ypedef]$')
    call expression_map#map#remove_map_word()
    return "typedef "
  elseif (mword =~ '\v^c%[onst]$')
    call expression_map#map#remove_map_word()
    return "const "
  elseif (mword =~ '\v^r%[eal]$')
    call expression_map#map#remove_map_word()
    return "real "
  elseif (mword =~ '\v^r%[andomize]$')
    call expression_map#map#remove_map_word()
    return sv#sv#sv#complete('sv#sv#sv#randomize', -1)
  elseif (mword =~ '\v^s%[solve]b%[efore]$')
    call expression_map#map#remove_map_word()
    return "solve maa before `aa"
  elseif (mword =~ '\v^i%[nside]$')
    call expression_map#map#remove_map_word()
    return "inside {maa}`aa"
  elseif (mword =~ '\v^d%[ist]$')
    call expression_map#map#remove_map_word()
    return "dist {maa}`aa"
  elseif (mword =~ '\v^p%[re_]r%[andomize]$')
    call expression_map#map#remove_map_word()
    return "pre_randomize "
  elseif (mword =~ '\v^p%[arameter]$')
    call expression_map#map#remove_map_word()
    return "parameter "
  elseif (mword =~ '\v^p%[ost_]r%[andomize]$')
    call expression_map#map#remove_map_word()
    return "post_randomize "
  elseif (mword =~ '\v^a%[utomatic]$')
    call expression_map#map#remove_map_word()
    return "automatic "
  elseif (mword =~ '\v^a%[utomatic]i%[nt]$')
    call expression_map#map#remove_map_word()
    return "automatic int "
  elseif (mword =~ '\v^e%[vent]$')
    call expression_map#map#remove_map_word()
    return "event "
  elseif (mword =~ '\v^w%[ait]$')
    call expression_map#map#remove_map_word()
    return "wait (maa)`aa"
  elseif (mword =~ '\v^w%[ait]t%[riggered]$')
    call expression_map#map#remove_map_word()
    return "wait (maa.triggered())`aa"
  elseif (mword =~ '\v^n%[ew]$')
    call expression_map#map#remove_map_word()
    return "\<space>= new(maa);`aa"
  elseif (mword =~ '\v^m%[ailbox]$')
    call expression_map#map#remove_map_word()
    return "\<space>= mailbox(maa);`aa"
  else
    return ''
  endif
endfunction
imap <M-k> =<SID>Exp_Map_Mk()
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Others
"-------------------------------------------------------------------------------
imap <buffer> <M-/> f"a,
imap <buffer> <M-[> []<Left>
imap <buffer> <M-{> {}<Left>
imap <buffer> <M-.> ->
imap <buffer> <M-=> <space>=
imap <buffer> <C-CR> A;


"-------------------------------------------------------------------------------
" Alias
"-------------------------------------------------------------------------------
abbr %%h 'h%0h
abbr %%b 'b%0b





