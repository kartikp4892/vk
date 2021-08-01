let g:parser#uvm#null#null = {}

"-------------------------------------------------------------------------------
" Function : g:parser#uvm#null#null.get
"-------------------------------------------------------------------------------
function! g:parser#uvm#null#null.get() dict
  call debug#debug#log(printf("g:parser#uvm#null#null.get == %s", string(self.get)))
  return self
endfunction

"-------------------------------------------------------------------------------
" Function : g:parser#uvm#null#null.string
"-------------------------------------------------------------------------------
function! g:parser#uvm#null#null.string() dict
  call debug#debug#log(printf("g:parser#uvm#null#null.string == %s", string(self.string)))
  return "NULL"
endfunction

lockvar g:parser#uvm#null#null


