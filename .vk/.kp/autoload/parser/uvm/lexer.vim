let parser#uvm#lexer#lexer = {}

"-------------------------------------------------------------------------------
" Function : parser#uvm#lexer#lexer.new
"-------------------------------------------------------------------------------
function! parser#uvm#lexer#lexer.new(...) dict
  call debug#debug#log(printf("parser#uvm#lexer#lexer.new == %s", string(self.new)))

  TVarArg ['source_file', expand('%:p')], ['firstline', 1], ['lastline', line('$')]

  let this = deepcopy(self)
  let this.source_file = l:source_file
  let this.m_scanner = g:parser#uvm#scanner#scanner.new(l:source_file, l:firstline, l:lastline)
  let this.m_current_keyword = g:parser#uvm#null#null
  let this.m_prev_keyword = g:parser#uvm#null#null
  " || let this.scanner_restore_stack = []

  return this

endfunction

"-------------------------------------------------------------------------------
" Function : parser#uvm#lexer#lexer.skip_whitespaces
"-------------------------------------------------------------------------------
function! parser#uvm#lexer#lexer.skip_whitespaces() dict
  call debug#debug#log(printf("parser#uvm#lexer#lexer.skip_whitespaces == %s", string(self.skip_whitespaces)))
  
  let m_char = self.m_scanner.get_next_char()

  while m_char != g:parser#uvm#null#null && m_char.cargo =~ '\v(\n|\s|\t)'
    let m_char = self.m_scanner.get_next_char()
  endwhile

  if (m_char == g:parser#uvm#null#null)
    return
  endif

  call self.m_scanner.get_prev_char()
endfunction

"-------------------------------------------------------------------------------
" Function : parser#uvm#lexer#lexer.get_next_keyword
"-------------------------------------------------------------------------------
function! parser#uvm#lexer#lexer.get_next_keyword() dict
  call debug#debug#log(printf("parser#uvm#lexer#lexer.get_next_keyword == %s", string(self.get_next_keyword)))
  
  call self.skip_whitespaces() 

  " || call self.put_scanner_to_stack(self.m_scanner)

  let self.m_prev_keyword = self.m_current_keyword 
  let self.m_current_keyword = self.parse_next_keyword() 

  return self.m_current_keyword 
endfunction

"-------------------------------------------------------------------------------
" Function : parser#uvm#lexer#lexer.parse_next_keyword
"-------------------------------------------------------------------------------
function! parser#uvm#lexer#lexer.parse_next_keyword() dict
  call debug#debug#log(printf("parser#uvm#lexer#lexer.parse_next_keyword == %s", string(self.parse_next_keyword)))

  let keyword = ''
  let m_char = self.m_scanner.get_next_char()

  if (m_char == g:parser#uvm#null#null)
    return g:parser#uvm#null#null
  endif

  let start_pos = m_char.get_pos()
  
  " Macro
  if (m_char.cargo =~ '\v(`|\$)')
    let keyword .= m_char.cargo 

    let m_char = self.m_scanner.get_next_char()

    while m_char != g:parser#uvm#null#null && m_char.cargo =~ '\v\w'
      let keyword .= m_char.cargo 
      let m_char = self.m_scanner.get_next_char()
    endwhile

    if (m_char.cargo == '`')
      echoerr printf('Undefined keyword "%s" at %s', keyword, string(start_pos))
      return
    endif

  " Alphanum
  elseif(m_char.cargo =~ '\v\w')
    let keyword .= m_char.cargo 

    let m_char = self.m_scanner.get_next_char()

    while m_char != g:parser#uvm#null#null && m_char.cargo =~ '\v\w'
      let keyword .= m_char.cargo 
      let m_char = self.m_scanner.get_next_char()
    endwhile

  " String
  elseif (m_char.cargo == '"')
    let keyword .= m_char.cargo 

    let m_char = self.m_scanner.get_next_char()

    while m_char != g:parser#uvm#null#null && m_char.cargo != '"'
      let keyword .= m_char.cargo 
      let m_char = self.m_scanner.get_next_char()
    endwhile

    let keyword .= m_char.cargo 
    let m_char = self.m_scanner.get_next_char()

  " Comment
  elseif (m_char.cargo == '/')

    ParserReturnOnNull 'm_char_n1', 'self.m_scanner.clone_next_char()'

    " example a/b
    if (m_char_n1.cargo != '/' && m_char_n1.cargo != '*')
      let keyword .= m_char.cargo 
      let m_keyword = g:parser#uvm#keyword#keyword.new(keyword , start_pos, start_pos)
      return m_keyword 
    endif

    let comment_id = m_char.cargo
    let m_char = self.m_scanner.get_next_char()
    let comment_id .= m_char.cargo
    let keyword .= comment_id 

    " parser#uvm#line comment
    if (comment_id == '//')
      let m_char = self.m_scanner.get_next_char()

      while m_char.cargo != "\n"
        let keyword .= m_char.cargo  
        let m_char = self.m_scanner.get_next_char()
      endwhile

    " Block comment
    elseif (comment_id == '/*')
      let m_prev_char = self.m_scanner.get_next_char()
      let m_char = self.m_scanner.get_next_char()

      let keyword .= m_prev_char.cargo . m_char.cargo

      let comment_end = m_prev_char.cargo . m_char.cargo

      while comment_end != '*/'
        let m_prev_char = m_char
        let m_char = self.m_scanner.get_next_char()
        let keyword .= m_char.cargo

        let comment_end = m_prev_char.cargo . m_char.cargo
      endwhile

      let m_char = self.m_scanner.get_next_char()
    endif

  " Parameters
  elseif (m_char.cargo == '#')
    let keyword = m_char.cargo 

    ParserReturnOnNull 'm_char_n1', 'self.m_scanner.clone_next_char()'
    if (m_char_n1.cargo == "(")
      ParserReturnOnNull 'm_char', 'self.m_scanner.get_next_char()'
      let keyword .= m_char.cargo 

      ParserReturnOnNull 'm_char', 'self.m_scanner.get_next_char()'
    else
      let m_keyword = g:parser#uvm#keyword#keyword.new(keyword , start_pos, start_pos)
      return m_keyword 
    endif

  elseif (m_char.cargo == ':')
    let keyword = m_char.cargo 

    " --> ::
    ParserReturnOnNull 'm_char_n1', 'self.m_scanner.clone_next_char()'
    if (m_char_n1.cargo == ":")
      ParserReturnOnNull 'm_char', 'self.m_scanner.get_next_char()'
      let keyword .= m_char.cargo 

      ParserReturnOnNull 'm_char', 'self.m_scanner.get_next_char()'
    else
      let m_keyword = g:parser#uvm#keyword#keyword.new(keyword , start_pos, start_pos)
      return m_keyword 
    endif

  else
    let keyword .= m_char.cargo 
    let m_keyword = g:parser#uvm#keyword#keyword.new(keyword , start_pos, start_pos)
    return m_keyword 
  endif

  let m_char = self.m_scanner.get_prev_char()
  let end_pos = m_char.get_pos()

  let m_keyword = g:parser#uvm#keyword#keyword.new(keyword , start_pos, end_pos)

  return m_keyword 
endfunction

"-------------------------------------------------------------------------------
" Function : parser#uvm#lexer#lexer.clone_next_keyword
"-------------------------------------------------------------------------------
function! parser#uvm#lexer#lexer.clone_next_keyword(...) dict
  call debug#debug#log(printf("parser#uvm#lexer#lexer.clone_next_keyword == %s", string(self.clone_next_keyword)))
  
  TVarArg ['offset', 1]

  let this = deepcopy(self)

  for l:idx in range(offset)
    let m_keyword = this.get_next_keyword()
  endfor

  return m_keyword
endfunction


" || "-------------------------------------------------------------------------------
" || " Function : parser#uvm#lexer#lexer.put_scanner_to_stack
" || " Depth - 5
" || "-------------------------------------------------------------------------------
" || function! parser#uvm#lexer#lexer.put_scanner_to_stack(scanner) dict
" ||   call debug#debug#log(printf("parser#uvm#lexer#lexer.put_scanner_to_stack == %s", string(self.put_scanner_to_stack)))
" ||   
" ||   let self.scanner_restore_stack = [deepcopy(a:scanner)] + self.scanner_restore_stack 
" ||   if (len(self.scanner_restore_stack) > 5)
" ||     let self.scanner_restore_stack = self.scanner_restore_stack[0:4]
" ||   endif
" || endfunction
" || 
" || "-------------------------------------------------------------------------------
" || " Function : parser#uvm#lexer#lexer.get_prev_keyword
" || "-------------------------------------------------------------------------------
" || function! parser#uvm#lexer#lexer.get_prev_keyword() dict
" ||   call debug#debug#log(printf("parser#uvm#lexer#lexer.get_prev_keyword == %s", string(self.get_prev_keyword)))
" ||   
" ||   if (len(self.scanner_restore_stack) == 1)
" ||     return g:parser#uvm#null#null
" ||   endif
" || 
" ||   let self.scanner_restore_stack = self.scanner_restore_stack[1:4]
" ||   let self.m_scanner = self.scanner_restore_stack[0]
" || 
" ||   return self.parse_next_keyword()
" || endfunction








