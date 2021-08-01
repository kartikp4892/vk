" || "-------------------------------------------------------------------------------
" || " s:get_tag_name: Function
" || "-------------------------------------------------------------------------------
" || function! s:get_tag_name()
" ||   " find search start & end
" ||   let l:s_start =  search('\v^\s*%(%(protected|private|typedef|public)\s+)?\w+%(\s*#\(\_[[:alnum:]_, ]+\))?\_[[:alnum:]_, ]+<' .
" ||                    \         expand("<cword>") .
" ||                    \         '>%(\[\_.{-}\])*;$', 'bn')
" || 
" ||   let l:s_end   =  search('\v^\s*%(%(protected|private|typedef|public)\s+)?\w+%(\s*#\(\_[[:alnum:]_, ]+\))?\_[[:alnum:]_, ]+<' .
" ||                    \         expand("<cword>") .
" ||                    \         '>%(\[\_.{-}\])*;$', 'ben')
" || 
" ||   let l:curr_pos = col('.') - indent(l:s_start) + indent(l:s_end) - 1
" || 
" ||   " get the class type name
" ||   let l:type_name = matchstr(
" ||                    \ join (
" ||                    \ map(
" ||                    \ getline(
" ||                    \  l:s_start,
" ||                    \  l:s_end
" ||                    \ ), 'substitute(v:val, "^\\s\\+", "", "")'
" ||                    \ ), "\n" . repeat(' ', l:curr_pos)),
" ||                    \ '\v^\s*%(%(protected|private|typedef|public)\s+)?\zs\w+\ze%(\s*#\(\_[[:alnum:]_, ]+\))?'
" ||                    \)
" ||   let l:type_name = matchstr(l:type_name, '\w\+') 
" ||   return l:type_name
" || endfunction
" || 
" || "-------------------------------------------------------------------------------
" || " Desctiption: Jump to class name tag from object
" || "-------------------------------------------------------------------------------
" || nmap <M-]> :exe 'tag ' . <SID>get_tag_name()

nmap <M-]> :call sv#tags#auto_tags()
" Search where current file is included by `include
" nmap g<M-]> :call sv#tags#include()
nmap g<M-]> :call sv#tags#auto_tags(expand('<cword>'))

"===============================================================================
" Redefine <C-]> to jump on a tag
"===============================================================================
"-------------------------------------------------------------------------------
" get_tag_under_cursor: Function
"-------------------------------------------------------------------------------
function! s:get_tag_under_cursor()
  " Check if macro
  if (search('`\<\w\+\%' . line(".") . 'l\%' . col(".") . 'c\w*\>'))
    return '`' . expand("<cword>")
  else
    return expand("<cword>")
  endif
endfunction

nmap <C-]> :exe 'tag ' . <SID>get_tag_under_cursor()
