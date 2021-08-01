" Vim syntax file
" Language:sysVerilog
" Maintainer:  Malkesh J Adesra

" Last Update: 13 September 2006

augroup filetypedetect
au BufNewFile,BufRead *.v setf va
augroup END

if version < 600
   syntax clear
elseif exists("b:current_syntax")
   finish
endif

" Set the local value of the 'iskeyword' option
if version >= 600
   setlocal iskeyword=@,48-57,_,192-255,+,-,?
else
   set iskeyword=@,48-57,_,192-255,+,-,?
endif
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" eI  ROCKS !!!
syn match sysVerilogMyname "ei[a-zA-Z0-9_\(]\+[)]\>"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" A bunch of useful sysVerilog keywords
 syn keyword sysVerilogStatement  alias always always_comb 
 syn keyword sysVerilogStatement  always_ff always_latch 
 syn keyword sysVerilogStatement  and assert 
 syn keyword sysVerilogStatement  assert_strobe assign 
 syn keyword sysVerilogStatement  automatic before 
 syn keyword sysVerilogStatement  begin bind 
 syn keyword sysVerilogStatement  bit break 
 syn keyword sysVerilogStatement  buf bufif0 
 syn keyword sysVerilogStatement  bufif1 byte 
 syn keyword sysVerilogStatement  case casex 
 syn keyword sysVerilogStatement  casez cell 
 syn keyword sysVerilogStatement  chandle                 
 syn keyword sysVerilogStatement  cmos 
 syn keyword sysVerilogStatement  const 
 syn keyword sysVerilogStatement  constraint context 
 syn keyword sysVerilogStatement  continue cover covergroup 
 syn keyword sysVerilogStatement  deassign default 
 syn keyword sysVerilogStatement  defparam design 
 syn keyword sysVerilogStatement  disable dist 
 syn keyword sysVerilogStatement  do edge 
 syn keyword sysVerilogStatement  else end 
 syn keyword sysVerilogStatement  endcase endclass 
 syn keyword sysVerilogStatement  endclocking endconfig 
 syn keyword sysVerilogStatement  endfunction endgenerate endgroup 
 syn keyword sysVerilogStatement  endinterface endmodule endpackage 
 syn keyword sysVerilogStatement  endprimitive endprogram 
 syn keyword sysVerilogStatement  endproperty endspecify 
 syn keyword sysVerilogStatement  endsequence endtable 
 syn keyword sysVerilogStatement  endtask enum 

 syn keyword sysVerilogStatement   enum 
 syn keyword sysVerilogStatement  event export 
 syn keyword sysVerilogStatement  extends extern 
 syn keyword sysVerilogStatement  final first_match 
 syn keyword sysVerilogStatement  for force foreach 
 syn keyword sysVerilogStatement  forever fork 
 syn keyword sysVerilogStatement  fork join 
 syn keyword sysVerilogStatement  genvar 
 syn keyword sysVerilogStatement  highz0 highz1 
 syn keyword sysVerilogStatement  if iff 
 syn keyword sysVerilogStatement  ifnone import 
 syn keyword sysVerilogStatement  incdir include 
 syn keyword sysVerilogStatement  initial inout 
 syn keyword sysVerilogStatement  input inside 
 syn keyword sysVerilogStatement  instance int 
 syn keyword sysVerilogStatement  integer 
 syn keyword sysVerilogStatement  intersect join 
 syn keyword sysVerilogStatement  join_any join_none 
 syn keyword sysVerilogStatement  large liblist 
 syn keyword sysVerilogStatement  library local 
 syn keyword sysVerilogStatement  localparam logic 
 syn keyword sysVerilogStatement  longint macromodule 
 syn keyword sysVerilogStatement  medium modport 
 syn keyword sysVerilogStatement  nand 
 syn keyword sysVerilogStatement  negedge new 
 syn keyword sysVerilogStatement  nmos nor 
 syn keyword sysVerilogStatement  noshowcancelled not 
 syn keyword sysVerilogStatement  notif0 notif1 
 syn keyword sysVerilogStatement  null or 
 syn keyword sysVerilogStatement  output packed 
 syn keyword sysVerilogStatement  parameter pmos 
 syn keyword sysVerilogStatement  posedge 
 syn keyword sysVerilogStatement  priority 
 syn keyword sysVerilogStatement  protected 
 syn keyword sysVerilogStatement  pull0 pull1 
 syn keyword sysVerilogStatement  pulldown pullup 
 syn keyword sysVerilogStatement  pulsestyle_onevent pulsestyle_ondetect 
 syn keyword sysVerilogStatement  pure rand 
 syn keyword sysVerilogStatement  randc rcmos 
 syn keyword sysVerilogStatement  ref real 
 syn keyword sysVerilogStatement  realtime reg 
 syn keyword sysVerilogStatement  release repeat 
 syn keyword sysVerilogStatement  return rnmos 
 syn keyword sysVerilogStatement  rpmos rtran 
 syn keyword sysVerilogStatement  rtranif0 rtranif1 
 syn keyword sysVerilogStatement  scalared 
 syn keyword sysVerilogStatement  shortint shortreal 
 syn keyword sysVerilogStatement  showcancelled signed 
 syn keyword sysVerilogStatement  small solve 
 syn keyword sysVerilogStatement  specparam 
 syn keyword sysVerilogStatement  static string 
 syn keyword sysVerilogStatement  strong0 strong1 
 syn keyword sysVerilogStatement  struct super 
 syn keyword sysVerilogStatement  supply0 supply1 
 "syn keyword sysVerilogStatement  
 syn keyword sysVerilogStatement  this throughout 
 syn keyword sysVerilogStatement  time timeprecision 
 syn keyword sysVerilogStatement  timeunit tran 
 syn keyword sysVerilogStatement  tranif0 tranif1 
 syn keyword sysVerilogStatement  tri tri0 
 syn keyword sysVerilogStatement  tri1 triand 
 syn keyword sysVerilogStatement  trior trireg 
 syn keyword sysVerilogStatement  type typedef 
 syn keyword sysVerilogStatement  union unique 
 syn keyword sysVerilogStatement  unsigned use 
 syn keyword sysVerilogStatement  var vectored 
 syn keyword sysVerilogStatement  virtual void 
 syn keyword sysVerilogStatement  wait wait_order 
 syn keyword sysVerilogStatement  wand weak0 
 syn keyword sysVerilogStatement  weak1 while 
 syn keyword sysVerilogStatement  wire with 
 syn keyword sysVerilogStatement  within wor 
 syn keyword sysVerilogStatement  xnor xor


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"----------------------------Added by Malkesh Adesra--------------------------------
"data types
 syn keyword sysVerilogData  bit byte reg logic string struct enum event wire 
 syn keyword sysVerilogData  int integer real shortreal chandle mailbox semaphore
 
 syn keyword sysVerilogPort  input output inout 
 
 
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"----------------------------Added by Malkesh Adesra--------------------------------
"VMM Synopsis
 syn keyword sysVerilogVMMtask  run stop start wait_for_end cleanup report
 syn keyword sysVerilogVMMtask  gen_cfg build reset_dut cfg_dut
 
 syn keyword sysVerilogVMMtask  stop_xactor start_xactor
 syn keyword sysVerilogVMMtask  reset_xactor wait_if_stopped wait_if_stopped_or_empty

 syn keyword sysVerilogVMMtask  put get sneak peek reconfigure flush connect tee
 
 syn keyword sysVerilogVMMtask  append_callback prepend_callback 
 syn keyword sysVerilogVMMtask  inject scenario_set
 syn keyword sysVerilogVMMtask  define_scenario scenario_kind 
 syn keyword sysVerilogVMMtask  wait_for
 syn keyword sysVerilogVMMtask  copy compare list byte_pack byte_unpack byte_size

 
 syn keyword sysVerilogVMMfield stop_after_n_scenarios stop_after_n_errors stop_after_n_insts 
 syn keyword sysVerilogVMMfield scenario_kind scenario_set notify log items
 syn keyword sysVerilogVMMfield data_id stream_id scenario_id out_chan
 syn keyword sysVerilogVMMfield repeated length repeat_thresh

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"----------------------------Added by Malkesh Adesra--------------------------------
"VMM library classes
syn keyword sysVerilogVMMclass vmm_data vmm_xactor vmm_channel vmm_env vmm_log
syn keyword sysVerilogVMMclass vmm_scheduler vmm_notify vmm_log_format


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"----------------------------Added by Malkesh Adesra--------------------------------
" Various Blocks  

 syn keyword sysVerilogBlock  primitive specify config 
 syn keyword sysVerilogBlock  endprimitive endspecify endconfig 
 syn keyword sysVerilogBlock  generate group
 syn keyword sysVerilogBlock  endgenerate endgroup
 
 syn keyword sysVerilogBlock1  module class program package
 syn keyword sysVerilogBlock1  endmodule endclass endprogram endpackage

 syn keyword sysVerilogBlock2  function task clocking interface table
 syn keyword sysVerilogBlock2  endfunction endtask endclocking endinterface endtable

 syn keyword sysVerilogBlock3 property sequence assert assume expect
 syn keyword sysVerilogBlock3 endproperty endsequence
 
 syn keyword sysVerilogBlockC covergroup cross coverpoint cover bins 
 syn keyword sysVerilogBlockC illegal_bins ignore_bins


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"----------------------------Added by Malkesh Adesra--------------------------------
"Inbuilt array/queue functions

 syn keyword sysVerilogTask  num delete exists name
 syn keyword sysVerilogTask  first last next prev
 syn keyword sysVerilogTask  insert size
 syn keyword sysVerilogTask  pop_front pop_back push_front push_back
 syn keyword sysVerilogTask  find find_first find_last
 syn keyword sysVerilogTask  find_index find_first_index find_last_index
 syn keyword sysVerilogTask  reverse sort rsort shuffle

 syn keyword sysVerilogTask1  new randomize with
 syn keyword sysVerilogTask1 constraint_mode rand_mode pre_randomize post_randomize
 

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"----------------------------Added/Modified by Malkesh Adesra---------------------------
 syn keyword sysVerilogLabel       begin end fork join join_any join_none join_all
 syn keyword sysVerilogConditional if else case casex casez default endcase
 syn keyword sysVerilogRepeat      forever repeat while for do foreach
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


