let s:hex_expr = '0[xX][0-9A-Za-z]*'
let s:hex_no   = '0[xX][0-9A-Za-z]\+'
" Expression that is not a hex numeber
let s:not_hex = '\(' . s:hex_expr . '\)\@<!\(0[xX]\)\@!'
" Expression that is hex or decimal
let s:hex_or_decimal = s:not_hex . '-\?\d\+' . '\|' . s:hex_no

"-------------------------------------------------------------------------------
" compare_lines: Function
"-------------------------------------------------------------------------------
function! s:compare_lines(lines)
  " As of now consider only two lines
  " decimal numbers
  let l:tmp_ln1 = substitute(a:lines[0], s:not_hex . '-\?\d\+', '0', 'g')
  let l:tmp_ln2 = substitute(a:lines[1], s:not_hex . '-\?\d\+', '0', 'g')

  " hex numbers
  let l:tmp_ln1 = substitute(l:tmp_ln1 , s:hex_no, '0', 'g')
  let l:tmp_ln2 = substitute(l:tmp_ln2 , s:hex_no, '0', 'g')

  if (l:tmp_ln1 != l:tmp_ln2)
    return 0
  else
    return 1
  endif

endfunction

"-------------------------------------------------------------------------------
" perform_arith: Function
" Perform arithmatic operation on hex or decimal and produce result accordingly
"-------------------------------------------------------------------------------
function! s:perform_arith(expr)
  let [op1, op2] = split(a:expr, '+\|-')
  if (eval(op1) =~ '^0x\|^0X')
    " Len of hex number
    let len = len(eval(op1)) - 2
    if (eval(op1) =~ '^0x')
      return printf("0x%0" . len . "x", eval(a:expr))
    else
      return printf("0X%0" . len . "X", eval(a:expr))
    endif
  else
    let len = len(eval(op1))
    if (eval(op1) =~ '^0\+')
      
    endif
    return printf("%0" . len . "d", eval(a:expr))
  endif
endfunction

"-------------------------------------------------------------------------------
" anaylize_lines: Function
"-------------------------------------------------------------------------------
function! common#append_line_in_series#append_lines() range
  let l:lines = getline(a:firstline, a:lastline)
  if (len(l:lines) < 2)
    return
  endif

  let l:line_after_last = []
  let l:line_before_first = []

  call map(l:lines, 'substitute(v:val, "^\\s\\+\\|\\s\\+$", "", "g")')

  if (!s:compare_lines(l:lines))
    echohl Error
    echo "Lines are not equal. Couldn't perform special paste!!!"
    echohl None
    return
  endif

  let l:offset1 = 0
  let l:offset2 = 0
  let l:save_off = 0
  while (l:offset1 <= len(l:lines[0]) && l:offset2 <= len(l:lines[1]))
    let l:match1 = matchstr(l:lines[0], s:hex_or_decimal, l:offset1)
    let l:match2 = matchstr(l:lines[1], s:hex_or_decimal, l:offset2)

    " If not found any further numbers then save last sub-string and exit
    if (l:match1 == '') || (l:match2 == '')
      call add(l:line_after_last, strpart(l:lines[0], l:save_off))
      call add(l:line_before_first, strpart(l:lines[0], l:save_off))

      break
    endif

    let l:end_off1 = matchend(l:lines[0], s:hex_or_decimal, l:offset1)
    let l:end_off2 = matchend(l:lines[1], s:hex_or_decimal, l:offset2)

    if (l:match1 != l:match2)
      let l:stride = l:match2 - l:match1
      " Calculate matching nr of first and last line in the range
      let l:first_ln_nr = matchstr(l:lines[0], s:hex_or_decimal, l:offset1)
      let l:last_ln_nr = matchstr(l:lines[-1], s:hex_or_decimal, l:offset2)

      let l:start_off1 = match(l:lines[0], s:hex_or_decimal, l:offset1)
      let l:start_off2 = match(l:lines[1], s:hex_or_decimal, l:offset2)

      call add(l:line_after_last, strpart(l:lines[0], l:save_off, (l:start_off1 - l:save_off)))
      call add(l:line_after_last, [l:last_ln_nr, l:stride])

      call add(l:line_before_first, strpart(l:lines[0], l:save_off, (l:start_off1 - l:save_off)))
      call add(l:line_before_first, [l:first_ln_nr, l:stride])

      """echohl Error
      """echo l:line_before_first
      """echo l:line_after_last
      """echohl None

      " Save the offset for next iteration
      let l:save_off = l:end_off1

    endif

    let l:offset1 = l:end_off1
    let l:offset2 = l:end_off2

  endwhile

  let l:ln_before = a:firstline - 1
  let l:ln_after = a:lastline
  let l:direction = getchar()

  while(l:direction == "\<Down>") || (l:direction == "\<Up>")
    if (l:direction == "\<Down>")
      let l:line = join(map(deepcopy(l:line_after_last), '(type(v:val) == type([])) ? 
                                                            \s:perform_arith("v:val[0] + v:val[1]") :
                                                            \ v:val'), '')
      call map(l:line_after_last, '(type(v:val) == type([])) ? 
                                  \ ([s:perform_arith("v:val[0] + v:val[1]"), v:val[1]]) : v:val')
      call append(l:ln_after , repeat(' ', indent(l:ln_after)) . l:line)
      let l:ln_after += 1
      exe l:ln_after
    elseif (l:direction == "\<Up>")
      let l:line = join(map(deepcopy(l:line_before_first), '(type(v:val) == type([])) ? s:perform_arith("v:val[0] - v:val[1]") : v:val'), '')
      call map(l:line_before_first, '(type(v:val) == type([])) ? ([s:perform_arith("v:val[0] - v:val[1]"), v:val[1]]) : v:val')
      call append(l:ln_before, repeat(' ', indent(l:ln_before + 1)) . l:line)
      let l:ln_after += 1
      exe l:ln_before
    endif
    normal zz
    exe 'match Visual /\%>' . (a:firstline - 1) . 'l\%<' . (l:ln_after + 1) . 'l/'
    redraw

    let l:direction = getchar()
  endwhile
  exe 'match None /\%>' . (a:firstline - 1) . 'l\%<' . (l:ln_after + 1) . 'l/'
  redraw!
endfunction


"-------------------------------------------------------------------------------
" Increment numbers matching regex in highlighted range
"-------------------------------------------------------------------------------
function! common#append_line_in_series#incr_numbers() range
  let l:lines = getline(a:firstline, a:lastline)
  if (len(l:lines) < 2)
    return
  endif

  call map(l:lines, 'substitute(v:val, "^\\s\\+\\|\\s\\+$", "", "g")')

  let l:expr = input ("Pattern? ", '')
  let l:l = a:firstline
  let l:num = 0
  while l:l <= a:lastline
    exe l:l
    let l:curline = getline(l:l)

    if (l:expr == '$')

      exe 'normal A' . l:num . ''

    else
      let l:substr = matchstr(l:curline , l:expr)
      let l:substr = substitute(l:substr, '\v\d+', l:num, 'g')
      let l:replace = substitute(l:curline, l:expr, l:substr, 'g')
      exe 'normal 0Di' . l:replace . ''
    endif

    let l:num = l:num + 1
    let l:l = l:l + 1
  endwhile
endfunction





