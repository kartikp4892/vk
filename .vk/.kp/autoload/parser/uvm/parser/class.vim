"-------------------------------------------------------------------------------
" _set_indent: Function
"-------------------------------------------------------------------------------
function! s:_set_indent(offset)
  return '=common#indent#imode_set_indent(' . a:offset . ')'
endfunction

let parser#uvm#parser#class#class = {}

"-------------------------------------------------------------------------------
" Function : Class.new
"-------------------------------------------------------------------------------
function! parser#uvm#parser#class#class.new(lexer) dict
  call debug#debug#log(printf("parser#uvm#parser#class#class.new == %s", string(self.new)))

  let this = deepcopy(self)

  " list of keys that should be part of comments
  let this.comments_keys = ['name', 'parent', 'parameters']
  let this.placeholder_comments_keys = {'name': 'Class', 'parent': 'Parent', 'parameters': 'Parameters'}
  
  let this.start_pos = g:parser#uvm#null#null
  let this.end_pos = g:parser#uvm#null#null
  let this.type = 'class'
  let this.name = ''
  let this.parent = ''
  let this.lexer = a:lexer
  let this.parameters = []
  let this.parent_inst_parameters = []
  let this.start_pos = g:parser#uvm#null#null
  let this.end_pos = g:parser#uvm#null#null

  return this
endfunction

"-------------------------------------------------------------------------------
" Function : Class.parse_inst_parameters
"-------------------------------------------------------------------------------
function! parser#uvm#parser#class#class.parse_inst_parameters() dict
  call debug#debug#log(printf("parser#uvm#parser#class#class.parse_inst_parameters == %s", string(self.parse_inst_parameters)))
  
  let inst_parameters = []
  if (self.lexer.m_current_keyword.cargo == '#(')
    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'

    ParserExpectKeywordPtrn 'm_keyword', '\v^\w+$', 0, 'parser/class.vim', '35'
    let inst_parameters += [m_keyword.cargo]
    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'

    while (self.lexer.m_current_keyword.cargo == ',')
      ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'

      ParserExpectKeywordPtrn 'm_keyword', '\v^\w+$', 0, 'parser/class.vim', '42'
      let inst_parameters += [m_keyword.cargo]
      ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'

    endwhile

    ParserExpectKeyword 'self.lexer.m_current_keyword', ')', 0, 'parser/class.vim', '48'

    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'

  endif

  return inst_parameters 
endfunction

"-------------------------------------------------------------------------------
" Function : Class.parse_parameters
"-------------------------------------------------------------------------------
function! parser#uvm#parser#class#class.parse_parameters() dict
  call debug#debug#log(printf("parser#uvm#parser#class#class.parse_parameters == %s", string(self.parse_parameters)))
  
  let parameters = []
  if (self.lexer.m_current_keyword.cargo == '#(')
    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'

    " let m_parameter = g:Parameter.new(self.lexer)
    let m_parameter = g:parser#uvm#parser#variable#variable.new(self.lexer, '\v^(\)|,)')
    if (m_parameter.parse())
      let parameters += [m_parameter]
    endif

    ParserExpectKeywordPtrn 'self.lexer.m_current_keyword', '\v^(\)|,)$', 0, 'parser/class.vim', '84'

    while (self.lexer.m_current_keyword.cargo == ',')
      ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'

      " let m_parameter = g:Parameter.new(self.lexer)
      let m_parameter = g:parser#uvm#parser#variable#variable.new(self.lexer, '\v^(\)|,)$', 1) " variable_continue = 1
      if (m_parameter.parse())
        if (len(parameters) != 0)
          if (m_parameter.m_variable.variable_type == '')
            let m_parameter.m_variable.variable_type = parameters[-1].m_variable.variable_type
          endif

          if (m_parameter.m_variable.datatype == '')
            let m_parameter.m_variable.datatype = parameters[-1].m_variable.datatype
            let m_parameter.m_variable.unpacked_range = parameters[-1].m_variable.unpacked_range
          endif
        endif
        let parameters += [m_parameter]
      endif

      ParserExpectKeywordPtrn 'self.lexer.m_current_keyword', '\v^(\)|,)', 0, 'parser/class.vim', '95'

    endwhile

    ParserExpectKeyword 'self.lexer.m_current_keyword', ')', 0, 'parser/class.vim', '99'

    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'

  endif

  return parameters 
endfunction

