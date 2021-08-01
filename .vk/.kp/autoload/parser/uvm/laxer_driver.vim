let s:pfile = $HOME . '/parser.log'

"-------------------------------------------------------------------------------
" Function : s:parse_fun
"-------------------------------------------------------------------------------
function! s:parse_fun(lexer)
  let m_fun = g:Function.new(a:lexer)
  if (m_fun.parse())
    call debug#debug#log (m_fun.string(), s:pfile)
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : s:parse_task
"-------------------------------------------------------------------------------
function! s:parse_task(lexer)
  let m_task = g:Task.new(a:lexer)
  if (m_task.parse())
    call debug#debug#log (m_task.string(), s:pfile)
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : s:parse_variable
"-------------------------------------------------------------------------------
function! s:parse_variable(lexer)
  let m_variable = g:parser#uvm#parser#variable#variable.new(a:lexer)
  if (m_variable.parse())
    call debug#debug#log (m_variable.string(), s:pfile)

    ParserExpectKeywordPtrn 'a:lexer.m_current_keyword', '\v^(;|,)', 0, 'laxer_driver.vim', '31'

    ParserReturnOnNull 'm_keyword', 'a:lexer.get_next_keyword()'

    return 1
  endif
  return 0
endfunction

"-------------------------------------------------------------------------------
" Function : s:parse_class
"-------------------------------------------------------------------------------
function! s:parse_class(lexer)
  let m_class = g:Class.new(a:lexer)
  if (m_class.parse_header())
    call debug#debug#log (m_class.string(), s:pfile)
    return 1
  endif
  return 0
endfunction

"-------------------------------------------------------------------------------
" Function : drive
"-------------------------------------------------------------------------------
function! Drive_Laxer()

    call debug#debug#ftouch()
    call debug#debug#ftouch(s:pfile)
    call debug#debug#ftouch('~/temp.log')

    let g:debug#debug#enable[s:pfile] = 1
    let g:debug#debug#enable[$HOME . '/debug.log'] = 1

    let m_lexer = g:parser#uvm#lexer#lexer.new()

    while 1

      if (s:parse_fun(m_lexer))
      elseif (s:parse_task(m_lexer))
      elseif (s:parse_variable(m_lexer))
      elseif (s:parse_class(m_lexer))
      else
        let m_keyword = m_lexer.get_next_keyword()

        if (m_keyword == g:parser#uvm#null#null)
          break
        endif

        call debug#debug#log (m_keyword.string(), s:pfile)

      endif
    endwhile

endfunction

nmap <F6> :call Drive_Laxer() 






