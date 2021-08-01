if ($VIM_HOME != $HOME . '/.vim')
  set runtimepath+=$VIM_HOME
endif
exe 'so ' . $VIM_HOME . '/.kp/source_scripts.vim'
exe 'so ' . $VIM_HOME . '/.gvimrc'
exe 'so ' . $VIM_HOME . '/.vimrc'
exe 'so ' . $VIM_HOME . '/.gvimrc1'
