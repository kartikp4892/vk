"-------------------------------------------------------------------------------
" _set_indent: Function
"-------------------------------------------------------------------------------
function! s:_set_indent(offset)
  return '=common#indent#imode_set_indent(' . a:offset . ')'
endfunction

let parser#uvm#parser#arg#arg = {}

"-------------------------------------------------------------------------------
" Function : Arg.new
"-------------------------------------------------------------------------------
function! parser#uvm#parser#arg#arg.new(lexer) dict
  call debug#debug#log(printf("parser#uvm#parser#arg#arg.new == %s", string(self.new)))

  let this = deepcopy(self)

  let this.start_pos = g:parser#uvm#null#null
  let this.end_pos = g:parser#uvm#null#null
  let this.direction = ''
  let this.type = ''
  let this.unpacked_range = ''
  let this.packed_range = ''
  let this.variable = ''
  let this.default_value = ''
  let this.cargo = '' 
  let this.const = '' 
  let this.lexer = a:lexer
  
  return this
endfunction

"-------------------------------------------------------------------------------
" Function : Arg.parse_range
"-------------------------------------------------------------------------------
function! parser#uvm#parser#arg#arg.parse_range() dict
  call debug#debug#log(printf("parser#uvm#parser#arg#arg.parse_range == %s", string(self.parse_range)))
  
  ParserReturnOnNull 'm_keyword', 'self.lexer.m_current_keyword'
  if (m_keyword.cargo == '[')
    let range_str = printf('%s ', m_keyword.cargo)

    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
    let self.cargo .= printf('%s ', m_keyword.cargo)

    while m_keyword.cargo != ']'
      let range_str .= printf('%s ', m_keyword.cargo)

      ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
      let self.cargo .= printf('%s ', m_keyword.cargo)
    endwhile

    let range_str .= printf('%s ', m_keyword.cargo)

    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
    let self.cargo .= printf('%s ', m_keyword.cargo)

    return range_str
  endif

  return ''
endfunction

"-------------------------------------------------------------------------------
" Function : Arg.parse
"-------------------------------------------------------------------------------
function! parser#uvm#parser#arg#arg.parse() dict
  call debug#debug#log(printf("parser#uvm#parser#arg#arg.parse == %s", string(self.parse)))
  
  ParserReturnOnNull 'm_keyword_n1', 'self.lexer.clone_next_keyword()'

  if (m_keyword_n1.cargo =~ '\v^\w+$')
    let is_continue = 0
    if (self.lexer.m_current_keyword.cargo == ',')
      let is_continue = 1
    endif

    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
    let self.cargo .= printf('%s ', m_keyword.cargo)

    let self.start_pos = m_keyword.start_pos

    if (m_keyword.cargo =~ '\v^(const)$')
      let self.const = m_keyword.cargo 
      ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
      let self.cargo .= printf('%s ', m_keyword.cargo)
    endif

    if (m_keyword.cargo =~ '\v^(ref|input|output|inout)$')
      let self.direction = m_keyword.cargo 
      ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
      let self.cargo .= printf('%s ', m_keyword.cargo)
    endif

    let self.type = m_keyword.cargo

    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
    let self.cargo .= printf('%s ', m_keyword.cargo)

    let self.packed_range = ''
    let str = self.parse_range()
    while str != ''
      let self.packed_range .= str 
      let str = self.parse_range()
    endwhile

    ParserReturnOnNull 'm_keyword', 'self.lexer.m_current_keyword'

    " datatype is decided by previous variable datatype: ex: (bit a,b)
    if ((m_keyword.cargo =~ '\v^(\)|,|\=)') && (is_continue == 1))
      let self.variable = common#utils#trim(self.type)
      let self.type = ''
      let self.end_pos = self.lexer.m_prev_keyword.end_pos

      if (m_keyword.cargo == '=')
        call self.parse_default()
      endif

      return 1
    else
      ParserExpectKeywordPtrn 'm_keyword', '\v^(\w+)$', '0', 'parser/arg.vim', '108'
      let self.variable = common#utils#trim(m_keyword.cargo)
    endif

    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
    let self.cargo .= printf('%s ', m_keyword.cargo)

    let self.unpacked_range = ''
    let str = self.parse_range()

    while str != ''
      let self.unpacked_range .= str 
      let str = self.parse_range()
    endwhile

    call self.parse_default()

    ParserExpectKeywordPtrn 'self.lexer.m_current_keyword', '\v^(\)|,)$', '0', 'parser/arg.vim', '131'
    let self.end_pos = self.lexer.m_prev_keyword.end_pos

    let self.unpacked_range = common#utils#trim(self.unpacked_range)
    return 1
  else
    return 0
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : Arg.parse_default
"-------------------------------------------------------------------------------
function! parser#uvm#parser#arg#arg.parse_default() dict
  call debug#debug#log(printf("parser#uvm#parser#arg#arg.parse_default == %s", string(self.parse_default)))
  
  ParserReturnOnNull 'm_keyword', 'self.lexer.m_current_keyword'
  if (m_keyword.cargo == '=')
    let self.default_value = ''

    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
    let self.cargo .= printf('%s ', m_keyword.cargo)
    let self.default_value .= printf('%s ', m_keyword.cargo)

    ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
    let self.cargo .= printf('%s ', m_keyword.cargo)

    while m_keyword.cargo !~ '\v^(\)|,)'
      let self.default_value .= printf('%s ', m_keyword.cargo)

      ParserReturnOnNull 'm_keyword', 'self.lexer.get_next_keyword()'
      let self.cargo .= printf('%s ', m_keyword.cargo)
    endwhile

    ParserExpectKeywordPtrn 'm_keyword', '\v^(\)|,)$', '0', 'parser/arg.vim', '166'
  endif

