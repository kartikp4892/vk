let parser#uvm#parser#variable#user_datatype#user_datatype = {}

let s:datatypes = []

let s:reserved_a = ['class', 'endclass', 'function', 'endfunction', 'task', 'endtask', 'constraint', 'extends', 'begin', 'end', 'package', 'endpackage', 'input', 'output', 'inout', 'clocking', 'endclocking', 'posedge', 'negedge']

"-------------------------------------------------------------------------------
" Function : UserDatatype.new
"-------------------------------------------------------------------------------
function! parser#uvm#parser#variable#user_datatype#user_datatype.new(lexer, ...) dict
  call debug#debug#log(printf("parser#uvm#parser#variable#user_datatype#user_datatype.new == %s", string(self.new)))

  let this = deepcopy(self)
  
  let this.default_end_ptrn = '\v^(;|,)$'

  TVarArg ['end_ptrn', this.default_end_ptrn], ['variable_continue', 0]
  
  let this.end_ptrn = end_ptrn

  let this.datatype_ptrn = '\v^\w+$'
  let this.lexer = a:lexer
  let this.variable_type = ''
  let this.datatype = ''
  let this.variable_name = ''
  let this.unpacked_range = ''
  let this.packed_range = ''
  let this.cargo = ''
  let this.parameter = ''
  let this.typedef = ''
  let this.accesibility = ''
  let this.start_pos = g:parser#uvm#null#null
  let this.end_pos = g:parser#uvm#null#null
  let this.init_value = ''
  let this.variable_continue = variable_continue

  return this
endfunction

"-------------------------------------------------------------------------------
" Function : UserDatatype.copy
"-------------------------------------------------------------------------------
function! parser#uvm#parser#variable#user_datatype#user_datatype.copy(this) dict
  call debug#debug#log(printf("parser#uvm#parser#variable#user_datatype#user_datatype.copy == %s", string(self.copy)))
  
  for l:key in keys(a:this)
    if (exists(printf('*%s.copy', self[l:key])))
      
    endif
    let self[l:key] = a:this[l:key]
  endfor
endfunction

"-------------------------------------------------------------------------------
" Function : UserDatatype.parse_range
"-------------------------------------------------------------------------------
function! parser#uvm#parser#variable#user_datatype#user_datatype.parse_range(start_kw, end_kw) dict
  call debug#debug#log(printf("parser#uvm#parser#variable#user_datatype#user_datatype.parse_range == %s", string(self.parse_range)))
  
  ParserReturnOnNull 'm_keyword', 'self.lexer.m_current_keyword'
  if (m_keyword.cargo == a:start_kw)
    let range_str = ''

    let range_str .= printf('%s ', m_keyword.cargo)

    while m_keyword.cargo != a:end_kw
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

