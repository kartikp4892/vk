fun! comments#header#Kp_set_header()
  if (&filetype == 'sv')
    let l:c_start = '//'
  else " Implement for other launguage
    let l:c_start = '//'
  endif

  let l:line =  l:c_start . repeat("-", 80) . "\n" .
               \l:c_start . repeat("-", 80) . "\n"
  call append(0, split(l:line, "\n"))
endfun

let s:spath = expand("<sfile>:h") . "/"
"-------------------------------------------------------------------------------
" set_header_from_file: Function
"-------------------------------------------------------------------------------
function! comments#header#set_header_from_file(skelaton_file)
  let file = s:spath . a:skelaton_file
  let header_lines = readfile(file)
  normal ggO=header_lines
endfunction
