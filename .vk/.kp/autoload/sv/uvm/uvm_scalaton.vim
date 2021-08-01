"-------------------------------------------------------------------------------
" TODO LIST
" bypass sequencer logic in driver (done for agent and config. search for bypass_sequencer)
" 
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" _set_indent: Function
"-------------------------------------------------------------------------------
function! s:_set_indent(offset)

  return '=common#indent#imode_set_indent(' . a:offset . ')'
endfunction

"-------------------------------------------------------------------------------
" Function : ifndef
"-------------------------------------------------------------------------------
function! s:ifndef()
  call debug#debug#log('function! s:ifndef()')

  if (line('.') == 1)
    let name = expand('%:t')
    let name = substitute(name, '\.', '_', 'g')
    return sv#sv#sv#ifndef(name)
  endif
  return ""
endfunction

"-------------------------------------------------------------------------------
" Function : map_str
" v:idx -> replace with index
" v:len -> replace with len of array
" v:key:v:idx -> replace with '' if used with loop else '_' . l:idx
" v:val:v:idx -> replace with 'i' if used with loop else ''
"-------------------------------------------------------------------------------
function! s:map_str(str, ...)
  call debug#debug#log('function! s:map_str(str, ...)')

  let str = a:str
  TVarArg ['array']

  if (exists('array["instances"]'))
    if (array['instances'] == 1)
      let str = substitute(str, '\V[v:idx]', '', 'g')
      let str = substitute(str, '\V[v:len]', '', 'g')
      let str = substitute(str, '\V[v:key:v:idx\.\{-\}]', '', 'g')
      let str = substitute(str, '\Vv:val:v:idx', '', 'g')

      return str
    elseif (array['instances'] > 1)

      if (!exists('array["indexes"]'))
        if (matchstr(str, '\V\w\+\s\*[v:len]') != '')
          let str = substitute(str, '\V[v:len]', printf('[%0d]', array['instances']), 'g')

          return str
        else
          let array_var = matchstr(str, '\V\w\+\ze\s\*[v:key:v:idx\.\{-\}]')
          if (array_var =~ '^\s*$')
            let array_var = matchstr(str, '\V\[0-9a-zA-Z_.]\+\ze\s\*[v:idx]')
          endif

          let array_var = substitute(array_var, '\V[v:idx]', '[i]', 'g')
          let temp_str = substitute(str, '\V[v:idx]', '[i]', 'g')
          let temp_str = substitute(temp_str , '\Vv:key:v:idx', '', 'g')
          let temp_str = substitute(temp_str , '\Vv:val:v:idx', 'i', 'g')

          if (exists('array["parallel_loop"]') && array["parallel_loop"] == 1)
            let str = 'begin' .
              \ s:_set_indent(&shiftwidth) . printf('for (int idx = 0; idx < $size(%s); idx++) begin', array_var) .
              \ s:_set_indent(&shiftwidth) . 'automatic int i = idx;' .
              \ s:_set_indent(0) . 'fork' .
              \ s:_set_indent(0) . temp_str . '' .
              \ s:_set_indent(0) . 'join_none' .
              \ s:_set_indent(-&shiftwidth) . 'end' .
              \ s:_set_indent(0) . 'wait fork;' .
              \ s:_set_indent(-&shiftwidth) . 'end'
          else
            let str = printf('foreach (%s[i]) begin', array_var ) .
              \ s:_set_indent(&shiftwidth) . temp_str . '' .
              \ s:_set_indent(-&shiftwidth) . 'end'
          endif

            return str
        endif

      elseif (matchstr(str, '\V\w\+\s\*[v:len]') != '')
        if (range(0, array['instances'] - 1) == array["indexes"])
          let temp_str = ''
          for l:idx in array["indexes"]
            let temp_str .= substitute(str, '\V[v:idx]', '_' . l:idx, 'g') . ''
          endfor
          let str = temp_str
        else
          let str = substitute(str, '\V[v:len]', printf('[%0d]', array['instances']), 'g')
        endif

        return str
      else
        if (range(0, array['instances'] - 1) == array["indexes"])
          let array_var = matchstr(str, '\V\w\+\s\*[v:idx]')
          let array_var = substitute(array_var, '\V[v:idx]', '[i]', 'g')
          let temp_str = substitute(str, '\V[v:idx]', '[i]', 'g')
          let temp_str = substitute(temp_str , '\Vv:key:v:idx', '', 'g')
          let temp_str = substitute(temp_str , '\Vv:val:v:idx', 'i', 'g')

          let str = printf('foreach (%s) begin', array_var ) .
            \ s:_set_indent(&shiftwidth) . temp_str . '' .
            \ s:_set_indent(-&shiftwidth) . 'end'
        else
          let temp_str = ''
          let temp1_str = substitute(str, '\V[v:idx]', '_' . l:idx, 'g')
          let temp1_str = substitute(temp_str , '\V[v:key:v:idx\.\{-\}]', '_' . l:idx, 'g')
          let temp1_str = substitute(temp_str , '\Vv:val:v:idx', 'i', 'g')

          for l:idx in array["indexes"]
            let temp_str .= temp1_str  . ''
          endfor
          let str = temp_str
        endif

        return str
      endif
    else
      let str = '';
    endif
  endif

  return str
endfunction

"-------------------------------------------------------------------------------
" s:GetTemplete: Function
"-------------------------------------------------------------------------------
function! s:GetTemplete(char, ...)
  call debug#debug#log('function! s:GetTemplete(char, ...)')

  return common#mov_thru_user_mark#get_template(a:char, a:000)
endfunction

"-------------------------------------------------------------------------------
" Function : show_err
"-------------------------------------------------------------------------------
function! s:show_err(msg)
  call debug#debug#log('function! s:show_err(msg)')

  echohl Error
  echoerr a:msg
  echohl None
endfunction

"############################################################
" direction : 1 - uni, 2 - bidirectional
let s:TLM_Port = {'direction': 1, 'this': '', 'm_this': '', 'req': '', 'rsp': ''}

"-------------------------------------------------------------------------------
" Function : new
" a:1 - dictionary
"-------------------------------------------------------------------------------
function! s:TLM_Port.new(...) dict
  call debug#debug#log('function! s:TLM_Port.new(...) dict')

  TVarArg ['Dict', {}]

  let tlm = deepcopy(self)

  if (type(Dict) != type({}))
    echoerr "Not a dictionary"
    finish
  endif

  if (!(has_key(Dict, 'this')))
    echoerr 'key this must be provided'
    finish
  endif

  if (!(has_key(Dict, 'm_this')))
    echoerr 'key m_this must be provided'
    finish
  endif

  for l:key in keys(Dict)
    let tlm[l:key] = Dict[l:key]
  endfor

  return tlm
endfunction

"-------------------------------------------------------------------------------
" Function : declaration
"-------------------------------------------------------------------------------
function! s:TLM_Port.declaration() dict
  call debug#debug#log('function! s:TLM_Imp.declaration(...) dict')
  if (self.direction == 1)
    let str = printf('%s #(%s) %s;', self.this, self.req, self.m_this)
  else
    let str = printf('%s #(%s, %s) %s;', self.this, self.req, self.rsp, self.m_this)
  endif
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : instantiation
"-------------------------------------------------------------------------------
function! s:TLM_Port.instantiation() dict
  call debug#debug#log('function! s:TLM_Imp.instantiation(...) dict')
  let str = printf('%s = new("%s", this);', self.m_this, self.m_this)
  return str
endfunction

"############################################################
" direction : 1 - uni, 2 - bidirectional
let s:TLM_Imp = {'direction': 1, 'this': '', 'm_this': '', 'req': '', 'rsp': '', 'imp': ''}

"-------------------------------------------------------------------------------
" Function : new
" a:1 - dictionary
"-------------------------------------------------------------------------------
function! s:TLM_Imp.new(...) dict
  call debug#debug#log('function! s:TLM_Imp.new(...) dict')

  TVarArg [Dict, {}]

  let tlm = deepcopy(self)

  if (type(Dict) != type({}))
    echoerr "Not a dictionary"
    finish
  endif

  if (!(has_key(Dict, 'this')))
    echoerr 'key this must be provided'
    finish
  endif

  if (!(has_key(Dict, 'm_this')))
    echoerr 'key m_this must be provided'
    finish
  endif

  for l:key in keys(Dict)
    let tlm[l:key] = Dict[l:key]
  endfor

  return tlm
endfunction

"-------------------------------------------------------------------------------
" Function : put
"-------------------------------------------------------------------------------
function! s:TLM_Imp.put() dict
  let str = printf('virtual task put (%s m_trans);', self.req)
  \ s:_set_indent(&shiftwidth) . '' .
  \ s:_set_indent(0) . 'endtask'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : declaration
"-------------------------------------------------------------------------------
function! s:TLM_Imp.declaration() dict
  if (self.direction == 1)
    let str = printf('%s #(%s, %s) %s;', self.this, self.req, self.imp, self.m_this)
  else
    let str = printf('%s #(%s, %s, %s) %s;', self.this, self.req, self.rsp, self.imp, self.m_this)
  endif
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : get
"-------------------------------------------------------------------------------
function! s:TLM_Imp.get() dict
  let str = printf('virtual task get (%s m_trans);', self.req)
  \ s:_set_indent(&shiftwidth) . '' .
  \ s:_set_indent(0) . 'endtask'

  return str
endfunction


"############################################################
let s:SequenceDatabase = {'prefix': '', 'file': '', 'this': '', 'path': '', 'sub_sequences': [], 'req_seq_item': '', 'rsp_seq_item': '', 'base_seq': '', 'parameters': {'req_seq_item': '', 'rsp_seq_item': ''}}

"-------------------------------------------------------------------------------
" Function : new
" a:1 - dictionary
"       either file or path key must be provided. If path key provided then it will search for seqr in path
"-------------------------------------------------------------------------------
function! s:SequenceDatabase.new(...) dict
  call debug#debug#log('function! s:SequenceDatabase.new(...) dict')

  let seq = deepcopy(self)
  if (a:0 == 0)
    echoerr "Argument required"
    finish
  endif

  if (type(a:1) != type({}))
    echoerr "Not a dictionary"
    finish
  endif

  if (!(has_key(a:1, 'file')))
    echoerr 'key file must be provided'
    finish
  endif

  if (!(has_key(a:1, 'prefix')))
    echoerr 'key prefix must be provided'
    finish
  endif

  for l:key in keys(a:1)
    let seq[l:key] = a:1[l:key]
  endfor

  call seq.parse()

  return seq
