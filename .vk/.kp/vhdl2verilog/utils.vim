" Select text between two positions
function! Utils_visual(startpos, ...)
  TVarArg ['endpos', []]
  call setpos(".", a:startpos)
  if (len(endpos) == 0)
    normal v$
  else
    normal v
    call setpos(".", endpos)
  endif
endfunction

" Get text between two positions
function! Utils_gettext(startpos, ...)
  TVarArg ['endpos', []]
  let saveview = winsaveview()
  if (len(endpos) == 0)
    call Utils_visual(a:startpos)
  else
    call Utils_visual(a:startpos, endpos)
  endif
  normal "*y
  let txt = @*
  call winrestview(saveview)
  return txt
endfunction

let UTILS_NULL_POS = [0,0,0,0]

function! Utils_search(pattern, flags)
  let saveview = winsaveview()
  let startpos = g:UTILS_NULL_POS
  let endpos = g:UTILS_NULL_POS
  let txt = ''
  if(search(a:pattern, a:flags))
    let startpos = getpos('.')
    call search(a:pattern, 'e')
    let endpos = getpos('.')
    let txt = Utils_gettext(startpos, endpos)
  endif

  call winrestview(saveview)
  return [startpos, endpos, txt]
endfunction

function! Utils_Open_File(filename)
py << EOF

import vim
filename = vim.eval("a:filename")
fh = open(filename, 'w')
fh.write("// Verilog Starts Here\n")
fh.close()

EOF
endfunction

function! Utils_Append_File(filename, text)
echo "TEXT: " . a:text
py << EOF

import vim
filename = vim.eval("a:filename")
fh = open(filename, 'a')
fh.write(vim.eval('a:text'))
fh.close()

EOF
endfunction


