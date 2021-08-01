"""fun! Test()
"""  "perl push @INC, '/home/kartik/Project/RCI/perl';
"""perl <<
"""  #push @INC, '/home/kartik/Project/RCI/perl';
"""  use lib '/home/kartik/Project/RCI/perl';
"""  use get_parameters;
"""  our $units;
"""  #VIM::DoCommand("let g:units = " . $units->conv2str());
"""  #$h1 = { a => [{one => 1, two => 2}, 2, 3], b => {1 => 'one', 2 => 'two'}};
"""  #VIM::DoCommand('let g:units = substitute(string(' . conv2str($units) . '), "[[:cntrl:]]", "", "g")');
"""  VIM::DoCommand("let g:units = " . conv2str($units));
""".
"""endfun
""""set debug=msg

" set path+=/opt/Project/RCI/NGAP/CVS_NGAP/RCI_NGAP/nand_controller/trunk/dv/**
" set lz
" set textwidth=0
" ***************************************************************************
" NGAP
" ***************************************************************************
"let $DV = '/home/kartik/Project/RCI/NGAP/CVS_NGAP/RCI_NGAP/nand_controller/trunk/dv/'
" ### fun! Kp_GoToSourceCode()
" ###   ""----------------------------------------------------------------------------
" ###   "" Balloon Lines
" ###   ""----------------------------------------------------------------------------
" ###   "let l:beval_lines = getline(v:beval_lnum + 1, search("^--$"))
" ###   "let l:beval_expr = join(l:beval_lines, "\n")
" ###   "set balloondelay=1
" ###   "set balloonexpr=l:beval_expr
" ### 
" ###   let l:line = getline(v:beval_lnum)
" ###   let l:line = substitute(l:line, '\s*', '', 'g')
" ###   let l:words = split(l:line, '\~>')
" ###   if (len(l:words) > 1)
" ###     let l:source_code = l:words[1]
" ###     if (getfsize(findfile(split(l:source_code, '::')[0])) <= 0)
" ###       return
" ###     endif
" ###   else
" ###     if (getfsize(findfile(split(l:line, '::')[0])) <= 0)
" ###       return
" ###     endif
" ###     let l:source_code = l:words[0]
" ###   endif
" ### 
" ###   let l:source_list = split(l:source_code, '::')
" ###   if (l:source_list[0] != '')
" ###     "exe 'tabnew ' . findfile(l:source_list[0])
" ###     "if (bufname(2) !~ l:source_list[0])
" ###       if (bufname('#') != '')
" ###         exe 'bwipeout ' . bufname('#')
" ###       endif
" ###       exe 'sp ' . findfile(l:source_list[0])
" ###     "else
" ###     "  exe '1wincmd w'
" ###     "endif
" ###   else
" ###     return
" ###   endif
" ### 
" ###   for l:i in l:source_list[1:-1]
" ###     let l:done = search('\<' . l:i . '\>', 'n')
" ###     if (l:done <= 0)
" ###       echohl Error
" ###       echo l:i . ": Not found in " . l:source_list[0]
" ###       echohl None
" ###       "call getchar()
" ###       "call getchar()
" ###     else
" ###       call search('\<' . l:i . '\>')
" ###     endif
" ###   endfor
" ###   if (len(l:source_list) >= 3)
" ###     exe '1match DiffAdd ''\<' . l:source_list[-2] . '\>'''
" ###   endif
" ### 
" ###   if (len(l:source_list) >= 2)
" ###     exe '2match DiffChange ''\<' . l:source_list[-1] . '\>'''
" ###     exe 'let @/ = ''\<' . l:source_list[-1] . '\>'''
" ###   endif
" ### 
" ###   "let l:done = search(l:source_list[-1], 'n')
" ###   "if (l:done != 0)
" ###   "  exe 'match DiffChange ''\<' . l:source_list[-1] . '\>'''
" ###   "  for l:i in l:source_list
" ###   "    if (l:i == l:source_list[0])
" ###   "      continue
" ###   "    endif
" ###   "    call search(l:i)
" ###   "  endfor
" ###   "  exe 'let @/ = ''\<' . l:source_list[-1] . '\>'''
" ###   "  "normal ngd
" ###   "else
" ###   "  echo l:source_list[-1] . ' Not found in the code'
" ###   "  call getchar()
" ###   "endif
" ### endfun
" ### 
" ###  nmap <silent> <C-LeftMouse> <LeftMouse>:call  Kp_GoToSourceCode()