"-------------------------------------------------------------------------------
" Function : Class.parse_header
"-------------------------------------------------------------------------------
function! parser#uvm#parser#class#class.parse_header() dict
  call debug#debug#log(printf("parser#uvm#parser#class#class.parse_header == %s", string(self.parse_header)))
  
  " Comment
  ParserReturnOnNull 'm_keyword', 'self.lexer.m_current_keyword'
  if (self.lexer.m_current_keyword.cargo =~ '\v^(\/\/|\/\*)')
    return 0
  endif
  
  ParserReturnOnNull 'm_keyword_p1', 'self.lexer.m_prev_keyword'

  if (m_keyword_p1.cargo == 'typedef')
    return 0
  endif

  if (m_keyword.cargo == 'class')

    let self.start_pos = m_keyword.start_pos

    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'

    let self.name = m_keyword.cargo
    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'

    let self.parameters = self.parse_parameters()

    if (self.lexer.m_current_keyword.cargo == 'extends')
      ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'

      ParserExpectKeywordPtrn 'm_keyword', '\v^\w+$', 0, 'parser/class.vim', '114'
      let self.parent = m_keyword.cargo

      ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
      let self.parent_inst_parameters = self.parse_inst_parameters()
    endif

    let self.end_pos = self.lexer.m_current_keyword.end_pos
    ParserExpectKeyword 'self.lexer.m_current_keyword', ';', 0, 'parser/class.vim', '122'

    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'

    return 1
  endif

  return 0
endfunction

"-------------------------------------------------------------------------------
" Function : Class.parse
"-------------------------------------------------------------------------------
function! parser#uvm#parser#class#class.parse() dict
  call debug#debug#log(printf("parser#uvm#parser#class#class.parse == %s", string(self.parse)))
  
  " Comment
  ParserReturnOnNull 'm_keyword', 'self.lexer.m_current_keyword'
  if (self.lexer.m_current_keyword.cargo =~ '\v^(\/\/|\/\*)')
    return 0
  endif
  
  ParserReturnOnNull 'm_keyword_p1', 'self.lexer.m_prev_keyword'

  if (m_keyword_p1.cargo == 'typedef')
    return 0
  endif

  if (m_keyword.cargo == 'class')
    call self.__parse__() " TODO: ADD task to parse the whole class instead of just header
    return 1
  endif

  return 0

endfunction

"-------------------------------------------------------------------------------
" Function : Class.string
"-------------------------------------------------------------------------------
function! parser#uvm#parser#class#class.string() dict
  call debug#debug#log(printf("parser#uvm#parser#class#class.string == %s", string(self.string)))
  
  TVarArg ['indent', 0]
  
  let indent_str = repeat(' ', indent)
  let str = "<CLASS START>\n"

  let str .= printf("<name> %s\n", self.name)
  let str .= printf("<parent> %s\n", self.parent)
  let str .= printf("<start_pos> %s\n", string(self.start_pos))
  let str .= printf("<end_pos> %s\n", string(self.end_pos))

  let str .= "<PARAMETERS> \n"
  for l:arg in self.parameters
    let str .= printf("%s\n", l:arg.string(indent + 2))
  endfor

  let str .= "<PARAMETERS_INST_PARENT> \n"
  for l:i_arg in self.parent_inst_parameters
    let str .= printf("%s\n", l:i_arg)
  endfor
  let str .= "<CLASS END>\n"

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : Class.get_comments
"-------------------------------------------------------------------------------
function! parser#uvm#parser#class#class.get_comments(...) dict
  call debug#debug#log(printf("parser#uvm#parser#class#class.get_comments == %s", string(self.get_comments)))

  TVarArg ['m_old_comment_h', {}]  

  let comments = []
  for l:key in self.comments_keys
    if (l:key == 'parameters')
      let idx = 0
      for l:m_param in self[l:key]
        let m_old_parameter_h = filter(deepcopy(get(m_old_comment_h, 'parameters', [])), 'v:val.name == l:m_param.name')
        if (len(m_old_parameter_h) == 0)
          let param_desc = ''
        else
          let param_desc = printf(' - %s', m_old_parameter_h[0].description)
        endif

        if (idx == 0)
          let idx += 1
          let cmt = printf('%-15s: %s%s', self.placeholder_comments_keys[l:key], l:m_param.get_comments(), param_desc)
        else
          let cmt = printf('%-15s  %s%s', '', l:m_param.get_comments(), param_desc)
        endif
        " let cmt = l:m_param.get_comments()

        let comments += [l:cmt]
      endfor

      continue
    endif

    if (l:key == 'parent' && self[l:key] == '')
      continue
    endif

    let k = tolower(self.placeholder_comments_keys[l:key])
    if (exists('m_old_comment_h[k]'))
      let desc = printf(" - %s", m_old_comment_h[k].description)
    else
      let desc = ''
    endif
    let cmt = printf('%-15s: %s%s', self.placeholder_comments_keys[l:key], self[l:key], desc)
    let comments += [l:cmt]
  endfor

  if (exists('m_old_comment_h["description"]'))
    let idx = 0
    for l:desc in m_old_comment_h["description"]
      if (idx == 0)
        let idx += 1
        let cmt = printf('%-15s: %s', 'Description', l:desc)
      else
        let cmt = printf('%-15s  %s', '', l:desc)
      endif
      let comments += [cmt]

    endfor
  else
    let cmt = printf('%-15s: ', 'Description')
    let comments += [cmt]
  endif

  let save_cmt_en = g:comments#variables#enable_comment
  let g:comments#variables#enable_comment = 1

  let comment_header = call('comments#block_comment#getComments', ['', ''] + comments)

  let g:comments#variables#enable_comment = save_cmt_en 

  return comment_header 
endfunction