endfunction

"-------------------------------------------------------------------------------
" Function : Arg.string
"-------------------------------------------------------------------------------
function! parser#uvm#parser#arg#arg.string(...) dict
  call debug#debug#log(printf("parser#uvm#parser#arg#arg.string == %s", string(self.string)))
  
  TVarArg ['indent', 0]

  let indent_str = repeat(' ', indent)

  let str = ''
  let str .= printf("%s<direction> %s\n", indent_str, self.direction)
  let str .= printf("%s<type> %s\n", indent_str, self.type)
  let str .= printf("%s<unpacked_range> %s\n", indent_str, self.unpacked_range)
  let str .= printf("%s<variable> %s\n", indent_str, self.variable)
  let str .= printf("%s<packed_range> %s\n", indent_str, self.packed_range)
  let str .= printf("%s<default_value> %s\n", indent_str, self.default_value)
  let str .= printf("%s<cargo> %s\n", indent_str, self.cargo)
  let str .= printf("%s<start_pos> %s\n", indent_str, string(self.start_pos))
  let str .= printf("%s<end_pos> %s\n", indent_str, string(self.end_pos))

  return str
  
endfunction

function! parser#uvm#parser#arg#arg.get_default_comment() dict
  call debug#debug#log(printf("parser#uvm#parser#arg#arg.get_default_comment == %s", string(self.get_default_comment)))
  
  if (self.type == 'uvm_recorder')
    let str = " - Object of policy class for recording utility."
  elseif (self.type == 'uvm_packer')
    let str = " - Object of policy class for packing & unpacking utilities."
  elseif (self.type == 'uvm_comparer')
    let str = " - Object of policy class for compare utility."
  elseif (self.type == 'uvm_printer')
    let str = " - Object of policy class for printing utility."
  elseif (self.type == 'string' && self.variable == 'name')
    let str = " - Name of the object."
  elseif (self.type == 'uvm_component' && self.variable == 'parent')
    let str = " - Object of parent component class."
  elseif (self.type == 'uvm_phase' && self.variable == 'phase')
    let str = " - Handle of uvm_phase."
  else
    let str = ''
  endif

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : Arg.get_comments
"-------------------------------------------------------------------------------
function! parser#uvm#parser#arg#arg.get_comments() dict
  call debug#debug#log(printf("parser#uvm#parser#arg#arg.get_comments == %s", string(self.get_comments)))
  
  let arg = ''
  if (self.const != '') | let arg .= printf('%s ', self.const) | endif
  if (self.direction != '') | let arg .= printf('%s ', self.direction) | endif
  if (self.type != '') | let arg .= printf('%s ', self.type) | endif
  if (self.packed_range != '') | let arg .= printf('%s ', self.packed_range) | endif
  if (self.variable != '') | let arg .= printf('%s ', self.variable) | endif
  if (self.unpacked_range != '') | let arg .= printf('%s ', self.unpacked_range) | endif

  if (self.default_value != '')
    " let cmt = printf('@%-10s: %s[ default := %s]', 'arg', arg, self.default_value)
    let cmt = printf('%s[ default := %s]', arg, self.default_value )
  else
    " let cmt = printf('@%-10s: %s', 'arg', arg)
    let cmt = printf('%s', arg)
  endif

  return cmt
endfunction


