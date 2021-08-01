" start of PHP
imap <M-p> =php#common#start_php()<CR>
imap <M-P> <?php maa ?>`aa

"------------------------
" to make use of "some text" . $var . "some text" easy
imap <M-/> f"a . 
imap <M-?> . "maa"`aa
"------------------------

"------------------------
" Variables
imap <expr> <M-4> php#common#expand_scalar_variable()
imap <expr> <M-2> php#common#expand_array_variable()
"------------------------

"-------------------------------------------------------------------------------
" php
" Function
imap <M-j>fn =php#common#function()<CR>
" Class
imap <M-j>cl =php#common#class()<CR>
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Create tags
" Single line
imap <M-M> =html#htags#create_tab_multi_line()<CR>
imap <M-m> =html#htags#create_tab_single_line()<CR>
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" Others
imap <M-[> [maa]`aa
imap <M-{> {maa}`aa
"-------------------------------------------------------------------------------

"-------------------------------------------------------------------------------
" HTML Mappings
"-------------------------------------------------------------------------------
imap  <br>
imap <M-j>e echo "maa";`aa
imap <M-j>p print "maa";`aa
