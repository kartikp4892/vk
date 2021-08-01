"|| "-------------------------------------------------------------------------------
"|| " Completion: Function
"|| "-------------------------------------------------------------------------------
"|| function! s:Completion()
"||   let l:macro = @+
"||   let l:info = @*
"||   let l:infos = split(@*, "\n")
"||   let l:infos[1:] = map(l:infos[1:], '"    \\" . v:val . " "')
"||   let l:str = []
"||   call add(l:str, '# `' . @+)
"||   call add(l:str, 'word  ~> =sv#ovm#ovm_macro#' .  matchstr(l:macro, 'ovm_\zs\w\+') . '()')
"||   call add(l:str, 'abbr  ~> ' . join(map(split(l:macro, "_"), "strpart(v:val, 0, 1)"), ""))
"||   call add(l:str, 'menu  ~> `' . l:macro)
"||   call add(l:str, 'info  ~>' . join(l:infos, "\n"))
"||   call add(l:str, 'kind  ~> m')
"||   call add(l:str, 'icase ~>')
"||   call add(l:str, 'dup   ~>')
"||   call add(l:str, '--')
"||   call add(l:str, ' ')
"||   put =l:str
"|| endfunction
"|| 
"|| "-------------------------------------------------------------------------------
"|| " s:Completion_fn: Function
"|| "-------------------------------------------------------------------------------
"|| function! s:Completion_fn()
"||   let l:str = comments#block_comment#getComments('`' . @*)
"||   let l:str .= 'function sv#ovm#ovm_macro#' . matchstr(@*, 'ovm_\zs\w\+') . '()'
"||   let l:str .= '  let l:str = ""'
"||   let l:str .= 'let l:str .= "`' . @* . '(maa, OVM_ALL_ON)`aa"'
"||   let l:str .= 'return l:str'
"||   let l:str .= 'endfunction'
"||   return l:str
"|| endfunction
"|| 
"|| command! -nargs=0 -bar CompletionSet call s:Completion()
"|| nmap ä a=<SID>Completion_fn()
