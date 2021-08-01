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
" connect: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_phases#connect()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  let str = comments#block_comment#getComments("Function", "connect")
  let str .= 'virtual function void connect();' .
    \ s:_set_indent(&shiftwidth) . 'super.connect();' .
    \ s:_set_indent(0) . 'uvm_report_info(get_full_name(),"INSIDE of connect ",UVM_LOW);' .
    \ s:_set_indent(0) . 'maa' .
    \ s:_set_indent(-&shiftwidth) . 'endfunction : connect`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" build: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_phases#build()
  let str = comments#block_comment#getComments("Function", "build")
  let str .= 'virtual function void build();' .
    \ s:_set_indent(&shiftwidth) . 'super.build();' .
    \ s:_set_indent(0) . 'uvm_report_info(get_full_name(),"INSIDE of build ",UVM_LOW);' .
    \ s:_set_indent(0) . 'maa' .
    \ s:_set_indent(-&shiftwidth) . 'endfunction : build`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" run: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_phases#run()
  let str = comments#block_comment#getComments("Task", "run")
  let str .= 'task run();' .
    \ s:_set_indent(&shiftwidth) . 'uvm_report_info(get_full_name(),"INSIDE run ",UVM_LOW);' .
    \ s:_set_indent(0) . 'maa' .
    \ s:_set_indent(-&shiftwidth) . 'endtask : run`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" build_phase: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_phases#build_phase()
  let str = comments#block_comment#getComments("Function", "build_phase")
  let str .= 'virtual function void build_phase(uvm_phase phase);' .
    \ s:_set_indent(&shiftwidth) . 'super.build_phase(phase);' .
    \ s:_set_indent(0) . 'uvm_report_info(get_full_name(),"START of build_phase ",UVM_LOW);' .
    \ s:_set_indent(0) . 'maa' .
    \ s:_set_indent(0) . 'uvm_report_info(get_full_name(),"END of build_phase ",UVM_LOW);' .
    \ s:_set_indent(-&shiftwidth) . 'endfunction : build_phase`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" start_of_simulation_phase: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_phases#start_of_simulation_phase()
  let str = comments#block_comment#getComments("Function", "start_of_simulation_phase")
  let str .= 'virtual function void start_of_simulation_phase(uvm_phase phase);' .
           \ s:_set_indent(&shiftwidth) . 'super.start_of_simulation_phase(phase);' .
           \ s:_set_indent(0) . 'maa' .
           \ s:_set_indent(-&shiftwidth) . 'endfunction : start_of_simulation_phase`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" end_of_elaboration_phase: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_phases#end_of_elaboration_phase()
  let str = comments#block_comment#getComments("Function", "end_of_elaboration_phase")
  let str .= 'virtual function void end_of_elaboration_phase(uvm_phase phase);' .
           \ s:_set_indent(&shiftwidth) . 'super.end_of_elaboration_phase(phase);' .
           \ s:_set_indent(0) . 'maa' .
           \ s:_set_indent(-&shiftwidth) . 'endfunction : end_of_elaboration_phase`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" check_phase: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_phases#check_phase()
  let str = comments#block_comment#getComments("Function", "check_phase")
  let str .= 'virtual function void check_phase(uvm_phase phase);' .
           \ s:_set_indent(&shiftwidth) . 'super.check_phase(phase);' .
           \ s:_set_indent(0) . 'maa' .
           \ s:_set_indent(-&shiftwidth) . 'endfunction : check_phase`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" extract_phase: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_phases#extract_phase()
  let str = comments#block_comment#getComments("Function", "extract_phase")
  let str .= 'virtual function void extract_phase(uvm_phase phase);' .
           \ s:_set_indent(&shiftwidth) . 'super.extract_phase(phase);' .
           \ s:_set_indent(0) . 'maa' .
           \ s:_set_indent(-&shiftwidth) . 'endfunction : extract_phase`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" final_phase: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_phases#final_phase()
  let str = comments#block_comment#getComments("Function", "final_phase")
  let str .= 'virtual function void final_phase(uvm_phase phase);' .
           \ s:_set_indent(&shiftwidth) . 'uvm_report_server report_server;' .
           \ s:_set_indent(0) . 'string description = "";' .
           \ s:_set_indent(0) . '' .
           \ s:_set_indent(0) . 'super.final_phase(phase);' .
           \ s:_set_indent(0) . 'report_server = uvm_report_server :: get_server();' .
           \ s:_set_indent(0) . 'description = {description, $psprintf ("          ############################################################\n", )};' .
           \ s:_set_indent(0) . 'description = {description, $psprintf ("          #################    TESTCASE RESULT   #####################\n", )};' .
           \ s:_set_indent(0) . 'description = {description, $psprintf ("          ############################################################\n", )};' .
           \ s:_set_indent(0) . 'description = {description, $psprintf ("          ##  UVM_WARNINGS : %-3d%38s\n", report_server.get_severity_count(UVM_WARNING), "##")};' .
           \ s:_set_indent(0) . 'description = {description, $psprintf ("          ##  UVM_ERRORS   : %-3d%38s\n", report_server.get_severity_count(UVM_ERROR), "##")};' .
           \ s:_set_indent(0) . 'description = {description, $psprintf ("          ##  UVM_FATAL    : %-3d%38s\n", report_server.get_severity_count(UVM_FATAL), "##")};' .
           \
           \ s:_set_indent(0) . 'if (report_server.get_severity_count(UVM_FATAL) +' .
           \ s:_set_indent(&shiftwidth + 2) . 'report_server.get_severity_count(UVM_ERROR) +' .
           \ s:_set_indent(0) . 'report_server.get_severity_count(UVM_WARNING) > 0) begin' .
           \ s:_set_indent(-2) . 'description = {description, $psprintf ("          ##  STATUS       : FAILED%35s\n", "##")};' .
           \ s:_set_indent(-&shiftwidth) . 'end' .
           \ s:_set_indent(0) . 'else begin ' .
           \ s:_set_indent(&shiftwidth) . 'description = {description, $psprintf ("          ##  STATUS       : PASSED%35s\n", "##")};' .
           \ s:_set_indent(-&shiftwidth) . 'end' .
           \ s:_set_indent(0) . 'description = {description, $psprintf ("          ############################################################\n", )};' .
           \
           \ s:_set_indent(0) . '`uvm_info(get_full_name(), $psprintf("\n\n%s", description),UVM_LOW)' .
           \ s:_set_indent(-&shiftwidth) . 'endfunction : final_phase'

  return str
