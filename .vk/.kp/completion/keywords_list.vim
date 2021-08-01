"-------------------------------------------------------------------------------
" Autocommand
"-------------------------------------------------------------------------------
" If aucmd already defined then skip
if !exists('s:au_defined')
  autocmd Bufwinenter *.sv exe 'so ' . expand('<sfile>')
  autocmd Bufwinenter *.svh exe 'so ' . expand('<sfile>')
  autocmd Bufwinenter *.v exe 'so ' . expand('<sfile>')
  autocmd Bufwinenter *.vhd exe 'so ' . expand('<sfile>')
  autocmd Bufwinenter *.pl exe 'so ' . expand('<sfile>')
  autocmd Bufwinenter *.pm exe 'so ' . expand('<sfile>')
  autocmd Bufwinenter *.vim exe 'so ' . expand('<sfile>')
  " VBA file
  autocmd Bufwinenter *.bas exe 'so ' . expand('<sfile>')
  " C++ file
  autocmd Bufwinenter *.cpp exe 'so ' . expand('<sfile>')
  " php
  autocmd Bufwinenter *.php exe 'so ' . expand('<sfile>')
  " python
  autocmd Bufwinenter *.py exe 'so ' . expand('<sfile>')
  " Matlab File
  autocmd Bufwinenter *.m exe 'so ' . expand('<sfile>')

  " Scala
  autocmd Bufwinenter *.scala exe 'so ' . expand('<sfile>')

  " setting formatoption
  autocmd Bufwinenter * set fo=cql
  let s:au_defined = 1
endif
"-------------------------------------------------------------------------------

if (&filetype == 'vhd')
  let b:fname1 = "vhdl/vhdl.txt"
  let b:fname2 = "vhdl/vhdl1.txt"
elseif (&filetype =~ '^sv$\|^verilog$')
  let b:fname1 = "sv/ovm.txt|sv/uvm.txt"
  let b:fname2 = "sv/ovm_macro.txt|sv/uvm_macros.txt"
  let b:fname3 = "sv/sv.txt|sv/sv1.txt" " SV
elseif (&filetype == 'perl')
  let b:fname1 = "perl/perl.txt"
  let b:fname2 = "perl/html-element.txt|perl/html-treebuilder-xpath.txt|perl/text-csv.txt|perl/web-scraper.txt|perl/www-mechanize-firefox.txt|perl/www-mechanize.txt|perl/use-modules.txt|perl/win32-ole.txt|perl/perl-tk.txt|perl/json-parse.txt|perl/www-selenium.txt|perl/HTML-TableExtract.txt|perl/parallel-forkManager.txt|perl/tie-file.txt"
  let b:fname3 = "perl/my-perl-package.txt" " My Local Packages
elseif (&filetype == 'vim')
  let b:fname1 = "vim/vim.txt"
  let b:fname2 = "vim/vim.txt" " FIXME
elseif (&filetype == 'vb')
  let b:fname1 = "vba/vba.txt"
  let b:fname2 = "vba/vba.txt" " FIXME
elseif (&filetype == 'cpp')
  let b:fname1 = "cpp/cpp.txt"
  let b:fname2 = "cpp/cpp.txt"  " FIXME
elseif (&filetype == 'matlab')
  let b:fname1 = "matlab/matlab.txt"  " FIXME
  let b:fname2 = "matlab/matlab.txt"
elseif (&filetype == 'php')
  let b:fname1 = "php/php.txt|php/php_filesystem.txt"
  let b:fname2 = "html/html.txt"
elseif (&filetype == 'python')
  let b:fname1 = "python/csv.txt|python/regex.txt"
  let b:fname2 = "python/mechanize.txt|python/beautifulsoup.txt|python/xlrd.txt"
elseif (&filetype =~ '^scala$')
  let b:fname1 = "scala/spinalHDL.txt"
  let b:fname2 = "scala/spinalHDL.txt"
  let b:fname3 = "scala/spinalSIM.txt" " FIXME
else
  finish
endif


