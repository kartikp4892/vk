"-------------------------------------------------------------------------------
" s:GetTemplete: Function
"-------------------------------------------------------------------------------
function! s:GetTemplete(char, ...)
  return common#mov_thru_user_mark#get_template(a:char, a:000)
endfunction

"-------------------------------------------------------------------------------
" _set_indent: Function
"-------------------------------------------------------------------------------
function! s:_set_indent(offset)
  return '=common#indent#imode_set_indent(' . a:offset . ')'
endfunction

"-------------------------------------------------------------------------------
" get_default_name: Function
"-------------------------------------------------------------------------------
function! s:get_default_name()
  let name = expand('%:p:t')
  let name = substitute(name, '\v\.\w+$', '', '')
  return name
endfunction


function! matlab#userdefined#report_info()
  let name = matchstr(getline(search('\v^\s*function>', 'nb')), '\v^\s*function.{-}\W+\zs\w+\ze\s*\(')
  call setline(line("."), repeat(" ", indent(".")))

  if (name == '')
    let name = s:get_default_name()
  endif

  let str = printf("report_info('%0s', sprintf('maa', ), VERBOSITY_LOW);`aa", name)

  return str
endfunction

function! matlab#userdefined#report_error()
  let name = matchstr(getline(search('\v^\s*function>', 'nb')), '\v^\s*function.{-}\W+\zs\w+\ze\s*\(')
  call setline(line("."), repeat(" ", indent(".")))

  if (name == '')
    let name = s:get_default_name()
  endif

  let str = printf("report_error('%0s', sprintf('maa', ), VERBOSITY_LOW);`aa", name)

  return str
endfunction

function! matlab#userdefined#report_pass()
  let name = matchstr(getline(search('\v^\s*function>', 'nb')), '\v^\s*function.{-}\W+\zs\w+\ze\s*\(')
  call setline(line("."), repeat(" ", indent(".")))

  if (name == '')
    let name = s:get_default_name()
  endif

  let str = printf("report_pass('%0s', sprintf('maa', ));`aa", name)

  return str
endfunction

function! matlab#userdefined#report_fail()
  let name = matchstr(getline(search('\v^\s*function>', 'nb')), '\v^\s*function.{-}\W+\zs\w+\ze\s*\(')
  call setline(line("."), repeat(" ", indent(".")))

  if (name == '')
    let name = s:get_default_name()
  endif

  let str = printf("report_fail('%0s', sprintf('maa', ));`aa", name)

  return str
endfunction

function! matlab#userdefined#pretest_step()
  let name = matchstr(getline(search('\v^\s*function>', 'nb')), '\v^\s*function.{-}\W+\zs\w+\ze\s*\(')
  call setline(line("."), repeat(" ", indent(".")))

  if (name == '')
    let name = s:get_default_name()
  endif

  let str = "pretest_step('maa');`aa"

  return str
endfunction

function! matlab#userdefined#stim_step()
  let name = matchstr(getline(search('\v^\s*function>', 'nb')), '\v^\s*function.{-}\W+\zs\w+\ze\s*\(')
  call setline(line("."), repeat(" ", indent(".")))

  if (name == '')
    let name = s:get_default_name()
  endif

  let str = "stim_step('maa');`aa"

  return str
endfunction













