function! matlab#tags#call_expr(...)
  " Default is word under cursor
  TVarArg ['name', expand('<cword>')]
  let tagname = printf ('#call#%0s', name)
  exe 'tag /^' . tagname

endfunction

function! matlab#tags#call(...)
  " Default is current mfile script/function
  TVarArg ['name', expand('%:t:r')]
  let tagname = printf ('#call#%0s', name)
  exe 'tag ' . tagname

endfunction

function! s:tag(select)
  if (a:select == 'call')
    call matlab#tags#call()
  endif
endfunction

function! matlab#tags#auto_tags()
  let atags = ['call']

  call inputsave()
  let select = tlib#input#List('s', 'Select Tag', atags,[], '')
  call inputrestore()

  call s:tag(select)
endfunction





