
"-------------------------------------------------------------------------------
" Function : drive
"-------------------------------------------------------------------------------
function! Drive()
    let pfile = $HOME . '/parser.log'

    call debug#debug#ftouch()
    call debug#debug#ftouch(pfile)

    let g:debug#debug#enable[pfile] = 1

    let m_scanner = g:parser#uvm#scanner.new(expand('%:p'))

    while 1
      let m_char = m_scanner.get_next_char()
      if (m_char == g:parser#uvm#null#null)
        break
      endif

      call debug#debug#log (m_char.string(), pfile)
    endwhile

    " while 1
    "   let m_char = m_scanner.get_prev_char()
    "   if (m_char == g:parser#uvm#null#null)
    "     break
    "   endif

    "   call debug#debug#log (m_char.string(), pfile)
    " endwhile

endfunction

nmap <F5> :call Drive() 






