let parser#uvm#parser#variable#inbuilt_datatype#inbuilt_datatype = {}

let s:datatypes = ['enum', 'type', 'int', 'string', 'bit', 'byte', 'integer', 'logic']

"-------------------------------------------------------------------------------
" Function : InbuiltDatatype.new
"-------------------------------------------------------------------------------
function! parser#uvm#parser#variable#inbuilt_datatype#inbuilt_datatype.new(lexer, ...) dict
  call debug#debug#log(printf("parser#uvm#parser#variable#inbuilt_datatype#inbuilt_datatype.new == %s", string(self.new)))

  let this = deepcopy(self)

  let this.default_end_ptrn = '\v^(;|,)$'

  TVarArg ['end_ptrn', this.default_end_ptrn], ['variable_continue', 0]
  
  let this.end_ptrn = end_ptrn

  let this.datatype_ptrn = printf('\v^(%s)$', join(s:datatypes, "|"))
  let this.lexer = a:lexer
  let this.variable_type = ''
  let this.datatype = ''
  let this.subdatatype = ''
  let this.variable_name = ''
  let this.unpacked_range = ''
  let this.packed_range = ''
  let this.enum_range = ''
  let this.cargo = ''
  let this.start_pos = g:parser#uvm#null#null
  let this.end_pos = g:parser#uvm#null#null
  let this.init_value = ''
  let this.accesibility = ''
  let this.typedef = ''
  let this.variable_continue = variable_continue " ex: int a,b --> datatype of b is int

  return this
endfunction

"-------------------------------------------------------------------------------
" Function : InbuiltDatatype.parse_range
"-------------------------------------------------------------------------------
function! parser#uvm#parser#variable#inbuilt_datatype#inbuilt_datatype.parse_range() dict
  call debug#debug#log(printf("parser#uvm#parser#variable#inbuilt_datatype#inbuilt_datatype.parse_range == %s", string(self.parse_range)))

  " Comment
  ParserReturnOnNull 'm_keyword', 'self.lexer.m_current_keyword'
  if (self.lexer.m_current_keyword.cargo =~ '\v^(\/\/|\/\*)')
    return 0
  endif
  
  if (m_keyword.cargo == '[')
    let range_str = ''

    let range_str .= printf('%s ', m_keyword.cargo)

    while m_keyword.cargo != ']'
      ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
      let self.cargo .= printf('%s ', m_keyword.cargo)

      let range_str .= printf('%s ', m_keyword.cargo)
    endwhile

    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
    let self.cargo .= printf('%s ', m_keyword.cargo)

    return range_str
  endif

  return ''
endfunction

function! parser#uvm#parser#variable#inbuilt_datatype#inbuilt_datatype.parse_enum() dict
  call debug#debug#log(printf("parser#uvm#parser#variable#inbuilt_datatype#inbuilt_datatype.parse_enum == %s", string(self.parse_enum)))
  
  ParserReturnOnNull 'm_keyword', 'self.lexer.m_current_keyword'
  if (m_keyword.cargo == 'enum')
    
    let self.datatype = m_keyword.cargo 

    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
    if (m_keyword.cargo == 'bit')
      let self.subdatatype = m_keyword.cargo 

      ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
    endif
  endif

  let self.cargo .= printf('%s ', m_keyword.cargo)

  let str = self.parse_range()
  let self.unpacked_range = str

  while str != ''
    let str = self.parse_range()
    let self.unpacked_range .= str
  endwhile

  ParserReturnOnNull 'm_keyword', 'self.lexer.m_current_keyword'

  ParserExpectKeyword 'm_keyword', '{', 0, 'parser/variable/inbuilt_datatype.vim', '100'

  if (m_keyword.cargo == '{')
    let self.enum_range = m_keyword.cargo
    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'

    while m_keyword.cargo != '}'
      let self.enum_range .= printf(' %s', m_keyword.cargo)
      ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
    endwhile

    let self.enum_range = m_keyword.cargo
    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
  endif

  ParserExpectKeywordPtrn 'm_keyword', '\v^\w+$', 0, 'parser/variable/inbuilt_datatype.vim', '115'
  let self.variable_name = m_keyword.cargo

  ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'

  let self.end_pos = self.lexer.m_prev_keyword.end_pos

endfunction

