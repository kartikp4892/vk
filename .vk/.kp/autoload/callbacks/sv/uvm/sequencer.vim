"-------------------------------------------------------------------------------
" _set_indent: Function
"-------------------------------------------------------------------------------
function! s:_set_indent(offset)
  return '=common#indent#imode_set_indent(' . a:offset . ')'
endfunction

let s:default = {'declaration': '', 'parameter': printf("#(%s)", g:sv#glob_var#seq_item), 'fun_declaration': '', 'constructor': {'declaration': '', 'body': ''}, 'build_phase': {'declaration': '', 'body': ''}, 'connect_phase': {'declaration': '', 'body': ''}, 'temporary': {}}
let s:interface = ''

let callbacks#sv#uvm#sequencer#Callback = deepcopy(s:default)
"-------------------------------------------------------------------------------
" Function : new
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#sequencer#Callback.new()
  let this = deepcopy(g:callbacks#sv#uvm#sequencer#Callback)

  call this.SetDefault()

  return this
endfunction

"-------------------------------------------------------------------------------
" Function : is_default
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#sequencer#Callback.is_default() dict
  if (self.declaration == s:default.declaration &&
    \ self.build_phase == s:default.build_phase &&
    \ self.connect_phase == s:default.connect_phase &&
    \ self.parameter == s:default.parameter)
    return 1
  endif
  return 0
endfunction

"-------------------------------------------------------------------------------
" Function : SetDefault
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#sequencer#Callback.SetDefault() dict
  for l:key in keys(s:default)
    let self[l:key] = s:default[l:key]
  endfor

  let self.temporary = {}
endfunction

"-------------------------------------------------------------------------------
" Function : SetTlib
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#sequencer#Callback.SetTlib() dict
  call self.SetTlibDeclaration()
  call self.SetTlibParameter()
  call self.SetTlibBuildPhase() 
  call self.SetTlibConnectPhase() 
endfunction

"-------------------------------------------------------------------------------
" Function : SetTempVars
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#sequencer#Callback.SetTempVars() dict
  call inputsave()

  "-------------------------------------------------------------------------------
  " Seq Item
  let transactions = split(glob('`find . -regextype sed -regex ".*/\w*_\(seq_item\|trans\(action\)\?\).sv"`'), "\n")
  call map (transactions, 'fnamemodify(v:val, ":p:t:r")')
  let self.temporary.req = tlib#input#List('s', 'Sequence Item [Request]', transactions)
  let self.temporary.rsp = tlib#input#List('s', 'Sequence Item [Response]', transactions)
  "-------------------------------------------------------------------------------

  call inputrestore()
endfunction

"-------------------------------------------------------------------------------
" Function : SetTlibDeclaration
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#sequencer#Callback.SetTlibDeclaration() dict
   let self.declaration = s:default.declaration

endfunction

"-------------------------------------------------------------------------------
" Function : SetTlibParameter
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#sequencer#Callback.SetTlibParameter() dict
  if (self.temporary.req == self.temporary.rsp)
    let self.parameter = printf('#(%s)', self.temporary.req)
  else
    let self.parameter = printf('#(%s, %s)', self.temporary.req, self.temporary.rsp)
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : SetTlibBuildPhase
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#sequencer#Callback.SetTlibBuildPhase() dict
  let self.build_phase.body = s:default.build_phase.body
endfunction

"-------------------------------------------------------------------------------
" Function : SetTlibConnectPhase
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#sequencer#Callback.SetTlibConnectPhase() dict
  let self.connect_phase['declaration'] = ''
  let self.connect_phase['body'] = ''
endfunction

"-------------------------------------------------------------------------------
" Function : Get
" Return the current state of callback and go back to default
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#sequencer#Callback.Get() dict
  let cb = deepcopy(self)

  if (cb.is_default())
    call cb.SetTempVars()
    call cb.SetTlib()
  endif

  call self.SetDefault()

  return cb
endfunction

let callbacks#sv#uvm#sequencer#cb = callbacks#sv#uvm#sequencer#Callback.new()







