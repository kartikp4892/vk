"==========================================================================================
" ****** formating the different statement in VHDL
"==========================================================================================
function! Kp_formate(count) range

  if (a:count == '>1')
    echo 'count? : '
    let l:count = nr2char(getchar())

    if (l:count !~ '\d')
      echohl Error
      echo 'Not a number'
      echohl None
      return
    endif

  else
    let l:count = a:count
  endif

  let l:expr = input ("String? ", '')
  let l:l = a:firstline
  let l:max_ln = -1

  while l:l <= a:lastline
    let l:str = getline(l:l)
    let l:ln = match(l:str , l:expr, 0, l:count)
    if (max_ln < ln)
      let l:max_ln = ln
    endif
    let l:l = l:l + 1
  endwhile

  let l:l = a:firstline
  while l:l <= a:lastline
    exe l:l
    let l:str = getline(l:l)
    let l:ln = match(l:str , l:expr, 0, l:count)

    if (l:expr != '$')

      if (l:max_ln > l:ln) && (l:ln > -1)
        if (l:ln > 0)
          exe "normal 0" . l:ln . "l" . (l:max_ln - l:ln) . "i "
        elseif (l:ln == 0)
          exe "normal 0" . (l:max_ln - l:ln) . "i "
        endif
      endif

    else
      if (l:max_ln > l:ln)
        exe "normal $" . (l:max_ln - l:ln) . "a "
      endif
    endif

    let l:l = l:l + 1
  endwhile

endfunction

vmap  :'<,'>call Kp_formate(1)
vmap  :'<,'>call Kp_formate('>1')
vmap . <Up>
"==========================================================================================
"==========================================================================================
