" autocmd BufNewFile *.txt TSkeletonSetup plane.txt

vnoremap <silent> , :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy:mat Error "<C-R><C-R>=substitute
  \(escape(@", '/".*$^~['), '_s+', '\_s\+', 'g')<CR>"<CR>
  \gV:call setreg('"', old_reg, old_regtype)<CR>

nnoremap 1, :1mat Error "<C-R><C-W>"<CR>
nnoremap 2, :2mat DiffAdd "<C-R><C-W>"<CR>
nnoremap 3, :3mat DiffChange "<C-R><C-W>"<CR>
map <F3> @@
set is
set ai sw=2
set et
set showcmd
set lz

"mat Error "\*\*\* \zsFIXME\ze \*\*\*"

















































" fun! Kp_clock()
"   let l:virtualedit = &virtualedit
"   set virtualedit=all
"   return "___/\<Up>___\<Down>\\"
" endfun
" 
" let s:signal_state = -1
" 
" fun! Kp_signal(state)
" 
"   set virtualedit=all
"   if (a:state == "high")
" 
"     if (s:signal_state == 0)
"       let l:ret_val = "/\<Up>_______\<Down>"
"     elseif (s:signal_state == 1)
"       let l:ret_val = "\<Up>-_______\<Down>"
"     else
"       let l:ret_val = "\<Up>_______\<Down>"
"     endif
"     let s:signal_state = 1
" 
"   elseif (a:state == "low")
"     
"     if (s:signal_state == 0)
"       let l:ret_val = "-_______"
"     elseif (s:signal_state == 1)
"       let l:ret_val = "\\_______"
"     else
"       let l:ret_val = "_______"
"     endif
"     let s:signal_state = 0
" 
"   endif
" 
"   return l:ret_val
" 
" endfun
" 
" let s:data_state = -1
" 
" fun! Kp_data_bus(state)
"   set virtualedit=all
" 
"   if (a:state == "high")
"     if (s:data_state == 0)
"       let l:ret_val = "maa\\/\<Up>______\<Down>`aa\<Down>/\\______\<Up>"
"     elseif (s:data_state == 1)
"       let l:ret_val = "maa\<Up>-_______\<Down>`aa\<Down>-_______\<Up>"
"     else
"       let l:ret_val = "maa\<Up>_______\<Down>`aa\<Down>_______\<Up>"
"     endif
" 
"     let s:data_state = 1
"   elseif (a:state == "low")
"     if (s:data_state == 0)
"       let l:ret_val = "maa\<Up>-_______\<Down>`aa\<Down>-_______\<Up>"
"     elseif (s:data_state == 1)
"       let l:ret_val = "maa\\/\<Up>______\<Down>`aa\<Down>/\\______\<Up>"
"     else
"       let l:ret_val = "maa\<Up>_______\<Down>`aa\<Down>_______\<Up>"
"     endif
" 
"     let s:data_state = 0
"   " High impedence wave  elseif (a:state == "low")
"   " High impedence wave    if (s:data_state == 0)
"   " High impedence wave      let l:ret_val = "-_______"
"   " High impedence wave    elseif (s:data_state == 1)
"   " High impedence wave      let l:ret_val = "maa\\_______mb`aa\<Down>/`ba"
"   " High impedence wave    else
"   " High impedence wave      let l:ret_val = "_______"
"   " High impedence wave    endif
" 
"   " High impedence wave    let s:data_state = 0
"   endif
" 
"   return l:ret_val
" endfun
" 
" imap <expr> <C-MouseDown> Kp_clock()
" imap <expr> <C-MouseUp> Kp_clock()
" 
" imap <expr> <M-MouseDown> Kp_signal("high")
" imap <expr> <M-MouseUp> Kp_signal("low")
" 
" imap <expr> <S-MouseDown> Kp_data_bus("high")
" imap <expr> <S-MouseUp> Kp_data_bus("low")
" 
" 
" 
" 
" fun! Kp_DrawBlock() range
"   let [@_, @_, l:col1, l:off1] = getpos("'<")
"   let [@_, @_, l:col2, l:off2] = getpos("'>")
" 
"   let l:vcol1 = l:col1 + l:off1
"   let l:vcol2 = l:col2 + l:off2
" 
"   let l:vcolmin = min([l:vcol1, l:vcol2])
"   let l:vcolmax = max([l:vcol1, l:vcol2])
" 
"   call setpos(".", [0, a:firstline, l:vcolmin, 0])
"   normal r+
" 
"   call setpos(".", [0, a:lastline, l:vcolmin, 0])
"   normal r+
" 
"   call setpos(".", [0, a:firstline, l:vcolmax, 0])
"   normal r+
" 
"   call setpos(".", [0, a:lastline, l:vcolmax, 0])
"   normal r+
" 
"   if (a:firstline != a:lastline)
"     for l:lnum in range(a:firstline + 1, a:lastline - 1)
"       call setpos(".", [0, l:lnum, l:vcolmin, 0])
"       normal r|
" 
"       call setpos(".", [0, l:lnum, l:vcolmax, 0])
"       normal r|
"     endfor
"   endif
" 
"   if (l:vcolmin != l:vcolmax)
"     for l:cnum in range(l:vcolmin + 1, l:vcolmax - 1)
"       call setpos(".", [0, a:firstline, l:cnum, 0])
"       normal r-
" 
"       call setpos(".", [0, a:lastline, l:cnum, 0])
"       normal r-
"     endfor
"   endif
" endfun
" 
" " <C-D>
" vmap ä :'<,'>call Kp_DrawBlock()
