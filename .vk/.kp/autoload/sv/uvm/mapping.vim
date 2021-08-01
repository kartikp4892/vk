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
function! sv#uvm#mapping#get_default_name()
  let name = expand('%:p:t')
  let name = substitute(name, '\v\.\w+$', '', '')
  return name
endfunction

function! s:unique_array(array)
  let array_h = {}
  let uarray = []

  for val in a:array
    if (!exists('array_h[val]'))
      let array_h[val] = 1
      let uarray += [val]
    endif
  endfor

  return uarray
endfunction

function! sv#uvm#mapping#get_descendants(clsname)
  if (exists('$SVTAGSPATH'))
    let decendents = [a:clsname]
    let svtagsdirs = []

py << EOD
import sys
import os
import imp

def import_(filename):
    path, name = os.path.split(filename)
    name, ext = os.path.splitext(name)

    file, filename, data = imp.find_module(name, [path])
    mod = imp.load_module(name, file, filename, data)
    return mod

decendents = vim.bindeval('decendents')
svtagsdirs = vim.bindeval('svtagsdirs')

#-------------------------------------------------------------------------------
# Get list of svtags directories
envutil_path = '{kp_vim_home}/python_lib/vim/lib/Utils/env_vars.py'.format(kp_vim_home=os.environ['KP_VIM_HOME'])
envutil = import_(envutil_path)
svtagsdirs.extend(envutil.env2path('SVTAGSPATH'))
#-------------------------------------------------------------------------------

# FIXED: Get descendats from all the clstree/_main.py scripts in all svtags dir
for path in svtagsdirs:
  module_file = "{0}/clstree/_main.py".format(path)
  try:
    clstree = import_(module_file)
    temp_decendents = clstree.get_descendants(vim.eval('a:clsname'))
    #decendents.extend(temp_decendents)
    decendents.extend([decendent for decendent in temp_decendents if not decendent.startswith('uvm_')])
    #decendents.extend(set(temp_decendents) - set(decendents))
  except Exception as e:
    pass
EOD
    
  endif

  return s:unique_array(decendents)
endfunction

function! sv#uvm#mapping#get_parent(default)
  let decendents = sv#uvm#mapping#get_descendants(a:default)

  call inputsave()
  let parent = tlib#input#List('s', 'Parent Class', decendents,[], a:default)
  call inputrestore()

  if (parent == '')
    return a:default
  endif

  let parent_syntax = sv#uvm#mapping#get_clsname_syntax(parent)

  return parent_syntax

endfunction

function! sv#uvm#mapping#get_clsname_syntax(clsname)
  " || OR || let cls_syntax = system(printf('python %0s/python_lib/vim/lib/Utils/tag2syntax_prg.py --clsname %0s', $KP_VIM_HOME, a:clsname))
  " || OR || let cls_syntax = substitute(cls_syntax, '^\n*', '', 'g')

py << EOD
import imp
import os
import vim

def import_(filename):
    path, name = os.path.split(filename)
    name, ext = os.path.splitext(name)

    file, filename, data = imp.find_module(name, [path])
    mod = imp.load_module(name, file, filename, data)
    return mod

tag2syntax_path = '{kp_vim_home}/python_lib/vim/lib/Utils/tag2syntax.py'.format(kp_vim_home=os.environ['KP_VIM_HOME'])
tag2syntax = import_(tag2syntax_path)

cls_syntax = tag2syntax.get_class_syntax(vim.eval('a:clsname'))
vim.command('let cls_syntax = "{0}"'.format(cls_syntax))

EOD

  return cls_syntax
endfunction

"-------------------------------------------------------------------------------
" monitor: Function
"-------------------------------------------------------------------------------
function! sv#uvm#mapping#monitor()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  let parent = sv#uvm#mapping#get_parent('uvm_monitor')

  let str = s:ifndef()

  let str .= comments#block_comment#getComments("Monitor", "" . name )
  let str .= printf ('class ' . name . ' extends %0s;', parent) .
    \ s:_set_indent(&shiftwidth) . '`uvm_component_utils (' . name . ')' .
    \ s:_set_indent(0) . comments#block_comment#getComments("Function", "new") .
    \ 'function new(string name, uvm_component parent = null);' .
    \ s:_set_indent(&shiftwidth) . 'super.new(name,parent);' .
    \ s:_set_indent(-&shiftwidth) . 'endfunction : new' .
    \
    \ s:_set_indent(0) . comments#block_comment#getComments("Function", "build_phase") .
    \ 'virtual function void build_phase(uvm_phase phase);' .
    \ s:_set_indent(&shiftwidth) . 'super.build_phase(phase);' .
    \ s:_set_indent(-&shiftwidth) . 'endfunction : build_phase' .
    \
    \ s:_set_indent(0) . comments#block_comment#getComments("Task", "run_phase") .
    \ 'task run_phase(uvm_phase phase);' .
    \ s:_set_indent(&shiftwidth) . 'maa' .
    \ s:_set_indent(0) . 'endtask : run_phase' .
    \ s:_set_indent(-&shiftwidth) . 'endclass : ' . name . '`aa'


  return str
endfunction

"-------------------------------------------------------------------------------
" component: Function
"-------------------------------------------------------------------------------
function! sv#uvm#mapping#component()
  let name = matchstr(getline("."), '^\s*\zs\w\+')

  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  let parent = sv#uvm#mapping#get_parent('uvm_component')

  let str = s:ifndef()

  let str .= comments#block_comment#getComments("Component", "" . name )
  let str .= printf('class ' . name . ' extends %0s;', parent) .
    \ s:_set_indent(&shiftwidth) . 'maa' .
    \ s:_set_indent(&shiftwidth) . '`uvm_component_utils (' . name . ')' .
    \ comments#block_comment#getComments("Function", "new") .
    \ 'function new(string name, uvm_component parent = null);' .
    \ s:_set_indent(&shiftwidth) . 'super.new(name,parent);' .
    \ s:_set_indent(-&shiftwidth) . 'endfunction' .
    \ comments#block_comment#getComments("Function", "build_phase") .
    \ 'virtual function void build_phase(uvm_phase phase);' .
    \ s:_set_indent(&shiftwidth) . 'super.build_phase(phase);' .
    \ s:_set_indent(-&shiftwidth) . 'endfunction : build_phase' .
    \ comments#block_comment#getComments("Task", "run_phase") .
    \ 'task run_phase(uvm_phase phase);' .
    \ s:_set_indent(&shiftwidth) . '' .
    \ s:_set_indent(0) . 'endtask' .
    \ s:_set_indent(-&shiftwidth) . 'endclass : ' . name . '`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" _get_scb_ports: Function
"-------------------------------------------------------------------------------
function! s:_get_scb_ports()
  let cline = line('.')
  let idx = 1
  let ports = []
  while (idx < cline)
    let lstr = getline(idx)
    if (lstr =~ '^\s*`uvm_analysis_imp_decl')
      let port = matchstr(lstr, '\vuvm_analysis_imp_decl\s*\(\zs\w+\ze\)')
      call extend(ports, [port])
    endif
    let idx += 1
  endwhile
  return ports
endfunction

