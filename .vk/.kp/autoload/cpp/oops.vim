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
" class: Function
"-------------------------------------------------------------------------------
function! cpp#oops#class()
  let name = matchstr(getline("."), '\w\+')
  call setline(line("."), repeat(" ", indent(".")))
  if (name == '')
    let name = s:GetTemplete('a', 'cls')
  endif

  let str = comments#block_comment#getComments("Class", "" . name ) .
     \      s:_set_indent(0) . printf('class %s {', name) .
     \      s:_set_indent(&shiftwidth) . 'maa' .
     \      s:_set_indent(&shiftwidth) . 'public:' .
     \      s:_set_indent(&shiftwidth) . printf('%s ( void ) { // Constructor', name) .
     \      s:_set_indent(&shiftwidth) . '' .
     \      s:_set_indent(0) . '}' .
     \      s:_set_indent(0) . printf('~%s ( void ) { // Destructor', name) .
     \      s:_set_indent(&shiftwidth) . '' .
     \      s:_set_indent(0) . '}' .
     \      s:_set_indent(0) . printf('%s ( const %s &obj ) { // Copy Constructor', name, name) .
     \      s:_set_indent(&shiftwidth) . '' .
     \      s:_set_indent(0) . '}' .
     \      s:_set_indent(-2 * &shiftwidth) . '};`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" class_extended: Function
"-------------------------------------------------------------------------------
function! cpp#oops#class_extended()
  let name = matchstr(getline("."), '\w\+')
  call setline(line("."), repeat(" ", indent(".")))
  if (name == '')
    let name = s:GetTemplete('a', 'cls')
  endif

  let str = comments#block_comment#getComments("Class", "" . name ) .
     \      s:_set_indent(0) . printf('class %s : public %s {', name, s:GetTemplete('a', 'base')) .
     \      s:_set_indent(&shiftwidth) . 'maa' .
     \      s:_set_indent(&shiftwidth) . 'public:' .
     \      s:_set_indent(&shiftwidth) . printf('%s ( void ) { // Constructor', name) .
     \      s:_set_indent(&shiftwidth) . '' .
     \      s:_set_indent(0) . '}' .
     \      s:_set_indent(0) . printf('~%s ( void ) { // Destructor', name) .
     \      s:_set_indent(&shiftwidth) . '' .
     \      s:_set_indent(0) . '}' .
     \      s:_set_indent(0) . printf('%s ( const %s &obj ) { // Copy Constructor', name, name) .
     \      s:_set_indent(&shiftwidth) . '' .
     \      s:_set_indent(0) . '}' .
     \      s:_set_indent(-2 * &shiftwidth) . '};`aa'
  return str
endfunction

"-------------------------------------------------------------------------------
" function: Operator Overloading
"-------------------------------------------------------------------------------
function! cpp#oops#operator_overloading()
  let valid_operators = ['+', '-', '*', '/', '%', '^', '&', '|', '~', '!', ',', '=', '<', '>', '<=', '>=', '++', '--', '<<', '>>', '==', '!=', '&&', '||', '+=', '-=', '/=', '%=', '^=', '&=', '|=', '*=', '<<=', '>>=', '[]', '()', '->', '->*', 'new', 'new []', 'delete', 'delete []']

  call setline(line("."), repeat(" ", indent(".")))

  let operators = tlib#input#List('m', 'Select Operator', valid_operators)

  let str = ''

  for l:operator in operators
    let str .= s:operator_overloading_template(operator)
  endfor

  if (str != '')
    return str
  endif

  let name = s:GetTemplete('a', 'op')

  let str = comments#block_comment#getComments("Function", "" . name ) .
  \         s:_set_indent(0) . printf('void operator%0s ( void ) {', name) .
  \         s:_set_indent(&shiftwidth) . 'maa' .
  \         s:_set_indent(0) . '}`aa'
   return str
endfunction