syn keyword sysVerilogTodo contained TODO

syn match   sysVerilogOperator "[&|~><!)(*#%@+/=?:;}{,.\^\-\[\]]"

syn region  sysVerilogComment start="/\*" end="\*/" contains=sysVerilogTodo
syn match   sysVerilogComment "//.*" oneline

syn match   sysVerilogDefines "`[a-zA-Z0-9_]\+\>"
syn match   sysVerilogGlobal "$[a-zA-Z0-9_]\+\>"

syn match   sysVerilogConstant "\<[A-Z][A-Z0-9_]\+\>"

syn match   sysVerilogNumber "\(\<\d\+\|\)'[bB]\s*[0-1_xXzZ?]\+\>"
syn match   sysVerilogNumber "\(\<\d\+\|\)'[oO]\s*[0-7_xXzZ?]\+\>"
syn match   sysVerilogNumber "\(\<\d\+\|\)'[dD]\s*[0-9_xXzZ?]\+\>"
syn match   sysVerilogNumber "\(\<\d\+\|\)'[hH]\s*[0-9a-fA-F_xXzZ?]\+\>"
syn match   sysVerilogNumber "\<[+-]\=[0-9_]\+\(\.[0-9_]*\|\)\(e[0-9_]*\|\)\>"

syn region  sysVerilogString start=+"+  end=+"+