endfunction

"-------------------------------------------------------------------------------
" pre_body: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_phases#pre_body()
  let str = comments#block_comment#getComments("Task", "pre_body")
  let str .= 'virtual task pre_body();' .
           \ s:_set_indent(&shiftwidth) . 'uvm_phase starting_phase = get_starting_phase();' .
           \ s:_set_indent(0) . 'super.pre_body();' .
           \ s:_set_indent(0) . 'if (starting_phase != null) begin' .
           \ s:_set_indent(&shiftwidth) . '`uvm_info(get_type_name(), $sformatf("%s pre_body() raising %s objection", get_sequence_path(), starting_phase.get_name()),UVM_MEDIUM );' .
           \ s:_set_indent(0) . 'starting_phase.raise_objection(this);' .
           \ s:_set_indent(-&shiftwidth) . 'end' .
           \
           \ s:_set_indent(0) . 'if (starting_phase != null) begin ' .
           \ s:_set_indent(&shiftwidth) . 'uvm_phase run_phase = uvm_domain::get_common_domain().find(uvm_run_phase::get());' .
           \ 
           \ s:_set_indent(0) . '`uvm_info(get_type_name(), $sformatf("%s pre_body() raising %s objection", get_sequence_path(), run_phase.get_name()),UVM_MEDIUM );' .
           \ s:_set_indent(0) . 'run_phase.raise_objection(this);' .
           \ s:_set_indent(-&shiftwidth) . 'end' .
           \ s:_set_indent(-&shiftwidth) . 'endtask : pre_body'

  return str
endfunction

"-------------------------------------------------------------------------------
" post_body: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_phases#post_body()
  let str = comments#block_comment#getComments("Task", "post_body")
  let str .= 'virtual task post_body();' .
           \ s:_set_indent(&shiftwidth) . 'uvm_phase starting_phase = get_starting_phase();' .
           \ s:_set_indent(0) . 'super.post_body();' .
           \ s:_set_indent(0) . 'if (starting_phase != null) begin' .
           \ s:_set_indent(&shiftwidth) . '`uvm_info(get_type_name(), $sformatf("%s post_body() droping %s objection", get_sequence_path(), starting_phase.get_name()),UVM_MEDIUM );' .
           \ s:_set_indent(0) . 'starting_phase.drop_objection(this);' .
           \ s:_set_indent(-&shiftwidth) . 'end' .
           \
           \ s:_set_indent(0) . 'if (starting_phase != null) begin ' .
           \ s:_set_indent(&shiftwidth) . 'uvm_phase run_phase = uvm_domain::get_common_domain().find(uvm_run_phase::get());' .
           \
           \ s:_set_indent(0) . '`uvm_info(get_type_name(), $sformatf("%s post_body() droping %s objection", get_sequence_path(), run_phase.get_name()),UVM_MEDIUM );' .
           \ s:_set_indent(0) . 'run_phase.drop_objection(this);' .
           \ s:_set_indent(-&shiftwidth) . 'end' .
           \ s:_set_indent(-&shiftwidth) . 'endtask : post_body'

  return str
