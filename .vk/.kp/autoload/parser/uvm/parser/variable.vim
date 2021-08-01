"-------------------------------------------------------------------------------
" _set_indent: Function
"-------------------------------------------------------------------------------
function! s:_set_indent(offset)
  return '=common#indent#imode_set_indent(' . a:offset . ')'
endfunction

let parser#uvm#parser#variable#variable = {}

"-------------------------------------------------------------------------------
" Function : Variable.new
"-------------------------------------------------------------------------------
function! parser#uvm#parser#variable#variable.new(lexer, ...) dict
  call debug#debug#log(printf("parser#uvm#parser#variable#variable.new == %s", string(self.new)))

  let this = deepcopy(self)
  
  let this.default_end_ptrn = '\v^(;|,)$'

  TVarArg ['end_ptrn', this.default_end_ptrn], ['variable_continue', 0]

  let this.lexer = a:lexer
  let this.end_ptrn = end_ptrn
  let this.eos_keyword = g:parser#uvm#null#null
  let this.variable_continue = variable_continue
  let this.m_variable = {}
  let this.name = ''
  let this.start_pos = g:parser#uvm#null#null

  return this
endfunction

"-------------------------------------------------------------------------------
" Function : Variable.parse_eos
"-------------------------------------------------------------------------------
function! parser#uvm#parser#variable#variable.parse_eos() dict
  call debug#debug#log(printf("parser#uvm#parser#variable#variable.parse_eos == %s", string(self.parse_eos)))
  
  ParserReturnOnNull 'm_keyword', 'self.lexer.m_current_keyword'

  ParserExpectKeywordPtrn 'self.lexer.m_current_keyword', self.end_ptrn, 0, 'parser/variable.vim', '31'

  let self.eos_keyword = m_keyword.get()
endfunction

"-------------------------------------------------------------------------------
" Function : Variable.parse
"-------------------------------------------------------------------------------
function! parser#uvm#parser#variable#variable.parse() dict
  call debug#debug#log(printf("parser#uvm#parser#variable#variable.parse == %s", string(self.parse)))
  
  " Comment
  call debug#debug#log(printf("m_keyword ======= %s", string(self.lexer.m_current_keyword)))

  ParserReturnOnNull 'm_keyword', 'self.lexer.m_current_keyword'

  call debug#debug#log(printf("m_keyword == %s", string(m_keyword.cargo)))
  if (self.lexer.m_current_keyword.cargo =~ '\v^(\/\/|\/\*)')
    return 0
  endif

  let m_inbuilt_datatype = g:parser#uvm#parser#variable#inbuilt_datatype#inbuilt_datatype.new(self.lexer, self.end_ptrn, self.variable_continue)
  if (m_inbuilt_datatype.parse())
    call debug#debug#log(printf("m_keyword1 == %s", string(m_keyword.cargo)))
    let self.m_variable = m_inbuilt_datatype
    let self.name = self.m_variable.variable_name

    call self.parse_eos()

    let self.start_pos = self.m_variable.start_pos
    return 1
  endif

  let m_user_datatype = g:parser#uvm#parser#variable#user_datatype#user_datatype.new(self.lexer, self.end_ptrn, self.variable_continue)
  if (m_user_datatype.parse())
    call debug#debug#log(printf("m_keyword2 == %s", string(m_keyword.cargo)))
    let self.m_variable = m_user_datatype
    let self.name = self.m_variable.variable_name

    call self.parse_eos()

    let self.start_pos = self.m_variable.start_pos
    return 1
  endif
  call debug#debug#log(printf("m_keyword3 == %s", string(m_keyword.cargo)))

  return 0
endfunction

"-------------------------------------------------------------------------------
" Function : Variable.string
"-------------------------------------------------------------------------------
function! parser#uvm#parser#variable#variable.string(...) dict
  call debug#debug#log(printf("parser#uvm#parser#variable#variable.string == %s", string(self.string)))
  
  TVarArg ['indent', 0]
  
  let indent_str = repeat(' ', indent)

  let str = ''
  let str .= printf("%s<eos_keyword> %s\n", indent_str, string(self.eos_keyword))
  let str .= self.m_variable.string(indent)
  return str 
  
endfunction

"-------------------------------------------------------------------------------
" Function : Variable.get_comments
"-------------------------------------------------------------------------------
function! parser#uvm#parser#variable#variable.get_comments(...) dict
  call debug#debug#log(printf("parser#uvm#parser#variable#variable.get_comments == %s", string(self.get_comments)))
  
  TVarArg ['m_old_comment_h', {}]  

  let cmt = self.m_variable.get_comments()

  return cmt
endfunction

function! parser#uvm#parser#variable#variable.get_default_desc_comment() dict
  call debug#debug#log(printf("parser#uvm#parser#variable#variable.get_default_desc_comment == %s", string(self.get_default_desc_comment)))
  
  return ''
endfunction

"-------------------------------------------------------------------------------
" Function : Variable.get_var_comments
"-------------------------------------------------------------------------------
function! parser#uvm#parser#variable#variable.get_var_comments(...) dict
  call debug#debug#log(printf("parser#uvm#parser#variable#variable.get_var_comments == %s", string(self.get_var_comments)))
  
  TVarArg ['m_old_comment_h', {}]  

  if (self.m_variable.typedef != '')
    let var_type = 'Typedef'
  else
    let var_type = 'Variable'
  endif
  let comments = [printf('%-12s: %s', var_type, self.m_variable.variable_name)]

  if (exists('m_old_comment_h["description"]'))
    let idx = 0
    for l:desc in m_old_comment_h["description"]
      if (idx == 0)
        let idx += 1
        let cmt = printf('%-12s: %s', 'Description', l:desc)
      else
        let cmt = printf('%-12s  %s', '', l:desc)
      endif
      let comments += [cmt]

    endfor
  else
    let cmt = printf('%-12s: %s', 'Description', self.get_default_desc_comment())
    let comments += [cmt]
  endif

  let comments = map(comments , 'printf("// %s", v:val)')

  let comment_header = join(comments, '')

  return comment_header
endfunction