" ===========================================================================
" Search criteria VS Source code
" ===========================================================================
"fun! Kp_get_cp_definition()
"  let g:cp_dict = {}
"  let l:cpoint = expand("<cword>")
"  if (expand("%:t") =~ "search_criteria.txt")
"    let l:lines = getline(line("."), search('^\s*$', "n") - 1)
"    call map(l:lines, 'substitute(v:val, "^\\s\\+", "", "")')
"
"    for l:line in l:lines
"      if (l:line !~ '^\s*\w')
"        continue
"      endif
"      let l:comma_list = split(l:line, ",")
"      let l:point_list = split(l:comma_list[0], '\.')
"      normal 
"      1
"      "echo l:point_list
"      "return
"      let l:done = search(l:point_list[1] . '\s*:\s*\zscoverpoint')
"      if (l:done <= 0)
"        echohl ErrorMsg
"        echo "coverpoint " . l:point_list[1] . " not found"
"        echohl None
"      endif
"      let l:line_no = line(".") - 1
"      let l:lines1 = getline(line("."), search('\(\/\/.*\)\@<!coverpoint\|endgroup') - 1)
"      for l:line1 in l:lines1
"        let l:line_no += 1
"        "echo line1 . "\n"
"        if (l:line1 =~ '\vbins\s*' . l:point_list[2] . '\s*\=\s*(%(\{|\().*%(\)|\}))')
"          "echo 'kartik' . matchlist(l:line1, '\vbins\s*' . l:point_list[2] . '\s*\=\s*(%(\{|\().*%(\)|\}))')[1]
"          "return
"          let g:cp_dict[l:comma_list[0]] = expand("%:t") . " (line " . l:line_no . "):" . l:point_list[2] . " = "
"          let g:cp_dict[l:comma_list[0]] .= matchlist(l:line1, '\vbins\s*' . l:point_list[2] . '\s*\=\s*(%(\{|\().*%(\)|\}))')[1]
"        endif
"      endfor
"      normal 
"    endfor
"  endif
"endfun
"
"fun! Kp_write_cp_definition()
"  let l:str = ''
"  let l:line = getline(line(".") - 1)
"  let l:line = matchstr(l:line, '\~>\zs.*')
"  let l:cg_key = split(l:line, ",")[0]
"  for l:key in keys(g:cp_dict)
"    if (l:key == l:cg_key)
"      return "Is the definition for all coverbins in coverpoint found in Source File~>YES\n" . 
"        \ "Coments~>" . g:cp_dict[l:key] . "\n--\n"
"    endif
"  endfor
"  return Kp_write_cross()
"endfun
"
"fun! Kp_get_cross()
"  let g:cp_cross_list = {}
"  let l:lines = getline(1, search('\%$','n'))
"  for l:line in l:lines
"    if (l:line =~ '\(\/\/.*\)\@!\<cross\>')
"      let l:key = split(l:line, ':')[0]
"      let l:key = substitute(l:key, '\s\+', '', 'g')
"      let g:cp_cross_list[l:key] = substitute(l:line, '^\s*', '', 'g')
"    endif
"  endfor
"endfun
"
"fun! Kp_write_cross()
"  let l:line = getline(line(".") - 1)
"  let l:line = matchstr(l:line, '\~>\zs.*')
"  let l:cg_str = split(l:line, ",")[0]
"  let l:cg_key = split(l:cg_str, '\.')[1]
"  if (exists('g:cp_cross_list[l:cg_key]'))
"    return "Is the definition for all coverbins in coverpoint found in Source File~>YES\n" . 
"      \ "Coments~>" . expand("%:t") . " (line " . line(".") . "): " . g:cp_cross_list[l:cg_key] . "\n--\n"
"  else
"    return "--\n"
"  endif
"endfun
"
"nmap <silent> ± :call Kp_get_cp_definition()
"nmap ² o=Kp_write_cp_definition()
"nmap à :call Kp_get_cross()