endfunction

"-------------------------------------------------------------------------------
" report_phase: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_phases#report_phase()
  let str = comments#block_comment#getComments("Function", "report_phase")
  let str .= 'virtual function void report_phase(uvm_phase phase);' .
           \ s:_set_indent(&shiftwidth) . 'super.report_phase(phase);' .
           \ s:_set_indent(0) . 'maa' .
           \ s:_set_indent(-&shiftwidth) . 'endfunction : report_phase`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" connect_phase: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_phases#connect_phase()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  let str = comments#block_comment#getComments("Function", "connect_phase")
  let str .= 'virtual function void connect_phase(uvm_phase phase);' .
    \ s:_set_indent(&shiftwidth) . 'super.connect_phase(phase);' .
    \ s:_set_indent(0) . 'uvm_report_info(get_full_name(),"START of connect_phase ",UVM_LOW);' .
    \ s:_set_indent(0) . 'maa' .
    \ s:_set_indent(0) . 'uvm_report_info(get_full_name(),"END of connect_phase ",UVM_LOW);' .
    \ s:_set_indent(-&shiftwidth) . 'endfunction : connect_phase`aa'

  return str
endfunction


"-------------------------------------------------------------------------------
" run_phase: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_phases#run_phase()
  let str = comments#block_comment#getComments("Task", "run_phase")
  let str .= 'task run_phase(uvm_phase phase);' .
    \ s:_set_indent(&shiftwidth) . 'uvm_report_info(get_full_name(),"INSIDE of run_phase ",UVM_LOW);' .
    \ s:_set_indent(0) . 'maa' .
    \ s:_set_indent(-&shiftwidth) . 'endtask : run_phase`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" reset_phase: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_phases#reset_phase()
  let str = comments#block_comment#getComments("Task", "reset_phase")
  let str .= 'task reset_phase(uvm_phase phase);' .
    \ s:_set_indent(&shiftwidth) . 'phase.raise_objection(.obj(this), .description("reset_phase"));' .
    \ s:_set_indent(0) . 'maa' .
    \ s:_set_indent(0) . 'phase.drop_objection(.obj(this), .description("reset_phase"));' .
    \ s:_set_indent(-&shiftwidth) . 'endtask : reset_phase`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" main_phase: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_phases#main_phase()
  let str = comments#block_comment#getComments("Task", "main_phase")
  let str .= 'task main_phase(uvm_phase phase);' .
    \ s:_set_indent(&shiftwidth) . 'phase.raise_objection(.obj(this), .description("main_phase"));' .
    \ s:_set_indent(0) . 'maa' .
    \ s:_set_indent(0) . 'phase.drop_objection(.obj(this), .description("main_phase"));' .
    \ s:_set_indent(-&shiftwidth) . 'endtask : main_phase`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" configure_phase: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_phases#configure_phase()
  let str = comments#block_comment#getComments("Task", "configure_phase")
  let str .= 'task configure_phase(uvm_phase phase);' .
    \ s:_set_indent(&shiftwidth) . 'phase.raise_objection(.obj(this), .description("configure_phase"));' .
    \ s:_set_indent(0) . 'maa' .
    \ s:_set_indent(0) . 'phase.drop_objection(.obj(this), .description("configure_phase"));' .
    \ s:_set_indent(-&shiftwidth) . 'endtask : configure_phase`aa'

  return str
endfunction


"-------------------------------------------------------------------------------
" Function : do_print
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_phases#do_print()
  let str = comments#block_comment#getComments("Function", "do_print")
  let str .= 'function void do_print(uvm_printer printer);' .
    \ s:_set_indent(&shiftwidth) . 'super.do_print(printer);' .
    \ s:_set_indent(0) . printf('printer.print_string("maa%s", %s);', s:GetTemplete('a', 'var'), s:GetTemplete('a', 'varstr')) .
    \ s:_set_indent(-&shiftwidth) . 'endfunction : do_print`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : do_compare
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_phases#do_compare()
  let str = comments#block_comment#getComments("Function", "do_compare")
  let str .= 'virtual function bit do_compare(uvm_object rhs, uvm_comparer comparer);' .
    \ s:_set_indent(&shiftwidth) . printf('maa%s that;', s:GetTemplete('a', 'trans')) .
    \ s:_set_indent(0) . 'if ( ! $cast( that, rhs ) ) begin' .
    \ s:_set_indent(&shiftwidth) . '`uvm_fatal("do_compare", "Transactions are not compatible!!!")' .
    \ s:_set_indent(0) . 'return 0;' .
    \ s:_set_indent(-&shiftwidth) . 'end' .
    \ s:_set_indent(0) . 'do_compare = super.do_compare(rhs, comparer);' .
    \ s:_set_indent(0) . '// TODO: do_compare = (this.data == that.data);' .
    \ s:_set_indent(-&shiftwidth) . 'endfunction : do_compare`aa'

  return str
