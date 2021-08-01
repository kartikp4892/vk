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

" Insert text at the begning of the file if text is not found in the file.
function! s:_insert_if_not_exists(text)
  if (search(a:text, 'bn') == 0)
    let saveview = winsaveview()
    call append(0, a:text)
    " Added line so adjust lnum 
    let saveview['lnum'] += 1
    call winrestview(saveview)
  endif
endfunction

"-------------------------------------------------------------------------------
" main: Function
"-------------------------------------------------------------------------------
function! cpp#cpp#main()
 let str = '#include <iostream>' .
          \'using namespace std;' .
          \ s:_set_indent(0) . comments#block_comment#getComments("Function", "main") .
          \ s:_set_indent(0) . 'int main () {' .
          \ s:_set_indent(&shiftwidth) . 'maa' .
          \ s:_set_indent(&shiftwidth) . 'return 0;' .
          \ s:_set_indent(-&shiftwidth) . '}`aa' 
  return str
endfunction

"-------------------------------------------------------------------------------
" function: Function
"-------------------------------------------------------------------------------
function! cpp#cpp#function()
  let name = matchstr(getline("."), '\w\+')
  if (name == '')
    let name = s:GetTemplete('a', 'fun')
  endif

  call setline(line("."), repeat(" ", indent(".")))
  let str = comments#block_comment#getComments("Function", "" . name ) .
  \         s:_set_indent(0) . printf('void %s ( void ) {', name) .
  \         s:_set_indent(&shiftwidth) . 'maa' .
  \         s:_set_indent(0) . '}`aa'
   return str
endfunction

"-------------------------------------------------------------------------------
" for_incr: Function
"-------------------------------------------------------------------------------
function! cpp#cpp#for_incr()
  let name = matchstr(getline("."), '\w\+')
  call setline(line("."), repeat(" ", indent(".")))
  let str = printf('for (int %0s = 0; %0s <= maa; %0s++) {', name, name, name) .
  \         s:_set_indent(&shiftwidth) . '' .
  \         s:_set_indent(0) . '}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" for_decr: Function
"-------------------------------------------------------------------------------
function! cpp#cpp#for_decr()
  let name = matchstr(getline("."), '\w\+')
  call setline(line("."), repeat(" ", indent(".")))
  let str = printf('for (int %0s = maa; %0s >= 0; %0s++) {', name, name, name) .
  \         s:_set_indent(&shiftwidth) . '' .
  \         s:_set_indent(0) . '}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" foreach: Function
"-------------------------------------------------------------------------------
function! cpp#cpp#foreach()
  let name = matchstr(getline("."), '\w\+')
  call setline(line("."), repeat(" ", indent(".")))

  if (name =~ '^\s*$')
    let name = s:GetTemplete('a', 'var')
  endif

  let str = printf('for (auto const& %s : maa) {', name) .
  \         s:_set_indent(&shiftwidth) . '' .
  \         s:_set_indent(0) . '}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" while: Function
"-------------------------------------------------------------------------------
function! cpp#cpp#while()
 let str = 'while (maa) {' .
  \        s:_set_indent(&shiftwidth) . '' .
  \        s:_set_indent(0) . '}`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" do_while: Function
"-------------------------------------------------------------------------------
function! cpp#cpp#do_while()
 let str = 'do {' .
  \        s:_set_indent(&shiftwidth) . '' .
  \        s:_set_indent(0) . '} while (maa)`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" struct: Function
"-------------------------------------------------------------------------------
function! cpp#cpp#struct()
  let name = matchstr(getline("."), '\w\+')
  if (name == '')
    let name = s:GetTemplete('a', 'name')
  endif

  call setline(line("."), repeat(" ", indent(".")))
  let str = 'typedef struct {' .
   \        s:_set_indent(&shiftwidth) . 'maa' .
   \        s:_set_indent(0) . printf('} %0s;`aa', name)
  return str
