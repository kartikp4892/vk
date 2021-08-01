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
" Function : s:get_current_class_name
"-------------------------------------------------------------------------------
function! s:get_current_class_name()
  let ln = search('\v^\s*class\s+\w+', 'bn')
  let class_name = matchstr(getline(ln), '\v^\s*class\s+\zs\w+')
  return class_name
endfunction


"-------------------------------------------------------------------------------
" Function : class
"-------------------------------------------------------------------------------
function! python#oops#class()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  let str = comments#block_comment#getComments('Class', var)
  let str .= 'class ' . var . '(object):' .
           \ s:_set_indent(&shiftwidth) . '"""class: ' . var . '"""' .
           \ s:_set_indent(0) . comments#block_comment#getComments('Function', '__init__') .
           \ s:_set_indent(0) . 'def __init__(selfmaa):' .
           \ s:_set_indent(&shiftwidth) . '`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : class_singleton
"-------------------------------------------------------------------------------
function! python#oops#class_singleton()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = 'Singleton'
  endif

  let str = 'class ' . var . '(type):' .
           \ s:_set_indent(&shiftwidth) . '"""class: ' . var . '"""' .
           \ s:_set_indent(0) . '_instances = {}' .
           \ s:_set_indent(0) . comments#block_comment#getComments('Function', '__call__') .
           \ s:_set_indent(0) . 'def __call__(cls, *args, **kwargs):' .
           \ s:_set_indent(&shiftwidth) . 'if cls not in cls._instances:' .
           \ s:_set_indent(&shiftwidth) . 'cls._instances[cls] = super(Singleton, cls).__call__(*args, **kwargs)' .
           \ s:_set_indent(-&shiftwidth) . 'else:' .
           \ s:_set_indent(&shiftwidth) . 'cls._instances[cls].__init__(*args, **kwargs)' .
           \ s:_set_indent(-&shiftwidth) . 'return cls._instances[cls]'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : metaclass
"-------------------------------------------------------------------------------
function! python#oops#metaclass()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  let str = comments#block_comment#getComments('Class', var)
  let str .= 'class ' . var . '(type):' .
           \ s:_set_indent(&shiftwidth) . '"""class: ' . var . '"""' .
           \ s:_set_indent(0) . 'def __init__(cls, name, parents, dict):' .
           \ s:_set_indent(0) . comments#block_comment#getComments('Function', '__init__') .
           \ s:_set_indent(&shiftwidth) . '"""def: __init__"""' .
           \ s:_set_indent(0) . printf('super(%s, self).__init__(name, parents, dict)', var) .
           \ s:_set_indent(0) 

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : metaclass_init
"-------------------------------------------------------------------------------
function! python#oops#metaclass_init()

  let str = comments#block_comment#getComments('Function', '__init__')
  let str .= 'def __init__(cls, name, parents, dict):' .
           \ s:_set_indent(&shiftwidth) . '"""def: __init__"""' .
           \ s:_set_indent(0) . printf('super(%s, cls).__init__(name, parents, dict)', s:get_current_class_name()) .
           \ s:_set_indent(0) 

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : metaclass_new
"-------------------------------------------------------------------------------
function! python#oops#metaclass_new()

  let str = comments#block_comment#getComments('Function', '__new__')
  let str .= 'def __new__(cls, name, parents, dict):' .
           \ s:_set_indent(&shiftwidth) . '"""def: __new__"""' .
           \ s:_set_indent(0) . printf('return super(%s, cls).__new__(cls, name, parents, dict)', s:get_current_class_name()) .
           \ s:_set_indent(0) 

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : metaclass_call
"-------------------------------------------------------------------------------
function! python#oops#metaclass_call()

  let str = comments#block_comment#getComments('Function', '__call__')
  let str .= 'def __call__(cls, *args, **kwargs):' .
           \ s:_set_indent(&shiftwidth) . '"""def: __call__"""' .
           \ s:_set_indent(0) . printf('return super(%s, cls).__call__(*args, **kwargs)', s:get_current_class_name()) .
           \ s:_set_indent(0) 

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : class_meta
"-------------------------------------------------------------------------------
function! python#oops#class_meta()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  let str = 'class ' . var . '(object):' .
           \ s:_set_indent(&shiftwidth) . '"""class: ' . var . '"""' .
           \ s:_set_indent(0) . '__metaclass__ = ' . s:GetTemplete('2', 'class')

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : descriptor_class
"-------------------------------------------------------------------------------
function! python#oops#descriptor_class()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  
  let str = comments#block_comment#getComments('Class', var)
  let str .= 'class ' . var . '(object):' .
        \ s:_set_indent(&shiftwidth) . '"""class: ' . var . '"""' .
        \ s:_set_indent(0) . comments#block_comment#getComments('Function', '__init__') .
        \ s:_set_indent(0) . 'def __init__(self):' .
        \ s:_set_indent(&shiftwidth) . 'pass' .
        \ s:_set_indent(0) . comments#block_comment#getComments('Function', '__get__') .
        \ s:_set_indent(-&shiftwidth) . 'def __get__(self, instance, cls):' .
        \ s:_set_indent(&shiftwidth) . 'return getattr(instance, self.name, self.default)' .
        \ s:_set_indent(0) . comments#block_comment#getComments('Function', '__set__') .
        \ s:_set_indent(-&shiftwidth) . 'def __set__(self,instance,value):' .
        \ s:_set_indent(&shiftwidth) . 'setattr(instance, self.name, value)' .
        \ s:_set_indent(0) . comments#block_comment#getComments('Function', '__delete__') .
        \ s:_set_indent(-&shiftwidth) . 'def __delete__(self, instance):' .
        \ s:_set_indent(&shiftwidth) . 'pass'

  return str
