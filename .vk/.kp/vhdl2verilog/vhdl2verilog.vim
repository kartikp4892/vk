so ~/.vk/.kp/vhdl/tokens.vim
so ~/.vk/.kp/vhdl/lexer.vim
so ~/.vk/.kp/sv/utils.vim
let s:verilog_output_file = "/home/kartik/output.v"
call Utils_Open_File(s:verilog_output_file)

let s:parameters = {}
let s:signals = {}
let s:dsl_scope = []

function! s:delete_statement_with(keyword)
  let l:ptrn = '\v^\c%' . line('.') . 'l\s*<' . a:keyword . '>\_.{-};(\_s*\n)?'
  if (search(l:ptrn, 'nc'))
    "exe 's!' . l:ptrn . '!!g'
    return 1
  else
    return 0
  endif
endfunction

function! s:convert_generics_begin()
  let l:ptrn = '\v\c%' . line('.') . 'l\_s*<generic\_s+\('

  if (!search(l:ptrn, 'nc'))
    return 0
  endif

  call Utils_Append_File(s:verilog_output_file, ' #(\n')
  "exe 's!' . l:ptrn . '! #(\r!g'
  return 1
endfunction

function! s:verilog_parameter_decl(name, ...)
  let name = toupper(a:name)
  if(exists('a:1'))
    let default = a:1
    let stmt = 'parameter ' . name . ' = ' . default
  else
    let stmt = 'parameter ' . name
  endif

  let s:parameters[name] = 1
  return stmt
endfunction

function! s:convert_generic_parameter() " return 1 upon end of generic block
  let l:ptrn = '\v^\c%' . line('.') . 'l(\_s*)<(\w+)\_s*:%([^);]){-}'
  let EOS1 = '%(\(\_[^()]{-}\))?;'
  let EOS2 = '\);'
  let DEFAULT = ':\=\_s*([^);]{-})'

  let ptrn1 = l:ptrn . DEFAULT . EOS1
  let ptrn2 = l:ptrn . DEFAULT . EOS2
  let ptrn3 = l:ptrn . EOS1
  let ptrn4 = l:ptrn . EOS2

  if (search(ptrn1, 'nc'))
    let subcmd = 's/' . ptrn1 . '/\=submatch(1) . s:verilog_parameter_decl(submatch(2), submatch(3)) . ","/g'
    echo "1>> " . subcmd
    exe subcmd
    return 0
  elseif (search(ptrn2, 'nc'))
    let subcmd = 's/' . ptrn2 . '/\=submatch(1) . s:verilog_parameter_decl(submatch(2), submatch(3)) . ")"/g'
    echo "2>> " . subcmd
    exe subcmd
    return 1
  elseif (search(ptrn3, 'nc'))
    let subcmd = 's/' . ptrn3 . '/\=submatch(1) . s:verilog_parameter_decl(submatch(2)) . ","/g'
    echo "3>> " . subcmd
    exe subcmd
    return 0
  elseif (search(ptrn4, 'nc'))
    let subcmd = 's/' . ptrn4 . '/\=submatch(1) . s:verilog_parameter_decl(submatch(2)) . ")"/g'
    echo "4>> " . subcmd
    exe subcmd
    return 1
  else
    echo "5>> "
  endif

  return 0
endfunction

function! s:convert_entity_header()
  let l:ptrn = '\v^\c%' . line('.') . 'l\s*<' . 'ENTITY\_s+(\w+)\_s+IS>'

  if (!search(l:ptrn, 'nc'))
    return 0
  endif

  "exe 's!' . l:ptrn . '!module \L\1!g'

  return 1
endfunction

function! s:convert_generics()
  if (s:convert_generics_begin())
    let s:dsl_scope += ['generic']
    return 1
  endif
  return 0
endfunction

function! s:verilog_port_decl(direction, datatype, name)
  let name = tolower(a:name)
  if(a:direction == 'in')
    let direction = 'input'
  elseif(a:direction == 'out')
    let direction = 'output'
  elseif(a:direction == 'inout')
    let direction = 'inout'
  endif
    
  let datatype = substitute(a:datatype, '\<\(downto\|to\)\>', ':', 'g')
  let stmt = direction . ' logic ' . datatype . ' ' . a:name

  let s:signals[name] = 1
  return stmt
endfunction