"-------------------------------------------------------------------------------
" Function : UserDatatype.__parse__
"-------------------------------------------------------------------------------
function! parser#uvm#parser#variable#user_datatype#user_datatype.__parse__(...) dict
  call debug#debug#log(printf("parser#uvm#parser#variable#user_datatype#user_datatype.__parse__ == %s", string(self.__parse__)))
  
  TVarArg ['create_copy', 0]

  if (create_copy == 1)
    let this = deepcopy(self)
  else
    let this = self
  endif

  ParserReturnOnNull 'm_keyword', 'this.lexer.m_current_keyword'
  if (!empty(filter(deepcopy(s:reserved_a), printf('v:val == "%s"', m_keyword.cargo)))) | return 0 | endif

  ParserReturnOnNull 'm_keyword_n1', 'this.lexer.clone_next_keyword()'
  if (!empty(filter(deepcopy(s:reserved_a), printf('v:val == "%s"', m_keyword_n1.cargo)))) | return 0 | endif

  " Comment
  let m_keyword_p1 = this.lexer.m_prev_keyword

  " ||if (m_keyword_p1 != g:parser#uvm#null#null && m_keyword_p1.cargo =~ '\v^(\/\/|\/\*)')
  " ||  return 0
  " ||endif
  
  " || if (m_keyword_p1 != g:parser#uvm#null#null && !empty(filter(deepcopy(s:reserved_a), printf('v:val == "%s"', m_keyword_p1.cargo)))) | return 0 | endif

  if (m_keyword.cargo !~ '\v^(rand|const|typedef|local|protected|public)$' || m_keyword_n1.cargo !~ this.datatype_ptrn) && (m_keyword.cargo !~ this.datatype_ptrn)
    if (this.variable_continue == 0)
      return 0
    endif
  endif

  " virtual interface xyz_if.xhz_mp m_vif;
  if (m_keyword_p1 != g:parser#uvm#null#null && m_keyword_p1.cargo == '.')
    return 0
  endif

  let is_continue = 0
  if (m_keyword_p1 != g:parser#uvm#null#null && m_keyword_p1.cargo == ',')
    let is_continue = 1
  endif

  let this.cargo = ''

  let this.cargo .= printf('%s ', m_keyword.cargo)

  let this.start_pos = m_keyword.start_pos

  if (m_keyword.cargo =~ '\v^(local|protected|public)$')
    let this.accesibility = m_keyword.cargo 

    ParserReturnOnNull 'm_keyword', 'this.lexer.get_next_keyword()'

    if (!empty(filter(deepcopy(s:reserved_a), printf('v:val == "%s"', m_keyword.cargo)))) | return 0 | endif
    let this.cargo .= printf('%s ', m_keyword.cargo)
  endif

  if (m_keyword.cargo =~ '\v^(typedef)$')
    let this.typedef = m_keyword.cargo 

    ParserReturnOnNull 'm_keyword', 'this.lexer.get_next_keyword()'

    if (!empty(filter(deepcopy(s:reserved_a), printf('v:val == "%s"', m_keyword.cargo)))) | return 0 | endif
    let this.cargo .= printf('%s ', m_keyword.cargo)
  endif

  if (m_keyword.cargo =~ '\v^(rand|const)$')
    let this.variable_type = m_keyword.cargo 

    ParserReturnOnNull 'm_keyword', 'this.lexer.get_next_keyword()'

    if (!empty(filter(deepcopy(s:reserved_a), printf('v:val == "%s"', m_keyword.cargo)))) | return 0 | endif
    let this.cargo .= printf('%s ', m_keyword.cargo)
  endif

  if (m_keyword.cargo =~ this.datatype_ptrn)
    let this.datatype = m_keyword.cargo 

  endif

  ParserReturnOnNull 'm_keyword', 'this.lexer.get_next_keyword()'
  if (!empty(filter(deepcopy(s:reserved_a), printf('v:val == "%s"', m_keyword.cargo)))) | return 0 | endif
  let this.cargo .= printf('%s ', m_keyword.cargo)

  let str = this.parse_range('#(', ')')
  let this.parameter = str

  let str = this.parse_range('[', ']')
  let this.unpacked_range = str

  while str != ''
    let str = this.parse_range('[', ']')
    let this.unpacked_range .= str
  endwhile

  let m_keyword = this.lexer.m_current_keyword

  " datatype is decided by previous variable datatype: ex: (bit a,b)
  if (is_continue == 1 && (m_keyword.cargo =~ this.end_ptrn || m_keyword.cargo =~ '^\v(\=)$'))
    let this.variable_name = this.datatype 
    let this.datatype = ''

    let m_init = g:parser#uvm#parser#variable#initialization#initialization.new(this.lexer, this.end_ptrn)
    
    if (m_init.parse())
      let this.init_value = m_init.cargo
      let this.cargo .= this.init_value 
    endif

    ParserReturnOnNull 'm_keyword', 'this.lexer.m_current_keyword'
    if (!empty(filter(deepcopy(s:reserved_a), printf('v:val == "%s"', m_keyword.cargo)))) | return 0 | endif

    ParserExpectKeywordPtrn 'm_keyword', this.end_ptrn, '0', 'parser/variable/user_datatype.vim', '148'
    let this.end_pos = this.lexer.m_prev_keyword.end_pos

    return 1
  else
    if (create_copy == 1 && m_keyword.cargo !~ '\v^\w+$')
      return 0
    endif

    ParserExpectKeywordPtrn 'm_keyword', '\v^\w+$', 0, 'parser/variable/user_datatype.vim', '134'
    let this.variable_name = m_keyword.cargo
  endif

  ParserReturnOnNull 'm_keyword', 'this.lexer.get_next_keyword()'
  let this.cargo .= printf('%s ', m_keyword.cargo)

  if (this.lexer.m_current_keyword.cargo == ';')
    let this.end_pos = this.lexer.m_current_keyword.end_pos
    return 1
  endif

  let str = this.parse_range('[', ']')
  let this.packed_range = str

  while str != ''
    let str = this.parse_range('[', ']')
    let this.packed_range .= str

    if (this.lexer.m_current_keyword.cargo == ';')
      let this.end_pos = this.lexer.m_current_keyword.end_pos
      return 1
    endif
  endwhile

  let m_init = g:parser#uvm#parser#variable#initialization#initialization.new(this.lexer, this.end_ptrn)
  
  if (m_init.parse())

    let this.init_value = m_init.cargo
    let this.cargo .= this.init_value 
  else
    ParserReturnOnNull 'm_keyword_n1', 'this.lexer.clone_next_keyword()'
    if (!empty(filter(deepcopy(s:reserved_a), printf('v:val == "%s"', m_keyword_n1.cargo)))) | return 0 | endif

    if (create_copy == 1 && m_keyword_n1.cargo !~ this.end_ptrn)
      return 0
    endif
    ParserExpectKeywordPtrn 'm_keyword_n1', this.end_ptrn, 0, 'parser/variable/user_datatype.vim', '214'
  endif

  if (!empty(filter(deepcopy(s:reserved_a), printf('v:val == "%s"', this.lexer.m_current_keyword.cargo)))) | return 0 | endif

  ParserReturnOnNull 'm_keyword', 'this.lexer.m_current_keyword'
  if (create_copy == 1 && m_keyword.cargo !~ this.end_ptrn)
    return 0
  endif
  ParserExpectKeywordPtrn 'm_keyword', this.end_ptrn, 0, 'parser/variable/user_datatype.vim', '188'

  let this.end_pos = this.lexer.m_current_keyword.end_pos

  return 1
endfunction

function! parser#uvm#parser#variable#user_datatype#user_datatype.check_and_return (...) dict
  call debug#debug#log(printf("parser#uvm#parser#variable#user_datatype#user_datatype.check_and_return == %s", string(self.check_and_return)))
  
  TVarArg ['exp_val', '']

  let str = ''

  return str

endfunction

"-------------------------------------------------------------------------------
" Function : UserDatatype.parse
"-------------------------------------------------------------------------------
function! parser#uvm#parser#variable#user_datatype#user_datatype.parse() dict
  call debug#debug#log(printf("parser#uvm#parser#variable#user_datatype#user_datatype.parse == %s", string(self.parse)))
  
  " Comment
  ParserReturnOnNull 'm_keyword', 'self.lexer.m_current_keyword'
  if (self.lexer.m_current_keyword.cargo =~ '\v^(\/\/|\/\*)')
    return 0
  endif

  ParserReturnOnNull 'm_keyword_n1', 'self.lexer.clone_next_keyword()'

  if (m_keyword.cargo !~ '\v^(rand|const)$' || m_keyword_n1.cargo !~ self.datatype_ptrn) && (m_keyword.cargo !~ self.datatype_ptrn)
    if (self.variable_continue == 0)
      return 0
    endif
  endif

  if (!self.__parse__(1)) " create_copy => 1
    return 0
  endif

  return self.__parse__(0)

endfunction

"-------------------------------------------------------------------------------
" Function : UserDatatype.string
"-------------------------------------------------------------------------------
function! parser#uvm#parser#variable#user_datatype#user_datatype.string(...) dict
  call debug#debug#log(printf("parser#uvm#parser#variable#user_datatype#user_datatype.string == %s", string(self.string)))
  
  TVarArg ['indent', 0]
  
  let indent_str = repeat(' ', indent)

  let str = printf("%s<user variable>\n", indent_str)
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
" Function : UserDatatype.get_comments
"-------------------------------------------------------------------------------
function! parser#uvm#parser#variable#user_datatype#user_datatype.get_comments() dict
  call debug#debug#log(printf("parser#uvm#parser#variable#user_datatype#user_datatype.get_comments == %s", string(self.get_comments)))
  
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