endfunction

"-------------------------------------------------------------------------------
" Function : s:SequenceDatabase.parse
"-------------------------------------------------------------------------------
function! s:SequenceDatabase.parse() dict
  call debug#debug#log('function! s:SequenceDatabase.parse() dict')


  let self.path = fnamemodify(self.file, ':p:h')
  let self.this = fnamemodify(self.file, ':p:t:r')
  let self.m_this = printf('m_%s', self.this)

  let self.m_this = substitute(self.m_this, '\vseq%[uence]', 'seq', 'g')
  let self.m_this = substitute(self.m_this, '\vvir%[tual]', 'virt', 'g')

  if (!(isdirectory(self.path)))
    call mkdir(self.path, 'p', 0700)
  endif

endfunction

"-------------------------------------------------------------------------------
function! s:SequenceDatabase.skalaton() dict
  call debug#debug#log('function! s:SequenceDatabase.skalaton() dict')

  " If file is not empty
  if (getfsize(self.file) > 1)
    return
  endif

  exe 'e ' . self.file

  let cb = g:callbacks#sv#uvm#sequence#cb

  " Not base sequence
  if (self.this !~ '\v_(seq%[uence]_base|base_seq%[uence])')

    if (type(self.base_seq) != type(""))
      let cb.parameter = ""
      let cb.base_seq = self.base_seq.this
    endif

    " Not a virtual sequence
    if (len(self.sub_sequences) == 0)
      let cb.fun_declaration = s:_set_indent(0) . comments#block_comment#getComments("Task", "body") .
      \ 'task body();' .
      \ s:_set_indent(&shiftwidth) . printf('%s %s;' , self.req_seq_item.this, self.req_seq_item.m_this).
      \ s:_set_indent(0) . printf('`uvm_create(%s)' , self.req_seq_item.m_this).
      \ s:_set_indent(0) . ('wait_for_grant();') .
      \ s:_set_indent(0) . printf('send_request(%s);', self.req_seq_item.m_this) .
      \ s:_set_indent(0) . printf('assert (%s.randomize())', self.req_seq_item.m_this) .
      \ s:_set_indent(0) . printf('else $fatal (0, $sformatf("[%%m]: Randomization failed!!!", %s));', self.req_seq_item.m_this) .
      \ s:_set_indent(0) . ('wait_for_item_done();') .
      \ s:_set_indent(0) . ('get_response(rsp);') .
      \ s:_set_indent(-&shiftwidth) . 'endtask : body'

    " Virtual sequence
    else

      let cb.declaration = ''

      let idx = 0
      let start_seq = ''
      for l:seq in self.sub_sequences
        if (idx == 0)
          let indent = ''
        else
          let indent = s:_set_indent(0) 
        endif

        let cb.declaration .= s:_set_indent(0) . s:map_str(printf('%s %s[v:len];', l:seq.sequence.this, l:seq.sequence.m_this), l:seq)

        let start_seq .= indent . s:map_str(printf('`uvm_do_on(%s[v:idx], p_sequencer.%s[v:idx]);', l:seq.sequence.m_this , l:seq.sequence.sequencer.m_this), extend(l:seq, {"parallel_loop": 1}))
        "let start_seq .= indent . printf('%s[v:idx].start(p_sequencer.%s[v:idx]);', l:seq.sequence.m_this , l:seq.sequence.sequencer.m_this)
      endfor
      let cb.declaration .= ""

      let cb.declaration .= printf('`uvm_declare_p_sequencer (%s)', self.sequencer.this)

      let cb.parameter = "#(uvm_sequence_item)"

      if (type(self.base_seq) != type(""))
        let cb.base_seq = self.base_seq.this
      endif

      let cb.fun_declaration = s:_set_indent(0) . comments#block_comment#getComments("Task", "body") .
      \ s:_set_indent(0) .  'task body();' .
      \ s:_set_indent(&shiftwidth) . 'fork' .
      \ s:_set_indent(&shiftwidth) . start_seq . '' .
      \ s:_set_indent(-&shiftwidth) .'join' .
      \ s:_set_indent(-&shiftwidth) . 'endtask : body'
    endif

    let str = sv#uvm#mapping#sequence()

  " base sequence
  else
    
    " not a top base sequence
    if (type(self.base_seq) != type(""))
      let cb.fun_declaration = ""

      let cb.base_seq = self.base_seq.this

      " Parameterized sequence
      if (type(self.parameters.req_seq_item) != type("") && type(self.parameters.rsp_seq_item) != type(""))
        if (self.parameters.req_seq_item == self.parameters.rsp_seq_item)
          let cb.parameter = printf('#(type REQ=%s, RSP=REQ)', self.parameters.req_seq_item.this)
        else
          let cb.parameter = printf('#(type REQ=%s, RSP=%s)', self.parameters.req_seq_item.this, self.parameters.rsp_seq_item.this)
        endif

        let str = sv#uvm#mapping#parameterized_sequence()
      else
        if (self.parameters.req_seq_item != "")
          if (self.parameters.req_seq_item == self.parameters.rsp_seq_item)
            let cb.parameter = printf('#(type REQ=%s, RSP=REQ)', self.parameters.req_seq_item)
          else
            let cb.parameter = printf('#(type REQ=%s, RSP=%s)', self.parameters.req_seq_item, self.parameters.rsp_seq_item)
          endif

          let str = sv#uvm#mapping#parameterized_sequence()
        else
          if (type(self.req_seq_item) == type("") && type(self.rsp_seq_item) == type(""))
            let cb.parameter = ""
          elseif (self.req_seq_item.this == self.rsp_seq_item.this)
            let cb.parameter = printf("#(%s)", self.req_seq_item.this)
          else
            let cb.parameter = printf("#(%s, %s)", self.req_seq_item.this, self.rsp_seq_item.this)
          endif

          let str = sv#uvm#mapping#sequence()
        endif
      endif

    " If root base
    else

      " Parameterized sequence
      if (type(self.parameters.req_seq_item) != type("") && type(self.parameters.rsp_seq_item) != type(""))
        if (self.parameters.req_seq_item == self.parameters.rsp_seq_item)
          let cb.parameter = printf('#(type REQ=%s, RSP=REQ)', self.parameters.req_seq_item.this)
        else
          let cb.parameter = printf('#(type REQ=%s, RSP=%s)', self.parameters.req_seq_item.this, self.parameters.rsp_seq_item.this)
        endif

        let str = sv#uvm#mapping#parameterized_sequence()
      else
        if (self.parameters.req_seq_item != "")
          if (self.parameters.req_seq_item == self.parameters.rsp_seq_item)
            let cb.parameter = printf('#(type REQ=%s, RSP=REQ)', self.parameters.req_seq_item)
          else
            let cb.parameter = printf('#(type REQ=%s, RSP=%s)', self.parameters.req_seq_item, self.parameters.rsp_seq_item)
          endif

          let str = sv#uvm#mapping#parameterized_sequence()
        else
          if (type(self.req_seq_item) == type("") && type(self.rsp_seq_item) == type(""))
            let cb.parameter = ""
          elseif (self.req_seq_item.this == self.rsp_seq_item.this)
            let cb.parameter = printf("#(%s)", self.req_seq_item.this)
          else
            let cb.parameter = printf("#(%s, %s)", self.req_seq_item.this, self.rsp_seq_item.this)
          endif

          let str = sv#uvm#mapping#sequence()
        endif
      endif
    endif

  endif

  exe 'normal ggi' . str
  w
endfunction


"############################################################
let s:TestDatabase = {'prefix': '', 'file': '', 'this': '', 'path': '', 'env': '', 'sanity_seq': ''}

"-------------------------------------------------------------------------------
" Function : new
" a:1 - dictionary
"       either file or path key must be provided. If path key provided then it will search for seqr in path
"-------------------------------------------------------------------------------
function! s:TestDatabase.new(...) dict
  call debug#debug#log('function! s:TestDatabase.new(...) dict')

  let test = deepcopy(self)
  if (a:0 == 0)
    echoerr "Argument required"
    finish
  endif

  if (type(a:1) != type({}))
    echoerr "Not a dictionary"
    finish
  endif

  if (!(has_key(a:1, 'file')))
    echoerr 'key file must be provided'
    finish
  endif

  for l:key in keys(a:1)
    let test[l:key] = a:1[l:key]
  endfor

  call test.parse()

  return test
endfunction

"-------------------------------------------------------------------------------
" Function : s:TestDatabase.set_prefix
" ?a:1 : Prefix
"-------------------------------------------------------------------------------
function! s:TestDatabase.set_prefix(...)
  call debug#debug#log('function! s:TestDatabase.set_prefix(...)')

  if (a:0 == 0)
    let self.prefix = matchstr(self.this, '\v\w+\ze_t%[est]')
    if (self.prefix == '')
      let self.prefix = self.this
    endif
    return
  endif

  let self.prefix = a:1
endfunction

"-------------------------------------------------------------------------------
" Function : s:TestDatabase.parse
"-------------------------------------------------------------------------------
function! s:TestDatabase.parse() dict
  call debug#debug#log('function! s:TestDatabase.parse() dict')


  let self.path = fnamemodify(self.file, ':p:h')
  let self.this = fnamemodify(self.file, ':p:t:r')

  if (!(isdirectory(self.path)))
    call mkdir(self.path, 'p', 0700)
  endif

  call self.set_prefix()

endfunction