"-------------------------------------------------------------------------------
" _decl_imp_ports: Function
"-------------------------------------------------------------------------------
function! s:_decl_imp_ports(ports, scb_name)
  let str = ""
  let cnt = 1
  for port in a:ports
    let str .= printf('uvm_analysis_imp%s #(%s, %s) %s;', port, g:sv#glob_var#seq_item, a:scb_name, s:GetTemplete('a', 'PORT_NAME' . cnt))
    let cnt += 1
  endfor
  return str
endfunction

"-------------------------------------------------------------------------------
" _imp_write_fun: Function
"-------------------------------------------------------------------------------
function! s:_imp_write_fun(ports)
  let str = ""
  for port in a:ports
    let fun_name = 'write' . port
    let str .= printf('virtual function void ' . fun_name . '(%s trans);', g:sv#glob_var#seq_item) .
               \printf('  %s', s:GetTemplete('b', '')) .
               \'endfunction : ' . fun_name . ''
  endfor
  return str
endfunction

"-------------------------------------------------------------------------------
" _ports_inst: Function
"-------------------------------------------------------------------------------
function! s:_ports_inst(ports)
  let str = ""
  let cnt = 1
  for port in a:ports
    let str .= printf('%s = new("%s", this);', s:GetTemplete('a', 'PORT_NAME' . cnt), s:GetTemplete('a', 'PORT_NAME' . cnt))
    let cnt += 1
  endfor
  return str
endfunction

"-------------------------------------------------------------------------------
" _decl_act_exp_fifo: Function
"-------------------------------------------------------------------------------
function! s:_decl_act_exp_fifo()
  let str = ""
  let str .= printf('uvm_tlm_analysis_fifo #(%s) m_exp_fifo;', g:sv#glob_var#seq_item) .
            \printf('uvm_tlm_analysis_fifo #(%s) m_act_fifo;', g:sv#glob_var#seq_item)
  return str
endfunction

"-------------------------------------------------------------------------------
" _inst_act_exp_fifo: Function
"-------------------------------------------------------------------------------
function! s:_inst_act_exp_fifo()
  let str = 'm_exp_fifo = new ("m_exp_fifo", this);' . 
    \'m_act_fifo = new ("m_act_fifo", this);'
  return str
endfunction

"-------------------------------------------------------------------------------
" _imp_fifo_funs: Function
"-------------------------------------------------------------------------------
function! s:_imp_fifo_funs()

  let str = ""
  let comment = 'Returns the number of available transactions in the expected FIFO'
  let str .= comments#block_comment#getComments("Function", "get_exp_fifo_size", comment ) . 
             \'virtual function unsigned int get_exp_fifo_size();' . 
             \'  return m_exp_fifo.used();' . 
             \'endfunction : get_exp_fifo_size'

  let comment = 'Returns the number of available transactions in the actual FIFO'
  let str .= comments#block_comment#getComments("Function", "get_act_fifo_size", comment ) .
             \'virtual function unsigned int get_act_fifo_size();' . 
             \'  return m_act_fifo.used();' . 
             \'endfunction : get_act_fifo_size'

  let comment = 'Flushes all the FIFOs of comparator'
  let str .= comments#block_comment#getComments("Function", "flush_fifo", comment ) .
             \'virtual function void flush_fifo();' .
             \'  m_exp_fifo.flush();' .
             \'m_act_fifo.flush();' .
             \'endfunction : flush_fifo'

  return str
endfunction

"-------------------------------------------------------------------------------
" _report_fifo_status: Function
"-------------------------------------------------------------------------------
function! s:_report_fifo_status()
    let str =
    \'if((get_exp_fifo_size() != 0) || (get_act_fifo_size() != 0)) begin' .
    \'  `uvm_error(this.get_name(), $psprintf("Leftover transactions found in exp_fifo(%0d) OR act_fifo(%0d)",' .
    \'  m_exp_fifo.used(),m_act_fifo.used()))' .
    \'end'

  return str
endfunction

"-------------------------------------------------------------------------------
" scoreboard: Function
"-------------------------------------------------------------------------------
function! sv#uvm#mapping#scoreboard()
  let name = matchstr(getline("."), '^\s*\zs\w\+')

  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  let ports = s:_get_scb_ports()

  call setline(".", repeat(' ', indent(".")))

  let str = s:ifndef()

  let parent = sv#uvm#mapping#get_parent('uvm_scoreboard')

  let str .= comments#block_comment#getComments("Scoreboard", "" . name )
  let str .= printf('class ' . name . ' extends %0s;', parent) .
    \'  maa' .
    \'//Indicates number of matches and mismatches' . 
    \'bit [31:0] m_matches, m_mismatches;'
  
  let str .= s:_decl_imp_ports(ports, name)

  let str .= s:_decl_act_exp_fifo()

  let str .=
    \'`uvm_component_utils (' . name . ')' . comments#block_comment#getComments("Function", "new") .
    \'function new(string name, uvm_component parent);' .
    \'  super.new(name,parent);' .
    \s:_ports_inst(ports) . 
    \s:_inst_act_exp_fifo() .
    \'endfunction' . comments#block_comment#getComments("Function", "build_phase") .
    \'virtual function void build_phase(uvm_phase phase);' .
    \'  super.build_phase(phase);' .
    \'endfunction : build_phase' .comments#block_comment#getComments("Function", "report_phase") .
    \'function void report_phase(uvm_phase phase);' .
    \'  uvm_report_info(get_type_name(),' .
    \'  $psprintf("Scoreboard Report %s", this.sprint()), UVM_LOW);' .
    \s:_report_fifo_status() . 
    \'endfunction : report_phase' . comments#block_comment#getComments("Task", "run_phase") .
    \'task run_phase(uvm_phase phase);' .
    \'  ' .
    \'endtask'

  let str .= s:_imp_write_fun(ports)

  let str .= s:_imp_fifo_funs()

  let str .=
    \'endclass : ' . name . '`aa'
  return str
endfunction

function! sv#uvm#mapping#scoreboard_with_analysis_fifo()
  let name = matchstr(getline("."), '^\s*\zs\w\+')

  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  let analysis_exports = ['exp', 'act']

  call inputsave()
  let analysis_exports = tlib#input#EditList('Exports Details:', analysis_exports)
  call inputrestore()

  let parent = sv#uvm#mapping#get_parent('uvm_scoreboard')

  let str = s:ifndef()

  let str .= s:_set_indent(0) . printf('class %0s #(type ITEM, string ID = "") extends %0s;', name, parent)
    
  let str .= s:_set_indent(&shiftwidth) . '// Typedef     : this_type'
  let str .= s:_set_indent(0) .           '// Description : Type declaration of base comparator'
  let str .= s:_set_indent(0) . printf('typedef %0s #(ITEM, ID) this_type;', name)
  
  let str .= s:_set_indent(0) . '`uvm_component_param_utils(this_type)'

  for l:export in analysis_exports
    let str .= s:_set_indent(0) . printf('// Export      : m_%0s_export' , l:export) 
    let str .= s:_set_indent(0) . printf('// Description : Analysis export for %0s transactions', l:export) 
    let str .= s:_set_indent(0) . printf('uvm_analysis_export #(ITEM) m_%0s_export;', l:export) 
  endfor

  for l:export in analysis_exports
    let str .= s:_set_indent(0) . printf('// Fifo        : m_%0s_fifo', l:export) 
    let str .= s:_set_indent(0) . printf('// Description : Analysis fifo for storing the %0s transactions', l:export) 
    let str .= s:_set_indent(0) . printf('uvm_tlm_analysis_fifo #(ITEM) m_%0s_fifo;', l:export) 
  endfor

  let str .= s:_set_indent(0) . '// Variable    : m_matches'
  let str .= s:_set_indent(0) . '// Description : Indicates number of matches'
  let str .= s:_set_indent(0) . 'int unsigned m_matches;'

  let str .= s:_set_indent(0) . '// Variable    : m_mismatches'
  let str .= s:_set_indent(0) . '// Description : Indicates number of mismatches'
  let str .= s:_set_indent(0) . 'int unsigned m_mismatches;'

  let str .= s:_set_indent(0) . '// Variable    : comp_id'
  let str .= s:_set_indent(0) . '// Description : The comparison id used in report messages'
  let str .= s:_set_indent(0) . 'string comp_id;'

  let str .= s:_set_indent(0) . '//-------------------------------------------------------------------------------'
  let str .= s:_set_indent(0) . '// Function       : new'
  let str .= s:_set_indent(0) . '// Arguments      : string name  - Name of the object.'
  let str .= s:_set_indent(0) . '//                  uvm_component parent  - Object of parent component class.'
  let str .= s:_set_indent(0) . '// Description    : Constructor for creating this class object'
  let str .= s:_set_indent(0) . '//-------------------------------------------------------------------------------'
  let str .= s:_set_indent(0) . 'function new(string name, uvm_component parent);'
  let str .= s:_set_indent(&shiftwidth) . 'super.new(name,parent);'

  for l:export in analysis_exports
    let str .= s:_set_indent(0) . printf('m_%0s_fifo = new ("m_%0s_fifo", this);', l:export, l:export)
  endfor
  let str .= ''

  for l:export in analysis_exports
    let str .= s:_set_indent(0) . printf('m_%0s_export = new ("m_%0s_export", this);', l:export, l:export)
  endfor
  let str .= ''

  let str .= s:_set_indent(0) . 'if (ID == "") begin '
  let str .= s:_set_indent(&shiftwidth) . 'comp_id = get_name();'
  let str .= s:_set_indent(-&shiftwidth) . 'end'
  let str .= s:_set_indent(0) . 'else begin '
  let str .= s:_set_indent(&shiftwidth) . 'comp_id = ID;'
  let str .= s:_set_indent(-&shiftwidth) . 'end'
  let str .= s:_set_indent(-&shiftwidth) . 'endfunction'

  let str .= s:_set_indent(0) . '//-------------------------------------------------------------------------------'
  let str .= s:_set_indent(0) . '// Function       : build_phase'
  let str .= s:_set_indent(0) . '// Arguments      : uvm_phase phase  - Handle of uvm_phase.'
  let str .= s:_set_indent(0) . '// Description    : This phase creates all the required objects'
  let str .= s:_set_indent(0) . '//-------------------------------------------------------------------------------'
  let str .= s:_set_indent(0) . 'virtual function void build_phase(uvm_phase phase);'
  let str .= s:_set_indent(&shiftwidth) . 'super.build_phase(phase);'
  let str .= s:_set_indent(-&shiftwidth) . 'endfunction : build_phase'

  let str .= s:_set_indent(0) . '//-------------------------------------------------------------------------------'
  let str .= s:_set_indent(0) . '// Function       : connect_phase'
  let str .= s:_set_indent(0) . '// Arguments      : uvm_phase phase  - Handle of uvm_phase.'
  let str .= s:_set_indent(0) . '// Description    : This phase establish the connections between different component'
  let str .= s:_set_indent(0) . '//-------------------------------------------------------------------------------'
  let str .= s:_set_indent(0) . 'virtual function void connect_phase(uvm_phase phase);'
  let str .= s:_set_indent(&shiftwidth) . 'super.connect_phase(phase);'

  for l:export in analysis_exports
    let str .= s:_set_indent(0) . printf('m_%0s_export.connect(m_%0s_fifo.analysis_export);', l:export, l:export)
  endfor

  let str .= s:_set_indent(-&shiftwidth) . 'endfunction : connect_phase'

  let str .= s:_set_indent(0) . '//-------------------------------------------------------------------------------'
  let str .= s:_set_indent(0) . '// Function       : report_phase'
  let str .= s:_set_indent(0) . '// Arguments      : uvm_phase phase  - Handle of uvm_phase.'
  let str .= s:_set_indent(0) . '// Description    : Report the leftover transaction in base comparator'
  let str .= s:_set_indent(0) . '//-------------------------------------------------------------------------------'
  let str .= s:_set_indent(0) . 'function void report_phase(uvm_phase phase);'
  let str .= s:_set_indent(&shiftwidth) . 'uvm_report_info(get_type_name(), $psprintf("Scoreboard Report %0s", this.sprint()), UVM_LOW);'

  " Check if fifo are empty in report phase
  for l:export in analysis_exports
    let str .= s:_set_indent(0) . printf('// Report leftover transactions in %0s fifo', l:export)
    let str .= s:_set_indent(0) . printf('if(get_%0s_fifo_size() != 0) begin', l:export)
    let str .= s:_set_indent(&shiftwidth) . printf('`uvm_error(this.get_name(), $psprintf("Leftover transactions found in %0s_fifo(%%0d)", m_%0s_fifo.used()))', l:export, l:export)

    let str .= s:_set_indent(0) . printf('while (get_%0s_fifo_size() != 0) begin ', l:export)
    let str .= s:_set_indent(&shiftwidth) . printf('ITEM %0s_tx;', l:export)

    let str .= s:_set_indent(0) . printf('if (m_%0s_fifo.try_get(%0s_tx)) begin', l:export, l:export)
    let str .= s:_set_indent(&shiftwidth) . printf('%0s_tx.print();', l:export)
    let str .= s:_set_indent(-&shiftwidth) . 'end'
    let str .= s:_set_indent(-&shiftwidth) . 'end'
    let str .= s:_set_indent(-&shiftwidth) . 'end'
  endfor

  let str .= s:_set_indent(-&shiftwidth) . 'endfunction : report_phase'

  let str .= s:_set_indent(0) . '//-------------------------------------------------------------------------------'
  let str .= s:_set_indent(0) . '// Task           : run_phase'
  let str .= s:_set_indent(0) . '// Arguments      : uvm_phase phase  - Handle of uvm_phase.'
  let str .= s:_set_indent(0) . '// Description    : In this phase the TB execution starts'
  let str .= s:_set_indent(0) . '//-------------------------------------------------------------------------------'
  let str .= s:_set_indent(0) . 'task run_phase(uvm_phase phase);'

  let str .= s:_set_indent(&shiftwidth) . 'forever begin '
  let str .= s:_set_indent(&shiftwidth) . 'string msg;'

  let str .= s:_set_indent(0) . '// ########### TODO: Compare transactions logic ########### '
  let str .= s:_set_indent(0) . '/* '

  for l:export in analysis_exports
    let str .= s:_set_indent(0) . printf('ITEM %0s_tx;', l:export)
  endfor
  let str .= ''

  for l:export in analysis_exports
    let str .= s:_set_indent(0) . printf('m_%0s_fifo.get(%0s_tx);', l:export, l:export)
  endfor
  let str .= ''

  let str .= s:_set_indent(0) . 'msg = "";'
  for l:export in analysis_exports
    let str .= s:_set_indent(0) . printf('msg = {msg, $psprintf ("%0s transaction: \n%%0s", %0s_tx.sprint())};', l:export, l:export)
  endfor
  let str .= ''

  let str .= s:_set_indent(0) . printf('if (%0s_tx.compare(%0s_tx)) begin', analysis_exports[0], analysis_exports[1])
  let str .= s:_set_indent(&shiftwidth) . printf('`uvm_info(comp_id, $psprintf("EXP (%%0s) and ACT (%%0s) transactions match!!!\n%%0s", %0s_tx.get_name(), %0s_tx.get_name(), msg))', analysis_exports[0], analysis_exports[1])
  let str .= s:_set_indent(0) . 'm_matches += 1;'
  let str .= s:_set_indent(-&shiftwidth) . 'end'
  let str .= s:_set_indent(0) . 'else begin '
  let str .= s:_set_indent(&shiftwidth) . printf('`uvm_error(comp_id, $psprintf("EXP (%%0s) and ACT (%%0s) transactions mismatch!!!%%0s", %0s_tx.get_name(), %0s_tx.get_name(), msg))', analysis_exports[0], analysis_exports[1])
  let str .= s:_set_indent(0) . 'm_mismatches += 1;'
  let str .= s:_set_indent(-&shiftwidth) . 'end'

  let str .= s:_set_indent(0) . '*/'
  let str .= s:_set_indent(0) . '// ########### TODO: Compare transactions logic ########### '
  let str .= s:_set_indent(-&shiftwidth) . 'end'
  let str .= s:_set_indent(-&shiftwidth) . 'endtask'

  for l:export in analysis_exports
    let str .= s:_set_indent(0) . '//-------------------------------------------------------------------------------'
    let str .= s:_set_indent(0) . printf('// Function       : get_%0s_fifo_size', l:export)
    let str .= s:_set_indent(0) . '// Return Type    : unsigned int'
    let str .= s:_set_indent(0) . printf('// Description    : Returns number of transactions left in %0s fifo', l:export)
    let str .= s:_set_indent(0) . '//-------------------------------------------------------------------------------'
    let str .= s:_set_indent(0) . printf('virtual function int get_%0s_fifo_size();', l:export)
    let str .= s:_set_indent(&shiftwidth) . printf('return m_%0s_fifo.used();', l:export)
    let str .= s:_set_indent(-&shiftwidth) . printf('endfunction : get_%0s_fifo_size', l:export)
  endfor

  let str .= s:_set_indent(0) . '//-------------------------------------------------------------------------------'
  let str .= s:_set_indent(0) . '// Function       : flush_fifo'
  let str .= s:_set_indent(0) . '// Description    : Flush analysis fifos'
  let str .= s:_set_indent(0) . '//-------------------------------------------------------------------------------'
  let str .= s:_set_indent(0) . 'virtual function void flush_fifo();'

  let str .= s:_set_indent(&shiftwidth) 
  for l:export in analysis_exports
    let str .= printf('m_%0s_fifo.flush();', l:export) . s:_set_indent(0) 
  endfor

  let str .= s:_set_indent(-&shiftwidth) . 'endfunction : flush_fifo'

  let str .= s:_set_indent(-&shiftwidth) . printf('endclass : %0s', name)

  return str
endfunction

"-------------------------------------------------------------------------------
" agent: Function
"-------------------------------------------------------------------------------
function! sv#uvm#mapping#agent()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  let cb = g:callbacks#sv#uvm#agent#cb.Get()

  let parent = sv#uvm#mapping#get_parent('uvm_component')

  let str = s:ifndef()

  let str .= comments#block_comment#getComments("Component", "" . name )
  let str .= printf('class ' . name . ' extends %0s;', parent) .
    \ s:_set_indent(&shiftwidth) . 'maa' .
    \ s:_set_indent(&shiftwidth) . '`uvm_component_utils (' . name . ')' .
    \ cb.declaration .
    \ s:_set_indent(0) . comments#block_comment#getComments("Function", "new") .
    \ 'function new(string name, uvm_component parent = null);' .
    \ s:_set_indent(&shiftwidth) . 'super.new(name,parent);' .
    \ s:_set_indent(-&shiftwidth) . 'endfunction' .
    \
    \ s:_set_indent(0) . comments#block_comment#getComments("Function", "build_phase") .
    \ 'virtual function void build_phase(uvm_phase phase);' .
    \ cb.build_phase.declaration .
    \ s:_set_indent(&shiftwidth) . 'super.build_phase(phase);' .
    \ cb.build_phase.body .
    \ s:_set_indent(-&shiftwidth) . 'endfunction : build_phase' .
    \
    \ s:_set_indent(0) . comments#block_comment#getComments("Function", "connect_phase") .
    \ 'virtual function void connect_phase(uvm_phase phase);' .
    \ cb.connect_phase.declaration .
    \ s:_set_indent(&shiftwidth) . 'super.connect_phase(phase);' .
    \ cb.connect_phase.body .
    \ s:_set_indent(-&shiftwidth) . 'endfunction : connect_phase' .
    \ s:_set_indent(-&shiftwidth) . 'endclass : ' . name . '`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" env: Function
"-------------------------------------------------------------------------------
function! sv#uvm#mapping#env()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  let cb = g:callbacks#sv#uvm#env#cb.Get()

  let parent = sv#uvm#mapping#get_parent('uvm_env')

  let str = s:ifndef()

  let str .= comments#block_comment#getComments("Component", "" . name )
  let str .= printf('class ' . name . ' extends %0s;', parent) .
    \ s:_set_indent(&shiftwidth) . 'maa' .
    \ s:_set_indent(&shiftwidth) . '`uvm_component_utils (' . name . ')' .
    \ cb.declaration .
    \ s:_set_indent(0) . comments#block_comment#getComments("Function", "new") .
    \ 'function new(string name, uvm_component parent = null);' .
    \ s:_set_indent(&shiftwidth) . 'super.new(name,parent);' .
    \ s:_set_indent(-&shiftwidth) . 'endfunction' .
    \ s:_set_indent(0) . comments#block_comment#getComments("Function", "build_phase") .
    \ s:_set_indent(0) . 'virtual function void build_phase(uvm_phase phase);' .
    \ s:_set_indent(&shiftwidth) . 'super.build_phase(phase);' .
    \ cb.build_phase.body .
    \ s:_set_indent(-&shiftwidth) . 'endfunction : build_phase' .
    \ s:_set_indent(0) . comments#block_comment#getComments("Function", "connect_phase") .
    \ 'virtual function void connect_phase(uvm_phase phase);' .
    \ s:_set_indent(&shiftwidth) . 'super.connect_phase(phase);' .
    \ cb.connect_phase.body .
    \ s:_set_indent(-&shiftwidth) . 'endfunction : connect_phase' .
    \ sv#uvm#uvm_phases#final_phase() .
    \ s:_set_indent(-&shiftwidth) . 'endclass : ' . name . '`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" driver: Function
"-------------------------------------------------------------------------------
function! sv#uvm#mapping#driver()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  let str = s:ifndef()

  let run_phase = 'task run_phase(uvm_phase phase);' .
  \ s:_set_indent(&shiftwidth) . '' .
  \ s:_set_indent(&shiftwidth) . 'forever begin' .
  \ s:_set_indent(&shiftwidth) .  'seq_item_port.get_next_item(req);' .
  \
  \ s:_set_indent(0) . 'void''(begin_tr(req, "DRV_ITEM"));' .
  \
  \ s:_set_indent(0) . '`uvm_info(get_full_name(), $psprintf("Driving packet", ),UVM_LOW)' .
  \ s:_set_indent(0) . 'req.print();' .
  \
  \ s:_set_indent(0) . '/////////////////////// DRIVING LOGIC //////////////////////////' .
  \ s:_set_indent(0) . '#10;' .
  \
  \ s:_set_indent(0) . 'end_tr(req);' .
  \
  \ s:_set_indent(0) . 'seq_item_port.item_done();' .
  \ s:_set_indent(0) . 'assert ($cast(rsp, req.clone()));' .
  \ s:_set_indent(0) . 'rsp.set_id_info(req);' .
  \ s:_set_indent(0) . 'seq_item_port.put_response(rsp);' .
  \ s:_set_indent(-&shiftwidth) . 'end' .
  \ s:_set_indent(-&shiftwidth) . 'endtask'

  let parent = sv#uvm#mapping#get_parent('uvm_driver')

  if (parent == 'uvm_driver')
    let parent = printf('uvm_driver #(%0s)', s:GetTemplete('a', 'REQ'))
  endif

  let str .= comments#block_comment#getComments("Component", "" . name )
  let str .= printf('class %s extends %0s;', name , parent ) .
    \ s:_set_indent(&shiftwidth) . 'maa' .
    \ s:_set_indent(&shiftwidth) . '`uvm_component_utils (' . name . ')' .
    \ s:_set_indent(0) . comments#block_comment#getComments("Function", "new") .
    \ 'function new(string name, uvm_component parent = null);' .
    \ s:_set_indent(&shiftwidth) . 'super.new(name,parent);' .
    \ s:_set_indent(-&shiftwidth) . 'endfunction' .
    \
    \ s:_set_indent(0) . comments#block_comment#getComments("Function", "build_phase") .
    \ 'virtual function void build_phase(uvm_phase phase);' .
    \ s:_set_indent(&shiftwidth) . 'super.build_phase(phase);' .
    \
    \ s:_set_indent(-&shiftwidth) . 'endfunction : build_phase' .
    \
    \ comments#block_comment#getComments("Task", "run_phase") .
    \ s:_set_indent(0) . run_phase .
    \ s:_set_indent(-&shiftwidth) . 'endclass : ' . name . '`aa'

  return str
endfunction

function! sv#uvm#mapping#default_sequence_set()
  let str = s:_set_indent(0) . printf('uvm_config_wrapper::set(this, "maa%s.run_phase", "default_sequence", %s::type_id::get());`aa', s:GetTemplete('a', 'seqr_path'), s:GetTemplete('a', 'seq'))
  return str
endfunction

"-------------------------------------------------------------------------------
" subscriber: Function
"-------------------------------------------------------------------------------
function! sv#uvm#mapping#subscriber()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  let str = s:ifndef()

  let parent = sv#uvm#mapping#get_parent('uvm_subscriber')

  if (parent == 'uvm_subscriber')
    let parent = printf('uvm_subscriber %0s', g:sv#glob_var#seq_item)
  endif

  if (parent =~ '^uvm_subscriber')
    let write_fun_decl = s:_set_indent(0) . printf('function void write( %s t );', s:GetTemplete('a', 'T')) .
          \ s:_set_indent(&shiftwidth) . '' .
          \ s:_set_indent(0) . 'endfunction: write'
  else
    let write_fun_decl = ''
  endif

  let str .= comments#block_comment#getComments("Class", "" . name )
  let str .= printf('class %s extends %0s;', name, parent) .
          \ s:_set_indent(&shiftwidth) . printf('`uvm_component_utils( %s )', name) .
          \ s:_set_indent(0) . 'maa' .
          \ s:_set_indent(0) . printf('function new( string name = "%s", uvm_component parent );', name) .
          \ s:_set_indent(&shiftwidth) . 'super.new( name, parent );' .
          \ s:_set_indent(-&shiftwidth) . 'endfunction: new' .
          \ write_fun_decl .
          \ s:_set_indent(-&shiftwidth) . printf('endclass: %s`aa', name)

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : s:uvm_test_base
"-------------------------------------------------------------------------------
function! s:uvm_test_base(name)
  let str = s:ifndef()

  let cb = g:callbacks#sv#uvm#test#cb.Get()

  let parent = sv#uvm#mapping#get_parent('uvm_test')

  let str .= comments#block_comment#getComments("Test", "" . a:name )
  let str .= printf('class ' . a:name . ' extends %0s;', parent) .
    \ s:_set_indent(&shiftwidth) . 'maa' .
    \ s:_set_indent(&shiftwidth) . '`uvm_component_utils (' . a:name . ')' .
    \ cb.declaration . 
    \ s:_set_indent(0) . comments#block_comment#getComments("Function", "new") .
    \ 'function new(string name = "' . a:name . '", uvm_component parent = null);' .
    \ s:_set_indent(&shiftwidth) . 'super.new(name,parent);' .
    \ s:_set_indent(-&shiftwidth) . 'endfunction : new' .
    \ 
    \ s:_set_indent(0) . comments#block_comment#getComments("Function", "build_phase") .
    \ 'virtual function void build_phase(uvm_phase phase);' .
    \ s:_set_indent(&shiftwidth) . 'super.build_phase(phase);' .
    \ cb.build_phase.body . 
    \ s:_set_indent(-&shiftwidth) . 'endfunction : build_phase' .
    \ 
    \ s:_set_indent(-&shiftwidth) . 'endclass : ' . a:name . '`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : s:uvm_test_child
"-------------------------------------------------------------------------------
function! s:uvm_test_child(name)
  let str = s:ifndef()

  " || TODO || let parent = sv#uvm#mapping#get_parent('uvm_test') 

  let files = split(glob(expand('%:p:h:r') . '/*.sv'), "\n")
  call filter(files, 'v:val =~ ''\v_(base_test|test_base)>''')
  let files = map(files, 'fnamemodify(v:val, ":t:r")')

  let base_test = tlib#input#List('s', 'Base Test', files)

  let cb = g:callbacks#sv#uvm#test#cb.Get()

  let build_phase = {'body': '', 'declaration': ''}
  if (cb.build_phase == build_phase)
    let build_phase.body = s:_set_indent(0) . printf('uvm_config_wrapper::set(this, "%s.run_phase", "default_sequence", %s::type_id::get());', s:GetTemplete('a', 'seqr_path'), s:GetTemplete('a', 'seq'))
  else
    let build_phase.body = cb.build_phase.body
  endif

  let str .= comments#block_comment#getComments("Test", "" . a:name )
  let str .= 'class ' . a:name . ' extends ' . base_test . ';' .
    \ s:_set_indent(&shiftwidth) . 'maa' .
    \ s:_set_indent(&shiftwidth) . '`uvm_component_utils (' . a:name . ')' .
    \
    \ s:_set_indent(0) . comments#block_comment#getComments("Function", "new") .
    \ 'function new(string name = "' . a:name . '", uvm_component parent = null);' .
    \ s:_set_indent(&shiftwidth) . 'super.new(name,parent);' .
    \ s:_set_indent(-&shiftwidth) . 'endfunction : new' .
    \ 
    \ s:_set_indent(0) . comments#block_comment#getComments("Function", "build_phase") .
    \ 'virtual function void build_phase(uvm_phase phase);' .
    \ s:_set_indent(&shiftwidth) . 'super.build_phase(phase);' .
    \ build_phase.body .
    \ s:_set_indent(-&shiftwidth) . 'endfunction : build_phase' .
    \ 
    \ s:_set_indent(-&shiftwidth) . 'endclass : ' . a:name . '`aa'

"    \ s:_set_indent(0) . comments#block_comment#getComments("Task", "run_phase") .
"    \ 'task run_phase(uvm_phase phase);' .
"    \ s:_set_indent(&shiftwidth) . 'phase.phase_done.set_drain_time(.obj(this), .drain(10us));' .
"    \ s:_set_indent(0) . 'phase.raise_objection(.obj(this));' . 
"    \ s:_set_indent(0) . 'phase.drop_objection(.obj(this));' .
"    \ s:_set_indent(-&shiftwidth) . 'endtask : run_phase' .

  return str
endfunction

"-------------------------------------------------------------------------------
" test: Function
"-------------------------------------------------------------------------------
function! sv#uvm#mapping#test()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  return s:uvm_test_base(name)

  " || if (name =~ '\v(_base_test|_test_base)')
  " ||   return s:uvm_test_base(name)
  " || else
  " ||   return s:uvm_test_child(name)
  " || endif

endfunction

"-------------------------------------------------------------------------------
" transaction: Function
"-------------------------------------------------------------------------------
function! sv#uvm#mapping#transaction()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  let parent = sv#uvm#mapping#get_parent('uvm_sequence_item')
  let str = s:ifndef()

  let str .= comments#block_comment#getComments("Sequence Item", "" . name )
  let str .= printf('class ' . name . ' extends %0s;', parent) .
    \ s:_set_indent(&shiftwidth) . 'maa' .
    \ s:_set_indent(&shiftwidth) . '`uvm_object_utils_begin (' . name . ')' .
    \ s:_set_indent(&shiftwidth) . '//`uvm_field_int (' . s:GetTemplete ("a", "var") . ', UVM_ALL_ON)' .
    \'`uvm_object_utils_end' .
    \
    \ s:_set_indent(0) . comments#block_comment#getComments("Function", "new") .
    \ 'function new(string name = "' . name. '");' .
    \ s:_set_indent(&shiftwidth) . 'super.new(name);' .
    \ s:_set_indent(-&shiftwidth) . 'endfunction' .
    \
    \ s:_set_indent(0) . 'function void do_record(uvm_recorder recorder);' .
    \ s:_set_indent(&shiftwidth) . 'super.do_record(recorder);' .
    \ s:_set_indent(0) . printf('`uvm_record_attribute(recorder.tr_handle, "%s", %s);', s:GetTemplete('a', 'var'), s:GetTemplete('a', 'var')) .
    \ s:_set_indent(-&shiftwidth) . 'endfunction : do_record' .
    \ 
    \ s:_set_indent(-&shiftwidth) . 'endclass : ' . name . '`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" sequence_library: Function
"-------------------------------------------------------------------------------
function! sv#uvm#mapping#sequence_library()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  let parent = sv#uvm#mapping#get_parent('uvm_sequence_library')
  let str = s:ifndef()

  let str .= comments#block_comment#getComments("Sequence Library", "" . name )
  let str .= printf('class %s extends %0s #(%s);', name, parent, g:sv#glob_var#seq_item) .
    \ s:_set_indent(&shiftwidth) . 'maa' .
    \ s:_set_indent(&shiftwidth) . '`uvm_object_utils (' . name . ')' .
    \ s:_set_indent(0) . '`uvm_sequence_library_utils (' . name . ')' .
    \
    \ s:_set_indent(0) . comments#block_comment#getComments("Function", "new") .
    \ s:_set_indent(0) . 'function new(string name = "' . name. '");' .
    \ s:_set_indent(&shiftwidth) . 'super.new(name);' .
    \ s:_set_indent(0) . 'init_sequence_library();' .
    \ s:_set_indent(-&shiftwidth) . 'endfunction' .
    \
    \ s:_set_indent(-&shiftwidth) . 'endclass : ' . name . '`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" parameterized_sequence: Function
"-------------------------------------------------------------------------------
function! sv#uvm#mapping#parameterized_sequence()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  " || TODO || let parent = sv#uvm#mapping#get_parent('uvm_sequence_library')

  let str = s:ifndef()

  let cb = g:callbacks#sv#uvm#sequence#cb

  if (name =~ '\v_(seq%[uence]_base|base_seq%[uence])')
    let fun_declaration = cb.fun_declaration
  else
    if (cb.fun_declaration == "")
      let fun_declaration = s:_set_indent(0) . comments#block_comment#getComments("Task", "body") .
      \ 'task body();' .
      \ s:_set_indent(0) . '`uvm_create(req)' .
      \ s:_set_indent(0) . 'wait_for_grant();' .
      \ s:_set_indent(0) . 'send_request(req);' .
      \ s:_set_indent(0) . 'assert (req.randomize())' .
      \ s:_set_indent(0) . 'else $fatal (0, $sformatf("[%%m]: Randomization failed!!!", req));' .
      \ s:_set_indent(0) . 'wait_for_item_done();' .
      \ s:_set_indent(0) . 'get_response(rsp);' .
      \ s:_set_indent(-&shiftwidth) . 'endtask : body'

    else
      let fun_declaration = cb.fun_declaration
    endif
  endif

  " let cb = g:callbacks#sv#uvm#sequence#cb.Get()

  let str .= comments#block_comment#getComments("Sequence", "" . name )

  " If default parameter
  if (cb.parameter == g:callbacks#sv#uvm#sequence#cb.parameter)
    let cb.parameter = printf("#(type REQ=%s, RSP=REQ)", g:sv#glob_var#seq_item)
  endif

  " uvm_sequence
  let str .= printf('class %s %s extends %s #(REQ, RSP);', name, cb.parameter, cb.base_seq, ) .
    \ s:_set_indent(&shiftwidth) . 'maa' .
    \ s:_set_indent(&shiftwidth) . printf('typedef %s #(REQ, RSP) this_type;', name) .
    \
    \ s:_set_indent(0) . '`uvm_object_param_utils (this_type)' .
    \ cb.declaration .
    \
    \ s:_set_indent(0) . comments#block_comment#getComments("Function", "new") .
    \ 'function new(string name = "' . name. '");' .
    \ s:_set_indent(&shiftwidth) . 'super.new(name);' .
    \ s:_set_indent(-&shiftwidth) . 'endfunction' .
    \
    \ fun_declaration .
    \
    \ s:_set_indent(-&shiftwidth) . 'endclass : ' . name . '`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" sequence: Function
"-------------------------------------------------------------------------------
function! sv#uvm#mapping#sequence()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  let str = s:ifndef()

  if (name !~ '\v_(seq%[uence]_base|base_seq%[uence])')
      let fun_declaration = s:_set_indent(0) . comments#block_comment#getComments("Task", "body") .
      \ 'task body();' .
      \ s:_set_indent(&shiftwidth) . '`uvm_create(req)' .
      \ s:_set_indent(0) . 'wait_for_grant();' .
      \ s:_set_indent(0) . 'send_request(req);' .
      \ s:_set_indent(0) . 'assert (req.randomize())' .
      \ s:_set_indent(0) . 'else $fatal (0, $sformatf("[%%m]: Randomization failed!!!", req));' .
      \ s:_set_indent(0) . 'wait_for_item_done();' .
      \ s:_set_indent(0) . 'get_response(rsp);' .
      \ s:_set_indent(-&shiftwidth) . 'endtask : body'

  else
    let fun_declaration = ''
  endif

  let parent = sv#uvm#mapping#get_parent('uvm_sequence')
  if (parent == 'uvm_sequence')
    let parent = printf('uvm_sequence #(%0s)',  g:sv#glob_var#seq_item)
  endif

  let str .= comments#block_comment#getComments("Sequence", "" . name )
  " uvm_sequence
  let str .= printf('class %s extends %s;', name, parent) .
    \ s:_set_indent(&shiftwidth) . 'maa' .
    \ s:_set_indent(&shiftwidth) . '`uvm_object_utils (' . name . ')' .
    \
    \ s:_set_indent(0) . comments#block_comment#getComments("Function", "new") .
    \ 'function new(string name = "' . name. '");' .
    \ s:_set_indent(&shiftwidth) . 'super.new(name);' .
    \ s:_set_indent(-&shiftwidth) . 'endfunction' .
    \
    \ fun_declaration .
    \
    \ s:_set_indent(-&shiftwidth) . 'endclass : ' . name . '`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" object: Function
"-------------------------------------------------------------------------------
function! sv#uvm#mapping#object()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  let cb = g:callbacks#sv#uvm#object#cb.Get()

  let str = s:ifndef()

  let get_config_comment1 = 'Convenience function that first gets the object out of the UVM database'
  let get_config_comment2 = 'and reports an error if the object is not present in the database'
  " \ s:_set_indent(0) . comments#block_comment#getComments("Function", "get_cfg", get_config_comment1, get_config_comment2) .

  let parent = sv#uvm#mapping#get_parent('uvm_object')

  if (parent == 'uvm_object')
    let get_cfg_fun_decl = s:_set_indent(0) . comments#block_comment#getComments("Function", "get_cfg") .
    \ s:_set_indent(0) . printf ('static function %s get_cfg(uvm_component component, string name = "%s");', name, name) . 
    \ s:_set_indent(&shiftwidth) . name . ' temp;' . 
    \ s:_set_indent(0) . 'if(!uvm_config_db#(' . name . ')::get(component,"", name, temp)) begin' .
    \ s:_set_indent(&shiftwidth) . 'component.uvm_report_error("no config error ",' .
    \ s:_set_indent(&shiftwidth) . '"this component has no config associated with id ' . name . '");' .
    \ s:_set_indent(-&shiftwidth) . 'return null;' .
    \ s:_set_indent(-&shiftwidth) . 'end' .
    \ s:_set_indent(0) . 'return temp;' . 
    \ s:_set_indent(-&shiftwidth) . 'endfunction : get_cfg'
  else
    let get_cfg_fun_decl = ''
  endif

  let str .= comments#block_comment#getComments("Object", "" . name )
  let str .= printf('class ' . name . ' extends %0s;', parent) .
    \ s:_set_indent(&shiftwidth) . 'maa' .
    \ s:_set_indent(&shiftwidth) . '`uvm_object_utils (' . name . ')' .
    \ cb.declaration .
    \
    \ s:_set_indent(0) . comments#block_comment#getComments("Function", "new") .
    \'function new(string name = "' . name. '");' .
    \ s:_set_indent(&shiftwidth) . 'super.new(name);' .
    \ s:_set_indent(-&shiftwidth) . 'endfunction' .
    \ get_cfg_fun_decl .
    \
    \ s:_set_indent(-&shiftwidth) . 'endclass : ' . name . '`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" singleton_object: Function
"-------------------------------------------------------------------------------
function! sv#uvm#mapping#singleton_object()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  let str = s:ifndef()

  let str .= comments#block_comment#getComments("Object", "" . name )
  let str .= 'class ' . name . ' extends uvm_object;' .
    \ s:_set_indent(&shiftwidth) . 'maa' .
    \ s:_set_indent(&shiftwidth) . '`uvm_object_utils (' . name . ')' .
    \ s:_set_indent(0) . 'static ' . name . ' m_' . name . ';' .
    \
    \ s:_set_indent(0) . comments#block_comment#getComments("Function", "new") .
    \'function new(string name = "' . name. '");' .
    \ s:_set_indent(&shiftwidth) . 'super.new(name);' .
    \ s:_set_indent(-&shiftwidth) . 'endfunction' .
    \
    \ s:_set_indent(0) . comments#block_comment#getComments("Function", "get_inst") .
    \'static function ' . name . ' get_inst();' . 
    \ s:_set_indent(&shiftwidth) . 'if (m_' . name . ' == null) begin' .
    \ s:_set_indent(&shiftwidth) . 'm_' . name . ' = new("m_' . name . '");' .
    \ s:_set_indent(-&shiftwidth) . 'end' . 
    \
    \ s:_set_indent(0) . 'return m_' . name . ';' .
    \ s:_set_indent(-&shiftwidth) . 'endfunction : get_inst' . 
    \ s:_set_indent(-&shiftwidth) . 'endclass : ' . name . '`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" sequencer: Function
"-------------------------------------------------------------------------------
function! sv#uvm#mapping#sequencer()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  let cb = g:callbacks#sv#uvm#sequencer#cb.Get()

  let parent = sv#uvm#mapping#get_parent('uvm_sequencer')
  let str = s:ifndef()

  let str .= comments#block_comment#getComments("Sequencer", "" . name )
  let str .= printf('class %s extends %0s %s;', name, parent, cb.parameter) .
    \ s:_set_indent(&shiftwidth) . 'maa' .
    \ s:_set_indent(&shiftwidth) . '`uvm_component_utils (' . name . ')' .
    \ cb.declaration .
    \ s:_set_indent(0) . comments#block_comment#getComments("Function", "new") .
    \'function new(string name, uvm_component parent = null);' .
    \ s:_set_indent(&shiftwidth) . 'super.new(name, parent);' .
    \ s:_set_indent(0) . cb.constructor.body .
    \ s:_set_indent(-&shiftwidth) . 'endfunction' .
    \ s:_set_indent(0) . cb.fun_declaration .
    \ s:_set_indent(-&shiftwidth) . 'endclass : ' . name . '`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" uvm_blocking_put_imp: Function
"-------------------------------------------------------------------------------
function! sv#uvm#mapping#uvm_blocking_put_imp()
  let ln = search('\v^\s*class\s+', 'bn')
  let name = matchstr(getline(ln), '\v^\s*class\s+\zs\w+\ze')
  return printf('uvm_blocking_put_imp#(maa%s, %s) %s;`aa', g:sv#glob_var#seq_item, name, s:GetTemplete('b', 'this'))
endfunction

"-------------------------------------------------------------------------------
" uvm_blocking_get_imp: Function
"-------------------------------------------------------------------------------
function! sv#uvm#mapping#uvm_blocking_get_imp()
  let ln = search('\v^\s*class\s+', 'bn')
  let name = matchstr(getline(ln), '\v^\s*class\s+\zs\w+\ze')
  return printf('uvm_blocking_get_imp#(maa%s, %s) %s;`aa', g:sv#glob_var#seq_item, name, s:GetTemplete('b', 'this'))
endfunction

"-------------------------------------------------------------------------------
" uvm_get_imp: Function
"-------------------------------------------------------------------------------
function! sv#uvm#mapping#uvm_get_imp()
  let ln = search('\v^\s*class\s+', 'bn')
  let name = matchstr(getline(ln), '\v^\s*class\s+\zs\w+\ze')
  return printf('uvm_get_imp#(maa%s, %s) %s;`aa', g:sv#glob_var#seq_item, name, s:GetTemplete('b', 'this'))
endfunction

"-------------------------------------------------------------------------------
" uvm_analysis_imp: Function
"-------------------------------------------------------------------------------
function! sv#uvm#mapping#uvm_analysis_imp()
  let ln = search('\v^\s*class\s+', 'bn')
  let name = matchstr(getline(ln), '\v^\s*class\s+\zs\w+\ze')
  return printf('uvm_analysis_imp#(maa%s, %s) %s;`aa', g:sv#glob_var#seq_item, name, s:GetTemplete('b', 'this'))
endfunction

"-------------------------------------------------------------------------------
" type_id_set_type_override: Function
"-------------------------------------------------------------------------------
function! sv#uvm#mapping#type_id_set_type_override()
  let str = printf('maa%s::type_id::set_type_override(.override_type(%s::get_type()), .replace(1));`aa', s:GetTemplete('a', 'ORIGINAL_TYPE'), s:GetTemplete('b', 'OVERRIDE_TYPE'))
  return str
endfunction

"-------------------------------------------------------------------------------
" type_id_set_type_override: Function
"-------------------------------------------------------------------------------
function! sv#uvm#mapping#type_id_set_inst_override()
  let str =printf( 'maa%s::type_id::set_inst_override(.override_type(%s::get_type()), .inst_path(""), .parent(null));`aa', s:GetTemplete('a', 'ORIGINAL_TYPE'), s:GetTemplete('b', 'OVERRIDE_TYPE'))
  return str
endfunction

"-------------------------------------------------------------------------------
" type_id::create
"-------------------------------------------------------------------------------
function! sv#uvm#mapping#type_id_create()
  " find search start & end
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  let l:s_start =  search('^\s*\%(rand\s+\)\?\w\+\%(\s*#(\_[^)]\+)\)\?\_[^)]\+\<' .
                   \         name .
                   \         '\>\_[^)]*;$', 'bn')

  let l:s_end   =  search('^\s*\%(rand\s+\)\?\w\+\%(\s*#(\_[^)]\+)\)\?\_[^)]\+\<' .
                   \         name .
                   \         '\>\_[^)]*;$', 'ben')

  let l:curr_pos = col('.') - indent(l:s_start) + indent(l:s_end) - 1

  " get the class type name
  let l:type_name = matchstr(
                   \ join (
                   \ map(
                   \ getline(
                   \  l:s_start,
                   \  l:s_end
                   \ ), 'substitute(v:val, "^\\s\\+", "", "")'
                   \ ), "\n" . repeat(' ', l:curr_pos)),
                   \ '^\s*\%(rand\s\+\)\?\zs\w\+\%(\s*#(\_[^)]\+)\)\?'
                   \)
  let l:type_name = substitute(l:type_name, "\n", "\na", "g")
  " let l:str = l:type_name . '::type_id::create("' . matchstr(l:type_name, '\w\+') . '", this);'
  let l:str = l:type_name . '::type_id::create("' . name . '", this);'
  if (getline('.') =~ '\s*=\s*')
    return l:str
  else
    return "= " . l:str
  endif
endfunction

"-------------------------------------------------------------------------------
" uvm_config_db#(Singleton)::set(this,"*","name", value);
"-------------------------------------------------------------------------------
function! sv#uvm#mapping#uvm_config_db_set()
  let [line,name_start_pos] = searchpos('\v<\w+\ze\s*%#', 'n')

  let name_start_pos = name_start_pos - 1
  let col_pos = col('.')
  let col_end = col('$')
  let len = col_pos - name_start_pos - 2
  let line_before = strpart(getline("."), 0, name_start_pos)
  let line_before = substitute(line_before, '^\s*', '', '')
  let line_after = strpart(getline("."), col_pos - 1)
  let name = strpart(getline("."), name_start_pos, len)
  let db_name = name

  if (name =~ '\v^\s*$')
    let found = 0
    let name = s:GetTemplete('c', 'INSTANCE_VALUE')
    let db_name = s:GetTemplete('b', 'FIELD_NAME')
    let l:type_name = s:GetTemplete('a', 'TYPE')

    let l:str = 'uvm_config_db#(maa' . l:type_name . ')::set(this,"*","' . db_name . '", ' . name . ')'
  else
    let found = 1
    " find search start & end
    let l:s_start =  search('\v^\s*%(%(virtual|rand)\s+)?%(%(<end>)@!<\w+)%(\s*#\(\_[^)]+\))?%(\s*\[\_.+\])?\_s*<' .
                     \         name .
                     \         '>', 'bn')

    let l:s_end   =  search('\v^\s*%(%(virtual|rand)\s+)?%(%(<end>)@!<\w+)%(\s*#\(\_[^)]+\))?%(\s*\[\_.+\])?\_s*<' .
                     \         name .
                     \         '>', 'ben')

    " BACKUP|| let l:s_start =  search('\v^\s*%(%(virtual|rand)\s+)?\w+%(\s*#\(\_[^)]+\))?\_[^)]+<' .
    " BACKUP||                  \         name .
    " BACKUP||                  \         '>\_[^)]*;', 'bn')

    " BACKUP|| let l:s_end   =  search('\v^\s*%(%(virtual|rand)\s+)?\w+%(\s*#\(\_[^)]+\))?\_[^)]+<' .
    " BACKUP||                  \         name .
    " BACKUP||                  \         '>\_[^)]*;', 'ben')

    let l:curr_pos = col('.') - indent(l:s_start) + indent(l:s_end) - 1

    " get the class type name
    let l:type_name = matchstr(
                     \ join (
                     \ map(
                     \ getline(
                     \  l:s_start,
                     \  l:s_end
                     \ ), 'substitute(v:val, "\\v^\\s+", "", "")'
                     \ ), "\n" . repeat(' ', l:curr_pos)),
                     \ '\v^\s*%(rand\s+)?\zs%(virtual\s+)?\w+%(\s*#\(\_[^)]+\))?%(\s*\[\_.+\])?'
                     \)

    let l:type_name = substitute(l:type_name, "\n", "\na", "g")

    let db_name = substitute(l:type_name, '\v^virtual>\s*', '', 'g')
    let db_name = matchstr(db_name, '^\w\+')

    let l:str = 'uvm_config_db#(' . l:type_name . ')::set(.cntxt(maa' . s:GetTemplete('a', 'component/this') . '), .inst_name("*"), .field_name("' . s:GetTemplete('b', 'Component/' . db_name ) . '"), .value(' . name . '))'
  endif


  call setline(".", repeat(' ', indent(".")))
  let out_line = line_before . l:str . line_after

  if (line_before =~ '^\s*$' && line_after =~ '^\s*$')
    let out_line .= ';'
    " if (found == 0)
      let out_line .= '`aa'
    " endif
  endif

  return out_line
endfunction

function! sv#uvm#mapping#uvm_config_db_get()
  let [line,name_start_pos] = searchpos('\v<\w+\ze\s*%#', 'n')

  let name_start_pos = name_start_pos - 1
  let col_pos = col('.')
  let col_end = col('$')
  let len = col_pos - name_start_pos - 2
  let line_before = strpart(getline("."), 0, name_start_pos)
  let line_before = substitute(line_before, '^\s*', '', '')
  let line_after = strpart(getline("."), col_pos - 1)
  let name = strpart(getline("."), name_start_pos, len)
  let db_name = name

  if (name =~ '\v^\s*$')
    let found = 0

    let name = s:GetTemplete('d', 'INSTANCE_VALUE')
    let db_name = s:GetTemplete('c', 'CONFIG_DB ELEMENT NAME')
    let l:type_name = s:GetTemplete('a', 'TYPE')

    let l:str = printf('uvm_config_db#(maa%s)::get(%s,"*","%s", %s)', l:type_name , s:GetTemplete('b', 'Component/this'), db_name , name )
  else
    " find search start & end
    let l:s_start =  search('\v^\s*%(%(virtual|rand)\s+)?%(%(<end>)@!<\w+)%(\s*#\(\_[^)]+\))?%(\s*\[\_.+\])?\_s*<' .
                     \         name .
                     \         '>', 'bn')

    let l:s_end   =  search('\v^\s*%(%(virtual|rand)\s+)?%(%(<end>)@!<\w+)%(\s*#\(\_[^)]+\))?%(\s*\[\_.+\])?\_s*<' .
                     \         name .
                     \         '>', 'ben')

    " BACKUP || let l:s_start =  search('\v^\s*%(%(rand|virtual)\s+)?\w+%(\s*#\(\_[^)]+\))?\_[^)]+<' .
    " BACKUP ||                  \         name .
    " BACKUP ||                  \         '>\_[^)]*;', 'bn')

    " BACKUP || let l:s_end   =  search('\v^\s*%(%(rand|virtual)\s+)?\w+%(\s*#\(\_[^)]+\))?\_[^)]+<' .
    " BACKUP ||                  \         name .
    " BACKUP ||                  \         '>\_[^)]*;', 'ben')

    let l:curr_pos = col('.') - indent(l:s_start) + indent(l:s_end) - 1

    " get the class type name
    let l:type_name = matchstr(
                     \ join (
                     \ map(
                     \ getline(
                     \  l:s_start,
                     \  l:s_end
                     \ ), 'substitute(v:val, "\\v^\\s+", "", "")'
                     \ ), "\n" . repeat(' ', l:curr_pos)),
                     \ '\v^\s*%(rand\s+)?\zs%(virtual\s+)?\w+%(\s*#\(\_[^)]+\))?%(\s*\[\_.+\])?'
                     \)

    let l:type_name = substitute(l:type_name, "\n", "\na", "g")
    let db_name = substitute(l:type_name, '\v^virtual>\s*', '', 'g')
    let db_name = matchstr(db_name, '^\w\+')

    " let l:str = l:type_name . '::type_id::create("' . matchstr(l:type_name, '\w\+') . '", this);'
    let l:str = printf('uvm_config_db#(%s)::get(.cntxt(maa%s), .inst_name(""), .field_name("%s"), .value(%s))', l:type_name , s:GetTemplete('b', 'Component/this'), s:GetTemplete('b', 'Component/' . db_name ), name)
  endif


  call setline(".", repeat(' ', indent(".")))
  let out_line = line_before . l:str . line_after

  if (line_before =~ '^\s*$' && line_after =~ '^\s*$')
    let out_line = 'if (!' . out_line . ') begin'
    let out_line .= '  `uvm_fatal(get_full_name(), "uvm_config_db #( ' . l:type_name . ' )::get cannot find resource ' . db_name . '!!!")'
    let out_line .= 'end'
  endif
  let out_line .= '`aa'

  return out_line
endfunction







