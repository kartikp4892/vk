" Vera
let $VIM_HOME = expand("<sfile>:h")
let $VIM_HOME = substitute($VIM_HOME, 'ftdetect$', '', 'g')

" if exists("did_load_filetypes")
if exists("did_load_myfiletypes")
finish
endif
let did_load_myfiletypes = 1

augroup filetypedetect
au!  BufRead,BufNewFile *.vr             setfiletype vera
au! BufRead,BufNewFile *.vrh             setfiletype vera
au! BufRead,BufNewFile *.sv             setfiletype sv
au! BufRead,BufNewFile *.svh             setfiletype sv
" file type for vba
au! BufRead,BufNewFile *.bas             setfiletype vb
au! BufRead,BufNewFile *.cls             setfiletype vb
augroup END

" runtime syntax/kp_redir_gen.vim
" nmap <silent> <M-0> :so $VIM_HOME/syntax/kp_redir_gen.vim
set runtimepath+=$VIM_HOME

runtime! after/kp_user_var_override.vim

"nmap <silent> <M-0> :runtime syntax/kp_redir_gen.vim
if $VIMSHARE == $HOME
  nmap <silent> <M-0> :runtime syntax/kp_redir_gen.vim
else
  runtime syntax/kp_redir_gen.vim
endif




