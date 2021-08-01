
"-------------------------------------------------------------------------------
" Function : drive
"-------------------------------------------------------------------------------
function! sv#uvm#parser#update_ifndef#parse_sv()

  let s:pfile = $HOME . '/parser.log'

  call debug#debug#ftouch()
  call debug#debug#ftouch(s:pfile)

  let g:debug#debug#enable[s:pfile] = 0
  let g:debug#debug#enable[$HOME . '/debug.log'] = 0

  let m_lexer = g:parser#uvm#lexer#lexer.new(expand('%:p'))

  ParserReturnOnNull 'm_keyword', 'm_lexer.get_next_keyword()'

  while 1
    " Skip comment
    if (m_keyword.cargo =~ '\v^(//|/\*)')
      while m_keyword.cargo =~ '\v^(//|/\*)'
        let m_keyword = m_lexer.get_next_keyword()
        if (m_keyword == g:parser#uvm#null#null)
          return 0
        endif
      endwhile

      continue
    endif

    if (m_keyword.cargo != '`ifndef')
      call s:add_ifndef(m_keyword)
    endif

    break

  endwhile
endfunction

function! s:add_ifndef(m_keyword)
  let text_macro_name = expand('%:p:t')
  let text_macro_name = substitute(text_macro_name, '\.', '_', 'g')
  let text_macro_name = toupper(text_macro_name)

  let lines = []
  let lines += [printf('`ifndef %s', text_macro_name)]
  let lines += [printf('`define %s', text_macro_name)]
  let lines += ['']

  let start_ln = a:m_keyword.start_pos[0]

  call append(start_ln - 1, lines)

  let lines = []
  let lines += ['']
  let lines += [printf('`endif // %s', text_macro_name)]
  let lines += repeat([''], 5)

  call append(line('$'), lines)
endfunction

"-------------------------------------------------------------------------------
" Function : sv#uvm#parser#update_ifndef
"-------------------------------------------------------------------------------
function! sv#uvm#parser#update_ifndef#update_ifndef()

  call sv#uvm#parser#update_ifndef#parse_sv()

endfunction

