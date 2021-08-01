let parser#uvm#line#line = {}

"-------------------------------------------------------------------------------
" Function : new
"-------------------------------------------------------------------------------
function! parser#uvm#line#line.new(line_idx, ...) dict
  call debug#debug#log(printf('parser#uvm#line#line.new == %s', string(g:parser#uvm#line#line.new)))

  TVarArg ['reverse_init_cidx', 0]

  let this = deepcopy(self)

  if (a:line_idx < 1 || a:line_idx > line('$'))
    call tlib#notify#Echo('Unknown line index!!!', 'Error')
    return g:parser#uvm#null#null
  endif
  let this.cargo = printf("%s\n", getline(a:line_idx))
  let this.len = len(this.cargo)

  if (l:reverse_init_cidx)
    let this.col_idx = this.len
  else
    let this.col_idx = -1
  endif

  let this.line_idx = a:line_idx

  return this
endfunction

"-------------------------------------------------------------------------------
" Function : eol
"-------------------------------------------------------------------------------
function! parser#uvm#line#line.eol() dict
  call debug#debug#log(printf('parser#uvm#line#line.eol == %s', string(g:parser#uvm#line#line.eol)))

  if (self.len == 0)
    call debug#debug#log( 'EOL NULL')
    return 1
  endif

  let eol = self.col_idx == (self.len - 1)

  if (eol)
      call debug#debug#log( printf('EOF %s', self.string()))
  endif

  return eol
endfunction

"-------------------------------------------------------------------------------
" Function : bol
"-------------------------------------------------------------------------------
function! parser#uvm#line#line.bol() dict
  call debug#debug#log(printf('parser#uvm#line#line.bol == %s', string(g:parser#uvm#line#line.bol)))

  if (self.len == 0)
    call debug#debug#log( 'BOL NULL')
    return 1
  endif

  let bol = self.col_idx <= 0

  if (bol)
      call debug#debug#log( printf('BOF %s', self.string()))
  endif

  return bol
endfunction

"-------------------------------------------------------------------------------
" Function : get_next_char
" return char object
"-------------------------------------------------------------------------------
function! parser#uvm#line#line.get_next_char() dict
  call debug#debug#log(printf('parser#uvm#line#line.get_next_char == %s', string(g:parser#uvm#line#line.get_next_char)))

  if (self.eol())
    echoerr 'End Of parser#uvm#line#line Reached!!!'
    return g:parser#uvm#null#null
    "call tlib#notify#Echo('End Of parser#uvm#line#line Reached!!!', 'Error')
  endif

  let self.col_idx += 1

  let c = self.cargo[self.col_idx]
  let self.m_char = g:parser#uvm#char#char.new(c, self.line_idx, self.col_idx)
  return self.m_char
endfunction

"-------------------------------------------------------------------------------
" Function : get_prev_char
" return char object
"-------------------------------------------------------------------------------
function! parser#uvm#line#line.get_prev_char() dict
  call debug#debug#log(printf('parser#uvm#line#line.get_prev_char == %s', string(g:parser#uvm#line#line.get_prev_char)))

  if (self.bol())
    let self.col_idx = -1
    return g:parser#uvm#null#null
    "call tlib#notify#Echo('End Of parser#uvm#line#line Reached!!!', 'Error')
  endif

  let self.col_idx -= 1

  let c = self.cargo[self.col_idx]
  let self.m_char = g:parser#uvm#char#char.new(c, self.line_idx, self.col_idx)
  return self.m_char
endfunction

"-------------------------------------------------------------------------------
" Function : string
"-------------------------------------------------------------------------------
function! parser#uvm#line#line.string() dict
  call debug#debug#log(printf('parser#uvm#line#line.string == %s', string(g:parser#uvm#line#line.string)))

  if (exists('self.cargo'))
    let cargo = self.cargo
  else
    let cargo = '###NULL###'
  endif

  if (exists('self.m_char'))
    let m_char = self.m_char.string()
  else
    let m_char = '###NULL###'
  endif

  let str = printf('%s, parser#uvm#line#line %s', m_char, cargo)

  return str
endfunction