function! s:operator_overloading_template(operator)
  let clsname = matchstr(getline(search('class\s\+\w\+', 'bn')), 'class\s\+\zs\w\+')

  let str = ''
  if (a:operator == '-' || a:operator == '+' || a:operator == '--' || a:operator == '++')
    let str .= comments#block_comment#getComments("Function", "" . a:operator ) .
    \         printf('// Overloaded unary prefix %s operator', a:operator ) .
    \         s:_set_indent(0) . printf('%0s operator%0s ( void ) {', clsname, a:operator) .
    \         s:_set_indent(&shiftwidth) . printf('%0s temp;', clsname) .
    \         s:_set_indent(0) . 'maa' .
    \         s:_set_indent(0) . 'return temp;' .
    \         s:_set_indent(-&shiftwidth) . '}'
  endif

  if (a:operator == '--' || a:operator == '++')
    let str .= comments#block_comment#getComments("Function", "" . a:operator ) .
    \         printf('// Overloaded unary postfix %s operator', a:operator ) .
    \         s:_set_indent(0) . printf('%0s operator%0s ( int ) {', clsname, a:operator) .
    \         s:_set_indent(&shiftwidth) . printf('%0s temp;', clsname) .
    \         s:_set_indent(0) . 'maa' .
    \         s:_set_indent(0) . 'return temp;' .
    \         s:_set_indent(-&shiftwidth) . '}'
  elseif (a:operator == '-' || a:operator == '+' || a:operator == '/' || a:operator == '*')
    let str .= comments#block_comment#getComments("Function", "" . a:operator ) .
    \         printf('// Overloaded binary %s operator', a:operator ) .
    \         s:_set_indent(0) . printf('%0s operator%0s ( const %0s& rhs_ ) {', clsname, a:operator, clsname) .
    \         s:_set_indent(&shiftwidth) . printf('%0s temp;', clsname) .
    \         s:_set_indent(0) . 'maa' .
    \         s:_set_indent(0) . 'return temp;' .
    \         s:_set_indent(-&shiftwidth) . '}'
  endif

  if (a:operator == '<' || a:operator == '<=' || a:operator == '>' || a:operator == '>=' || a:operator == '==')
    let str .= comments#block_comment#getComments("Function", "" . a:operator ) .
    \         printf('// Overloaded binary %s operator', a:operator ) .
    \         s:_set_indent(0) . printf('%0s operator%0s ( const %0s& rhs_ ) const {', 'bool', a:operator, clsname) .
    \         s:_set_indent(&shiftwidth) . 'maa' .
    \         s:_set_indent(0) . '}'
  endif

  if (a:operator == '<<')
    let str .= comments#block_comment#getComments("Function", "" . a:operator ) .
    \         printf('// Overloaded %s operator', a:operator ) .
    \         s:_set_indent(0) . printf('friend %0s &operator%0s ( ostream &output, const %0s &rhs_ ) {', 'ostream', a:operator, clsname) .
    \         s:_set_indent(&shiftwidth) . 'maa' .
    \         s:_set_indent(&shiftwidth) . 'return output;' .
    \         s:_set_indent(-&shiftwidth) . '}'
  endif

  if (a:operator == '>>')
    let str .= comments#block_comment#getComments("Function", "" . a:operator ) .
    \         printf('// Overloaded %s operator', a:operator ) .
    \         s:_set_indent(0) . printf('friend %0s &operator%0s ( istream &input, const %0s &rhs_ ) {', 'istream', a:operator, clsname) .
    \         s:_set_indent(&shiftwidth) . 'maa' .
    \         s:_set_indent(&shiftwidth) . 'return input;' .
    \         s:_set_indent(-&shiftwidth) . '}'
  endif

  if (a:operator == '=')
    let str .= comments#block_comment#getComments("Function", "" . a:operator ) .
    \         printf('// Overloaded %s operator', a:operator ) .
    \         s:_set_indent(0) . printf('void operator%0s ( const %0s &rhs_ ) {', a:operator, clsname) .
    \         s:_set_indent(&shiftwidth) . 'maa' .
    \         s:_set_indent(0) . '}'
  endif

  if (a:operator == '()')
    let str .= comments#block_comment#getComments("Function", "" . a:operator ) .
    \         printf('// Overloaded %s operator', a:operator ) .
    \         s:_set_indent(0) . printf('%0s operator%0s ( /* args */ ) {', clsname, a:operator) .
    \         s:_set_indent(&shiftwidth) . printf('%0s temp;', clsname) .
    \         s:_set_indent(0) . 'maa' .
    \         s:_set_indent(0) . 'return temp;' .
    \         s:_set_indent(-&shiftwidth) . '}'
  endif

  if (a:operator == '[]')
    let str .= comments#block_comment#getComments("Function", "" . a:operator ) .
    \         printf('// Overloaded %s operator', a:operator ) .
    \         s:_set_indent(0) . printf('%0s &operator%0s ( int i ) {', s:GetTemplete('a', '/int'), a:operator) .
    \         s:_set_indent(&shiftwidth) . 'maa' .
    \         s:_set_indent(0) . '}'
  endif

  if (a:operator == '->')
    let str .= comments#block_comment#getComments("Function", "" . a:operator ) .
    \         printf('// Overloaded %s operator', a:operator ) .
    \         s:_set_indent(0) . printf('%0s* operator%0s () const {', s:GetTemplete('a', 'Class'), a:operator) .
    \         s:_set_indent(&shiftwidth) . 'maa' .
    \         s:_set_indent(0) . '}'
  endif

  return str
endfunction

"-------------------------------------------------------------------------------
" function: Function
"-------------------------------------------------------------------------------
function! cpp#oops#function()
  let name = matchstr(getline("."), '\w\+')
  if (name == '')
    let name = s:GetTemplete('a', 'fun')
  endif

  call setline(line("."), repeat(" ", indent(".")))
  let str = comments#block_comment#getComments("Function", "" . name ) .
  \         s:_set_indent(0) . printf('virtual void %s ( void ) %s%s{', name, s:GetTemplete('a', '/const '), s:GetTemplete('a', '/override ')) .
  \         s:_set_indent(&shiftwidth) . 'maa' .
  \         s:_set_indent(0) . '}`aa'
   return str
endfunction





