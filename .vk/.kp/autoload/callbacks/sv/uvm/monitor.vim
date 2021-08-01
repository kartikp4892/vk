"-------------------------------------------------------------------------------
" _set_indent: Function
"-------------------------------------------------------------------------------
function! s:_set_indent(offset)
  return '=common#indent#imode_set_indent(' . a:offset . ')'
endfunction

let s:default = {'declaration': '', 'build_phase': {'declaration': '', 'body': ''}, 'connect_phase': {'declaration': '', 'body': ''}, 'temporary': {}}
let s:interface = ''

let callbacks#sv#uvm#monitor#Callback = deepcopy(s:default)
"-------------------------------------------------------------------------------
" Function : new
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#monitor#Callback.new()
  let this = deepcopy(g:callbacks#sv#uvm#monitor#Callback)

  call this.SetDefault()

  return this
endfunction

"-------------------------------------------------------------------------------
" Function : is_default
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#monitor#Callback.is_default() dict
  if (self.declaration == s:default.declaration &&
    \ self.build_phase == s:default.build_phase &&
    \ self.connect_phase == s:default.connect_phase)
    return 1
  endif
  return 0
endfunction

"-------------------------------------------------------------------------------
" Function : SetDefault
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#monitor#Callback.SetDefault() dict
  for l:key in keys(s:default)
    let self[l:key] = s:default[l:key]
  endfor

  let self.temporary = {}
endfunction

"-------------------------------------------------------------------------------
" Function : SetTlib
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#monitor#Callback.SetTlib() dict
  call self.SetTlibDeclaration()
  call self.SetTlibBuildPhase() 
  call self.SetTlibConnectPhase() 
endfunction

"-------------------------------------------------------------------------------
" Function : SetTempVars
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#monitor#Callback.SetTempVars() dict
  call inputsave()

  let self.temporary.interface = g:sv#uvm#skalaton#interface#db.new({'path': expand('%:p:h:h')})

  "-------------------------------------------------------------------------------
  " Seq Item
  let transactions = split(glob('./**/*.sv'), "\n")
  call filter(transactions, 'v:val =~ ''\v_(seq%[uence]_item|trans%[action])>''')
  call map (transactions, 'fnamemodify(v:val, ":p:t:r")')
  let self.temporary.rsp = tlib#input#List('s', 'Sequence Item [Response]', transactions)
  "-------------------------------------------------------------------------------

  let self.temporary.analysis_port = substitute(expand('%:p:t:r'), '\vmon%[itor]', 'mon', 'g') . '_ap'

  call inputrestore()
endfunction

"-------------------------------------------------------------------------------
" Function : SetTlibDeclaration
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#monitor#Callback.SetTlibDeclaration() dict
   let self.declaration = s:_set_indent(0) . 'uvm_analysis_port #(' . self.temporary.rsp . ') ' . self.temporary.analysis_port  . ';' .
   \ s:_set_indent(0) . printf("virtual %s %s;", self.temporary.interface.this, self.temporary.interface.m_this)

endfunction

"-------------------------------------------------------------------------------
" Function : SetTlibBuildPhase
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#monitor#Callback.SetTlibBuildPhase() dict
  let self.build_phase.body = s:_set_indent(0) . printf('%s = new("%s", this);', self.temporary.analysis_port, self.temporary.analysis_port) .
    \ s:_set_indent(0) . printf('if (!uvm_config_db#(virtual %s)::get(.cntxt(this), .inst_name(""), .field_name("%s"), .value(%s))) begin', self.temporary.interface.this, self.temporary.interface.this, self.temporary.interface.m_this) .
    \ s:_set_indent(&shiftwidth) . printf('`uvm_fatal(get_full_name(), "uvm_config_db #( virtual %s )::get cannot find resource %s!!!")', self.temporary.interface.this, self.temporary.interface.this) .
    \ s:_set_indent(-&shiftwidth) . 'end'

endfunction

"-------------------------------------------------------------------------------
" Function : SetTlibConnectPhase
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#monitor#Callback.SetTlibConnectPhase() dict
  let self.connect_phase['declaration'] = ''
  let self.connect_phase['body'] = ''
endfunction

"-------------------------------------------------------------------------------
" Function : Get
" Return the current state of callback and go back to default
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#monitor#Callback.Get() dict
  let cb = deepcopy(self)

  if (cb.is_default())
    call cb.SetTempVars()
    call cb.SetTlib()
  endif

  call self.SetDefault()

  return cb
endfunction

let callbacks#sv#uvm#monitor#cb = callbacks#sv#uvm#monitor#Callback.new()







