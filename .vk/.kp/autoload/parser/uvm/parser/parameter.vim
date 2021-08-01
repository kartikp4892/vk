let parser#uvm#parser#parameter#parameter = {}

let s:valid_parameter_types = ['type', 'int', 'integer', 'logic', 'bit', 'string']

"-------------------------------------------------------------------------------
" Function : Parameter.new
"-------------------------------------------------------------------------------
function! parser#uvm#parser#parameter#parameter.new(lexer) dict
  call debug#debug#log(printf("parser#uvm#parser#parameter#parameter.new == %s", string(self.new)))

  let this = deepcopy(self)
  
  let this.parameter_type_ptrn = printf('\v^(%s)$', join(s:valid_parameter_types, '|'))
  let this.parameter_type = ''
  let this.parameter_name = ''
  let this.default_value = ''
  let this.start_pos = g:parser#uvm#null#null
  let this.end_pos = g:parser#uvm#null#null
  let this.cargo = ''
  let this.lexer = a:lexer

  return this
endfunction

"-------------------------------------------------------------------------------
" Function : Parameter.get_default_value
"-------------------------------------------------------------------------------
function! parser#uvm#parser#parameter#parameter.get_default_value() dict
  call debug#debug#log(printf("parser#uvm#parser#parameter#parameter.get_default_value == %s", string(self.get_default_value)))
  
  if (self.lexer.m_current_keyword.cargo == '=')
    let self.default_value = self.lexer.m_current_keyword.cargo 
    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'

    while m_keyword.cargo !~ '\v^(\)|,)$'

      let self.default_value = self.lexer.m_current_keyword.cargo 
      let self.end_pos = m_keyword.end_pos

      ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
    endwhile
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : Parameter.parse
"-------------------------------------------------------------------------------
function! parser#uvm#parser#parameter#parameter.parse() dict
  call debug#debug#log(printf("parser#uvm#parser#parameter#parameter.parse == %s", string(self.parse)))
  
  let self.start_pos = self.lexer.m_current_keyword.start_pos

  let m_variable = g:Variable.new(a:lexer, '\v^(\)|,)$')

  if (m_variable.parse())
    return 1
  endif

  " || if (self.lexer.m_current_keyword.cargo =~ self.parameter_type_ptrn)
  " ||   if (self.lexer.m_current_keyword.cargo != 'type')
  " ||   endif

  " ||   let self.parameter_type = self.lexer.m_current_keyword.cargo 
  " ||   ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
  " || endif

  " || let self.parameter_name = self.lexer.m_current_keyword.cargo 
  " || ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'

  " || let self.end_pos = m_keyword.end_pos

  " || call self.get_default_value()

  " || ParserExpectKeywordPtrn 'self.lexer.m_current_keyword', '\v^(\)|,)$'

  return 1
endfunction

"-------------------------------------------------------------------------------
" Function : Parameter.string
"-------------------------------------------------------------------------------
function! parser#uvm#parser#parameter#parameter.string(...) dict
  call debug#debug#log(printf("parser#uvm#parser#parameter#parameter.string == %s", string(self.string)))
  
  TVarArg ['indent', 0]

  let indent_str = repeat(' ', indent)

  let str = "<PARAMETERS>\n"
  let str .= printf("%s<parameter_type> %s\n", indent_str, self.parameter_type)
  let str .= printf("%s<parameter_name> %s\n", indent_str, self.parameter_name)
  let str .= printf("%s<default_value> %s\n", indent_str, self.default_value)
  let str .= printf("%s<start_pos> %s\n", indent_str, string(self.start_pos))
  let str .= printf("%s<end_pos> %s\n", indent_str, string(self.end_pos))

  return str
  
endfunction






