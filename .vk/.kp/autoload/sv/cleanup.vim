function! sv#cleanup#all() range
  SVIndentCleanUp

  SVCodeComment all
  SVEndLabel all

  silent! w!
endfunction


