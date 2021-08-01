"-------------------------------------------------------------------------------
" Function : assign_and_return_on_null
"-------------------------------------------------------------------------------
function! parser#uvm#utils#assign_and_return_on_null(var, value, ...)
  TVarArg ['ret_val', 0]

  let str = printf("let %s = %s \|", a:var, a:value)
  let str .= printf("if (%s == g:parser#uvm#null#null) \|", a:var)
  let str .= printf("return %s \|", l:ret_val)
  let str .= "endif"

  return str 
endfunction

"-------------------------------------------------------------------------------
" Function : assign_and_break_on_null
"-------------------------------------------------------------------------------
function! parser#uvm#utils#assign_and_break_on_null(var, value, ...)
  TVarArg ['ret_val', 0]

  let str = printf("let %s = %s |", a:var, a:value)
  let str .= printf("if (%s == g:parser#uvm#null#null)|", a:var)
  let str .= "break |"
  let str .= "endif"

  return str 
endfunction

"-------------------------------------------------------------------------------
" Function : expect_keyword
"-------------------------------------------------------------------------------
function! parser#uvm#utils#expect_keyword(m_keyword, exp_value, ...)
  TVarArg ['ret_val', 0], ['script_file', 'NULL'], ['script_line', 'NULL']

  let str = ''
  let str .= printf("if !(%s.cargo == %s)|", a:m_keyword, string(a:exp_value))
  let str .= "echoerr printf('Error: " . script_file . "[" . script_line ."] -->" . expand('%:p') . "@%s: expecting \"%s\" found \"%s\"', string(" . a:m_keyword . ".start_pos), " . string(a:exp_value) . ", " . a:m_keyword . ".cargo) " . "|"
  let str .= printf("return %s|", l:ret_val)
  let str .= "endif"

  return str 
endfunction

"-------------------------------------------------------------------------------
" Function : expect_keyword_ptrn
"-------------------------------------------------------------------------------
function! parser#uvm#utils#expect_keyword_ptrn(m_keyword, exp_ptrn, ...)
  TVarArg ['ret_val', 0], ['script_file', 'NULL'], ['script_line', 'NULL']

  let str = ''
  let str .= printf("if !(%s.cargo =~ %s)|", a:m_keyword, string(a:exp_ptrn))
  let str .= "echoerr printf('Error: " . script_file . "[" . script_line ."] -->" . expand('%:p') . "@%s: expecting pattern \"%s\" found \"%s\"', string(" . a:m_keyword . ".start_pos), " . string(a:exp_ptrn) . ", " . a:m_keyword . ".cargo) " . "|"
  let str .= printf("return %s|", l:ret_val)
  let str .= "endif"

  return str 
endfunction



