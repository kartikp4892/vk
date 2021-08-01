function! s:open_shortcut_file()
  vsp $HELP.scala
  setlocal buftype=nofile
  setlocal bufhidden=hide
  setlocal noswapfile
  read $KP_VIM_HOME/scala/Shortcuts.scala
endfunction

command! -nargs=0 Shortcuts silent call s:open_shortcut_file()