function! s:convert_port_io() " return 1 upon end of port block
  let l:ptrn = '\v^\c%' . line('.') . 'l(\_s*)<(\w+)\_s*:\_s*<(in|out|inout)>\_s*'
  let DT1 = '<std_logic>'
  let DT2 = '<std_logic_vector>\((\_.{-})\)'
  let EOS1 = '\_s*%(\(\_[^()]{-}\))?;'
  let EOS2 = '\_s*\);'

  let ptrn1 = l:ptrn . DT1 . EOS1
  let ptrn2 = l:ptrn . DT1 . EOS2
  let ptrn3 = l:ptrn . DT2 . EOS1
  let ptrn4 = l:ptrn . DT2 . EOS2

  if (search(ptrn1, 'nc'))
    let subcmd = 's/' . ptrn1 . '/\=submatch(1) . s:verilog_port_decl(submatch(3), "", submatch(2)) . ","/g'
    echo "1>> " . subcmd
    exe subcmd
    return 0
  elseif (search(ptrn2, 'nc'))
    let subcmd = 's/' . ptrn2 . '/\=submatch(1) . s:verilog_port_decl(submatch(3), "", submatch(2)) . ")"/g'
    echo "2>> " . subcmd
    exe subcmd
    return 1
  elseif (search(ptrn3, 'nc'))
    let subcmd = 's/' . ptrn3 . '/\=submatch(1) . s:verilog_port_decl(submatch(3), "[" . submatch(4) . "]", submatch(2)) . ","/g'
    echo "3>> " . subcmd
    exe subcmd
    return 0
  elseif (search(ptrn4, 'nc'))
    let subcmd = 's/' . ptrn4 . '/\=submatch(1) . s:verilog_port_decl(submatch(3), "[" . submatch(4) . "]", submatch(2)) . ")"/g'
    echo "4>> " . subcmd
    exe subcmd
    return 1
  else
    echo "5>> "
  endif

  return 0
endfunction

function! s:convert_ports_begin()
  let l:ptrn = '\v\c%' . line('.') . 'l\_s*<port\_s+\('

  if (!search(l:ptrn, 'nc')) | return 0 | endif

  "exe 's!' . l:ptrn . '! (\r!g'
  return 1
endfunction

function! s:convert_ports()
  if (s:convert_ports_begin())
    let s:dsl_scope += ['port']
    return 1
  endif
  return 0
endfunction

function! s:convert_entity()
  if (s:convert_entity_header())
    let s:dsl_scope += ['entity']
  else
    return 0
  endif

  return 1
endfunction

function! s:convert_signals() " return 1 upon end of port block
  let l:ptrn = '\v^\c%' . line('.') . 'l(\_s*)signal\_s+<(\w+)\_s*:\_s*'
  let DT1 = '<std_logic>'
  let DT2 = '<%(std_logic_vector|unsigned)>\((\_.{-})\)'
  let DEFAULT = ':\=\_s*([^);]{-})'
  let EOS = ';'

  let ptrn1 = l:ptrn . DT1 . EOS1
  let ptrn2 = l:ptrn . DT1 . EOS2
  let ptrn3 = l:ptrn . DT2 . EOS1
  let ptrn4 = l:ptrn . DT2 . EOS2

  if (search(ptrn1, 'nc'))
    let subcmd = 's/' . ptrn1 . '/\=submatch(1) . s:verilog_port_decl(submatch(3), "", submatch(2)) . ","/g'
    echo "1>> " . subcmd
    exe subcmd
    return 0
  elseif (search(ptrn2, 'nc'))
    let subcmd = 's/' . ptrn2 . '/\=submatch(1) . s:verilog_port_decl(submatch(3), "", submatch(2)) . ")"/g'
    echo "2>> " . subcmd
    exe subcmd
    return 1
  elseif (search(ptrn3, 'nc'))
    let subcmd = 's/' . ptrn3 . '/\=submatch(1) . s:verilog_port_decl(submatch(3), "[" . submatch(4) . "]", submatch(2)) . ","/g'
    echo "3>> " . subcmd
    exe subcmd
    return 0
  elseif (search(ptrn4, 'nc'))
    let subcmd = 's/' . ptrn4 . '/\=submatch(1) . s:verilog_port_decl(submatch(3), "[" . submatch(4) . "]", submatch(2)) . ")"/g'
    echo "4>> " . subcmd
    exe subcmd
    return 1
  else
    echo "5>> "
  endif

  return 0
endfunction

function! s:delete_architecture_header()
  let l:ptrn = '\v^\c%' . line('.') . 'l\s*<' . 'architecture\_s+\w+\_s+of\_s+\w+\_s+IS>(\_s*\n)?'

  if (!search(l:ptrn, 'nc')) | return 0 | endif

  "exe 's!' . l:ptrn . '!!g'

  return 1
endfunction

function! s:convert_architecture_footer()
  let l:ptrn = '\v^\c%' . line('.') . 'l\s*<' . 'end architecture\_s+\w+\_s*;'

  if (!search(l:ptrn, 'nc')) | return 0 | endif

  "exe 's!' . l:ptrn . '!endmodule!g'

  return 1
endfunction

function! s:convert_architecture()
  if (s:delete_architecture_header())
    let s:dsl_scope += ['architecture']
  else
    return 0
  endif

  return 1
endfunction

function! VHDL_TOKEN_COMMENT(comment)
  let comment = substitute(a:comment, '^--', '//', '')
  call Utils_Append_File(s:verilog_output_file, comment)
endfunction

function! VHDL_TOKEN_LIBRARY()
  let [__, __, kw] = Vhdl_current_keyword()
  if (kw == 'library')
    let m_obj = g:Vhdl_token_library.new()
    let ret = m_obj.parse()
    if (ret == 1)
      call Utils_Append_File(s:verilog_output_file, m_obj.verilog())
    endif
    return ret
  endif
  return 0
  