"-------------------------------------------------------------------------------
" Function : skalaton
"-------------------------------------------------------------------------------
function! s:TestDatabase.skalaton() dict
  call debug#debug#log('function! s:TestDatabase.skalaton() dict')

  " If file is not empty
  if (getfsize(self.file) > 1)
    return
  endif

  exe 'e ' . self.file

  let cb = g:callbacks#sv#uvm#test#cb

  if (self.this =~ '\v_(base_test|test_base)>')

    let cb.declaration = s:_set_indent(0) . printf('%s %s;', self.env.this, self.env.m_this)

    let cb.declaration .= s:_set_indent(0) . printf('%s %s;', self.env.config.this, self.env.config.m_this)
    let cb.declaration .= ''

    let cb.build_phase.body = self.env.get_create(0) . ''
    let cb.build_phase.body .= self.env.config.get_create(0)

    for l:agent in self.env.agents
      if (type(l:agent.agent) == type(s:AgentDatabase) && type(l:agent.agent.config) == type(s:ConfigDatabase))
        let cb.declaration .= s:_set_indent(0) . s:map_str(printf('%s %s[v:len];', agent.agent.config.this, agent.agent.config.m_this), l:agent)

        let cb.build_phase.body .= l:agent.agent.config.get_create(0, l:agent)
      endif
    endfor
    let cb.declaration .= ''
    let cb.build_phase.body .= ''

    " Get interface
    for l:agent in map(deepcopy(self.env.agents), 'v:val["agent"]')

      if (type(l:agent) == type(s:AgentDatabase) && type(l:agent.config) == type(s:ConfigDatabase))

        let cb.build_phase.body .= agent.interface.config_db_get('this', '', self.env.config.m_this)
      endif

    endfor

    " assign agent interface
    for l:agent in self.env.agents
      let cb.build_phase.body .= s:_set_indent(0) . s:map_str(printf('%s[v:idx].%s = %s.%s;', agent.agent.config.m_this, agent.agent.interface.m_this, self.env.config.m_this, agent.agent.interface.m_this), l:agent)
    endfor
    let cb.build_phase.body .= ''

    " assign agent config
    for l:agent in self.env.agents
      let cb.build_phase.body .= s:map_str(printf('%s.%s[v:idx] = %s[v:idx];', self.env.config.m_this, agent.agent.config.m_this, agent.agent.config.m_this), agent)
    endfor
    let cb.build_phase.body .= ''

    " set config
    let cb.build_phase.body .= self.env.config.config_db_set('this', self.env.m_this)

  else
    let cb.build_phase.body = printf('uvm_config_wrapper::set(this, "%s.%s.run_phase", "default_sequence", %s::type_id::get());', self.env.m_this, self.env.virtual_sequencer.m_this, self.sanity_seq.this)
    let cb.build_phase.body .= printf('// uvm_config_db#(uvm_object_wrapper)::set(this,"%s.%s.run_phase","default_sequence", %s::type_id::get());', self.env.m_this, self.env.virtual_sequencer.m_this, self.sanity_seq.this)
  endif

  let cb.build_phase.body .= ''

  let str = sv#uvm#mapping#test()

  exe 'normal ggi' . str
  w
endfunction



"############################################################
let s:ConfigDatabase = {'options': {'bypass_sequencer': {'enable': 0, 'bypass_port': ''}, 'reactive_slave': 0}, 'prefix': '', 'file': '', 'this': '', 'm_this': '', 'path': '', 'interfaces': [], 'sub_configs': []}
"-------------------------------------------------------------------------------
" Function : new
" a:1 - dictionary
"       either file or path key must be provided. If path key provided then it will search for seqr in path
"-------------------------------------------------------------------------------
function! s:ConfigDatabase.new(...) dict
  call debug#debug#log('function! s:ConfigDatabase.new(...) dict')

  let config = deepcopy(self)
  if (a:0 == 0)
    echoerr "Argument required"
    finish
  endif

  if (type(a:1) != type({}))
    echoerr "Not a dictionary"
    finish
  endif

  if (!(has_key(a:1, 'file') || has_key(a:1, 'path')))
    echoerr 'key file or path must be provided'
    finish
  endif

  for l:key in keys(a:1)
    let config[l:key] = a:1[l:key]
  endfor

  if (has_key(a:1, 'path'))
    call config.find()
  endif

  call config.parse()

  return config
endfunction

"-------------------------------------------------------------------------------
" Function : s:ConfigDatabase.get_create
"-------------------------------------------------------------------------------
function! s:ConfigDatabase.get_create(indent_offset, ...) dict
  call debug#debug#log('function! s:ConfigDatabase.get_create(indent_offset, ...) dict')

  TVarArg ['array']
  if (exists('array["instances"]') && array["instances"] > 1 )
    let str = s:_set_indent(a:indent_offset) . s:map_str(printf('%s[v:idx] = %s :: type_id :: create($psprintf("%s[v:key:v:idx%%0d]", v:val:v:idx));', self.m_this, self.this, self.m_this), array)
  else
    let str = s:_set_indent(a:indent_offset) . printf('%s = %s :: type_id :: create("%s");', self.m_this, self.this, self.m_this)
  endif
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : find
"-------------------------------------------------------------------------------
function! s:ConfigDatabase.find() dict
  call debug#debug#log('function! s:ConfigDatabase.find() dict')

  "let files = split(glob('`find ' . self.path . ' -name "*"`'), "\n")
  let files = split(glob(self.path . '/**/*.sv'), "\n")
  call filter(files, 'v:val =~ ''\v_c%[on]f%[i]g>''')
  call map(files, 'fnamemodify(v:val, ":.")')

  let self.file = tlib#input#List('s', 'Config', files)
endfunction

"-------------------------------------------------------------------------------
" Function : s:ConfigDatabase.set_prefix
" ?a:1 : Prefix
"-------------------------------------------------------------------------------
function! s:ConfigDatabase.set_prefix(...)
  call debug#debug#log('function! s:ConfigDatabase.set_prefix(...)')

  if (a:0 == 0)
    let self.prefix = matchstr(self.this, '\v\w+\ze_c%[on]f%[i]g>')
    if (self.prefix == '')
      let self.prefix = self.this
    endif
    return
  endif

  let self.prefix = a:1
endfunction

"-------------------------------------------------------------------------------
" Function : s:ConfigDatabase.parse
"-------------------------------------------------------------------------------
function! s:ConfigDatabase.parse() dict
  call debug#debug#log('function! s:ConfigDatabase.parse() dict')


  let self.path = fnamemodify(self.file, ':p:h')
  let self.this = fnamemodify(self.file, ':p:t:r')

  call self.set_prefix()

  let prefix = substitute(self.prefix, 'agent', 'agt', 'g')
  let prefix = substitute(prefix, 'environment', 'env', 'g')

  if (prefix != '')
    let self.m_this = 'm_' . prefix . '_cfg'
  endif

endfunction

"-------------------------------------------------------------------------------
" Function : config_db_set
" a:1 - Value prefix - example config.vif
"-------------------------------------------------------------------------------
function! s:ConfigDatabase.config_db_set(cntxt, inst_name, ...) dict
  call debug#debug#log('function! s:ConfigDatabase.config_db_set(cntxt, inst_name, ...) dict')

  if (self.this == "")
    return ""
  else
    let value = self.m_this
    if (a:0 != 0)
      let value = a:1 . "." . self.m_this
    endif
    return s:_set_indent(0) . printf('uvm_config_db#(%s)::set(.cntxt(%s), .inst_name("%s"), .field_name("%s"), .value(%s));', self.this, a:cntxt, a:inst_name, self.this, value)
  endif
endfunction