endfunction

"-------------------------------------------------------------------------------
" union: Function
"-------------------------------------------------------------------------------
function! cpp#cpp#union()
  let name = matchstr(getline("."), '\w\+')
  if (name == '')
    let name = s:GetTemplete('a', 'name')
  endif

  call setline(line("."), repeat(" ", indent(".")))
  let str = 'typedef union {' .
   \        s:_set_indent(&shiftwidth) . 'maa' .
   \        s:_set_indent(0) . printf('} %0s;`aa', name)
  return str
endfunction

function! cpp#cpp#namespace()
  let name = matchstr(getline("."), '\w\+')
  if (name == '')
    let name = s:GetTemplete('a', 'name')
  endif

  call setline(line("."), repeat(" ", indent(".")))
  
  let str = printf('namespace %s {', name) 
  let str .= s:_set_indent(&shiftwidth) . 'maa' 
  let str .= s:_set_indent(0) . '}`aa'

  return str
endfunction

function! cpp#cpp#template()
  let name = matchstr(getline("."), '\w\+')
  if (name == '')
    let name = s:GetTemplete('a', 'name')
  endif

  call setline(line("."), repeat(" ", indent(".")))
  
  let str = printf('template <maa%0s %0s>`aa', s:GetTemplete('a', 'typename/class'), s:GetTemplete('a', 'type/T'))

  return str
endfunction

function! cpp#cpp#if()
  let str = 'if ( maa ) {'
  let str .= s:_set_indent(&shiftwidth) . ''
  let str .= s:_set_indent(0) . '}`aa'

  return str
endfunction

function! cpp#cpp#else()
  let str = 'else {'
  let str .= s:_set_indent(&shiftwidth) . 'maa'
  let str .= s:_set_indent(0) . '}`aa'

  return str
endfunction

function! cpp#cpp#elseif()
  let str = 'else if ( maa ) {'
  let str .= s:_set_indent(&shiftwidth) . ''
  let str .= s:_set_indent(0) . '}`aa'

  return str
endfunction

function! cpp#cpp#case()
  let str = 'switch ( maa ) {'
  let str .= s:_set_indent(&shiftwidth) . printf('case (%s):', s:GetTemplete('a', 'value'))
  let str .= s:_set_indent(&shiftwidth) . '{'
  let str .= s:_set_indent(&shiftwidth) . ''
  let str .= s:_set_indent(0) . '}'
  let str .= s:_set_indent(0) . 'break;'
  let str .= s:_set_indent(-&shiftwidth) . 'default:'
  let str .= s:_set_indent(&shiftwidth) . 'break;'
  let str .= s:_set_indent(-2*&shiftwidth) . '}`aa'

  return str
endfunction

function! cpp#cpp#vector()
  call s:_insert_if_not_exists('#include <vector>')

  let str = 'vector<maa> `aa'
  return str
endfunction

function! cpp#cpp#initializer_list()
  call s:_insert_if_not_exists('#include <initializer_list>')

  let str = 'initializer_list<maa> `aa'
  return str
endfunction

function! cpp#cpp#map()
  call s:_insert_if_not_exists('#include <map>')

  let str = printf('map<maa%s, %s> `aa', s:GetTemplete('a', 'key'), s:GetTemplete('a', 'value'))
  return str
endfunction

function! cpp#cpp#map_iterator_for_inc()
  call s:_insert_if_not_exists('#include <map>')

  let str = printf('for (map<maa%s, %s>::iterator i1 = %s.begin(); i1 != %s.end(); ++i1) {', s:GetTemplete('a', 'key'), s:GetTemplete('a', 'value'), s:GetTemplete('a', 'm_map'), s:GetTemplete('a', 'm_map'))
  let str .= s:_set_indent(&shiftwidth) . ''
  let str .= s:_set_indent(0) . '}`aa'
  return str
endfunction