endfunction


"-------------------------------------------------------------------------------
" Function : abstract_class
"-------------------------------------------------------------------------------
function! python#oops#abstract_class()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  let str = 'from abc import ABCMeta, abstractmethod'
           \ 'class ' . var . '(object):' .
           \ s:_set_indent(&shiftwidth) . '"""class: ' . var . '"""' .
           \ s:_set_indent(0) . "__metaclass__ = ABCMeta" .
           \
          \ s:_set_indent(0) . comments#block_comment#getComments('Function', '__init__') .
           \ s:_set_indent(0) . 'def __init__(selfmaa):'
           \ s:_set_indent(&shiftwidth) . '`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : abstract_function
"-------------------------------------------------------------------------------
function! python#oops#abstract_function()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  let str = comments#block_comment#getComments('Function', var)
  let str .= '@abstractmethod' .
          \ 'def ' . var . ' (selfmaa):' .
           \ s:_set_indent(&shiftwidth) . '"""def: ' . var . '"""' .
            \ s:_set_indent(0) . 'pass`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : static_function
"-------------------------------------------------------------------------------
function! python#oops#static_function()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  let str = comments#block_comment#getComments('Function', var)
  let str .= '@staticmethod' .
          \ 'def ' . var . ' (maa):' .
           \ s:_set_indent(&shiftwidth) . '"""def: ' . var . '"""' .
            \ s:_set_indent(0) . 'pass`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : class_function
"-------------------------------------------------------------------------------
function! python#oops#class_function()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  let str = comments#block_comment#getComments('Function', var)
  let str = '@classmethod' .
          \ 'def ' . var . ' (clsmaa):' .
           \ s:_set_indent(&shiftwidth) . '"""def: ' . var . '"""' .
            \ s:_set_indent(0) . 'pass`aa'

  return str
endfunction


"-------------------------------------------------------------------------------
" Function : function
"-------------------------------------------------------------------------------
function! python#oops#function()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  let str = comments#block_comment#getComments('Function', var)
  let str .= 'def ' . var . ' (selfmaa):' .
           \ s:_set_indent(&shiftwidth) . '"""def: ' . var . '"""' .
            \ s:_set_indent(0) . '`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : init
"-------------------------------------------------------------------------------
function! python#oops#init()
  let str = comments#block_comment#getComments('Function', '__init__')
  let str .= 'def __init__ (selfmaa):' .
           \ s:_set_indent(&shiftwidth) . '"""Constructor"""' .
           \ s:_set_indent(&shiftwidth) . '`aa'

  return str
endfunction


