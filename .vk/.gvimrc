imap <F2> :w!<C-M>
nmap <F2> :w!<C-M>
set nobackup

"imap <C-CR> <End>;
"nmap <M-F3> ZZ

inoremap <expr> <M-,> (expand("%") == "command-line") ? "<>\<Left>" : "<>\<Left>"
" --> inoremap <expr> ( (expand("%") == "command-line") ? "()\<Left>" : "("
inoremap <expr> <M-9> (expand("%") == "command-line") ? "%()\<Left>" : "()\<Left>"
inoremap <expr> <M-"> (expand("%") == "command-line") ? "\"\"\<Left>" : "\"\"\<Left>"
" --> inoremap <expr> { (expand("%") == "command-line") ? "{}\<Left>" : "{"
" --> inoremap <expr> [ (expand("%") == "command-line") ? "[]\<Left>" : "["

"<M-\>
" --> inoremap <expr> <M-\><M-,> (expand("%") == "command-line") ? "\\<\\>\<Left>\<Left>" : "<>\<Left>"
" --> inoremap <expr> <M-\>( (expand("%") == "command-line") ? "\\(\\)\<Left>\<Left>" : "("
" --> inoremap <expr> <M-\><M-9> (expand("%") == "command-line") ? "\\%(\\)\<Left>\<Left>" : "()\<Left>"
" --> inoremap <expr> <M-\>{ (expand("%") == "command-line") ? "\\{\\}\<Left>\<Left>" : "{"
" --> inoremap <expr> <M-\>[ (expand("%") == "command-line") ? "\\[\\]\<Left>\<Left>" : "["






" prototype ets : " NDCTL: Scalaton for Prototype Testcase for ets
" prototype ets : autocmd BufNewFile  *.ets 0r ~/.vim/ets_scalaton|87
" prototype ets : autocmd BufNewFile,BufRead  *.ets setf tcl|
" prototype ets :           "\syntex match Comment '\v%(reg_%(read|write)_mem_tcl \{)@<=.{-}\ze\}'|
" prototype ets :           "\syntex match Identifier '\v%(-data \{)@<=\w+'
" prototype ets : 
" prototype ets : if (expand("%:t") =~ '\.ets$')
" prototype ets :   nmap <M-F3> :syntax match Comment '\v%(_tcl \{)@<=.{-}\ze\}'<C-M>
" prototype ets :              \:syntax match Identifier '\v%(-data \{)@<=\w+'<C-M>
" prototype ets :   nmap <S-F3> :syntax match None '\v%(_tcl \{)@<=.{-}\ze\}'<C-M>
" prototype ets :              \:syntax match None '\v%(-data \{)@<=\w+'<C-M>
" prototype ets : endif






































"||perl << EOF
"||use strict;
"||use warnings;
"||use num2word;
"||
"||our $word;
"||sub test {
"||  my $eval = shift || -1;
"||  my $num = shift || -1;
"||  our $word;
"||  if ($num == -1) {
"||    VIM::DoCommand('call inputsave()');
"||    ($eval, $num) = VIM::Eval('input("Enter a number : ")');
"||    VIM::DoCommand('call inputrestore()');
"||  }
"||  $word = &num2word($num);
"||  if ($word ne '') {
"||    VIM::DoCommand("let \@a = '$word'");
"||    #VIM::DoCommand(".perldo \$_ = \$_ . \$word");
"||  } else {
"||    #VIM::DoCommand('call feedkeys("a")');
"||  }
"||
"||}
"||
"||#VIM::DoCommand("imap  :perl &test\$a");
"||EOF
"||
"||"imap  :perl &testa<BS>
"||imap  :perl &test(VIM::Eval('getline(".")')) = a<BS>















" awesome****  function! GetPixel()
" awesome****     let c = getline(".")[col(".") - 1]
" awesome****     echo c
" awesome****     exe "noremap <LeftMouse> <LeftMouse>r".c
" awesome****     exe "noremap <LeftDrag>	<LeftMouse>r".c
" awesome****  endfunction
" awesome****  noremap <RightMouse> <LeftMouse>:call GetPixel()<CR>
" awesome****  set guicursor=n:hor20	   " to see the color beneath the cursor

























""   fun! s:Kp_get_expr_from_mouse(type, replace)
""     let l:replace_what = ''
""     let l:mouse_col = v:beval_col
""     let l:mouse_lnum = v:beval_lnum
""     let l:mouse_winnr = v:beval_winnr + 1
""     let l:new_pos = [0, l:mouse_lnum, l:mouse_col, 0]
""
""     let s:old_winnr = winnr()
""     let s:old_pos = getpos(".")
""
""     exe l:mouse_winnr . "wincmd w"
""     call setpos(".", l:new_pos)
""
""     if (a:type == 'w')
""
""       echo '1:w 2:W 3:f'
""
""       while (1)
""         let l:char = nr2char(getchar())
""         if (l:char =~ "\\v1|2|3|\<Esc>")
""           break
""         endif
""       endwhile
""
""       if (l:char == 1)
""         let l:ret_val = expand("<cword>")
""         let l:replace_what = 'iw'
""       elseif (l:char == 2)
""         let l:ret_val = expand("<cWORD>")
""         let l:replace_what = 'iW'
""       elseif (l:char == 3)
""         let l:ret_val = expand("<cfile>")
""         let l:replace_what = ''
""       else
""         let l:ret_val = ''
""       endif
""
""     elseif (a:type =~ 'a\|i')
""
""       echo '1:( 2:[ 3:{ 4:< q:" w:'' e:`'
""
""       while (1)
""         let l:char = nr2char(getchar())
""         if (l:char =~ "\\v1|2|3|4|q|w|e|\<Esc>")
""           break
""         endif
""       endwhile
""
""       if (l:char == 1)
""         let l:expr = '('
""       elseif (l:char == 2)
""         let l:expr = '['
""       elseif (l:char == 3)
""         let l:expr = '{'
""       elseif (l:char == 4)
""         let l:expr = '<'
""       elseif (l:char == 'q')
""         let l:expr = '"'
""       elseif (l:char == 'w')
""         let l:expr = ''''
""       elseif (l:char == 'e')
""         let l:expr = '`'
""       else
""         let l:expr = ''
""       endif
""
""       if (l:expr != '')
""         exe 'normal y' . a:type . l:expr
""       else
""         let @" = ''
""       endif
""       let l:ret_val = @"
""       let l:replace_what = a:type . l:expr
""
""     else
""       let l:ret_val = ''
""     endif
""
""     exe s:old_winnr . "wincmd w"
""     call setpos(".", s:old_pos)
""
""     if (a:replace == 1 && l:replace_what != '')
""       exe 'normal c' . l:replace_what
""     endif
""
""     return l:ret_val
""   endfun
""
""   imap  =<SID>Kp_get_expr_from_mouse('a',1)
""   imap <C-RightMouse> =<SID>Kp_get_expr_from_mouse('w',0)
""   imap <C-LeftMouse> =<SID>Kp_get_expr_from_mouse('w',1)



































" IMP**** function! MyBalloonExpr()
" IMP****    let beval_text = v:beval_text
" IMP****    return beval_text
" IMP****    "return 'Cursor is at line ' . v:beval_lnum .
" IMP****    "	\', column ' . v:beval_col .
" IMP****    "	\ ' of file ' .  bufname(v:beval_bufnr) .
" IMP****    "	\ ' on word "' . beval_text . '"'
" IMP**** endfunction
" IMP**** set bexpr=MyBalloonExpr()
" IMP**** set ballooneval
" IMP****
" IMP**** imap <expr>  MyBalloonExpr()