" Directives
syn match   sysVerilogDirective   "//\s*synopsys\>.*$"
syn region  sysVerilogDirective   start="/\*\s*synopsys\>" end="\*/"
syn region  sysVerilogDirective   start="//\s*synopsys dc_script_begin\>" end="//\s*synopsys dc_script_end\>"

syn match   sysVerilogDirective   "//\s*\$s\>.*$"
syn region  sysVerilogDirective   start="/\*\s*\$s\>" end="\*/"
syn region  sysVerilogDirective   start="//\s*\$s dc_script_begin\>" end="//\s*\$s dc_script_end\>"


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Methodology Specific highlighting

"----------------------------Added by Malkesh Adesra--------------------------------
"for classes : e.g; monitor_c
syn match   sysVerilogClass "\<[a-zA-Z0-9_]\+_c\>"
syn match   sysVerilogenum "\<[a-zA-Z0-9_]\+_e\>"
syn match   sysVeriloginterface "\<[a-zA-Z0-9_]\+_if\>"
syn match   sysVerilogchannel "\<[a-zA-Z0-9_]\+_channel\>"
syn match   sysVerilogscenario_gen "\<[a-zA-Z0-9_]\+_scenario_gen\>"
syn match   sysVerilogtag "\<[a-zA-Z0-9_]\+_L\>"

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"VMM library
"----------------------------Added by Malkesh Adesra--------------------------------
syn match   sysVerilogVMM "\`vmm_[a-zA-Z0-9_]\+\>"