"-------------------------------------------------------------------------------
" Mappings local to buffer
"-------------------------------------------------------------------------------
" <S-Tab>
if (exists("b:fname3"))
  inoremap <buffer> <C-Space> =(pumvisible() == 0) ? '=<SID>Kp_get_longest(my_list3)
                                  \=<SID>Kp_user_complete(my_list3)'
                               \: ''
endif

"|| inoremap <buffer> <S-Tab> =(pumvisible() == 0) ? '=<SID>Kp_get_longest(my_list2)
"||                                 \=<SID>Kp_user_complete(my_list2)'
"||                              \: ''

inoremap <buffer> <S-Tab> =(pumvisible() == 0) ? '=<SID>Kp_user_complete(my_list2)' : ''
inoremap <buffer> <C-Tab> =(pumvisible() == 0) ? ('=<SID>Kp_get_longest(my_list1)') : ('')

"-- OLD -- inoremap <buffer> <Tab> d$=<SID>Kp_tab_expr()maa$a"`aa
inoremap <buffer> <Tab> =<SID>Kp_tab_expr()
" <M-N>
inoremap <buffer> î =(pumvisible() == 1) ? '' : 'î'
"-------------------------------------------------------------------------------

if exists('b:fun_defined')
  " user defined completion list

  if (exists("b:fname3"))
    let my_list3 = <SID>Kp_ParseFile(b:fname3)
  endif

  let my_list2 = <SID>Kp_ParseFile(b:fname2)

  " list of keywords parsed from file
  let b:comp_list = <SID>Kp_ParseFile(b:fname1)
  let my_list1 = b:comp_list

  finish

endif

let b:src_dir = expand('<sfile>:h') . '/'
let b:comp_list = []
let b:words = {}
let b:longest = 1

" ***************************************************************************
" Get list of keywords from the file
" ***************************************************************************
fun! s:Kp_ParseFile(files)
  let l:lines = []
  let l:files = split(a:files, '|')
  for l:file in l:files
    call extend(l:lines, readfile(b:src_dir . l:file))
  endfor
  let l:ele = copy(b:words)
  let l:keyword_list = []
  let l:key = ''
  let l:value = ''
  for line in l:lines
    let line = substitute(line, '\s*$', '', 'g')
    if (line =~ '^#\|^\s*$')
      continue
    elseif (line =~ '\s*\~>\s*')
      if (line =~ '\~>\s*$')
        let [l:key] = split(line, '\s*\~>\s*')
        let l:value = ' '
      else
        let [l:key, l:value] = split(line, '\s*\~>\s*')
      endif
      let l:ele[eval("l:key")] = l:value
      "exe "normal o" . strtrans(line)
      "exe "normal o" . (line)
    elseif (line =~ '^\s*\\')
      let l:value = substitute(l:value . matchstr(line, '^\s*\\\zs.*'), '', "\n", 'g')
      let l:ele[eval("l:key")] = l:value
    elseif (line =~ "^--$") " Save and empty dictionary element
      if (!empty(l:ele) && empty(filter(deepcopy(l:keyword_list), '(type(v:val) == 4) ? v:val == l:ele : 0')))
        call add(l:keyword_list, copy(l:ele))
      endif
      let l:ele = copy(b:words)
      continue
    else
      if (empty(filter(deepcopy(l:keyword_list), '(type(v:val) == 1) ? v:val == line : 0')))
        call add(l:keyword_list, line)
      endif
    endif
  endfor
  return l:keyword_list
endfun

" ***************************************************************************
" Invoke pum for list of competions
" ***************************************************************************
fun! Kp_complete_keyword(findstart, base)
  " locate the start of the word
  if a:findstart
    let l:line = getline('.')
    let l:start = col('.') - 1
    while l:start > 0 && l:line[l:start - 1] =~ '\k'
      let l:start -= 1
    endwhile
    return start
  else
    let l:res = []
    " sequence through list and get the list of matches
    for i in range(len(b:comp_list))
      if (type(b:comp_list[i]) == 1)
        if b:comp_list[i] =~ '^' . a:base
          call add(l:res, b:comp_list[i])
        endif
      elseif (type(b:comp_list[i]) == 4)
        "if (b:comp_list[i].abbr =~ '^' . a:base || b:comp_list[i].word =~ '^' . a:base)
        if (a:base =~ '\v' . b:comp_list[i].abbr || b:comp_list[i].word =~ '^' . a:base)
          call add(l:res, b:comp_list[i])
        endif
      endif
    endfor
    return l:res
  endif
endfun
"set completeopt+=longest
set completefunc=Kp_complete_keyword

" Convert literally spacial character
fun! s:Kp_tab_expr()
  ""if (pumvisible() == 1)
  ""  return " "
  ""elseif (getline(".") =~ '[[:cntrl:]]')

  " Preserve typehead
  let typeafter = strpart(getline('.'), col('.'))
  let typebefore = strpart(getline('.'), 0, col('.') - 1)

  if (getline(".") =~ '[[:cntrl:]]')
    let l:line = getline(".")
    call setline(".", '')
    return typebefore . 'ma$a' . typeafter . '`aa'
  else
    return "\t"
  endif
  return ''
