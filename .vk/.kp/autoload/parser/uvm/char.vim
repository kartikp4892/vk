let parser#uvm#char#char = {}

"-------------------------------------------------------------------------------
" Function : new
"-------------------------------------------------------------------------------
function! parser#uvm#char#char.new(c, line_num, col_num) dict
  call debug#debug#log(printf('parser#uvm#char#char.new == %s', string(g:parser#uvm#char#char.new)))

  let this = deepcopy(self)

  let this.cargo = a:c
  let this.line_num = a:line_num
  let this.col_num = a:col_num

  return this
endfunction

"-------------------------------------------------------------------------------
" Function : string
"-------------------------------------------------------------------------------
function! parser#uvm#char#char.string() dict
    call debug#debug#log(printf('parser#uvm#char#char.string == %s', string(g:parser#uvm#char#char.string)))

    let char = self.cargo

    if (char == ' ')
      let char = 'SPACE'
    endif

    let col = self.col_num + 1

    let str = printf("Character %s", strtrans(string(self)))
    return str
endfunction

"-------------------------------------------------------------------------------
" Function : parser#uvm#char#char.get_pos
"-------------------------------------------------------------------------------
function! parser#uvm#char#char.get_pos() dict
  call debug#debug#log(printf("parser#uvm#char#char.get_pos == %s", string(self.get_pos)))
  return [self.line_num , self.col_num ]
endfunction