"-------------------------------------------------------------------------------
" Function : config_skalatorn
"-------------------------------------------------------------------------------
function! s:ConfigDatabase.skalaton() dict
  call debug#debug#log('function! s:ConfigDatabase.skalaton() dict')

  " If file is not empty
  if (getfsize(self.file) > 1)
    return
  endif

  exe 'e ' . self.file

  let cb = g:callbacks#sv#uvm#object#cb

  let str = ''
  for l:idx in range(len(self.interfaces))
    let indent = 0

    " Interface
    let obj = self.interfaces[l:idx]
    if (type(obj) == type(g:sv#uvm#skalaton#interface#db))
      let str .= s:_set_indent(indent) . obj.get_declaration_str()
    else
      call s:show_err('unknown type ' . type(obj))
    endif
  endfor
  let str .= ''

  for l:idx in range(len(self.sub_configs))
    let indent = 0

    " Sub Config
    let obj = self.sub_configs[l:idx]
    if (type(obj.config) == type(s:ConfigDatabase))
      let str .= s:_set_indent(indent) . s:map_str(printf("%s %s[v:len];", obj.config.this, obj.config.m_this), obj)
    else
      call s:show_err('unknown type ' . type(obj))
    endif

    if (l:idx == len(self.sub_configs))
      let str .= ''
    endif
  endfor

  " Bypass sequencer flag
  if (self.options.bypass_sequencer.enable == 1)
    let str .= 'rand bit is_bypass_sequencer;'
  endif

  let cb.declaration = str

  let str = sv#uvm#mapping#object()

  exe 'normal ggi' . str
  w
endfunction


"################################################################################################
let s:SequencerDatabase = {'options': {'reactive_slave': 0}, 'prefix': '', 'file': '', 'this': '', 'm_this': '', 'path': '', 'agent': '', 'sub_sequencers': []}
"-------------------------------------------------------------------------------
" Function : new
" a:1 - dictionary
"       either file or path key must be provided. If path key provided then it will search for seqr in path
"-------------------------------------------------------------------------------
function! s:SequencerDatabase.new(...) dict
  call debug#debug#log('function! s:SequencerDatabase.new(...) dict')

  let seqr = deepcopy(self)
  if (a:0 == 0)
    echoerr "Argument required"
    finish
  endif

  if (type(a:1) != type({}))
    echoerr "Not a dictionary"
    finish
  endif

  if (!(has_key(a:1, 'file') || has_key(a:1, 'path')))
    echoerr 'key file or path must be provided'
    finish
  endif

  for l:key in keys(a:1)
    let seqr[l:key] = a:1[l:key]
  endfor

  if (has_key(a:1, 'path'))
    call seqr.find()
  endif

  call seqr.parse()

  return seqr
endfunction

"-------------------------------------------------------------------------------
" Function : s:SequencerDatabase.get_create
"-------------------------------------------------------------------------------
function! s:SequencerDatabase.get_create(indent_offset) dict
  call debug#debug#log('function! s:SequencerDatabase.get_create(indent_offset) dict')

  let str = s:_set_indent(a:indent_offset) . printf('%s = %s :: type_id :: create("%s", this);', self.m_this, self.this, self.m_this)
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : find
"-------------------------------------------------------------------------------
function! s:SequencerDatabase.find() dict
  call debug#debug#log('function! s:SequencerDatabase.find() dict')

  "let files = split(glob('`find ' . self.path . ' -name "*"`'), "\n")
  let files = split(glob(self.path . '/**/*.sv'), "\n")
  call filter(files, 'v:val =~ ''\v_seq%[uence]r>''')
  call map(files, 'fnamemodify(v:val, ":.")')

  let self.file = tlib#input#List('s', 'Sequencer', files)
endfunction

"-------------------------------------------------------------------------------
" Function : s:SequencerDatabase.parse
"-------------------------------------------------------------------------------
function! s:SequencerDatabase.parse() dict
  call debug#debug#log('function! s:SequencerDatabase.parse() dict')


  let self.path = fnamemodify(self.file, ':p:h')
  let self.this = fnamemodify(self.file, ':p:t:r')

  call self.set_prefix()

  if (self.prefix != '')
    let self.m_this = 'm_' . self.prefix . '_seqr'

    if (self.options.reactive_slave == 1)
      let self.req_export = 'req_export'
      let self.req_analysis_fifo = printf('m_%s_tlm_fifo', self.prefix)
    endif
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : s:SequencerDatabase.set_prefix
" ?a:1 : Prefix
"-------------------------------------------------------------------------------
function! s:SequencerDatabase.set_prefix(...) dict
  call debug#debug#log('function! s:SequencerDatabase.set_prefix(...) dict')

  if (a:0 == 0)
    let self.prefix = matchstr(self.this, '\v\w+\ze_seq%[uence]r>')
    if (self.prefix == '')
      let self.prefix = self.this
    endif
    return
  endif

  let self.prefix = a:1
endfunction

"-------------------------------------------------------------------------------
" Function : skalaton
"-------------------------------------------------------------------------------
function! s:SequencerDatabase.skalaton() dict
  call debug#debug#log('function! s:SequencerDatabase.skalaton() dict')

  " If file is not empty
  if (getfsize(self.file) > 1)
    return
  endif

  exe 'e ' . self.file

  let cb = g:callbacks#sv#uvm#sequencer#cb

  if (type(self.agent) == type(s:AgentDatabase))
    let cb.parameter = printf('#(%s, %s)', self.agent.req_seq_item.this, self.agent.rsp_seq_item.this)
  elseif (self.this =~ '\v_v%[irtual]_seq%[uence]r>')
    let cb.parameter = "#(uvm_sequence_item)"
  endif

  let cb.declaration .= ""
  for l:sub_sequencer in self.sub_sequencers
    let cb.declaration .= s:_set_indent(0) . s:map_str(printf('%s %s[v:len];', l:sub_sequencer.sequencer.this, l:sub_sequencer.sequencer.m_this), l:sub_sequencer)
  endfor
  if (cb.declaration != '')
    let cb.declaration .= ''
  endif

  if (self.options.reactive_slave == 1)
    let cb.declaration .= s:_set_indent(0) . printf('uvm_analysis_export #(%s) %s;', self.agent.rsp_seq_item.this, self.req_export)
    let cb.declaration .= s:_set_indent(0) . printf('uvm_tlm_analysis_fifo #(%s) %s;', self.agent.rsp_seq_item.this, self.req_analysis_fifo)

    let cb.constructor.body = s:_set_indent(0) . printf('%s = new("%s", this);', self.req_analysis_fifo, self.req_analysis_fifo)
    let cb.constructor.body .= s:_set_indent(0) . printf('%s = new("%s", this);', self.req_export, self.req_export)

    let cb.connect_phase.body = s:_set_indent(0) . printf('%s.connect(%s.analysis_export);', self.req_export, self.req_analysis_fifo)

    let cb.fun_declaration = s:_set_indent(0) . comments#block_comment#getComments("Function", "connect") .
      \ s:_set_indent(0) . 'virtual function void connect_phase(uvm_phase phase);' .
      \ cb.connect_phase.declaration .
      \ s:_set_indent(&shiftwidth) . 'super.connect_phase(phase);' .
      \ cb.connect_phase.body . '' .
      \ s:_set_indent(-&shiftwidth) . 'endfunction : connect_phase'
  endif

  let str = sv#uvm#mapping#sequencer()

  exe 'normal ggi' . str
  w
endfunction


"############################################################
let s:DriverDatabase = {'options': {'bypass_sequencer': {'enable': 0, 'bypass': ''}, 'reactive_slave': 0}, 'prefix': '', 'file': '', 'this': '', 'm_this': '', 'path': '', 'agent': ''}
"-------------------------------------------------------------------------------
" Function : new
" a:1 - dictionary
"       either file or path key must be provided. If path key provided then it will search for driver in path
"-------------------------------------------------------------------------------
function! s:DriverDatabase.new(...) dict
  call debug#debug#log('function! s:DriverDatabase.new(...) dict')

  let driver = deepcopy(self)
  if (a:0 == 0)
    echoerr "Argument required"
    finish
  endif

  if (type(a:1) != type({}))
    echoerr "Not a dictionary"
    finish
  endif

  if (!(has_key(a:1, 'file') || has_key(a:1, 'path')))
    echoerr 'key file or path must be provided'
    finish
  endif

  for l:key in keys(a:1)
    let driver[l:key] = a:1[l:key]
  endfor

  if (has_key(a:1, 'path'))
    call driver.find()
  endif

  call driver.parse()

  return driver
endfunction

"-------------------------------------------------------------------------------
" Function : s:DriverDatabase.get_create
"-------------------------------------------------------------------------------
function! s:DriverDatabase.get_create(indent_offset) dict
  call debug#debug#log('function! s:DriverDatabase.get_create(indent_offset) dict')

  let str = s:_set_indent(a:indent_offset) . printf('%s = %s :: type_id :: create("%s", this);', self.m_this, self.this, self.m_this)
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : s:DriverDatabase.parse
"-------------------------------------------------------------------------------
function! s:DriverDatabase.parse() dict
  call debug#debug#log('function! s:DriverDatabase.parse() dict')


  let self.path = fnamemodify(self.file, ':p:h')
  let self.this = fnamemodify(self.file, ':p:t:r')

  call self.set_prefix()

  if (self.prefix != '')
    let self.m_this = 'm_' . self.prefix . '_drv'
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : find
"-------------------------------------------------------------------------------
function! s:DriverDatabase.find() dict
  call debug#debug#log('function! s:DriverDatabase.find() dict')

  "let files = split(glob('`find ' . self.path . ' -name "*"`'), "\n")
  let files = split(glob(self.path . '/**/*.sv'), "\n")
  call filter(files, 'v:val =~ ''\v_dr%[ive]r>''')
  call map(files, 'fnamemodify(v:val, ":.")')

  let self.file = tlib#input#List('s', 'Driver', files)
endfunction

"-------------------------------------------------------------------------------
" Function : s:DriverDatabase.set_prefix
" ?a:1 : Prefix
"-------------------------------------------------------------------------------
function! s:DriverDatabase.set_prefix(...) dict
  call debug#debug#log('function! s:DriverDatabase.set_prefix(...) dict')

  if (a:0 == 0)
    let self.prefix = matchstr(self.this, '\v\w+\ze_dr%[ive]r>')
    if (self.prefix == '')
      let self.prefix = self.this
    endif
    return
  endif

  let self.prefix = a:1
endfunction

"-------------------------------------------------------------------------------
" Function : new_driver
"-------------------------------------------------------------------------------
function! s:DriverDatabase.skalaton() dict
  call debug#debug#log('function! s:DriverDatabase.skalaton() dict')

  " If file is not empty
  if (getfsize(self.file) > 1)
    return
  endif

  exe 'e ' . self.file

  let cb = g:callbacks#sv#uvm#driver#cb

  let cb.declaration = s:_set_indent(0) . printf("virtual %s %s;", self.agent.interface.this, self.agent.interface.m_this)
  let cb.declaration .= s:_set_indent(0) . printf('%s %s;', self.agent.config.this, self.agent.config.m_this)
  let cb.declaration .= (self.options.bypass_sequencer.enable == 1) ? (s:_set_indent(0) . self.options.bypass_sequencer.bypass_port.declaration()) : ('')
  let cb.parameter = printf('%s, %s', self.agent.req_seq_item.this, self.agent.rsp_seq_item.this)

  let cb.build_phase.body = self.agent.interface.config_db_get('this', "")
  let cb.build_phase.body .= s:_set_indent(0) . printf('%s = %s :: get_config(this);', self.agent.config.m_this, self.agent.config.this)

  let cb.constructor.body = (self.options.bypass_sequencer.enable == 1) ? (s:_set_indent(0) . self.options.bypass_sequencer.bypass_port.instantiation()) : ('')

  if (self.options.bypass_sequencer.enable == 1)
    let cb.fun_declaration = '' . comments#block_comment#getComments("Task", "drive") .
      \ s:_set_indent(0) . 'task drive();' .
      \ s:_set_indent(&shiftwidth) . printf('if (%s.is_bypass_sequencer == 1) begin', self.agent.config.m_this) .
      \ s:_set_indent(&shiftwidth) . 'bypass_drive();' .
      \ s:_set_indent(-&shiftwidth) . 'end' .
      \ s:_set_indent(0) . 'else begin' .
      \ s:_set_indent(&shiftwidth) . 'seqr_drive();' .
      \ s:_set_indent(-&shiftwidth) . 'end' .
      \ s:_set_indent(-&shiftwidth) . 'endtask : drive'

    let cb.fun_declaration .= comments#block_comment#getComments("Task", "seqr_drive") .
      \ s:_set_indent(0) . 'task seqr_drive();' .
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
      \ s:_set_indent(-&shiftwidth) . 'endtask : seqr_drive'

    let cb.fun_declaration .= comments#block_comment#getComments("Task", "bypass_drive") .
      \ s:_set_indent(0) . 'task bypass_drive();' .
      \ s:_set_indent(&shiftwidth) . '' .
      \ s:_set_indent(&shiftwidth) . 'forever begin' .
      \ s:_set_indent(&shiftwidth) .  printf('%s.get(req);', self.options.bypass_sequencer.bypass_port.m_this) .
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
      \ s:_set_indent(0) . printf('rsp = %s::type_id::create("rsp");', self.agent.req_seq_item.this) .
      \ s:_set_indent(0) . 'rsp.set_id_info(req);' .
      \ s:_set_indent(0) . printf('%s.put(rsp);', self.options.bypass_sequencer.bypass_port.m_this) .
      \ s:_set_indent(-&shiftwidth) . 'end' .
      \ s:_set_indent(-&shiftwidth) . 'endtask : bypass_drive'

    let cb.override.run_phase = 'task run_phase(uvm_phase phase);' .
    \ s:_set_indent(&shiftwidth) . 'drive();' .
    \ s:_set_indent(-&shiftwidth) . 'endtask : run_phase'
  endif

  let str = sv#uvm#mapping#driver()

  exe 'normal ggi' . str
  w
endfunction

"############################################################

let s:MonitorDatabase = {'options': {'reactive_slave': 0},'prefix': '', 'file': '', 'this': '', 'm_this': '', 'path': '', 'agent': '', 'analysis_port': ''}
"-------------------------------------------------------------------------------
" Function : new
" a:1 - dictionary
"       either file or path key must be provided. If path key provided then it will search for monitor in path
"-------------------------------------------------------------------------------
function! s:MonitorDatabase.new(...) dict
  call debug#debug#log('function! s:MonitorDatabase.new(...) dict')

  let monitor = deepcopy(self)
  if (a:0 == 0)
    echoerr "Argument required"
    finish
  endif

  if (type(a:1) != type({}))
    echoerr "Not a dictionary"
    finish
  endif

  if (!(has_key(a:1, 'file') || has_key(a:1, 'path')))
    echoerr 'key file or path must be provided'
    finish
  endif

  for l:key in keys(a:1)
    let monitor[l:key] = a:1[l:key]
  endfor

  if (has_key(a:1, 'path'))
    call monitor.find()
  endif

  call monitor.parse()

  return monitor
endfunction

"-------------------------------------------------------------------------------
" Function : s:MonitorDatabase.get_create
"-------------------------------------------------------------------------------
function! s:MonitorDatabase.get_create(indent_offset) dict
  call debug#debug#log('function! s:MonitorDatabase.get_create(indent_offset) dict')

  let str = s:_set_indent(a:indent_offset) . printf('%s = %s :: type_id :: create("%s", this);', self.m_this, self.this, self.m_this)
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : find
"-------------------------------------------------------------------------------
function! s:MonitorDatabase.find() dict
  call debug#debug#log('function! s:MonitorDatabase.find() dict')

  "let files = split(glob('`find ' . self.path . ' -name "*"`'), "\n")
  let files = split(glob(self.path . '/**/*.sv'), "\n")
  call filter(files, 'v:val =~ ''\v_mon%[itor]>''')
  call map(files, 'fnamemodify(v:val, ":.")')

  let self.file = tlib#input#List('s', 'Monitor', files)
endfunction

"-------------------------------------------------------------------------------
" Function : s:MonitorDatabase.set_prefix
" ?a:1 : Prefix
"-------------------------------------------------------------------------------
function! s:MonitorDatabase.set_prefix(...) dict
  call debug#debug#log('function! s:MonitorDatabase.set_prefix(...) dict')

  if (a:0 == 0)
    let self.prefix = matchstr(self.this, '\v\w+\ze_mon%[itor]>')
    if (self.prefix == '')
      let self.prefix = self.this
    endif
    return
  endif

  let self.prefix = a:1
endfunction

"-------------------------------------------------------------------------------
" Function : s:MonitorDatabase.parse
"-------------------------------------------------------------------------------
function! s:MonitorDatabase.parse() dict
  call debug#debug#log('function! s:MonitorDatabase.parse() dict')

  let self.path = fnamemodify(self.file, ':p:h')
  let self.this = fnamemodify(self.file, ':p:t:r')

  call self.set_prefix()

  if (self.prefix != '')
    let self.m_this = 'm_' . self.prefix . '_mon'
    let self.analysis_port = self.m_this . '_ap'
    let self.reactive_slave_ap = 'm_' . self.prefix . '_req_ap'
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : s:MonitorDatabase.skalaton
"-------------------------------------------------------------------------------
function! s:MonitorDatabase.skalaton() dict
  call debug#debug#log('function! s:MonitorDatabase.skalaton() dict')

  " If file is not empty
  if (getfsize(self.file) > 1)
    return
  endif

  exe 'e ' . self.file

  let cb = g:callbacks#sv#uvm#monitor#cb

  let cb.declaration = s:_set_indent(0) . 'uvm_analysis_port #(' . self.agent.rsp_seq_item.this . ') ' . self.analysis_port  . ';' .
    \ ((self.options.reactive_slave == 1) ? (s:_set_indent(0) . 'uvm_analysis_port #(' . self.agent.rsp_seq_item.this . ') ' . self.reactive_slave_ap . ';') : ('')) . '' .
    \ s:_set_indent(0) . printf("virtual %s %s;", self.agent.interface.this, self.agent.interface.m_this) .
    \ s:_set_indent(0) . printf('%s %s;', self.agent.config.this, self.agent.config.m_this)

  let cb.build_phase.body = s:_set_indent(0) . printf('%s = new("%s", this);', self.analysis_port, self.analysis_port) .
    \ ((self.options.reactive_slave == 1) ? (s:_set_indent(0) . printf('%s = new("%s", this);', self.reactive_slave_ap, self.reactive_slave_ap)) : ('')) .
    \ self.agent.interface.config_db_get('this', '') .
    \ s:_set_indent(0) . printf('%s = %s :: get_config(this);', self.agent.config.m_this, self.agent.config.this)

  let str = sv#uvm#mapping#monitor()

  exe 'normal ggi' . str
  w
endfunction

"############################################################
let s:AgentDatabase = {'options': {'bypass_sequencer': {'enable': 0, 'bypass_port': ''}, 'reactive_slave': 1}, 'env_path': '', 'type_abbr' : '', 'prefix': '', 'file': '', 'this': '', 'm_this': '', 'path': '', 'monitor': '', 'driver': '', 'sequencer': '', 'config': '', 'interface': '', 'req_seq_item': '', 'rsp_seq_item': '', 'package_file': ''}
"-------------------------------------------------------------------------------
" Function : new
" a:1 - dictionary
"       either file or path key must be provided. If path key provided then it will search for monitor in path
"       env_path must be provided
"-------------------------------------------------------------------------------
function! s:AgentDatabase.new(...) dict
  call debug#debug#log('function! s:AgentDatabase.new(...) dict')

  let agent = deepcopy(self)
  if (a:0 == 0)
    echoerr "Argument required"
    finish
  endif

  if (type(a:1) != type({}))
    echoerr "Not a dictionary"
    finish
  endif

  if (!(has_key(a:1, 'file') || has_key(a:1, 'path')))
    echoerr 'key file or path must be provided'
    finish
  endif

  if (!has_key(a:1, 'env_path'))
    echoerr 'key file not found'
    finish
  endif

  for l:key in keys(a:1)
    let agent[l:key] = a:1[l:key]
  endfor

  if (has_key(a:1, 'path'))
    let key = 'path'
    call agent.find()
  elseif (has_key(a:1, 'file'))
    let key = 'file'
  endif

  call agent.parse()

  if (key == 'file')
    let mon_arg = {'options': agent.options, 'agent': agent, 'file': printf('%s/%s_monitor.sv',fnamemodify(agent.file, ':h'), agent.prefix)}
    let seqr_arg = {'options': agent.options, 'agent': agent, 'file': printf('%s/%s_sequencer.sv',fnamemodify(agent.file, ':h'), agent.prefix)}
    let drv_arg = {'options': agent.options, 'agent': agent, 'file': printf('%s/%s_driver.sv',fnamemodify(agent.file, ':h'), agent.prefix)}
    let cfg_arg = {'options': agent.options, 'file': printf('%s/%s_config.sv',fnamemodify(agent.file, ':h'), agent.this), 'interfaces': [agent.interface]}
  else
    let mon_arg = {'path': agent.path}
    let seqr_arg = {'path': agent.path}
    let drv_arg = {'path': agent.path}
    let cfg_arg = {'path': agent.path, 'interfaces': [agent.interface]}
  endif

  let agent.monitor = s:MonitorDatabase.new(mon_arg)
  let agent.driver = s:DriverDatabase.new(drv_arg)
  let agent.sequencer = s:SequencerDatabase.new(seqr_arg)
  let agent.config = s:ConfigDatabase.new(cfg_arg)

  return agent
endfunction

"-------------------------------------------------------------------------------
" Function : s:AgentDatabase.get_create
"-------------------------------------------------------------------------------
function! s:AgentDatabase.get_create(indent_offset) dict
  call debug#debug#log('function! s:AgentDatabase.get_create(indent_offset) dict')

  let str = s:_set_indent(a:indent_offset) . printf('%s = %s :: type_id :: create("%s", this);', self.m_this, self.this, self.m_this)
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : find
"-------------------------------------------------------------------------------
function! s:AgentDatabase.find() dict
  call debug#debug#log('function! s:AgentDatabase.find() dict')

  "let files = split(glob('`find ' . self.path . ' -name "*"`'), "\n")
  let agent_files = split(glob(self.path . '/**/*.sv'), "\n")
  let files = filter(deepcopy(agent_files), 'v:val =~ ''\v_ag%[en]t>''')
  call map(files, 'fnamemodify(v:val, ":.")')

  let self.file = tlib#input#List('s', 'Agent', files)

  " Package
  let files = filter(deepcopy(agent_files), 'v:val =~ ''\v_ag%[en]t_p%[ac]k%[a]g%[e]>''')

  call map(files, 'fnamemodify(v:val, ":.")')
  let self.package_file = tlib#input#List('s', 'Agent Package File', files)

  echo self.package_file

  if (self.package_file != '')
    let self.package_file = fnamemodify(self.package_file, ':p')
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : set_seq_item
"-------------------------------------------------------------------------------
function! s:AgentDatabase.set_seq_item() dict
  call debug#debug#log('function! s:AgentDatabase.set_seq_item() dict')


  "let transactions = split(glob('`find . -regextype sed -regex ".*/\w*_\(seq_item\|trans\(action\)\?\).sv"`'), "\n")
  let transactions = split(glob(self.path . '/**/*.sv'), "\n")
  call filter(transactions, 'v:val =~ ''\v_(seq%[uence]_i%[tem]|trans%[action])>''')

  if (len(transactions) == 0)
    call s:show_err ("seq_item not found!!!")
    return 0
  endif

  call map (transactions, 'fnamemodify(v:val, ":p")')

  " req and rsp are same
  if (len(transactions) == 1)
    let req = transactions[0]
    let rsp = transactions[0]
  else
    let req = tlib#input#List('s', 'Sequence Item [Request]', transactions)
    let rsp = tlib#input#List('s', 'Sequence Item [Response]', transactions)
  endif
  if (req == "" || rsp == "")
    return 0
  endif

  let self.req_seq_item = g:sv#uvm#skalaton#seq_item#db.new({'file': req})
  let self.rsp_seq_item = g:sv#uvm#skalaton#seq_item#db.new({'file': rsp})
  return 1
endfunction

"-------------------------------------------------------------------------------
" Function : s:AgentDatabase.parse
"-------------------------------------------------------------------------------
function! s:AgentDatabase.parse() dict
  call debug#debug#log('function! s:AgentDatabase.parse() dict')

  if (has_key(self, 'file'))
    let self.path = fnamemodify(self.file, ':p:h')
  elseif (has_key(self, 'path'))
    call self.find()
  endif

  let self.this = fnamemodify(self.file, ':p:t:r')
  let self.type_abbr = fnamemodify(self.file, ':p:h:t')
  call self.set_prefix()

  if (self.prefix != '')
    let self.m_this = 'm_' . self.prefix . '_agt'
  endif

  call self.set_intf()
  call self.set_seq_item()

  if (self.options.bypass_sequencer.enable == 1)
    let self.options.bypass_sequencer.bypass_port = s:TLM_Port.new({'direction': 2, 'this': 'uvm_slave_port', 'm_this': printf('m_%s_bypass_slave_port', self.prefix), 'req': self.req_seq_item.this, 'rsp': self.rsp_seq_item.this})
  endif

endfunction

"-------------------------------------------------------------------------------
" Function : set_intf
"-------------------------------------------------------------------------------
function! s:AgentDatabase.set_intf() dict
  call debug#debug#log('function! s:AgentDatabase.set_intf() dict')

  "let files = split(glob('`find ' . self.env_path . ' -name "*"`'), "\n")
  let files = split(glob(self.env_path . '/**/*.sv'), "\n")
  call filter(files, 'v:val =~ ''\v_i%[nter]f%[ace]>''')
  call map(files, 'fnamemodify(v:val, ":.")')

  let intf_file = tlib#input#List('s', printf('%s Interface', self.this), files)

  let self.interface = g:sv#uvm#skalaton#interface#db.new({'file': intf_file})
endfunction

"-------------------------------------------------------------------------------
" Function : s:AgentDatabase.set_prefix
"-------------------------------------------------------------------------------
function! s:AgentDatabase.set_prefix() dict
  call debug#debug#log('function! s:AgentDatabase.set_prefix() dict')


  let self.prefix = matchstr(self.this, '\v\w+\ze_(agent|agt)>')
  if (self.prefix == '')
    let self.prefix = self.this
  endif

endfunction

"-------------------------------------------------------------------------------
" Function : skalaton
"-------------------------------------------------------------------------------
function! s:AgentDatabase.skalaton() dict
  call debug#debug#log('function! s:AgentDatabase.skalaton() dict')

  " get sequence item
  if (self.req_seq_item.this == '')
    return 0
  endif

  " Name of the monitor analysis port

  let cb = g:callbacks#sv#uvm#agent#cb

  let cb.declaration = s:_set_indent(0) . printf('uvm_analysis_port #(%s) %s;', self.req_seq_item.this, self.monitor.analysis_port) .
  \ s:_set_indent(0) . printf('%s %s;', self.config.this, self.config.m_this) .
  \ s:_set_indent(0) . printf('%s %s;', self.driver.this, self.driver.m_this) .
  \ s:_set_indent(0) . printf('%s %s;', self.monitor.this, self.monitor.m_this) .
  \ s:_set_indent(0) . printf('%s %s;', self.sequencer.this, self.sequencer.m_this) .
  \ ((self.options.bypass_sequencer.enable) ? (s:_set_indent(0) . self.options.bypass_sequencer.bypass_port.declaration()) : ('')) . ''

  let cb.build_phase.body = '' . s:_set_indent(0) . printf('%s = %s::type_id::create("%s", this);', self.monitor.m_this, self.monitor.this, self.monitor.m_this) .
  \ s:_set_indent(0) . printf('%s = %s :: get_config(this);', self.config.m_this, self.config.this) .
  \ s:_set_indent(0) . printf('uvm_config_db#(%s)::set(.cntxt(this), .inst_name("*"), .field_name("%s"), .value(%s));', self.config.this, self.config.this, self.config.m_this) .
  \ s:_set_indent(0) . 'if (is_active == UVM_ACTIVE) begin' .
  \ ((self.options.bypass_sequencer.enable) ? (s:_set_indent(&shiftwidth) . printf('if (%s.is_bypass_sequencer == 0) begin', self.config.m_this)) : ('')) .
  \ s:_set_indent(&shiftwidth) . printf('%s = %s::type_id::create("%s", this);', self.sequencer.m_this, self.sequencer.this, self.sequencer.m_this) .
  \ ((self.options.bypass_sequencer.enable) ? (s:_set_indent(-&shiftwidth) . 'end') : ('')) .
  \ s:_set_indent(0) . printf('%s = %s::type_id::create("%s", this);', self.driver.m_this, self.driver.this, self.driver.m_this) .
  \ s:_set_indent(-&shiftwidth) . 'end' .
  \ self.interface.config_db_set('this', '*', self.config.m_this)

  let cb.connect_phase.body = '' . s:_set_indent(0) . 'if (is_active == UVM_ACTIVE) begin' .
  \ ((self.options.bypass_sequencer.enable) ? (s:_set_indent(&shiftwidth) . printf('if (%s.is_bypass_sequencer == 0) begin', self.config.m_this)) : ('')) .
  \ s:_set_indent(&shiftwidth) . printf('%s.seq_item_port.connect(%s.seq_item_export);', self.driver.m_this, self.sequencer.m_this) .
  \ ((self.options.bypass_sequencer.enable) ? (s:_set_indent(-&shiftwidth) . 'end') : ('')) .
  \ ((self.options.bypass_sequencer.enable) ? (s:_set_indent(0) . printf('%s = %s.%s;', self.options.bypass_sequencer.bypass_port.m_this, self.driver.m_this, self.options.bypass_sequencer.bypass_port.m_this)) : ('')) .
  \ s:_set_indent(-&shiftwidth) . 'end' .
  \ s:_set_indent(0) . printf('%s = %s.%s;', self.monitor.analysis_port, self.monitor.m_this, self.monitor.analysis_port) .
  \ ((self.options.reactive_slave == 1) ? (s:_set_indent(0) . printf('%s.%s.connect(%s.%s);', self.monitor.m_this, self.monitor.reactive_slave_ap, self.sequencer.m_this, self.sequencer.req_export)) : (''))

  let str = sv#uvm#mapping#agent()

  exe 'normal ggi' . str
  w
  return 1
endfunction

"-------------------------------------------------------------------------------
" Function : package
"-------------------------------------------------------------------------------
function! s:AgentDatabase.package() dict
  call debug#debug#log('function! s:AgentDatabase.package() dict')

  " get sequence item
  if (self.req_seq_item.this == '')
    return 0
  endif

  let fname = self.file
  let root = fnamemodify(copy(fname), ':p:r')
  let fname = printf("%s_pkg.sv", root)

  let self.package_file = fname

  exe 'e ' . fname

  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  let seq_items = [self.req_seq_item.file]

  if (self.rsp_seq_item.file != self.req_seq_item.file)
    let seq_items += [self.rsp_seq_item.file]
  endif

  let include_seq_items = join(map (seq_items, 'printf(''`include "%s"'', fnamemodify(v:val, ":p:t"))'), "") . ''

  let agent_components = [self.config.file, self.sequencer.file, self.driver.file, self.monitor.file, self.file]
  call map (filter(agent_components, 'v:val != ""'), '"`include \"" . fnamemodify(v:val, ":p:t") . "\""')

  let include_agent_components = '// ' . toupper(self.type_abbr) . " Agent"
  let include_agent_components .= join(agent_components, '') . ''

  let str = s:ifndef()
  let str .= comments#block_comment#getComments("Package", name) .
            \ s:_set_indent(0) . printf('package %s;', name) .
            \ s:_set_indent(0) . 'import uvm_pkg::*;' .
            \ s:_set_indent(0) . '`include "uvm_macros.svh"' .
            \
            \ s:_set_indent(0) . '// Sequence Items' .
            \ s:_set_indent(0) . include_seq_items .
            \
            \ s:_set_indent(0) . include_agent_components .
            \
            \ s:_set_indent(0) . printf('endpackage : %s', name)

  exe 'normal ggi' . str
  w

  return 1
endfunction


"#########################################################################################

let s:EnvDatabase = {'options': {'interactive': 0}, 'prefix': '', 'path': '', 'file': '', 'this': s:GetTemplete('a', 'env'), 'm_this': s:GetTemplete('a', 'm_env'), 'agents': [], 'interfaces': [], 'config': '', 'virtual_sequencer': ''}

"-------------------------------------------------------------------------------
" Function : parse_env
" Sets 'prefix', 'env.this', 'env.m_this'
" a:1 : env_name
"-------------------------------------------------------------------------------
function! s:EnvDatabase.parse_env(...) dict
  call debug#debug#log('function! s:EnvDatabase.parse_env(...) dict')


  if (a:0 == 0)
    let self.this = sv#uvm#mapping#get_default_name()
  else
    let self.this = a:1
  endif
  let self.m_this = 'm_' . self.this

  let self.prefix = matchstr(self.this, '\v\w+\ze_env>')
  if (self.prefix == '')
    let self.prefix = self.this
  endif

  let self.path = expand('%:p:h')
  let self.file = expand('%:p')

  "-------------------------------------------------------------------------------
  " Interface
  let intfs = split(glob(self.path . '/**/*.sv'), "\n")
  call filter(intfs, 'v:val =~ ''\v_i%[nter]f%[ace]>''')
  call map(intfs, 'fnamemodify(v:val, ":.")')
  let intfs = tlib#input#List('m', printf('%s Interfaces', self.this), intfs)

  if (len(intfs) == 0)
    call s:show_err('No Interface(s) Found!!')
    return 0
  endif

  call map (intfs, 'g:sv#uvm#skalaton#interface#db.new({"file": v:val})')
  call extend(self.interfaces, intfs)

  "-------------------------------------------------------------------------------

  "-------------------------------------------------------------------------------
  " Agents
  let agents = split(glob(self.path . '/**/*.sv'), "\n")
  call filter(agents, 'v:val =~ ''\v_ag%[en]t>''')
  call filter(agents, 'v:val !~ ''\v\.swp$''')
  call map(agents, 'fnamemodify(v:val, ":.")')

  if (self.options.interactive == 1)

    call map(agents, 'v:val . ": 1"')
    let agents = tlib#input#EditList('Agent <Number Of Instance>:', agents)

    call map(agents, '{"agent": matchstr(v:val, "\\v[^:]+"), "instances": matchstr(v:val, "\\v:\\s*\\zs\\d+")}')
  else
    let agents = tlib#input#List('m', 'Agents', agents)

    call map(agents, '{"agent": v:val, "instances": 1}')
  endif

  if (len(agents) == 0)
    call s:show_err('No Agent(s) Found!!')
    return 0
  endif

  call map (agents, '{"agent": s:AgentDatabase.new({"path": fnamemodify(v:val["agent"], ":h"), "env_path": self.path}), "instances": v:val["instances"]}')
  let self.agents = agents

  "-------------------------------------------------------------------------------

  "-------------------------------------------------------------------------------
  " Config
  let env_cfg_file = fnamemodify(self.file, ':r') . '_config.sv'
  let all_agent_configs = map(deepcopy(self.agents), 'extend(v:val, {"config": v:val.agent.config})') " {agent: object, instances: <number>, 'indexes': [array]}
  call filter(all_agent_configs, 'v:val.agent.this != ""')

  let self.config = s:ConfigDatabase.new({'file': env_cfg_file, 'interfaces': self.interfaces, 'sub_configs': all_agent_configs})
  "-------------------------------------------------------------------------------

  "-------------------------------------------------------------------------------
  " Virtual sequencer
  let virt_seqr_file = printf('%s_virtual_sequencer.sv', self.prefix)
  let self.virtual_sequencer = s:SequencerDatabase.new({'file': printf("%s/%s", self.path, virt_seqr_file), 'sub_sequencers': map(deepcopy(self.agents), 'extend(v:val, {"sequencer": v:val.agent.sequencer})')})
  "-------------------------------------------------------------------------------

  return 1

endfunction

"-------------------------------------------------------------------------------
" Function : s:EnvDatabase.get_create
"-------------------------------------------------------------------------------
function! s:EnvDatabase.get_create(indent_offset) dict
  call debug#debug#log('function! s:EnvDatabase.get_create(indent_offset) dict')

  let str = s:_set_indent(a:indent_offset) . printf('%s = %s :: type_id :: create("%s", this);', self.m_this, self.this, self.m_this)
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : package
"-------------------------------------------------------------------------------
function! s:EnvDatabase.package() dict
  call debug#debug#log('function! s:EnvDatabase.package() dict')

  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
  " Sequence Items
  " let seq_items = split(glob('./**/*.sv'), "\n")
  " call filter(seq_items, 'v:val =~ ''\v_(seq%[uence]_item|trans%[action])>''')
  " let include_seq_items = join(map (seq_items, 'printf(''`include "%s"'', fnamemodify(v:val, ":t"))'), "") . ''
  """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

  let agents_c = ""

  for l:agent in map(deepcopy(self.agents), 'v:val["agent"]')

    let seq_items = []

    let agents_c .= '// ' . toupper(l:agent.type_abbr) . " Agent"

    if (l:agent.package_file != "")
      let agents_c .= printf('import %s::*;', fnamemodify(l:agent.package_file , ':t:r'))
    else
      if (l:agent.req_seq_item.this == l:agent.rsp_seq_item.this)
        let seq_items += [fnamemodify(l:agent.req_seq_item.file, ':t')]
      else
        let seq_items += [fnamemodify(l:agent.req_seq_item.file, ':t'), fnamemodify(l:agent.rsp_seq_item.file, ':t')]
      endif
      let agent_components = seq_items + [l:agent.config.file, l:agent.sequencer.file, l:agent.driver.file, l:agent.monitor.file, l:agent.file]
      call map (filter(agent_components, 'v:val != ""'), '"`include \"" . fnamemodify(v:val, ":p:t") . "\""')
      let agents_c .= join(agent_components, '') . ''
    endif

  endfor

  let str = s:ifndef()
  let str .= comments#block_comment#getComments("Package", name) .
            \ s:_set_indent(0) . printf('package %s;', name) .
            \ s:_set_indent(0) . 'import uvm_pkg::*;' .
            \ s:_set_indent(0) . '`include "uvm_macros.svh"' .
            \
            \ s:_set_indent(0) . printf('`include "%s_defines.sv"', self.prefix) .
            \
            \ s:_set_indent(0) . agents_c .
            \
            \ s:_set_indent(0) . '// Env' .
            \ s:_set_indent(0) . printf('`include "%s.sv"', self.config.this) .
            \ s:_set_indent(0) . printf('`include "%s.sv"', self.virtual_sequencer.this) .
            \ s:_set_indent(0) . printf('`include "%s.sv"', self.this) .
            \
            \ s:_set_indent(0) . printf('endpackage : %s', name)

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : new_env_pkg
"-------------------------------------------------------------------------------
function! s:EnvDatabase.new_env_pkg(fname) dict
  call debug#debug#log('function! s:EnvDatabase.new_env_pkg(fname) dict')

  " If file is not empty
  if (getfsize(a:fname) > 1)
    return
  endif

  let self.package_file = a:fname
  exe 'e ' . a:fname

  let str = self.package()

  exe 'normal ggi' . str
  w
endfunction

"-------------------------------------------------------------------------------
" Function : s:defines
"-------------------------------------------------------------------------------
function! s:EnvDatabase.defines() dict
  call debug#debug#log('function! s:EnvDatabase.defines() dict')

  let str = s:ifndef()
  let str .= '`define SYS_CLK_PERIOD 40ns'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : new_defines
"-------------------------------------------------------------------------------
function! s:EnvDatabase.new_defines(fname) dict
  call debug#debug#log('function! s:EnvDatabase.new_defines(fname) dict')

  " If file is not empty
  if (getfsize(a:fname) > 1)
    return
  endif

  let self.define_file = a:fname

  exe 'e ' . a:fname

  let str = self.defines()

  exe 'normal ggi' . str
  w
endfunction

"-------------------------------------------------------------------------------
" Function : env
"-------------------------------------------------------------------------------
function! s:EnvDatabase.env_skalaton() dict
  call debug#debug#log('function! s:EnvDatabase.env_skalaton() dict')

  if (len(self.agents) == 0 || len(self.interfaces) == 0)
    return 0
  endif

  let cb = g:callbacks#sv#uvm#env#cb

  let cb.declaration = s:_set_indent(0) . printf('%s %s;', self.config.this, self.config.m_this)
  let cb.declaration .= s:_set_indent(0) . printf('%s %s;', self.virtual_sequencer.this, self.virtual_sequencer.m_this)

  let cb.build_phase.body = s:_set_indent(0) . printf('%s = %s :: get_config(this);', self.config.m_this, self.config.this)
  let cb.build_phase.body .= s:_set_indent(0) . printf('%s = %s::type_id::create("%s", this);', self.virtual_sequencer.m_this, self.virtual_sequencer.this, self.virtual_sequencer.m_this)
  let cb.connect_phase.body = ''

  for l:agent in self.agents
    let cb.declaration .= s:map_str((printf("%s %s[v:len];", agent.agent.this, agent.agent.m_this)), l:agent)
    let cb.build_phase.body .= s:_set_indent(0) . s:map_str(printf('%s[v:idx] = %s::type_id::create($psprintf("%s[v:key:v:idx%%0d]", v:val:v:idx), this);', agent.agent.m_this, agent.agent.this, agent.agent.m_this), l:agent)
    let cb.connect_phase.body .= s:_set_indent(0) . s:map_str(printf('%s.%s[v:idx] = %s[v:idx].%s;', self.virtual_sequencer.m_this, agent.agent.sequencer.m_this, agent.agent.m_this, agent.agent.sequencer.m_this), l:agent)
  endfor
  let cb.declaration .= ''
  let cb.build_phase.body .= ''

  for l:agent in self.agents
    if (agent.agent.config.this != '')
      let cb.build_phase.body .= s:_set_indent(0) . s:map_str(printf('uvm_config_db#(%s)::set(this,$psprintf("%s[v:key:v:idx%%0d]", v:val:v:idx),"%s", %s.%s[v:idx]);', agent.agent.config.this, agent.agent.m_this, agent.agent.config.this, self.config.m_this, agent.agent.config.m_this), l:agent)
    endif
  endfor
  let cb.build_phase.body .= ''

  let str = sv#uvm#mapping#env()

  exe 'normal ggi' . str
  w

  return 1
endfunction

"-------------------------------------------------------------------------------
" Function : test_package
" a:1 = {seq_pkg_file = '', tests = [], test_pkg_file = ''}
"-------------------------------------------------------------------------------
function! s:EnvDatabase.test_package(...) dict
  call debug#debug#log('function! s:EnvDatabase.test_package(...) dict')

  let pkg_arg = a:1

  if (pkg_arg.test_pkg_file == '')
    return 0
  endif

  exe 'e ' . pkg_arg.test_pkg_file

  let str = s:ifndef()

  let name = fnamemodify(pkg_arg.test_pkg_file, ':t:r')

  let seq_pkg_name = fnamemodify(pkg_arg.seq_pkg_file , ':t:r')

  let include_test_str = ''
  for l:test in pkg_arg.tests
    let include_test_str .= s:_set_indent(0) . printf('`include "%s"', fnamemodify(l:test, ':t'))
  endfor
  let include_test_str .= ''

  let import_agents = ''
  for l:agent in map(deepcopy(self.agents), 'v:val["agent"]')
    let import_agents .= s:_set_indent(0) . printf('import %s::*;', fnamemodify(l:agent.package_file, ':t:r'))
  endfor
  let import_agents .= ''

  let str .= comments#block_comment#getComments("Package", name) .
            \ s:_set_indent(0) . printf('package %s;', name) .
            \ s:_set_indent(0) . 'import uvm_pkg::*;' .
            \ s:_set_indent(0) . '`include "uvm_macros.svh"' .
            \
            \ s:_set_indent(0) . printf('import %s::*;', seq_pkg_name) .
            \ s:_set_indent(0) . printf('import %s::*;', fnamemodify(self.package_file, ':t:r')) .
            \ s:_set_indent(0) . import_agents .
            \
            \ s:_set_indent(0) . include_test_str .
            \
            \ s:_set_indent(0) . printf('endpackage : %s', name)

  exe 'normal ggi' . str
  w

  return 1
endfunction

"-------------------------------------------------------------------------------
" Function : seq_package
" a:1 = {sequences = [], seq_pkg_file = ''}
"-------------------------------------------------------------------------------
function! s:EnvDatabase.seq_package(...) dict
  call debug#debug#log('function! s:EnvDatabase.seq_package(...) dict')

  let pkg_arg = a:1

  if (pkg_arg.seq_pkg_file == '')
    return 0
  endif

  exe 'e ' . pkg_arg.seq_pkg_file

  let name = fnamemodify(pkg_arg.seq_pkg_file, ':t:r')

  let str = s:ifndef()

  let import_agent_str = ''
  for l:agent in map(deepcopy(self.agents), 'v:val["agent"]')
    if (l:agent.package_file != '')
      let import_agent_str .= printf('import %s::*;', fnamemodify(l:agent.package_file, ':t:r'))
    else
      let import_agent_str .= printf('`include "%s"', l:agent.req_seq_item.this)

      if (l:agent.req_seq_item.this != l:agent.rsp_seq_item.this)
        let import_agent_str .= printf('`include "%s"', l:agent.rsp_seq_item.this)
      endif
    endif
  endfor
  let import_agent_str .= ''

  let include_seq_str = ''
  for l:seq in pkg_arg.sequences 
    let include_seq_str .= s:_set_indent(0) . printf('`include "%s"', fnamemodify(l:seq, ':t'))
  endfor
  let include_seq_str .= ''

  let str .= comments#block_comment#getComments("Package", name) .
            \ s:_set_indent(0) . printf('package %s;', name) .
            \ s:_set_indent(0) . 'import uvm_pkg::*;' .
            \ s:_set_indent(0) . '`include "uvm_macros.svh"' .
            \
            \ s:_set_indent(0) . import_agent_str . '' .
            \ s:_set_indent(0) . printf('import %s::%s;', fnamemodify(self.package_file, ':t:r'), self.virtual_sequencer.this) .
            \
            \ s:_set_indent(0) . include_seq_str . '' .
            \
            \ s:_set_indent(0) . printf('endpackage : %s', name)

  exe 'normal ggi' . str
  w

  return 1
endfunction

"-------------------------------------------------------------------------------
" Function : tb_top
" a:1 = {tb_top_file: '', test_pkg_file: ''}
"-------------------------------------------------------------------------------
function! s:EnvDatabase.tb_top(...) dict
  call debug#debug#log('function! s:EnvDatabase.tb_top(...) dict')

  let arg = a:1

  if (arg.tb_top_file == '')
    return 0
  endif

  exe 'e ' . arg.tb_top_file

  let include_interface_str = ''
  let interface_inst_str = ''
  let config_db_interface_str = ''

  let interfaces_h = {}
  for l:agent in map(deepcopy(self.agents), 'v:val["agent"]')
    let interfaces_h[l:agent.interface.this] = l:agent.interface

  endfor

  for l:interface_o in values(interfaces_h)
    let include_interface_str .= printf('`include "%s"', fnamemodify(l:interface_o.file, ':t'))
    let interface_inst_str .= printf ('%s %s(clk);', l:interface_o.this, l:interface_o.m_this)

    let config_db_interface_str .= printf('uvm_config_db#(virtual %s)::set(.cntxt(null), .inst_name("*"), .field_name("%s"), .value(%s));', l:interface_o.this, l:interface_o.this, l:interface_o.m_this)
  endfor

  let str = s:ifndef()

  let name = fnamemodify(arg.tb_top_file, ':t:r')

  let str .= s:_set_indent(0) . 'import uvm_pkg::*;' .
           \ s:_set_indent(0) . '`include "uvm_macros.svh"'

  let str .= s:_set_indent(0) . printf('import %s::*;', fnamemodify(arg.test_pkg_file, ':t:r')) . ''

  let str .= s:_set_indent(0) . printf('`include "%s"', fnamemodify(self.define_file, ':t')) . ''

  let str .= s:_set_indent(0) . include_interface_str . ''

  let str .= comments#block_comment#getComments("Module", name) .
    \ s:_set_indent(0) . printf('module %s;', name) .
    \ s:_set_indent(&shiftwidth) . 'bit clk;' .
    \ s:_set_indent(0) . 'initial begin' .
    \ s:_set_indent(&shiftwidth) . 'forever #(`SYS_CLK_PERIOD/2) clk = ~clk;' .
    \ s:_set_indent(-&shiftwidth) . 'end' .
    \ s:_set_indent(0) . interface_inst_str . '' .
    \ s:_set_indent(0) . 'initial begin' .
    \ s:_set_indent(&shiftwidth) . config_db_interface_str . '' .
    \ s:_set_indent(0) . 'run_test();' .
    \ s:_set_indent(-&shiftwidth) . 'end' .
    \ s:_set_indent(-&shiftwidth) . 'endmodule'

  exe 'normal ggi' . str
  w

  return 1
endfunction

"#######################################################################################

"-------------------------------------------------------------------------------
" Function : agent_skalaton
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_scalaton#agent_skalaton()
  call debug#debug#log('function! sv#uvm#uvm_scalaton#agent_skalaton()')

  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  let agent = s:AgentDatabase.new({"file": expand('%:p'), "env_path": expand('%:p:h:h')})

  if (agent.skalaton())
    call agent.monitor.skalaton()
    call agent.driver.skalaton()
    call agent.sequencer.skalaton()
    call agent.config.skalaton()

    call agent.package()
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : env_skalaton
"-------------------------------------------------------------------------------
function! sv#uvm#uvm_scalaton#env_skalaton()
  call debug#debug#ftouch()

  call debug#debug#log('function! sv#uvm#uvm_scalaton#env_skalaton()')

  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  let s:env_o = deepcopy(s:EnvDatabase)

  "-------------------------------------------------------------------------------
  " ENV CONFIG
  let s:env_o.options.interactive = 1
  "-------------------------------------------------------------------------------

  call s:env_o.parse_env()


  if (s:env_o.env_skalaton())
    let prefix = s:env_o.prefix


    call s:env_o.config.skalaton()
    call s:env_o.virtual_sequencer.skalaton()
    call s:env_o.new_env_pkg(s:env_o.this . "_pkg.sv")
    call s:env_o.new_defines(prefix . '_defines.sv')

    let pkg_sequences = []
    " Base Sequence for agent
    let base_seq_arg = {'file': printf('%s/sequences/%s_base_seq.sv', s:env_o.path, prefix), 'prefix': prefix, 'parameters': {'req_seq_item': 'uvm_sequence_item', 'rsp_seq_item': 'uvm_sequence_item'}}
    let base_seq = s:SequenceDatabase.new(base_seq_arg)
    call base_seq.skalaton()

    let pkg_sequences += [base_seq_arg.file]

    let sequences = []
    for l:agent in map(deepcopy(s:env_o.agents), 'v:val')
      " Base Sequence for agent
      let agent_base_seq_arg = {'file': printf('%s/sequences/%s_base_seq.sv', s:env_o.path, l:agent.agent.prefix), 'prefix': l:agent.agent.prefix, 'req_seq_item': l:agent.agent.req_seq_item, 'rsp_seq_item': l:agent.agent.rsp_seq_item, 'base_seq': base_seq}
      let agent_base_seq = s:SequenceDatabase.new(agent_base_seq_arg)
      call agent_base_seq.skalaton()

      let pkg_sequences += [agent_base_seq_arg.file]

      " Sanity Sequence for agent
      let agent_sanity_seq_arg = {'file': printf('%s/sequences/%s_sanity_seq.sv', s:env_o.path, l:agent.agent.prefix), 'prefix': l:agent.agent.prefix, 'req_seq_item': l:agent.agent.req_seq_item, 'rsp_seq_item': l:agent.agent.rsp_seq_item, 'base_seq': agent_base_seq, 'sequencer': l:agent.agent.sequencer}
      let agent_sanity_seq_o = s:SequenceDatabase.new(agent_sanity_seq_arg)
      call agent_sanity_seq_o.skalaton()
      let sequences += [extend(l:agent, {'sequence': agent_sanity_seq_o})]

    endfor

    let pkg_sequences += map(deepcopy(sequences), 'v:val.sequence.file')

    " Virtual Sequence
    let vir_seq_arg = {'file': printf('%s/sequences/%s_virtual_seq.sv', s:env_o.path, prefix), 'prefix': prefix, 'sub_sequences': sequences, 'sequencer': s:env_o.virtual_sequencer, 'base_seq': base_seq}
    let vir_seq = s:SequenceDatabase.new(vir_seq_arg)
    call vir_seq.skalaton()

    let pkg_sequences += [vir_seq_arg.file]

    let pkg_tests = []

    " Base Testcase
    let base_test_arg = {'file': printf('%s/tests/%s_test_base.sv', s:env_o.path, prefix), 'env': s:env_o}
    let s:base_test = s:TestDatabase.new(base_test_arg)
    call s:base_test.skalaton()

    let pkg_tests += [base_test_arg.file]

    " Sanity Testcase
    let sanity_test_arg = {'file': printf('%s/tests/%s_test_sanity.sv', s:env_o.path, prefix), 'env': s:env_o, 'sanity_seq': vir_seq}
    let sanity_test = s:TestDatabase.new(sanity_test_arg)
    call sanity_test.skalaton()

    let pkg_tests += [sanity_test_arg.file]

    " Sequence Package
    let seq_pkg_arg = {'seq_pkg_file': printf('%s/sequences/%s_seq_pkg.sv', s:env_o.path, prefix), 'sequences': pkg_sequences}
    call s:env_o.seq_package(seq_pkg_arg)

    " Test Package
    let test_pkg_arg = {'test_pkg_file': printf('%s/tests/%s_test_pkg.sv', s:env_o.path, prefix), 'tests': pkg_tests, 'seq_pkg_file': seq_pkg_arg.seq_pkg_file}
    call s:env_o.test_package(test_pkg_arg)

    " tb_top
    let tb_top_arg = {'test_pkg_file': printf('%s/tests/%s_test_pkg.sv', s:env_o.path, prefix), 'tb_top_file': printf('%s/%s_tb_top.sv', s:env_o.path, prefix)}
    call s:env_o.tb_top(tb_top_arg)

  endif
endfunction





















