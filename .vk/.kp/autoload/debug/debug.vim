let g:debug#debug#enable = {}
let g:debug#debug#file = $HOME . "/debug.log"

"-------------------------------------------------------------------------------
" Function : ftouch
"-------------------------------------------------------------------------------
function! debug#debug#ftouch(...)
  TVarArg ['file', g:debug#debug#file]

  if (!exists('g:debug#debug#enable[file]'))
    let g:debug#debug#enable[file] = 1
  endif
  exe 'redir! > ' . file
  redir END

endfunction

"-------------------------------------------------------------------------------
" Function : log
"-------------------------------------------------------------------------------
function! debug#debug#log(msg, ...)
  TVarArg ['file', g:debug#debug#file]

  if (g:debug#debug#enable[file] == 1)
    exe 'redir >> ' . file
    silent echo a:msg
    redir END
  endif
endfunction








