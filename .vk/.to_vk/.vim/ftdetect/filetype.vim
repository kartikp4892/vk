" Vera

" if exists("did_load_filetypes")
if exists("did_load_myfiletypes")
finish
endif

augroup filetypedetect
au!  BufRead,BufNewFile *.vr             setfiletype vera
au! BufRead,BufNewFile *.vrh             setfiletype vera
au! BufRead,BufNewFile *.sv             setfiletype sv
au! BufRead,BufNewFile *.svh             setfiletype sv
" file type for vba
au! BufRead,BufNewFile *.bas             setfiletype vb
au! BufRead,BufNewFile *.cls             setfiletype vb
augroup END

"if (filereadable(printf("%0s/.kprc", $HOME)))
if (filereadable(printf('%0s/.kprc', $VIMSHARE)))
  exe printf('pyfile %0s/.kprc', $VIMSHARE)
endif

