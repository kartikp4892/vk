"-------------------------------------------------------------------------------
" get_map_word: Function
"-------------------------------------------------------------------------------
function! expression_map#map#get_map_word()
  let l:line = getline('.')
  let l:start = col('.') - 1
  let mapword = ""
  while l:start > 0 && l:line[l:start - 1] =~ '\k'
    let mapword = l:line[l:start - 1] . mapword
    let l:start -= 1
  endwhile
  return mapword
endfunction

"-------------------------------------------------------------------------------
" remove_map_word: Function
"-------------------------------------------------------------------------------
function! expression_map#map#remove_map_word()
  let mword = expression_map#map#get_map_word()

  if (mword == '')
    return
  endif

  let save_cursor = getpos(".")
  s/\v\w+%#//
  " Update cursor column
  let save_cursor[2] -= strlen(mword)
  call setpos(".", save_cursor)
endfunction


