"-------------------------------------------------------------------------------
" s:GetTemplete: Function
"-------------------------------------------------------------------------------
function! s:GetTemplete(char, ...)
  return common#mov_thru_user_mark#get_template(a:char, a:000)
endfunction

"-------------------------------------------------------------------------------
" _set_indent: Function
"-------------------------------------------------------------------------------
function! s:_set_indent(offset)
  return '=common#indent#imode_set_indent(' . a:offset . ')'
endfunction

" Insert text at the begning of the file if text is not found in the file.
function! s:_insert_if_not_exists(text)
  if (search(a:text, 'bn') == 0)
    let saveview = winsaveview()
    call append(0, a:text)
    " Added line so adjust lnum 
    let saveview['lnum'] += 1
    call winrestview(saveview)
  endif
endfunction

function! cpp#fileio#ifstream_open()
  call s:_insert_if_not_exists('#include <fstream>')
  let str = 'ifstream infile;' .
           \ printf('infile.open(maa%0s);`aa', s:GetTemplete('a', 'file'))

  return str
endfunction

function! cpp#fileio#ofstream_open()
  if (search('#include <fstream>', 'bn') == 0)
    let saveview = winsaveview()
    call append(0, "#include <fstream>")
    " Added line so adjust lnum 
    let saveview['lnum'] += 1
    call winrestview(saveview)
  endif

  let str = 'ofstream outfile;' .
           \ printf('outfile.open(maa%0s);`aa', s:GetTemplete('a', 'file'))

  return str
endfunction

function! cpp#fileio#seekp()
  let str = printf('seekp(maa%0s)`aa', s:GetTemplete('a', 'n'))
  return str
endfunction

function! cpp#fileio#seekg()
  let str = printf('seekg(%0s)', s:GetTemplete('a', 'n'))
  return str
endfunction