endfun

" ***************************************************************************
" User defined complition list
" Pass list to be used in completion seaching
" Use this function to use completion for user defined function
" ***************************************************************************
fun! s:Kp_user_complete(list)
  let l:line = getline('.')
  let l:start = col('.') - 1
  let l:end = copy(l:start)
  while l:start > 0 && l:line[l:start - 1] =~ '\k'
    let l:start -= 1
  endwhile
  let l:base = strpart(l:line, l:start, (l:end - l:start))
  
  let l:res = []
  " sequence through list and get the list of matches
  for i in range(len(a:list))
    if (type(a:list[i]) == 1)
      if a:list[i] =~ '^' . l:base
        call add(l:res, a:list[i])
      endif
    elseif (type(a:list[i]) == 4)
      " if (a:list[i].abbr =~ '^' . l:base || a:list[i].word =~ '^' . l:base)
      if (l:base =~ '\v' . a:list[i].abbr || a:list[i].word =~ '^' . l:base)
        call add(l:res, a:list[i])
      endif
    endif
  endfor
  call complete(l:start + 1, l:res)
  return ''
endfun

" ***************************************************************************
" get longest str from the list of keywords
" ***************************************************************************
fun! s:Kp_get_longest(com_list)
  if (b:longest == 0)
    return ''
  endif
  let l:line = getline('.')
  let l:start = col('.') - 1
  let l:end = l:start
  while l:start > 0 && l:line[l:start - 1] =~ '\k'
    let l:start -= 1
  endwhile
  let l:base = strpart(l:line, l:start, l:end)

  let l:org_list = deepcopy(a:com_list)
  " get the list of keywords matches keyword before cursor
  call filter(l:org_list, '((type(v:val) == 1) ? (v:val =~ "^" . l:base) : ((v:val.word =~ "^" . l:base) || (v:val.abbr =~ "^" . l:base)))')
  if empty(l:org_list)
    return ''
  endif
  let l:list = deepcopy(l:org_list)

  let l:i = 0
  while (l:list == l:org_list)
    let l:item = l:list[0]
    let l:cmp_str = ((type(l:item) == 1) ? (l:item) : (l:item.abbr))
    let l:i += 1
    let l:prev_list = deepcopy(l:list)
    call filter(l:list, '((type(v:val) == 1) ? (v:val =~ strpart(l:cmp_str, 0, l:i)) : ((v:val.abbr =~ strpart(l:cmp_str, 0, l:i)) || (v:val.word =~ strpart(l:cmp_str, 0, l:i))))')
    if (l:prev_list == l:list && strlen(l:cmp_str) == l:i)
      let l:i += 1
      break
    endif
  endwhile
  let l:i -= 1
  let l:res = strpart(((type(l:prev_list[0]) == 1) ? (l:prev_list[0]) : (l:prev_list[0].abbr)), 0, l:i)
  return strpart(l:res, strlen(l:base))
endfun

" user defined completion list
let my_list2 = <SID>Kp_ParseFile(b:fname2)

if (exists("b:fname3"))
  let my_list3 = <SID>Kp_ParseFile(b:fname3)
endif

" list of keywords parsed from file
let b:comp_list = <SID>Kp_ParseFile(b:fname1)
let my_list1 = b:comp_list

let b:fun_defined = 1