"Modify the following as needed.  The trade-off is performance versus
"functionality.
syn sync lines=50

if !exists("did_sysVerilog_syntax_inits")
  let did_sysVerilog_syntax_inits = 1
 " The default methods for highlighting.  Can be overridden later

  hi link sysVerilogCharacter       Character
  hi link sysVerilogTodo            Todo
  hi link sysVerilogNumber          Number
  hi link sysVerilogOperator        Special
  "hi link sysVerilogStatement       Statement
  hi      sysVerilogStatement       guifg=Indianred3 gui=bold
  hi link sysVerilogGlobal          String
  hi link sysVerilogDirective       SpecialComment
  hi      sysVerilogString          guifg=purple guibg=grey98
  hi      sysVerilogDefines         guifg=purple

"----------------------------Added by Malkesh Adesra--------------------------------

  hi sysVerilogData                 guifg=black gui=italic,bold
  hi sysVerilogPort                 guifg=Black gui=bold
  hi sysVerilogLabel                guifg=purple4 gui=bold
  hi sysVerilogtag                  guifg=lightslategrey gui=bold
  hi sysVerilogRepeat               guifg=darkcyan gui=bold
  hi sysVerilogConditional          guifg=darkseagreen4 gui=bold
  "hi sysVerilogComment              guifg=lightslategrey gui=bold 
  hi sysVerilogComment              guifg=dodgerblue3  
  "hi sysVerilogConstant             guifg=Orchid gui=bold
  hi link sysVerilogConstant        String 
  hi sysVerilogBlock                guifg=dimgrey gui=bold
  hi sysVerilogBlock1               guifg=Blue4 gui=bold
  hi sysVerilogBlock2               guifg=slateBlue1 gui=bold
  hi sysVerilogBlock3               guifg=orange3 gui=bold
  hi sysVerilogBlockC               guifg=Blue4 gui=bold
  hi sysVerilogTask1                guifg=#D80E48 gui=bold
  hi sysVerilogTask                 guifg=violetred1 gui=bold
  hi sysVerilogMyname               guifg=orange gui=italic

"----------------------------Added by Malkesh Adesra--------------------------------
  "hi sysVerilogClass                guifg=darkmagenta gui=bold
  hi sysVerilogClass                guifg=darkmagenta
  hi sysVeriloginterface            guifg=darkcyan gui=bold
  hi sysVerilogchannel              guifg=darkgoldenrod4 gui=bold
  hi sysVerilogscenario_gen         guifg=darkgoldenrod4 gui=bold
  hi sysVerilogenum                 guifg=mediumaquamarine gui=bold

"----------------------------Added by Malkesh Adesra--------------------------------
  hi sysVerilogVMM                  guifg=Orange gui=bold
  hi sysVerilogVMMtask              guifg=#ff6969 gui=bold
  hi sysVerilogVMMfield              guifg=forestgreen gui=bold

"----------------------------Added by Malkesh Adesra--------------------------------
  hi sysVerilogVMMclass             guifg=darkgoldenrod3 gui=bold
  "hi sysVerilogVMMclass             guifg=NavajoWhite4 gui=bold
endif

let b:current_syntax = "sysVerilog"

"----------------------------Added by Malkesh Adesra--------------------------------

abbr #x //---------------------------------------------------------------------
abbr #c ///////////////////////////////////////////////////////////////////////
abbr vdbg `vmm_debug(log,"");
abbr vwarn `vmm_warning(log,"");
abbr vnote `vmm_note(log,"");
abbr vftl `vmm_fatal(log,"");
abbr verr $error("");
abbr dpl $display("");
" vim: ts=80
