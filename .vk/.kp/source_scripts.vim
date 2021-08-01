" Use / for path seperator on windows
set shellslash
let s:src_dir = expand('<sfile>:h') . '/'
let s:src_dir = escape(s:src_dir, ' ')
let $KP_VIM_HOME = s:src_dir

fun! s:set_runtime(dir)
  let l:save_path = &runtimepath
  let &runtimepath = s:src_dir . a:dir
  runtime! <buffer> *.vim
  let &runtimepath = l:save_path
endfun

exe "set runtimepath+=" . s:src_dir
"-------------------------------------------------------------------------------
" FIXME temp uncommented
"let mov_thru_file = 'so ' . s:src_dir . 'vhdl/mov_thru_file.vi'
"nmap <C-F2> :exe mov_thru_file
"nmap <S-F2> :call <SID>set_runtime("vhdl")
"-------------------------------------------------------------------------------
call <SID>set_runtime("common")
call <SID>set_runtime("completion")

let s:file_ext = expand("%:e")
let s:file_name = expand("%:t")

"-------------------------------------------------------------------------------
" Function : s:vhdl_runtime
"-------------------------------------------------------------------------------
function! s:vhdl_runtime()
  " au!  BufRead,BufNewFile *.vhd call <SID>set_runtime("vhdl")
  if (s:file_ext == 'vhd')
    call <SID>set_runtime("vhdl")
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : s:vim_runtime
"-------------------------------------------------------------------------------
function! s:vim_runtime()
  if (s:file_ext == 'vim')
    call <SID>set_runtime("vim")
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : s:perl_runtime
"-------------------------------------------------------------------------------
function! s:perl_runtime()
  if (s:file_ext =~ '^p[lm]$')
    call <SID>set_runtime("templetes/perl") 
    call <SID>set_runtime("perl")
  endif

  " Runtime directory for perl
  " au!  BufRead,BufNewFile *.p[lm] call <SID>set_runtime("templetes/perl") | call <SID>set_runtime("perl")
  "au!  BufRead,BufNewFile *.p[lm] call <SID>set_runtime("perl")
endfunction

"-------------------------------------------------------------------------------
" Function : s:python_runtime
"-------------------------------------------------------------------------------
function! s:python_runtime()
  if (s:file_ext == 'py')
    call <SID>set_runtime("python3")
  endif
  "-------------------------------------------------------------------------------
  " Python
  " au!  BufRead,BufNewFile *.py call <SID>set_runtime("python")
  "-------------------------------------------------------------------------------
endfunction

"-------------------------------------------------------------------------------
" Function : s:make_runtime
"-------------------------------------------------------------------------------
function! s:make_runtime()
  
  if (s:file_ext == 'make' || s:file_name == 'Makefile')
    call <SID>set_runtime("templetes/make")
  endif
  "-------------------------------------------------------------------------------
  " Makefile
  " au!  BufRead,BufNewFile *.make call <SID>set_runtime("templetes/make")
  " au!  BufRead,BufNewFile Makefile call <SID>set_runtime("templetes/make")
  "-------------------------------------------------------------------------------
endfunction

"-------------------------------------------------------------------------------
" Function : s:shell_runtime
"-------------------------------------------------------------------------------
function! s:shell_runtime()
  
  if (s:file_ext =~ '\v^(bash|sh)$')
    call <SID>set_runtime("templetes/shell") 
    call <SID>set_runtime("bash")
  elseif (s:file_ext =~ '\v^(csh)$')
    call <SID>set_runtime("templetes/shell") 
    call <SID>set_runtime("cshell")
  endif
  " au!  BufRead,BufNewFile *.bash call <SID>set_runtime("templetes/shell") | call <SID>set_runtime("bash")
  " au!  BufRead,BufNewFile *.csh call <SID>set_runtime("templetes/shell") | call <SID>set_runtime("bash")
  " au!  BufRead,BufNewFile *.sh call <SID>set_runtime("templetes/shell") | call <SID>set_runtime("bash")
endfunction

"-------------------------------------------------------------------------------
" Function : s:sv_runtime
"-------------------------------------------------------------------------------
function! s:sv_runtime()
  
  if (s:file_ext =~ '\v^(sv|svh|v)$')
    call <SID>set_runtime("sv")
  endif
  " Runtime directory for system verilog
  " au!  BufRead,BufNewFile *.sv call <SID>set_runtime("sv")
  " au!  BufRead,BufNewFile *.svh call <SID>set_runtime("sv")
  " au!  BufRead,BufNewFile *.v call <SID>set_runtime("sv")
endfunction

"-------------------------------------------------------------------------------
" Function : php_runtime
"-------------------------------------------------------------------------------
function! s:php_runtime()
  
  if (s:file_ext =~ '\v^(php)$')
    call <SID>set_runtime("php")
  endif
  " PHP
  " au!  BufRead,BufNewFile *.php call <SID>set_runtime("php")
endfunction

"-------------------------------------------------------------------------------
" Function : log_runtime
"-------------------------------------------------------------------------------
function! s:log_runtime()
  
  if (s:file_ext =~ '\v^(log)$')
    call <SID>set_runtime("sim")
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : cpp_runtime
"-------------------------------------------------------------------------------
function! s:cpp_runtime()
  
  if (s:file_ext =~ '\v^([ch]pp)$')
    call <SID>set_runtime("cpp")
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : matlab_runtime
"-------------------------------------------------------------------------------
function! s:matlab_runtime()
  
  if (s:file_ext =~ '\v^(m)$')
    call <SID>set_runtime("matlab")
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : s:scala_runtime
"-------------------------------------------------------------------------------
function! s:scala_runtime()
  if (s:file_ext == 'scala')
    call <SID>set_runtime("scala")
  endif
endfunction

call s:vhdl_runtime()
call s:perl_runtime()
call s:python_runtime()
call s:make_runtime()
call s:shell_runtime()
call s:sv_runtime()
call s:php_runtime()
call s:vim_runtime()
call s:log_runtime()
call s:cpp_runtime()
call s:matlab_runtime()
call s:scala_runtime()


"" NGAP project
"exe 'so ' . s:src_dir  . '/ngap_review.vim'

" Create Completion item for user define completion
exe 'so ' . s:src_dir  . '/create_completion_item.vim'

" for commands and mapping that uses autoload feature of the functions
exe 'so ' . s:src_dir  . '/use_autoload_fun.vim'
