let parser#uvm#scanner#scanner = {}

"-------------------------------------------------------------------------------
" Function : init
"-------------------------------------------------------------------------------
function! parser#uvm#scanner#scanner.new(source_file, ...) dict

  call debug#debug#log(printf('parser#uvm#scanner#scanner.new == %s', string(g:parser#uvm#scanner#scanner.new)))

  let this = deepcopy(self)
  let this.source_file = a:source_file

  call this.buff_set()

  TVarArg ['firstline', 1], ['lastline', line('$')]

  let this.line_idx = l:firstline
  let this.firstline = l:firstline
  let this.lastline = l:lastline
  let this.m_line = g:parser#uvm#line#line.new(this.line_idx)

  return this

endfunction

"-------------------------------------------------------------------------------
" Function : __next_line__
"-------------------------------------------------------------------------------
function! parser#uvm#scanner#scanner.__next_line__() dict
  call debug#debug#log(printf('parser#uvm#scanner#scanner.__next_line__ == %s', string(g:parser#uvm#scanner#scanner.__next_line__)))

  if (self.line_idx != self.lastline)
    let self.line_idx += 1
    let self.m_line = g:parser#uvm#line#line.new(self.line_idx)

    return 1
  endif

  return 0
endfunction

"-------------------------------------------------------------------------------
" Function : __prev_line__
"-------------------------------------------------------------------------------
function! parser#uvm#scanner#scanner.__prev_line__() dict
  call debug#debug#log(printf('parser#uvm#scanner#scanner.__prev_line__ == %s', string(g:parser#uvm#scanner#scanner.__prev_line__)))

  if (self.line_idx != self.firstline)
    let self.line_idx -= 1
    let self.m_line = g:parser#uvm#line#line.new(self.line_idx, 1)

    return 1
  endif

  return 0
endfunction

"-------------------------------------------------------------------------------
" Function : buff_set
"-------------------------------------------------------------------------------
function! parser#uvm#scanner#scanner.buff_set() dict
  call debug#debug#log(printf('parser#uvm#scanner#scanner.buff_set == %s', string(g:parser#uvm#scanner#scanner.buff_set)))

  let self.restore = tlib#buffer#Set(self.source_file)

endfunction

"-------------------------------------------------------------------------------
" Function : buff_restore
"-------------------------------------------------------------------------------
function! parser#uvm#scanner#scanner.buff_restore() dict
  call debug#debug#log(printf('parser#uvm#scanner#scanner.buff_restore == %s', string(g:parser#uvm#scanner#scanner.buff_restore)))
  exec self.restore
endfunction

"-------------------------------------------------------------------------------
" Function : get_next_char
" Return the next character of the source text
"-------------------------------------------------------------------------------
function! parser#uvm#scanner#scanner.get_next_char() dict
  call debug#debug#log(printf('parser#uvm#scanner#scanner.get_next_char == %s', string(g:parser#uvm#scanner#scanner.get_next_char)))

  while (self.m_line.eol())
    if (!self.__next_line__())
      call self.buff_restore()

      return g:parser#uvm#null#null
    endif
  endwhile

  return self.m_line.get_next_char()
endfunction

"-------------------------------------------------------------------------------
" Function : clone_next_char
" Return the next character of the source text
"-------------------------------------------------------------------------------
function! parser#uvm#scanner#scanner.clone_next_char() dict
  call debug#debug#log(printf('parser#uvm#scanner#scanner.clone_next_char == %s', string(g:parser#uvm#scanner#scanner.clone_next_char)))

  let this = deepcopy(self)

  while (this.m_line.eol())
    if (!this.__next_line__())
      call this.buff_restore()

      return g:parser#uvm#null#null
    endif
  endwhile

  return this.m_line.get_next_char()
endfunction

"-------------------------------------------------------------------------------
" Function : get_prev_char
" Return the next character of the source text
"-------------------------------------------------------------------------------
function! parser#uvm#scanner#scanner.get_prev_char() dict
  call debug#debug#log(printf('parser#uvm#scanner#scanner.get_prev_char == %s', string(g:parser#uvm#scanner#scanner.get_prev_char)))

  if (self.m_line.bol())
    if (!self.__prev_line__())
      call self.buff_restore()

      return self.m_line.get_prev_char()
    endif
  endif

  return self.m_line.get_prev_char()
endfunction






