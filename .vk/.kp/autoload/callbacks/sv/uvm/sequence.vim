let callbacks#sv#uvm#sequence#Callback = {'declaration': '', 'base_seq': 'uvm_sequence', 'parameter': printf("#(%s)", g:sv#glob_var#seq_item), 'fun_declaration': ''}
"-------------------------------------------------------------------------------
" Function : new
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#sequence#Callback.new()
  let this = deepcopy(g:callbacks#sv#uvm#sequence#Callback)

  call this.SetDefault()

  return this
endfunction

"-------------------------------------------------------------------------------
" Function : SetDefault
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#sequence#Callback.SetDefault() dict
  call self.SetDefaultMember()
  call self.SetDefaultParameter() 
  call self.SetDefaultBaseSeq() 
  call self.SetDefaultFunDeclaration() 
endfunction

"-------------------------------------------------------------------------------
" Function : SetDefaultBaseSeq
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#sequence#Callback.SetDefaultFunDeclaration() dict
  let fname = expand('%:p:t')

  if (fname =~ '\v_(seq%[uence]_base|base_seq%[uence])')
    let self.fun_declaration = sv#uvm#uvm_phases#pre_body() . ''
    let self.fun_declaration .= sv#uvm#uvm_phases#post_body() . ''
  else
    let self.fun_declaration = ''
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : SetDefaultBaseSeq
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#sequence#Callback.SetDefaultBaseSeq() dict
  let self.base_seq ='uvm_sequence' 
endfunction

"-------------------------------------------------------------------------------
" Function : SetDefaultMember
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#sequence#Callback.SetDefaultMember() dict
  let self.declaration = ''
endfunction

"-------------------------------------------------------------------------------
" Function : SetDefaultParameter
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#sequence#Callback.SetDefaultParameter() dict
  let self.parameter = printf("#(%s)", g:sv#glob_var#seq_item)
endfunction

"-------------------------------------------------------------------------------
" Function : Get
" Return the current state of callback and go back to default
"-------------------------------------------------------------------------------
function! callbacks#sv#uvm#sequence#Callback.Get() dict
  let cb = deepcopy(self)

  call self.SetDefault()

  return cb
endfunction

let callbacks#sv#uvm#sequence#cb = callbacks#sv#uvm#sequence#Callback.new()







