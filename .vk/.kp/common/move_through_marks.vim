" Inbuild Marks
imap <M-Right> =common#move_through_mark#next_mark(1)
imap <M-Left> =common#move_through_mark#prev_mark(1)
imap <M-Up> =common#move_through_mark#1st_mark(1)

" Userdefined Marks
nmap <M-m> :call common#mov_thru_user_mark#nmap_alt_m()
nmap <M-`> :call common#mov_thru_user_mark#nmap_alt_tick()
imap <M-m> =common#mov_thru_user_mark#imap_alt_m()
imap <M-`> =common#mov_thru_user_mark#imap_alt_tick()
