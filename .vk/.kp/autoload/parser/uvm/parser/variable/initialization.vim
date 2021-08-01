let parser#uvm#parser#variable#initialization#initialization = {}

"-------------------------------------------------------------------------------
" Function : parser#uvm#parser#variable#initialization#initialization.new
"-------------------------------------------------------------------------------
function! parser#uvm#parser#variable#initialization#initialization.new(lexer, ...) dict
  call debug#debug#log(printf("parser#uvm#parser#variable#initialization#initialization.new == %s", string(self.new)))

  let this = deepcopy(self)

  let this.default_end_ptrn = '\v^;$'

  TVarArg ['end_ptrn', this.default_end_ptrn]
  
  let this.end_ptrn = end_ptrn

  let this.cargo = ''
  let this.lexer = a:lexer
  let this.start_pos = g:parser#uvm#null#null
  let this.end_pos = g:parser#uvm#null#null
  
  return this
endfunction

"-------------------------------------------------------------------------------
" Function : Initialization.parse_range
"-------------------------------------------------------------------------------
function! parser#uvm#parser#variable#initialization#initialization.parse_range() dict
  call debug#debug#log(printf("parser#uvm#parser#variable#initialization#initialization.parse_range == %s", string(self.parse_range)))
  
  ParserReturnOnNull 'm_keyword', 'self.lexer.m_current_keyword'

  if (m_keyword.cargo == '{')

    while m_keyword.cargo != '}'
      ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
      let self.cargo .= printf('%s ', m_keyword.cargo)

      call self.parse_range()
    endwhile

    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
    let self.cargo .= printf('%s ', m_keyword.cargo)

    return 1
  endif

  return 0
endfunction

"-------------------------------------------------------------------------------
" Function : Initialization.parse
"-------------------------------------------------------------------------------
function! parser#uvm#parser#variable#initialization#initialization.parse() dict
  call debug#debug#log(printf("parser#uvm#parser#variable#initialization#initialization.parse == %s", string(self.parse)))
  
  ParserReturnOnNull 'm_keyword', 'self.lexer.m_current_keyword'

  if (m_keyword.cargo == '=')
    let self.start_pos = m_keyword.start_pos

    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
    let self.cargo .= printf('%s ', m_keyword.cargo)

    while 1
      let ret = self.parse_range()

      if (self.lexer.m_current_keyword.cargo =~ self.end_ptrn)
        break
      endif

      ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'

      if (self.lexer.m_current_keyword.cargo =~ self.end_ptrn)
        break
      endif

      let self.cargo .= printf('%s ', m_keyword.cargo)

      let self.end_pos = self.lexer.m_current_keyword.end_pos

    endwhile

    return 1
  endif

  return 0
endfunction


