function! common#utils#trim(str)
  return substitute(a:str, '\v^\s+|\s+$', '' ,'g')
endfunction

function! common#utils#search_in_buffer(...)
  TVarArg ['ptrn', @/]
  let prev_file = ''
  while (!search(ptrn, 'We') && prev_file != expand('%:p'))
    let prev_file = expand('%:p')
    n
    1
  endwhile

  normal zz
endfunction

