"-------------------------------------------------------------------------------
" run_on_finish: Function
"-------------------------------------------------------------------------------
function! perl#parallel_forkmanager#run_on_finish()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))
  
  if (name == "")
    " Default value for callback subroutine
    let name = "s_run_on_finish"
  endif

  let str = ""
  let str .= 'my $' . name . ' {'
  let str .= '  my ($pid, $exit_code, $ident, $exit_signal, $core_dump, $data_structure_reference) = @_;'
  let str .= '  maa'
  let str .= '};'
  let str .= '$pm -> run_on_finish ($' . name . ');mb`aa'

  return str
  
endfunction

"-------------------------------------------------------------------------------
" run_on_start: Function
"-------------------------------------------------------------------------------
function! perl#parallel_forkmanager#run_on_start()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))
  
  if (name == "")
    " Default value for callback subroutine
    let name = "s_run_on_start"
  endif

  let str = ""
  let str .= 'my $' . name . ' {'
  let str .= '  my ($pid, $ident) = @_;'
  let str .= '  maa'
  let str .= '};'
  let str .= '$pm -> run_on_start ($' . name . ');mb`aa'

  return str
  
endfunction

"-------------------------------------------------------------------------------
" run_on_wait: Function
"-------------------------------------------------------------------------------
function! perl#parallel_forkmanager#run_on_wait()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))
  
  if (name == "")
    " Default value for callback subroutine
    let name = "s_run_on_wait"
  endif

  let str = ""
  let str .= 'my $' . name . ' {'
  let str .= '  maa'
  let str .= '};'
  let str .= '$pm -> run_on_wait ($' . name . ');mb`aa'

  return str
  
endfunction
