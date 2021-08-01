let s:default_name = 're.'

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
" Function : update_default_name
"-------------------------------------------------------------------------------
function! s:update_default_name()
  if (search('\v\w+\.\w+\.%#', 'n') != 0)
    return
  endif

  if (search('\v\w+\.%#', 'n') != 0)
    let [ln, cn] = searchpos('\v\w+\.%#', 'n')
    let s:default_name = strpart(getline('.'), cn - 1, col('.') - 1)
  endif
endfunction

"-------------------------------------------------------------------------------
" Function : get_default_name
"-------------------------------------------------------------------------------
function! s:get_default_name()
  "Matches . in current position?
  if (search('\v\.%#', 'n') != 0)
    call s:update_default_name()
    return ''
  endif

  return s:default_name
endfunction

"-------------------------------------------------------------------------------
" Function : compile
"-------------------------------------------------------------------------------
function! python#regex#compile()
  let str = 're.compile(maa)`aa'
  return str
endfunction

function! python#regex#search()
  let name = s:get_default_name()
  let str = name . 'search(maa)`aa'
  return str
endfunction

function! python#regex#split()
  let name = s:get_default_name()
  let str = name . 'split(maa)`aa'
  return str
endfunction

function! python#regex#sub()
  let name = s:get_default_name()
  let str = name . 'sub(maa)`aa'
  return str
endfunction

function! python#regex#span()
  let name = s:get_default_name()
  let str = name . 'span(maa)`aa'
  return str
endfunction

function! python#regex#subn()
  let name = s:get_default_name()
  let str = name . 'subn(maa)`aa'
  return str
endfunction

function! python#regex#escape()
  let name = s:get_default_name()
  let str = name . 'escape(maa)`aa'
  return str
endfunction

function! python#regex#purge()
  let name = s:get_default_name()
  let str = name . 'purge(maa)`aa'
  return str
endfunction

function! python#regex#group()
  let name = s:get_default_name()
  let str = name . 'group(maa)`aa'
  return str
endfunction

function! python#regex#groups()
  let name = s:get_default_name()
  let str = name . 'groups(maa)`aa'
  return str
endfunction

function! python#regex#groupdict()
  let name = s:get_default_name()
  let str = name . 'groupdict(maa)`aa'
  return str
endfunction

function! python#regex#start()
  let name = s:get_default_name()
  let str = name . 'start(maa)`aa'
  return str
endfunction

function! python#regex#end()
  let name = s:get_default_name()
  let str = name . 'end(maa)`aa'
  return str
endfunction

function! python#regex#findall()
  let name = s:get_default_name()
  let str = name . 'findall(maa)`aa'
  return str
endfunction

function! python#regex#finditer()
  let name = s:get_default_name()
  let str = name . 'finditer(maa)`aa'
  return str
endfunction

function! python#regex#match()
  let name = s:get_default_name()
  let str = name . 'match(maa)`aa'
  return str
endfunction

function! python#regex#DEBUG()
  let name = s:get_default_name()
  let str = name . 'DEBUG'
  return str
endfunction

function! python#regex#IGNORE()
  let name = s:get_default_name()
  let str = name . 'IGNORE'
  return str
endfunction

function! python#regex#LOCALE()
  let name = s:get_default_name()
  let str = name . 'LOCALE'
  return str
endfunction

function! python#regex#MULTILINE()
  let name = s:get_default_name()
  let str = name . 'MULTILINE'
  return str
endfunction

function! python#regex#DOTALL()
  let name = s:get_default_name()
  let str = name . 'DOTALL'
  return str
endfunction

function! python#regex#UNICODE()
  let name = s:get_default_name()
  let str = name . 'UNICODE'
  return str
endfunction

function! python#regex#VERBOSE()
  let name = s:get_default_name()
  let str = name . 'VERBOSE'
  return str
endfunction





