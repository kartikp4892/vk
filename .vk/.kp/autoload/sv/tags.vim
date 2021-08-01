function! sv#tags#include_expr(...)
  " Default is word under cursor
  TVarArg ['name', expand('<cword>')]
  let tagname = printf ('#include#%0s', name)
  exe 'tag /^' . tagname

endfunction

function! sv#tags#import_expr(...)
  " Default is word under cursor
  TVarArg ['name', expand('<cword>')]
  let tagname = printf ('#import#%0s', name)
  exe 'tag /^' . tagname

endfunction

function! sv#tags#handle_expr(...)
  " Default is word under cursor
  TVarArg ['name', expand('<cword>')]
  let tagname = printf ('#handle#%0s', name)
  exe 'tag /^' . tagname

endfunction

function! sv#tags#include(...)
  " Default is current file
  TVarArg ['name', expand('%:t')]
  let tagname = printf ('#include#%0s', name)
  exe 'tag ' . tagname

endfunction

function! sv#tags#import(...)
  " Default is current file
  TVarArg ['name', expand('%:t')]
  let tagname = printf ('#import#%0s', name)
  exe 'tag ' . tagname

endfunction

function! sv#tags#handle(...)
  " Default is current file
  TVarArg ['name', expand('%:t')]
  let tagname = printf ('#handle#%0s', name)
  exe 'tag ' . tagname

endfunction

function! sv#tags#extends(...)
  " Default is current file
  TVarArg ['name', expand('%:t')]
  let tagname = printf ('#extends#%0s', name)
  exe 'tag ' . tagname

endfunction

function! s:tag(select, ...)
  TVarArg ['name', expand('%:t')]

  if (a:select == 'include')
    call sv#tags#include_expr(name)
  elseif (a:select == 'import')
    call sv#tags#import_expr(name)
  elseif (a:select == 'handle')
    call sv#tags#handle(name)
  elseif (a:select == 'extends')
    call sv#tags#extends(name)
  endif
endfunction

function! sv#tags#auto_tags(...)
  " TVarArg ['name', expand('%:t')]
  TVarArg ['name', expand('%:t:r')]

  let atags = ['include', 'import', 'handle', 'extends']

  " ## " TODO: set path for auto tags at run time and after done restore path
  " ## let tagspath = join(map(split($SVTAGSPATH, ':'), 'printf("%0s/tags/_auto/**/tags", v:val)'), ',')
  " ## let tags_save = &tags
  " ## exe 'set tags=' . tagspath

  call inputsave()
  let select = tlib#input#List('s', 'Select Tag', atags,[], '')
  call inputrestore()

  call s:tag(select, name)

  " ## exe 'set tags=' . tags_save
endfunction





