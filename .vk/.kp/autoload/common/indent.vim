"-------------------------------------------------------------------------------
" get_indent: Function
" offset: Relative offset from the indent of the previous line
"-------------------------------------------------------------------------------
function! common#indent#imode_set_indent(offset)
  let indent = indent(prevnonblank(line(".") - 1))

  let indent += a:offset

  let spaces = repeat(' ', indent)
  return ':call setline(line("."), "'. spaces . substitute(getline('.'), '^\s*', '', 'g') . '")A'

  " ==> let str = '' .
  " ==>         \ ':let b:indent = indent(prevnonblank(line(".") - 1))' .
  " ==>         \ ':let b:indent += ' . a:offset . '' .
  " ==>         \ ':let b:spaces = repeat(" ", b:indent)' .
  " ==>         \ ':call setline(line("."), b:spaces)A'

  " ==> return str
endfunction
