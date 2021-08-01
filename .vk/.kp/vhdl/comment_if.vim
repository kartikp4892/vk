"===============================================================================
" Add comments to the if else statement
"===============================================================================
function! Kp_comment_if() range
  let l:line = a:firstline
  let l:if_que = []
  let l:endif_que = []
  let l:str = []
  let l:is_if = ""
  while l:line <= a:lastline
    if (matchstr(getline(l:line), '^\s*if\s*[ ,(]') != "")
      let l:start_if = l:line
      let l:is_if = 1
    endif
    if l:is_if == 1
      if (matchstr(getline(l:line), '[ ,)]\s*then\s*\(--.*\)\?$') != "") 
        let l:end_if = l:line
        let l:is_if = 0
        let l:str = getline(l:start_if, l:end_if)
        let l:alist = []
        for l:ln in l:str
            let l:ln = substitute(l:ln, '^\s*if\s*[ ,(]', '(', '')
            let l:ln = substitute(l:ln, '[ ,)]\s*then\s*\(--.*\)\?$', ')', '')
            let l:ln = substitute(l:ln, '\s*', ' ', '')
            call add(l:alist, l:ln)
        endfor
        call add(l:if_que, l:alist)
      endif
    endif
    if (matchstr(getline(l:line), '^\s*end\s\+if\s*;') != "")
      call add(l:endif_que, remove(l:if_que, -1))
    endif
    let l:line = l:line + 1
  endwhile
  0
  for l:count in range(len(l:endif_que))
    exe '.+1,/^\s*end\s\+if\s*;/g/^\s*end\s\+if\s*;/' .
        \'normal f;Da;'
    let l:str = remove(l:endif_que, 0)
    let l:max_col = col('$')
    exe 'normal a --' . remove(l:str, 0) . ''
    for l:ln in l:str
      exe 'normal o'
      exe 'normal ' . (l:max_col - col('.')) . 'a a -- ' . l:ln
    endfor
  endfor
endfunction

"===============================================================================
" Uncomment the if else statement
"===============================================================================
function! Kp_uncomment_if()
"------------------------------------------------------------------
"  exe 'g/^\s*end\s\+if\s*;/normal f(da(/'
"  exe 'g/^\s*end\s\+if\s*;/normal f-D/'
"------------------------------------------------------------------
let l:is_del = 0
let l:line = 1
while l:line <= line('$')
  if (matchstr(getline(l:line), '^\s*end\s\+if\s*;') != "")
    let l:idx = match(getline(l:line), '--')
    if l:idx != -1
      let l:is_del = 1
    endif
    let l:line = l:line + 1
    continue
  endif
  if l:is_del == 1
    if (match(getline(l:line), '^\s*--') != -1)
      if l:idx == match(getline(l:line), '--')
        exe l:line
        call setline('.', '--XXXXX')
      endif
    else
      let l:is_del = 0
    endif
  endif
  let l:line = l:line + 1
endwhile
g/^--XXXXX$/d
"g/^\s*end\s\+if\s*;/normal f;Da;
endfunction

nmap àf     :call Kp_uncomment_if()
           \:%call Kp_comment_if()
nmap <silent> ààf    àf:wnààf
"===============================================================================
"===============================================================================

