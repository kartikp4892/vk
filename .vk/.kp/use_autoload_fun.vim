" Create table
vmap <silent>  :call table#createTable#Kp_setTable()

" Copyright & header for coding
"command! -nargs=0 -bar SetHeader call comments#header#Kp_set_header()
command! -nargs=0 -bar SetHeader call comments#header#set_header_from_file('header')

" Append line in series by automatic recognize the given series
command! -nargs=0 -range AppenSeriesLines <line1>,<line2>call common#append_line_in_series#append_lines()
vmap gp :call common#append_line_in_series#append_lines()
vmap gn :call common#append_line_in_series#incr_numbers()

"-------------------------------------------------------------------------------
" Draw Clock and signals
"-------------------------------------------------------------------------------
imap <expr> <C-MouseDown> draw_signals#signals#clock()
imap <expr> <C-MouseUp> draw_signals#signals#clock()

imap <expr> <M-MouseDown> draw_signals#signals#signal("high")
imap <expr> <M-MouseUp> draw_signals#signals#signal("low")

imap <expr> <S-MouseDown> draw_signals#signals#data_bus("high")
imap <expr> <S-MouseUp> draw_signals#signals#data_bus("low")

imap <expr> <C-S-MouseDown> draw_signals#signals#hi_impedence_data_bus("high")
imap <expr> <C-S-MouseUp> draw_signals#signals#hi_impedence_data_bus("low")

command! -nargs=0 -range DrawClkSeperator <line1>,<line2>call draw_signals#signals#add_seperator_after_each_clk()

" Draw Blocks
command! -nargs=0 -range DrawBlock <line1>,<line2>call draw_signals#signals#draw_block()
command! -nargs=0 -range DrawConditionalBlock <line1>,<line2>call draw_signals#signals#draw_conditional_block()
" Draw Arrow
command! -nargs=0 -range DrawArrow <line1>,<line2>call draw_signals#signals#draw_arrow()
vmap <C-D> :'<,'>call draw_signals#signals#draw_arrow()

" Search
command! -nargs=* SearchInBuffer call common#utils#search_in_buffer(<args>)

