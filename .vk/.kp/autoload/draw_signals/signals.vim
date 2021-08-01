"-------------------------------------------------------------------------------
" Draw Clock and signals
"-------------------------------------------------------------------------------
fun! draw_signals#signals#clock()
  let l:virtualedit = &virtualedit
  set virtualedit=all
  return "___/\<Up>___\<Down>\\"
endfun

let s:signal_state = -1

fun! draw_signals#signals#signal(state)

  set virtualedit=all
  if (a:state == "high")

    if (s:signal_state == 0)
      let l:ret_val = "/\<Up>_______\<Down>"
    elseif (s:signal_state == 1)
      let l:ret_val = "\<Up>-_______\<Down>"
    else
      let l:ret_val = "\<Up>_______\<Down>"
    endif
    let s:signal_state = 1

  elseif (a:state == "low")
    
    if (s:signal_state == 0)
      let l:ret_val = "-_______"
    elseif (s:signal_state == 1)
      let l:ret_val = "\\_______"
    else
      let l:ret_val = "_______"
    endif
    let s:signal_state = 0

  endif

  return l:ret_val

endfun

let s:data_state = -1

fun! draw_signals#signals#data_bus(state)
  set virtualedit=all

  if (a:state == "high")
    if (s:data_state == 0)
      let l:ret_val = "maa\\/\<Up>______\<Down>`aa\<Down>/\\______\<Up>"
    elseif (s:data_state == 1)
      let l:ret_val = "maa\<Up>-_______\<Down>`aa\<Down>-_______\<Up>"
    else
      let l:ret_val = "maa\<Up>_______\<Down>`aa\<Down>_______\<Up>"
    endif

    let s:data_state = 1
  elseif (a:state == "low")
    if (s:data_state == 0)
      let l:ret_val = "maa\<Up>-_______\<Down>`aa\<Down>-_______\<Up>"
    elseif (s:data_state == 1)
      let l:ret_val = "maa\\/\<Up>______\<Down>`aa\<Down>/\\______\<Up>"
    else
      let l:ret_val = "maa\<Up>_______\<Down>`aa\<Down>_______\<Up>"
    endif

    let s:data_state = 0
  endif

  return l:ret_val
endfun

function! draw_signals#signals#hi_impedence_data_bus(state)
  set virtualedit=all

  if (a:state == "high")
    if (s:data_state == 0)
      "let l:ret_val = "maa\\/\<Up>______\<Down>`aa\<Down>/\\______\<Up>"
      let l:ret_val = "maa/\<Up>______\<Down>`aa\<Down>\\______\<Up>"
    elseif (s:data_state == 1)
      let l:ret_val = "maa\<Up>-_______\<Down>`aa\<Down>-_______\<Up>"
    else
      let l:ret_val = "maa\<Up>_______\<Down>`aa\<Down>_______\<Up>"
    endif

    let s:data_state = 1
  elseif (a:state == "low")
    if (s:data_state == 0)
      let l:ret_val = "-_______"
    elseif (s:data_state == 1)
      let l:ret_val = "maa\\_______mb`aa\<Down>/`ba"
    else
      let l:ret_val = "_______"
    endif

    let s:data_state = 0
  endif

  return l:ret_val
endfunction

let s:seperator = ':'
"-------------------------------------------------------------------------------
" add_seperator_after_each_clk: Function
" Add seperator at each clock cycle. Seperator is added to the column lines where
" start of the line in range has 'C' characters.
"-------------------------------------------------------------------------------
function! draw_signals#signals#add_seperator_after_each_clk() range
  let l:lines = getline(a:firstline, a:lastline)
  let l:line = l:lines[0]
  let l:columns = []
  while match(l:line , 'C') != -1
    call add(l:columns, match(l:line , 'C'))
    let l:line = substitute(l:line , 'C', s:seperator, '')
  endwhile
  let l:lines[0] = l:line
  let l:new_lines = []
  for l:line in l:lines
    let l:chars = split(l:line, '\zs')
    for l:off in l:columns
      if !exists('l:chars[l:off]')
        let l:line .= repeat(" ", l:off - len(l:line) + 1)
        let l:chars = split(l:line, '\zs')
      endif
      if (l:chars[l:off] =~ '^ $\|^$')
        let l:chars[l:off] = s:seperator
        let l:line = join(l:chars, '')
      endif
    endfor
    call add(l:new_lines, l:line)
  endfor
  call setline(a:firstline, l:new_lines)