" ===========================================================================
" Go to definition from search_criteria
" ===========================================================================
"set ballooneval
"set balloondelay=1
""fun! MyBalloonExpr(line)
""  return
""endfun
"
"fun! Kp_Go2SouceCode()
"  echo v:beval_lnum
"  let l:line = getline(v:beval_lnum)
"  let l:line = substitute(l:line, '^\s*\|\s*$', '', 'g')
"  exe 'match Keyword ''\%' . v:beval_lnum . 'l''' 
"  let l:words = split(l:line, ',')
"  "echo l:words
"  if (len(l:words) <= 1)
"    return
"  endif
"  let l:bin = l:words[0]
"  let g:b_expr = join(l:words[1:-1], "\n")
"  "let g:b_expr = join(split(l:bin, '\.')[1:-1], "\t\t") . "\n\n" . g:b_expr
"  set bexpr=g:b_expr
"  exe "tabnew " . findfile("ndctl_coverage_pkg.sv")
"  0
"  call search(split(l:bin, '\.')[1])
"  call search(split(l:bin, '\.')[2])
"  exe '1match DiffChange ''\<' . split(l:bin, '\.')[1] . '\>'''
"  exe '2match DiffAdd ''\<' . split(l:bin, '\.')[2] . '\>'''
"  let @/ = '\<' . split(l:bin, '\.')[1] . '\>'
"endfun
"
"nmap <S-LeftMouse> :call Kp_Go2SouceCode()

" ===========================================================================
" Source Code VS Search Criteria
" ===========================================================================
"fun! Kp_getBins()
"  let g:cbins = {}
"  let l:lines = getline(1, search('\%$', 'n'))
"  let l:ln_no = 0
"  for l:line in l:lines
"    let l:ln_no += 1
"    if (l:line =~ '\v(\/\/.*)@<!<covergroup>')
"      let l:cover_group = matchstr(l:line, 'covergroup\s*\zs\w\+')
"    endif
"    if (l:line =~ '\v(\/\/.*)@<!<coverpoint>')
"      let l:cover_point = matchstr(l:line, '^\s*\zs\w\+\ze\s*:')
"    endif
"    if (l:line =~ '\v(\/\/.*)@<!<bins>')
"      let l:bin = matchstr(l:line, 'bins\s*\zs\w\+')
"      let g:cbins[l:cover_point . '.' . l:bin] = expand("%:t") . "(Line " . l:ln_no .  "): " . l:cover_group . "." . l:cover_point . "." . l:bin
"    endif
"  endfor
"endfun
"
"fun! Kp_getCrossBins()
"  let g:crossbins = {}
"  let l:lines = getline(1, search('\%$', 'n'))
"  let l:ln_no = 0
"  for l:line in l:lines
"    let l:ln_no += 1
"    if (l:line =~ 'covergroup')
"      let l:cover_group = matchstr(l:line, 'covergroup\s*\zs\w\+')
"    endif
"    "if (l:line =~ '\v(\/\/.*)@<!<coverpoint>')
"    "  let l:cover_point = matchstr(l:line, '^\s*\zs\w\+\ze\s*:')
"    "endif
"    if (l:line =~ '\v(\/\/.*)@<!<cross>')
"      let l:cover_point = matchstr(l:line, '^\s*\zs\w\+\ze\s*:\s*cross')
"      let g:crossbins[l:cover_point] = expand("%:t") . "(Line " . l:ln_no .  "): " . l:cover_group . "." . l:cover_point
"    endif
"  endfor
"endfun
"
"fun! Kp_getMissingBins()
"  let g:missbins = []
"  for l:bin in keys(g:cbins)
"    let l:done = search('\V\<' . l:bin . '\>')
"    if (l:done <= 0)
"      let g:missbins = add(g:missbins, l:bin)
"    endif
"  endfor
"endfun
"
"fun! Kp_getMissingCrossBins()
"  let g:missCrossbins = []
"  for l:bin in keys(g:crossbins)
"    let l:done = search('\V\<' . l:bin . '\>')
"    if (l:done <= 0)
"      let g:missCrossbins = add(g:missCrossbins, l:bin)
"    endif
"  endfor
"endfun
"
"fun! Kp_printMissingBins()
"  let l:str = "Bins that are missing in Search Criterial but defined in ndctl_coverage_pkg.sv~>"
"  for l:bin in sort(copy(g:missbins))
"    call append(search('\%$'), l:str . g:cbins[l:bin])
"  endfor
"endfun
"
"fun! Kp_printMissingCrossBins()
"  let l:str = "Bins that are missing in Search Criterial but defined in ndctl_coverage_pkg.sv~>"
"  for l:bin in sort(copy(g:missCrossbins))
"    call append(search('\%$'), l:str . g:crossbins[l:bin])
"  endfor
"endfun
"
"nmap ± :call Kp_getBins()
"nmap ² :call Kp_getMissingBins()
"nmap ³ :call Kp_printMissingBins()
"nmap ´ :call Kp_getCrossBins()
"nmap µ :call Kp_getMissingCrossBins()
"nmap ¶ :call Kp_printMissingCrossBins()