endfunction


"-------------------------------------------------------------------------------
" Function : do_copy
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_phases#do_copy()
  let str = comments#block_comment#getComments("Function", "do_copy")
  let str .= 'virtual function void do_copy(uvm_object rhs);' .
    \ s:_set_indent(&shiftwidth) . printf('maa%s that;', s:GetTemplete('a', 'trans')) .
    \ s:_set_indent(0) . 'if ( ! $cast( that, rhs ) ) begin' .
    \ s:_set_indent(&shiftwidth) . '`uvm_fatal("do_copy", "Transactions are not compatible!!!")' .
    \ s:_set_indent(0) . 'return;' .
    \ s:_set_indent(-&shiftwidth) . 'end' .
    \ s:_set_indent(0) . 'super.do_copy(rhs);' .
    \ s:_set_indent(0) . '// TODO: this.data = that.data;' .
    \ s:_set_indent(-&shiftwidth) . 'endfunction : do_copy`aa'

  return str
endfunction


"-------------------------------------------------------------------------------
" Function : do_pack
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_phases#do_pack()
  let str = comments#block_comment#getComments("Function", "do_pack")
  let str .= 'virtual function void do_pack(uvm_packer packer);' .
    \ s:_set_indent(&shiftwidth) . 'super.do_pack(packer);' .
    \ s:_set_indent(0) . printf('packer.pack_field_int(maa%s, %s);', s:GetTemplete('a', 'var'), s:GetTemplete('a', 'length/8')) .
    \ s:_set_indent(-&shiftwidth) . 'endfunction : do_pack`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : do_record
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_phases#do_record()
  let str = comments#block_comment#getComments("Function", "do_record")
  let str .= 'virtual function void do_record(uvm_recorder recorder);' .
    \ s:_set_indent(&shiftwidth) . 'super.do_record(recorder);' .
    \ s:_set_indent(0) . printf('`uvm_record_attribute(recorder.tr_handle, "maa%s", %s);', s:GetTemplete('a', 'var'), s:GetTemplete('a', 'var')) .
    \ s:_set_indent(-&shiftwidth) . 'endfunction : do_record`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : do_unpack
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_phases#do_unpack()
  let str = comments#block_comment#getComments("Function", "do_unpack")
  let str .= 'virtual function void do_unpack(uvm_packer packer);' .
    \ s:_set_indent(&shiftwidth) . printf('maa%s %s;', s:GetTemplete('a', 'data_type'), s:GetTemplete('b', 'var')) .
    \ s:_set_indent(0) . 'super.do_unpack(packer);' .
    \ s:_set_indent(0) . printf('%s = packer.unpack_field_int(%s);',  s:GetTemplete('b', 'var'), s:GetTemplete('a', 'length/8')) .
    \ s:_set_indent(-&shiftwidth) . 'endfunction : do_unpack`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : convert2string
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_phases#convert2string()
  let str = comments#block_comment#getComments("Function", "convert2string")
  let str .= 'virtual function string convert2string();' .
    \ s:_set_indent(&shiftwidth) . 'string str = super.convert2string();' .
    \ s:_set_indent(0) . 'maa// TODO: str = {str, $psprintf( "\n data : 0x%0h", data)};' .
    \ s:_set_indent(0) . 'return str;' .
    \ s:_set_indent(-&shiftwidth) . 'endfunction : convert2string`aa'

  return str
endfunction



"-------------------------------------------------------------------------------
" raise_objection: Function
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_phases#raise_objection()
  let str = printf('phase.raise_objection(.obj(this), .description("maa%s"));' , s:GetTemplete('a', 'DESCRIPTION')). 
  \'' .
  \ printf('phase.drop_objection(.obj(this), .description("%s"));`aa', s:GetTemplete('a', 'DESCRIPTION'))
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : set_drain_time
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_phases#set_drain_time()
  let str = printf('phase.phase_done.set_drain_time(.obj(this), .drain(maa%s));`aa' , s:GetTemplete('a', 'time/10us')) 
  return str
endfunction


