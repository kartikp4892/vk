let parser#uvm#keyword#keyword = {}

"-------------------------------------------------------------------------------
" Function : new
"-------------------------------------------------------------------------------
function! parser#uvm#keyword#keyword.new(k, start_pos, end_pos) dict
  call debug#debug#log(printf('parser#uvm#keyword#keyword.new == %s', string(g:parser#uvm#keyword#keyword.new)))

  let this = deepcopy(self)

  let this.cargo = a:k
  let this.start_pos = a:start_pos
  let this.end_pos = a:end_pos

  return this
endfunction

"-------------------------------------------------------------------------------
" Function : string
"-------------------------------------------------------------------------------
function! parser#uvm#keyword#keyword.string() dict
    call debug#debug#log(printf('parser#uvm#keyword#keyword.string == %s', string(g:parser#uvm#keyword#keyword.string)))

    let keyword = self.cargo

    let str = printf("parser#uvm#keyword#keyword %s(begin %s - end %s)", self.cargo, string(self.start_pos) , string(self.end_pos))
    return str
endfunction

"-------------------------------------------------------------------------------
" Function : parser#uvm#keyword#keyword.get
"-------------------------------------------------------------------------------
function! parser#uvm#keyword#keyword.get() dict
  call debug#debug#log(printf("parser#uvm#keyword#keyword.get == %s", string(self.get)))
  
  return {'cargo': self.cargo, 'start_pos': self.start_pos, 'end_pos': self.end_pos}
endfunction