endfunction

function! VHDL_TOKEN_LIBRARY_USE()
  let [__, __, kw] = Vhdl_current_keyword()
  echo "VHDL_TOKEN_LIBRARY_USE: kw =" . kw
  if (kw == 'use')
    let m_obj = g:Vhdl_token_library_use.new()
    let ret = m_obj.parse()
    if (ret == 1)
      call Utils_Append_File(s:verilog_output_file, m_obj.verilog())
    endif
    return ret
  endif
  return 0
  
endfunction

function! VHDL_TOKEN_TYPE()
  let [__, __, kw] = Vhdl_current_keyword()
  if (kw == 'type')
    let m_obj = g:Vhdl_token_type.new()
    let ret = m_obj.parse()
    if (ret == 1)
      call Utils_Append_File(s:verilog_output_file, m_obj.verilog())
    endif
    return ret
  endif
  return 0
  
endfunction

function! VHDL_TOKEN_ENTITY()
  let [__, __, kw] = Vhdl_current_keyword()
  if (kw == 'entity')
    let m_obj = g:Vhdl_token_entity.new()
    let ret = m_obj.parse()
    if (ret == 1)
      call Utils_Append_File(s:verilog_output_file, m_obj.verilog())
    endif
    return ret
  endif
  return 0
  
endfunction

function! VHDL_TOKEN_ARCHITECTURE()
  let [__, __, kw] = Vhdl_current_keyword()
  if (kw == 'architecture')
    let m_obj = g:Vhdl_token_architecture.new()
    let ret = m_obj.parse()
    if (ret == 1)
      call Utils_Append_File(s:verilog_output_file, m_obj.verilog())
    endif
    return ret
  endif
  return 0
  
endfunction

function! VHDL_TOKEN_END()
  let [__, __, kw] = Vhdl_current_keyword()
  if (kw == 'end')
    let m_obj = g:Vhdl_token_end.new()
    let ret = m_obj.parse()
    if (ret == 1)
      call Utils_Append_File(s:verilog_output_file, m_obj.verilog())
    endif
    return ret
  endif
  return 0
  
endfunction

function! s:parse_statement()
  "" if (s:convert_comment()) | return | endif

  "" if(len(s:dsl_scope) != 0)
  ""   if(s:dsl_scope[-1] == 'entity')
  ""     if (s:convert_generics()) | return | endif

  ""     if (s:convert_ports()) | return | endif

  ""     if(s:delete_statement_with('end entity'))
  ""       let s:dsl_scope = s:dsl_scope[0:-2]
  ""       echo s:dsl_scope
  ""       return
  ""     endif
  ""   elseif(s:dsl_scope[-1] == 'generic')
  ""     if (!s:convert_generic_parameter())
  ""       normal j
  ""       return
  ""     else
  ""       let s:dsl_scope = s:dsl_scope[0:-2]
  ""     endif
  ""   elseif(s:dsl_scope[-1] == 'port')
  ""     if (!s:convert_port_io())
  ""       normal j
  ""       return
  ""     else
  ""       let s:dsl_scope = s:dsl_scope[0:-2]
  ""     endif
  ""     
  ""   elseif(s:dsl_scope[-1] == 'architecture')
  ""     if(s:convert_architecture_footer())
  ""       let s:dsl_scope = s:dsl_scope[0:-2]
  ""       return
  ""     endif
  ""   endif
  "" endif

  "" if (s:delete_statement_with('LIBRARY')) | return | endif

  "" if (s:delete_statement_with('USE IEEE')) | return | endif

  "" if (s:convert_entity()) | return | endif

  "" if (s:convert_architecture()) | return | endif

  if (VHDL_TOKEN_LIBRARY()) | return | endif
  if (VHDL_TOKEN_LIBRARY_USE()) | return | endif
  if (VHDL_TOKEN_TYPE()) | return | endif
  if (VHDL_TOKEN_ENTITY()) | return | endif
  if (VHDL_TOKEN_ARCHITECTURE()) | return | endif
  if (VHDL_TOKEN_END()) | return | endif

  let [SUCCESS, EOF, __, __, kw] = Vhdl_next_keyword()
  if (!SUCCESS || EOF) | return | endif
endfunction

function! s:vhdl2verilog()
  redir >> /home/kartik/vhdl2verilog.log
  echo "VHDL_COMMENT callbacks = " . len(g:VHDL_COMMENT.callbacks)
  call s:parse_statement()
  redir END
endfunction

function! s:next_keyword()
  redir! >> /home/kartik/vhdl2verilog.log
  call Vhdl_next_keyword()
  redir END
endfunction

nmap <F5> :so ~/.vk/.kp/sv/vhdl2verilog.vim
nmap <F6> :silent call <SID>vhdl2verilog()
nmap <F7> :silent call <SID>next_keyword()
redir! > /home/kartik/vhdl2verilog.log
call VHDL_COMMENT.add_callback(function('VHDL_TOKEN_COMMENT'))