endfunction

"-------------------------------------------------------------------------------
" Draw Block Diagram
"-------------------------------------------------------------------------------
fun! draw_signals#signals#draw_block() range
  echo "Enter block style (1 or 2)"
  let l:choice = nr2char(getchar())
  if (l:choice == 1)
    let ch1 = '+'
    let ch2 = '+'
    let hsep = '-'
  else
    let ch1 = ' '
    let ch2 = '|'
    let hsep = '_'
  endif
  let [@_, @_, l:col1, l:off1] = getpos("'<")
  let [@_, @_, l:col2, l:off2] = getpos("'>")

  let l:vcol1 = l:col1 + l:off1
  let l:vcol2 = l:col2 + l:off2

  let l:vcolmin = min([l:vcol1, l:vcol2])
  let l:vcolmax = max([l:vcol1, l:vcol2])

  call setpos(".", [0, a:firstline, l:vcolmin, 0])
  exe 'normal r' . ch1

  call setpos(".", [0, a:lastline, l:vcolmin, 0])
  exe 'normal r' . ch2

  call setpos(".", [0, a:firstline, l:vcolmax, 0])
  exe 'normal r' . ch1

  call setpos(".", [0, a:lastline, l:vcolmax, 0])
  exe 'normal r' . ch2

  if (a:firstline != a:lastline)
    for l:lnum in range(a:firstline + 1, a:lastline - 1)
      call setpos(".", [0, l:lnum, l:vcolmin, 0])
      normal r|

      call setpos(".", [0, l:lnum, l:vcolmax, 0])
      normal r|
    endfor
  endif

  if (l:vcolmin != l:vcolmax)
    for l:cnum in range(l:vcolmin + 1, l:vcolmax - 1)
      call setpos(".", [0, a:firstline, l:cnum, 0])
      exe 'normal r' . hsep

      call setpos(".", [0, a:lastline, l:cnum, 0])
      exe 'normal r' . hsep
    endfor
  endif
endfun