function! cpp#cpp#map_iterator_for_dec()
  call s:_insert_if_not_exists('#include <map>')

  let str = printf('for (map<maa%s, %s>::reverse_iterator i1 = %s.rbegin(); i1 != %s.rend(); ++i1) {', s:GetTemplete('a', 'key'), s:GetTemplete('a', 'value'), s:GetTemplete('a', 'm_map'), s:GetTemplete('a', 'm_map'))
  let str .= s:_set_indent(&shiftwidth) . ''
  let str .= s:_set_indent(0) . '}`aa'
  return str
endfunction

function! cpp#cpp#multimap()
  call s:_insert_if_not_exists('#include <map>')

  let str = printf('multimap<maa%s, %s> `aa', s:GetTemplete('a', 'key'), s:GetTemplete('a', 'value'))
  return str
endfunction

function! cpp#cpp#multimap_iterator_for_inc()
  call s:_insert_if_not_exists('#include <map>')

  let str = printf('for (multimap<maa%s, %s>::iterator i1 = %s.begin(); i1 != %s.end(); ++i1) {', s:GetTemplete('a', 'key'), s:GetTemplete('a', 'value'), s:GetTemplete('a', 'm_map'), s:GetTemplete('a', 'm_map'))
  let str .= s:_set_indent(&shiftwidth) . ''
  let str .= s:_set_indent(0) . '}`aa'
  return str
endfunction

function! cpp#cpp#multimap_iterator_for_dec()
  call s:_insert_if_not_exists('#include <map>')

  let str = printf('for (multimap<maa%s, %s>::reverse_iterator i1 = %s.rbegin(); i1 != %s.rend(); ++i1) {', s:GetTemplete('a', 'key'), s:GetTemplete('a', 'value'), s:GetTemplete('a', 'm_map'), s:GetTemplete('a', 'm_map'))
  let str .= s:_set_indent(&shiftwidth) . ''
  let str .= s:_set_indent(0) . '}`aa'
  return str
endfunction

function! cpp#cpp#multimap_iterator_for_range()
  call s:_insert_if_not_exists('#include <map>')

  let str = printf('pair<multimap<maa%s, %s>::iterator, multimap<%s, %s>::iterator> pii;', s:GetTemplete('a', 'key'), s:GetTemplete('a', 'value'), s:GetTemplete('a', 'key'), s:GetTemplete('a', 'value'))
  let str .= printf('pii = %s.equal_range(%s);', s:GetTemplete('a', 'm_map'), s:GetTemplete('a', 'key'))
  let str .= printf('for (multimap<%s, %s>::iterator i1 = pii.first; i1 != pii.second; ++i1) {', s:GetTemplete('a', 'key'), s:GetTemplete('a', 'value'))
  let str .= s:_set_indent(&shiftwidth) . ''
  let str .= s:_set_indent(0) . '}`aa'
  return str
endfunction

function! cpp#cpp#vector_iterator_for_inc()
  call s:_insert_if_not_exists('#include <vector>')

  let str = printf('for (vector<maa%s>::iterator i1 = %s.begin(); i1 != %s.end(); ++i1) {', s:GetTemplete('a', 'type'), s:GetTemplete('a', 'm_vector'), s:GetTemplete('a', 'm_vector'))
  let str .= s:_set_indent(&shiftwidth) . ''
  let str .= s:_set_indent(0) . '}`aa'
  return str
endfunction

function! cpp#cpp#vector_iterator_for_dec()
  call s:_insert_if_not_exists('#include <vector>')

  let str = printf('for (vector<maa%s, %s>::reverse_iterator i1 = %s.rbegin(); i1 != %s.rend(); ++i1) {', s:GetTemplete('a', 'type'), s:GetTemplete('a', 'm_vector'), s:GetTemplete('a', 'm_vector'))
  let str .= s:_set_indent(&shiftwidth) . ''
  let str .= s:_set_indent(0) . '}`aa'
  return str
endfunction



