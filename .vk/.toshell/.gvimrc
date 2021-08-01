
let &define = '\v^\s*`define|%(^[[:alnum:]_ ]*)@<=%(%(<function>|<task>).{-}\ze\w+\s*\(|<class>)'
let &include = '\s*`include'

set tags=$BASE_DIR/.ktagssv/tags/_merged/**/tags,$HOME/.tags,$HOME/.ktagssv/tags/_merged/**/tags
" set tags=$BASE_DIR/.ktagssv/tags/_libs/**/tags,$HOME/.tags,$HOME/.ktagssv/tags/_libs/**/tags
" set tags=$HOME/.tags,$HOME/.ktagssv/tags,$BASE_DIR/.ktagssv/tags

nmap ; :ls:b