"-------------------------------------------------------------------------------
" Draw conditional Block 
"-------------------------------------------------------------------------------
fun! draw_signals#signals#draw_conditional_block() range
  let [@_, @_, l:col1, l:off1] = getpos("'<")
  let [@_, @_, l:col2, l:off2] = getpos("'>")

  let l:vcol1 = l:col1 + l:off1
  let l:vcol2 = l:col2 + l:off2

  let l:vcolmin = min([l:vcol1, l:vcol2])
  let l:vcolmax = max([l:vcol1, l:vcol2])
  
  let l:midline = (a:firstline + a:lastline) / 2


  if (a:firstline != a:lastline)
    let l:offset = 0
    for l:lnum in reverse(range(a:firstline , l:midline))
      call setpos(".", [0, l:lnum, l:vcolmin + l:offset, 0])
      "normal r╱
      normal r/
      let l:offset += 1
    endfor

    let l:offset = 0
    for l:lnum in range(l:midline + 1, a:lastline)
      call setpos(".", [0, l:lnum, l:vcolmin + l:offset, 0])
      "normal r╲
      normal r\
      let l:offset += 1
    endfor

    let l:offset = 0
    for l:lnum in reverse(range(a:firstline , l:midline))
      call setpos(".", [0, l:lnum, l:vcolmax - l:offset, 0])
      "normal r╲
      normal r\
      let l:offset += 1
    endfor

    let l:offset = 0
    for l:lnum in range(l:midline + 1, a:lastline)
      call setpos(".", [0, l:lnum, l:vcolmax - l:offset, 0])
      "normal r╱
      normal r/
      let l:offset += 1
    endfor

  endif

  if (l:vcolmin != l:vcolmax)
    " First line
    let l:line = getline(a:firstline)
    let l:str = matchstr(l:line, '/\s\+\\')
    let l:str = tr(l:str, ' ', '-')
    let l:str = escape(l:str, '\') 
    let l:line = substitute(l:line, '/\s\+\\', l:str, '')
    call setline(a:firstline, l:line)

    " Last line
    let l:line = getline(a:lastline)
    let l:str = matchstr(l:line, '\\\s\+/')
    let l:str = tr(l:str, ' ', '-')
    let l:str = escape(l:str, '\') 
    let l:line = substitute(l:line, '\\\s\+/', l:str, '')
    call setline(a:lastline, l:line)
  endif

endfun

"-------------------------------------------------------------------------------
" draw_arrow: Function
"-------------------------------------------------------------------------------
function! draw_signals#signals#draw_arrow() range
  let [@_, @_, l:col1, l:off1] = getpos("'<")
  let [@_, @_, l:col2, l:off2] = getpos("'>")

  let l:vcol1 = l:col1 + l:off1
  let l:vcol2 = l:col2 + l:off2

  let l:vcolmin = min([l:vcol1, l:vcol2])
  let l:vcolmax = max([l:vcol1, l:vcol2])

  if (a:firstline == a:lastline) && (l:vcolmin == l:vcolmax)
    return
  endif

  echo "enter direction: <Up>, <Down>, <Left>, <Right>: "
  let l:direction1 = getchar()

  if (a:firstline == a:lastline)
    if (l:direction1 == "\<Left>")
      call setpos(".", [0, a:firstline, l:vcolmin, 0])
      normal r<

      for l:col_nr in range(l:vcolmin + 1, l:vcolmax)
        call setpos(".", [0, a:firstline, l:col_nr, 0])
        normal r-
      endfor
    elseif (l:direction1 == "\<Right>")
      call setpos(".", [0, a:firstline, l:vcolmax, 0])
      normal r>

      for l:col_nr in range(l:vcolmin, l:vcolmax - 1)
        call setpos(".", [0, a:firstline, l:col_nr, 0])
        normal r-
      endfor
    endif

    return
  endif

  if (l:vcolmin == l:vcolmax)
    if (l:direction1 == "\<Up>")
      call setpos(".", [0, a:firstline, l:vcolmin, 0])
      normal rA

      for l:line_nr in range(a:firstline + 1, a:lastline)
        call setpos(".", [0, l:line_nr, l:vcolmin, 0])
        normal r|
      endfor
    endif

    if (l:direction1 == "\<Down>")
      call setpos(".", [0, a:lastline, l:vcolmin, 0])
      normal rV

      for l:line_nr in range(a:firstline, a:lastline - 1)
        call setpos(".", [0, l:line_nr, l:vcolmin, 0])
        normal r|
      endfor
    endif

    return
  endif

  let l:direction2 = getchar()
  
  " Left arrow
  if (l:direction1 == "\<Left>" && l:direction2 == "\<Up>")
    call setpos(".", [0, a:firstline, l:vcolmin, 0])
    normal rA

    call setpos(".", [0, a:lastline, l:vcolmin, 0])
    normal r+

    for l:line_nr in range(a:firstline + 1, a:lastline - 1)
      call setpos(".", [0, l:line_nr, l:vcolmin, 0])
      normal r|
    endfor

    for l:col_nr in range(l:vcolmin + 1, l:vcolmax - 1)
      call setpos(".", [0, a:lastline, l:col_nr, 0])
      normal r-
    endfor
  " Right arrow
  elseif (l:direction1 == "\<Right>" && l:direction2 == "\<Up>")
    call setpos(".", [0, a:firstline, l:vcolmax, 0])
    normal rA

    call setpos(".", [0, a:lastline, l:vcolmax, 0])
    normal r+

    for l:line_nr in range(a:firstline + 1, a:lastline - 1)
      call setpos(".", [0, l:line_nr, l:vcolmax, 0])
      normal r|
    endfor

    for l:col_nr in range(l:vcolmin, l:vcolmax - 1)
      call setpos(".", [0, a:lastline, l:col_nr, 0])
      normal r-
    endfor
  " Up arrow
  elseif (l:direction1 == "\<Up>" && l:direction2 == "\<Right>")
    call setpos(".", [0, a:firstline, l:vcolmax, 0])
    normal r>

    call setpos(".", [0, a:firstline, l:vcolmin, 0])
    normal r+

    for l:col_nr in range(l:vcolmin + 1, l:vcolmax - 1)
      call setpos(".", [0, a:firstline, l:col_nr, 0])
      normal r-
    endfor

    for l:line_nr in range(a:firstline + 1, a:lastline)
      call setpos(".", [0, l:line_nr, l:vcolmin, 0])
      normal r|
    endfor
  " Down arrow
  elseif (l:direction1 == "\<Down>" && l:direction2 == "\<Right>")
    call setpos(".", [0, a:lastline, l:vcolmax, 0])
    normal r>

    call setpos(".", [0, a:lastline, l:vcolmin, 0])
    normal r+

    for l:col_nr in range(l:vcolmin + 1, l:vcolmax - 1)
      call setpos(".", [0, a:lastline, l:col_nr, 0])
      normal r-
    endfor

    for l:line_nr in range(a:firstline, a:lastline - 1)
      call setpos(".", [0, l:line_nr, l:vcolmin, 0])
      normal r|
    endfor
  elseif (l:direction1 == "\<Down>" && l:direction2 == "\<Left>")
    call setpos(".", [0, a:lastline, l:vcolmin, 0])
    normal r<

    call setpos(".", [0, a:lastline, l:vcolmax, 0])
    normal r+

    for l:col_nr in range(l:vcolmin + 1, l:vcolmax - 1)
      call setpos(".", [0, a:lastline, l:col_nr, 0])
      normal r-
    endfor

    for l:line_nr in range(a:firstline, a:lastline - 1)
      call setpos(".", [0, l:line_nr, l:vcolmax, 0])
      normal r|
    endfor
  elseif (l:direction1 == "\<Up>" && l:direction2 == "\<Left>")
    call setpos(".", [0, a:firstline, l:vcolmin, 0])
    normal r<

    call setpos(".", [0, a:firstline, l:vcolmax, 0])
    normal r+

    for l:col_nr in range(l:vcolmin + 1, l:vcolmax - 1)
      call setpos(".", [0, a:firstline, l:col_nr, 0])
      normal r-
    endfor

    for l:line_nr in range(a:firstline + 1, a:lastline)
      call setpos(".", [0, l:line_nr, l:vcolmax, 0])
      normal r|
    endfor
  elseif (l:direction1 == "\<Left>" && l:direction2 == "\<Down>")
    call setpos(".", [0, a:lastline, l:vcolmin, 0])
    normal rV

    call setpos(".", [0, a:firstline, l:vcolmin, 0])
    normal r+

    for l:col_nr in range(l:vcolmin + 1, l:vcolmax)
      call setpos(".", [0, a:firstline, l:col_nr, 0])
      normal r-
    endfor

    for l:line_nr in range(a:firstline + 1, a:lastline - 1)
      call setpos(".", [0, l:line_nr, l:vcolmin, 0])
      normal r|
    endfor
  elseif (l:direction1 == "\<Right>" && l:direction2 == "\<Down>")
    call setpos(".", [0, a:lastline, l:vcolmax, 0])
    normal rV

    call setpos(".", [0, a:firstline, l:vcolmax, 0])
    normal r+

    for l:col_nr in range(l:vcolmin, l:vcolmax - 1)
      call setpos(".", [0, a:firstline, l:col_nr, 0])
      normal r-
    endfor

    for l:line_nr in range(a:firstline + 1, a:lastline - 1)
      call setpos(".", [0, l:line_nr, l:vcolmax, 0])
      normal r|
    endfor
  else
    echohl WarningMsg
    echo l:direction1 . ": Choice is not valid!!!"
    echohl None
  endif

endfunction