" ===========================================================================
" validate.log to log files to search criteria
" ===========================================================================
"let g:ln = 0
"fun! Get_ln_no()
"  let g:ln += 1
"  return g:ln
"endfun
"let s:search_criteria = readfile(findfile('trunk/results/cvg_bin_search_criteria.txt'))
"call map(s:search_criteria, 'substitute(v:val, "^\\s*\\|\\s*$", "", "g")')
"call map(s:search_criteria, '"cvg_bin_search_criteria.txt (Line " . Get_ln_no() . "):\n" . v:val')
"
"fun! Kp_GoToLog()
"  let g:trace = {'log' : '', 'search' : '', 'validate' : ''}
"
"  let l:line_no = v:beval_lnum
"  let l:act_exp = []
"  let l:chks = {}
"  let l:match_list = []
"  while (getline(l:line_no) != '')
"    let l:line = getline(l:line_no)
"    if (l:line =~ '^Checking fields of')
"      let l:log_name = matchstr(l:line, '\w\+\.log\ze\s*$')
"      let l:line2 = matchstr(l:line, '@\s*\zs\d\+')
"    endif
"    if (l:line =~ '^All search criteria belongs to\|^PASS:')
"      let l:line1 = matchstr(l:line, '@\s*\(LINE NO\s*\)\?\zs\d\+')
"      if (l:line =~ '^PASS:')
"        call add(l:act_exp, 'LINE')
"        let l:log_name = matchstr(l:line, '\w\+\.log\ze\s*$')
"
"        call add(l:match_list, '\%' . (l:line1 + 1) . 'l') " FIXME In log file actuals are at next line instead of current
"      endif
"      let l:chks[l:line1] = copy(l:act_exp)
"      let l:act_exp = []
"    endif
"    if (l:line =~ '^Cheking expected and actual value of')
"      call add(l:act_exp, split(l:line, '\s*-\s*')[1])
"    endif
"    if (l:line =~ '^BIN=')
"      let l:bin = matchstr(l:line, '^BIN=\zs.*')
"      let l:idx = 0
"      let l:search_bins = filter(copy(s:search_criteria), 'v:val =~ "\\V" . l:bin')
"
"      if (len(l:search_bins) == 1)
"        let g:trace['search'] = substitute(l:search_bins[0], '^\s*\|\s*$', '', 'g')
"      elseif (len(l:search_bins) > 1)
"        echo "search_criteria.txt : multiple bins found of same name"
"        call getchar()
"        call getchar()
"        call getchar()
"      else
"        echo "No bins are found"
"        call getchar()
"        call getchar()
"        call getchar()
"      endif
"    endif
"    let l:line_no += 1
"  endwhile
"
"  exe 'match Keyword "\%>' . (v:beval_lnum - 1) . 'l\%<' . (l:line_no + 1) . 'l"'
"  let g:trace['validate'] = join(getline(v:beval_lnum, l:line_no - 1), "\n") . "\n"
"
"  if (exists('l:log_name'))
"    let g:trace['log'] = findfile(l:log_name) . "\n"
"    exe 'tabnew ' . findfile(l:log_name)
"
"    for l:i in sort(keys(l:chks))
"      for l:j in l:chks[l:i]
"        exe ': ' . l:i
"        if (l:j == 'LINE')
"          let l:search_ln_no = l:i
"          let l:search_ln_str = getline(l:search_ln_no + 1)
"          let g:trace['log'] = g:trace['log'] . "(Line " . (l:search_ln_no) . " + 1): " . Get_str(l:search_ln_str) . "\n"
"        else
"          let l:search_ln_no = search(matchstr(l:j, '^[[:alnum:]._]\+'), '', l:line2)
"          let l:search_ln_str = getline(".")
"          let g:trace['log'] = g:trace['log'] . "(Line " . l:search_ln_no . "): " . Get_str(l:search_ln_str) . "\n"
"        endif
"      endfor
"    endfor
"
"    exe ':' . l:line1
"    if (exists('l:line2'))
"      exe 'match Keyword "\%>' . (l:line1 - 1) . 'l\%<' . (l:line2 + 1) . 'l"'
"    else
"      exe 'match Keyword "' . join(l:match_list, '\|'). '"'
"    endif
"  endif
"endfun
"
"fun! Get_str(line)
"  let l:line = a:line
"  let l:line = substitute(l:line, '\V*', '', 'g')
"  let l:line = substitute(l:line, '#', '', 'g')
"  let l:line = substitute(l:line, '^\s*\|\s*$', '', 'g')
"  return l:line
"endfun
"
"fun! Print_trace()
"  let l:str = ''
"  for [l:key, l:val] in items(g:trace)
"    let l:str .= l:key . "~>" . l:val . "\n"
"  endfor
"  let l:str .= "--\n"
"  return l:str
"endfun
"
"nmap <C-RightMouse> <LeftMouse>:call Kp_GoToLog()
"nmap à Go=Print_trace()

