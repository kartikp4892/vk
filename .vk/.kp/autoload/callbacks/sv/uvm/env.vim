let callbacks#sv#uvm#env#Callback = {'declaration': '', 'build_phase': {'declaration': '', 'body': ''}, 'connect_phase': {'declaration': '', 'body': ''}}
"-------------------------------------------------------------------------------
" Function : new
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#env#Callback.new()
  let this = deepcopy(g:callbacks#sv#uvm#env#Callback)

  call this.SetDefault()

  return this
endfunction

"-------------------------------------------------------------------------------
" Function : SetDefault
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#env#Callback.SetDefault() dict
  call self.SetDefaultMember()
  call self.SetDefaultBuildPhase() 
  call self.SetDefaultConnectPhase() 
endfunction

"-------------------------------------------------------------------------------
" Function : SetDefaultMember
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#env#Callback.SetDefaultMember() dict
  let self.declaration = ''
endfunction

"-------------------------------------------------------------------------------
" Function : SetDefaultBuildPhase
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#env#Callback.SetDefaultBuildPhase() dict
  let self.build_phase['declaration'] = ''
  let self.build_phase['body'] = ''
endfunction

"-------------------------------------------------------------------------------
" Function : SetDefaultConnectPhase
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#env#Callback.SetDefaultConnectPhase() dict
  let self.connect_phase['declaration'] = ''
  let self.connect_phase['body'] = ''
endfunction

"-------------------------------------------------------------------------------
" Function : Get
" Return the current state of callback and go back to default
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#env#Callback.Get() dict
  let cb = deepcopy(self)

  call self.SetDefault()

  return cb
endfunction

let callbacks#sv#uvm#env#cb = callbacks#sv#uvm#env#Callback.new()