"-------------------------------------------------------------------------------
" Function : InbuiltDatatype.parse
"-------------------------------------------------------------------------------
function! parser#uvm#parser#variable#inbuilt_datatype#inbuilt_datatype.parse() dict
  call debug#debug#log(printf("parser#uvm#parser#variable#inbuilt_datatype#inbuilt_datatype.parse == %s", string(self.parse)))
  
  ParserReturnOnNull 'm_keyword', 'self.lexer.m_current_keyword'
  ParserReturnOnNull 'm_keyword_n1', 'self.lexer.clone_next_keyword()'
  ParserReturnOnNull 'm_keyword_p1', 'self.lexer.m_prev_keyword'

  if (m_keyword.cargo !~ self.datatype_ptrn) && (m_keyword.cargo !~ '\v^(rand|const|typedef|local|protected|public)$' || m_keyword_n1.cargo !~ self.datatype_ptrn)
    if (self.variable_continue == 0)
      return 0
    endif
  endif

  let is_continue = 0
  if (m_keyword_p1.cargo == ',')
    let is_continue = 1
  endif

  let self.cargo = ''

  let self.cargo .= printf('%s ', m_keyword.cargo)

  let self.start_pos = m_keyword.start_pos

  if (m_keyword.cargo =~ '\v^(typedef)$')
    let self.typedef = m_keyword.cargo 

    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
    let self.cargo .= printf('%s ', m_keyword.cargo)
  endif

  if (m_keyword.cargo =~ '\v^(local|protected|public)$')
    let self.accesibility = m_keyword.cargo 

    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
    let self.cargo .= printf('%s ', m_keyword.cargo)
  endif

  if (m_keyword.cargo =~ '\v^(rand|const)$')
    let self.variable_type = m_keyword.cargo 

    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
    let self.cargo .= printf('%s ', m_keyword.cargo)
  endif

  if (is_continue == 0)
    ParserExpectKeywordPtrn 'm_keyword', self.datatype_ptrn, 0, 'parser/variable/inbuilt_datatype.vim', '88'

    if (m_keyword.cargo == 'enum')
      call self.parse_enum()
      return 1
    endif
  endif
  let self.datatype = m_keyword.cargo 

  ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
  let self.cargo .= printf('%s ', m_keyword.cargo)

  let str = self.parse_range()
  let self.unpacked_range = str

  while str != ''
    let str = self.parse_range()
    let self.unpacked_range .= str
  endwhile

  ParserReturnOnNull 'm_keyword', 'self.lexer.m_current_keyword'

  " datatype is decided by previous variable datatype: ex: (bit a,b)
  if (is_continue == 1 && (m_keyword.cargo =~ self.end_ptrn || m_keyword.cargo =~ '^\v(\=)$'))
    let self.variable_name = self.datatype 
    let self.datatype = ''

    let m_init = g:parser#uvm#parser#variable#initialization#initialization.new(self.lexer, self.end_ptrn)
    
    if (m_init.parse())
      let self.init_value = m_init.cargo
      let self.cargo .= self.init_value 
    endif

    ParserReturnOnNull 'm_keyword', 'self.lexer.m_current_keyword'

    ParserExpectKeywordPtrn 'm_keyword', self.end_ptrn, '0', 'parser/variable/inbuilt_datatype.vim', '120'
    let self.end_pos = self.lexer.m_prev_keyword.end_pos

    return 1
  else
    ParserExpectKeywordPtrn 'm_keyword', '\v^(\w+)$', '0', 'parser/variable/inbuilt_datatype.vim', '108'
    let self.variable_name = m_keyword.cargo
  endif

  ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
  let self.cargo .= printf('%s ', m_keyword.cargo)

  let str = self.parse_range()
  let self.packed_range = str

  while str != ''
    let str = self.parse_range()
    let self.packed_range .= str

  endwhile

  let m_init = g:parser#uvm#parser#variable#initialization#initialization.new(self.lexer, self.end_ptrn)
  
  if (m_init.parse())
    let self.init_value = m_init.cargo
    let self.cargo .= self.init_value 
  endif

  let self.end_pos = self.lexer.m_prev_keyword.end_pos

  " || ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'

  " || ParserExpectKeywordPtrn 'self.lexer.m_current_keyword', self.end_ptrn , 0, 'parser/variable/inbuilt_datatype.vim', '132'

  return 1
endfunction

"-------------------------------------------------------------------------------
" Function : InbuiltDatatype.string
"-------------------------------------------------------------------------------
function! parser#uvm#parser#variable#inbuilt_datatype#inbuilt_datatype.string(...) dict
  call debug#debug#log(printf("parser#uvm#parser#variable#inbuilt_datatype#inbuilt_datatype.string == %s", string(self.string)))
  
  TVarArg ['indent', 0]
  
  let indent_str = repeat(' ', indent)

  let str = printf("%s<builtin variable>\n", indent_str)
  let str .= printf("%s<variable_type>%s\n", indent_str, self.variable_type)
  let str .= printf("%s<datatype>%s\n", indent_str, self.datatype)
  let str .= printf("%s<packed_range>%s\n", indent_str, self.packed_range)
  let str .= printf("%s<variable_name>%s\n", indent_str, self.variable_name)
  let str .= printf("%s<unpacked_range>%s\n", indent_str, self.unpacked_range)
  let str .= printf("%s<init_value>%s\n", indent_str, self.init_value)
  let str .= printf("%s<cargo>%s\n", indent_str, self.cargo)
  let str .= printf("%s<start_pos>%s\n", indent_str, string(self.start_pos))
  let str .= printf("%s<end_pos>%s\n", indent_str, string(self.end_pos))

  return str

endfunction

"-------------------------------------------------------------------------------
" Function : InbuiltDatatype.get_comments
"-------------------------------------------------------------------------------
function! parser#uvm#parser#variable#inbuilt_datatype#inbuilt_datatype.get_comments() dict
  call debug#debug#log(printf("parser#uvm#parser#variable#inbuilt_datatype#inbuilt_datatype.get_comments == %s", string(self.get_comments)))
  
  let var = ''
  if (self.variable_type != '') | let var .= printf('%s ', self.variable_type) | endif
  if (self.datatype != '') | let var .= printf('%s ', self.datatype) | endif
  if (self.unpacked_range != '') | let var .= printf('%s ', self.unpacked_range) | endif
  if (self.variable_name != '') | let var .= printf('%s ', self.variable_name) | endif
  if (self.packed_range != '') | let var .= printf('%s ', self.packed_range) | endif

  if (self.init_value != '')
    let cmt = printf('%s[ default := %s]', var, self.init_value)
  else
    let cmt = printf('%s', var)
  endif

  return cmt
endfunction