" ===========================================================================
" Functional Coverage Results document
" ===========================================================================
"fun! Kp_TraceResults()
"  let l:line = getline(v:beval_lnum)
"  let l:match_str1 = matchstr(getline(v:beval_lnum + 1), '\w\+\ze\s*$')
"  let l:match_str2 = matchstr(getline(v:beval_lnum + 2), 'covergroup instance\s\+\zs\w\+')
"  let l:line = substitute(l:line, '\s*', '', 'g')
"  let l:words = split(l:line, '\~>')
"  if (len(l:words) > 1)
"    let l:source_code = l:words[1]
"    if (getfsize(findfile(split(l:source_code, '::')[0])) <= 0)
"      return
"    endif
"  else
"    if (getfsize(findfile(split(l:line, '::')[0])) <= 0)
"      return
"    endif
"    let l:source_code = l:words[0]
"  endif
"
"  let l:source_list = split(l:source_code, '::')
"  if (l:source_list[0] != '')
"    exe 'tabnew ' . findfile(l:source_list[0])
"  else
"    return
"  endif
"
"  if (l:match_str1 != '')
"    exe '1match DiffChange ''\<' . l:match_str1 . '\>'''
"  endif
"
"  if (l:match_str2 != '')
"    exe '2match DiffAdd ''\<' . l:match_str2 . ''''
"  endif
"
"  "let l:done = search(l:source_list[-1], 'n')
"  "if (l:done != 0)
"  "  exe 'match DiffChange ''\<' . l:source_list[-1] . '\>'''
"  "  for l:i in l:source_list
"  "    if (l:i == l:source_list[0])
"  "      continue
"  "    endif
"  "    call search(l:i)
"  "  endfor
"  "  exe 'let @/ = ''\<' . l:source_list[-1] . '\>'''
"  "  "normal ngd
"  "else
"  "  echo 'not done'
"  "  call getchar()
"  "endif
"endfun
"
"nmap <silent> <C-RightMouse> <LeftMouse>:call  Kp_TraceResults()

