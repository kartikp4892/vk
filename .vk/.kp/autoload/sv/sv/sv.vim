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

" Note: See common/global_var.vim for global variables like _

"-------------------------------------------------------------------------------
" Complete the syntax
"-------------------------------------------------------------------------------
" @param a:1,a:2,a:3 = extra parameter to call function
" Give 'default' parameter to -1 if want user input if name is not present at begning of line
" else the default value will be used.
fun! sv#sv#sv#complete(fun_to_call, default, ...)

  " Check if name provided
  if (getline(".") =~ '^\s*\w\+\s*$')
    let l:name = matchstr(getline("."), '\w\+')
  else
    " If default name is given use this else get from input
    if (a:default != -1)
      let l:name = a:default
    else
      let l:name = input("Sequence Item Name: ")
    endif
  endif

  " Set proper indentation of current line
  let l:indent = substitute(getline("."), '\w\+\s*$', '', '')
  call setline(".", l:indent)

  " Insert name at the start of list
  if (a:0 != 0)
    let l:list = extend([l:name], a:000)
  else
    let l:list = [l:name]
  endif
  return call(a:fun_to_call, l:list)
endfun

"-------------------------------------------------------------------------------
" get_default_name: Function
"-------------------------------------------------------------------------------
function! sv#sv#sv#get_default_name()
  let name = @%
  let name = substitute(name, '\v\.\w+$', '', '')
  return name
endfunction

"-------------------------------------------------------------------------------
" Interface
"-------------------------------------------------------------------------------
fun! sv#sv#sv#interface(name)
  let l:str = '=comments#block_comment#getComments("Interface", "' . a:name . '")'
  let l:str .= 'interface automatic ' . a:name . ';
                \  maa
                \endinterface : ' . a:name . '`aa'
  return l:str
endfun

"-------------------------------------------------------------------------------
" clocking_block: Function
"-------------------------------------------------------------------------------
function! sv#sv#sv#clocking_block()
   let name = matchstr(getline("."), '^\s*\zs\w\+')
   if (name =~ '^\s*$')
     let name = s:GetTemplete('a', 'cb_name')
   endif

   call setline(".", repeat(' ', indent(".")))

   let str = printf('clocking %s @ ( posedge clk );', name) .
           \ s:_set_indent(&shiftwidth) . 'default input #1ns output #1ns;' .
           \ s:_set_indent(0) . printf('output maa%s;', s:GetTemplete('a', 'out_signals')) .
           \ s:_set_indent(0) . printf('input  %s;', s:GetTemplete('b', 'in_signals')) .
           \ s:_set_indent(-&shiftwidth) . printf('endclocking: %s', name) . '`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" modport: Function
"-------------------------------------------------------------------------------
function! sv#sv#sv#modport()
   let name = matchstr(getline("."), '^\s*\zs\w\+')
   if (name =~ '^\s*$')
     let name = s:GetTemplete('a', 'cb_name')
   endif

   call setline(".", repeat(' ', indent(".")))

   let str = printf('modport %s ( maa );`aa', name)

   return str
endfunction

"-------------------------------------------------------------------------------
" package
"-------------------------------------------------------------------------------
fun! sv#sv#sv#package()
  let name = matchstr(getline("."), '^\s*\zs\w\+')

  if (name =~ '^\s*$')
    let name = sv#sv#sv#get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  let l:str = '=comments#block_comment#getComments("Package", "' . name . '")'
  let l:str .= 'package ' . name . ';' . 
                \'  maa' . 
                \'endpackage : ' . name . '`aa'
  return l:str
endfun

"-------------------------------------------------------------------------------
" Class
"-------------------------------------------------------------------------------
fun! sv#sv#sv#class()

  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  let l:str = '=comments#block_comment#getComments("Class", "' . l:name . '")'
  let l:str .= s:_set_indent(0) . printf('class %s;', l:name) .
                \ s:_set_indent(&shiftwidth) .  'maa' .
                \ s:_set_indent(&shiftwidth) . comments#block_comment#getComments("Function", "new") .
                \ s:_set_indent(0) . 'function new();' .
                \ s:_set_indent(0) . 'endfunction : new' .
                \
                \ s:_set_indent(-&shiftwidth) .  printf('endclass : %s`aa', l:name)

  return l:str
endfun

"-------------------------------------------------------------------------------
" Struct
"-------------------------------------------------------------------------------
fun! sv#sv#sv#struct()

  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  let l:str = '=comments#block_comment#getComments("Struct", "' . l:name . '")'
  let l:str .= s:_set_indent(0) . 'typedef struct {' .
              \ s:_set_indent(&shiftwidth) . 'maa' .
              \ s:_set_indent(0) . printf('} %0s;`aa', name)

  return l:str
endfun

"-------------------------------------------------------------------------------
" Extended Class
"-------------------------------------------------------------------------------
fun! sv#sv#sv#class_extended()

  let name = matchstr(getline("."), '^\s*\zs\w\+')
  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  let l:str = '=comments#block_comment#getComments("Class", "' . l:name . '")'
  let l:str .= s:_set_indent(0) . printf('class %s extends %s;', l:name, s:GetTemplete('a', 'parent')) .
                \ s:_set_indent(&shiftwidth) .  'maa' .
                \ s:_set_indent(&shiftwidth) . comments#block_comment#getComments("Function", "new") .
                \ s:_set_indent(0) . 'function new();' .
                \ s:_set_indent(&shiftwidth) .  'super.new();' .
                \ s:_set_indent(-&shiftwidth) . 'endfunction : new' .
                \
                \ s:_set_indent(-&shiftwidth) .  printf('endclass : %s`aa', l:name)

  return l:str
endfun

"-------------------------------------------------------------------------------
" randomize: Function
"-------------------------------------------------------------------------------
function! sv#sv#sv#randomize(name)
  let l:str = 'assert (' . a:name . '.randomize())
              \else $fatal (0, $sformatf("[%m]: Randomization failed!!!", ' . a:name . '));'
  return l:str 
endfunction

"-------------------------------------------------------------------------------
" std_randomize: Function
"-------------------------------------------------------------------------------
function! sv#sv#sv#std_randomize()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  let l:str = printf('assert (std :: randomize (%s) with {maa%s;})', l:name , s:GetTemplete('a', 'constraint')) .
              \ 'else $fatal (0, $sformatf("Randomization failed!!!"));`aa'
  return l:str 
endfunction

"-------------------------------------------------------------------------------
" Program
"-------------------------------------------------------------------------------
fun! sv#sv#sv#program(name)
  let l:str = '=comments#block_comment#getComments("Program", "' . a:name . '")'
  let l:str .= 'program automatic ' . a:name . '();
                \  maa
                  \initial begin
                  \  mba
                  \end
                  \
                \endprogram : ' . a:name . '`ba'
  return l:str
endfun

"-------------------------------------------------------------------------------
" module
"-------------------------------------------------------------------------------
fun! sv#sv#sv#module()
  let name = matchstr(getline("."), '^\s*\zs\w\+')

  if (name =~ '^\s*$')
    let name = sv#sv#sv#get_default_name()
  endif

  call setline(".", repeat(' ', indent(".")))

  let l:str = '=comments#block_comment#getComments("Program", "' . name . '")'
  let l:str .= printf('module %0s();', name) .
               \ s:_set_indent(&shiftwidth) . 'parameter integer CLK_PERIOD = 20ns;' .
               \ s:_set_indent(0) . 'bit clk, reset;' .
               \ s:_set_indent(0) . 'default clocking cb @(posedge clk);' .
               \ s:_set_indent(0) . 'endclocking' .
               \ s:_set_indent(0) . 'initial begin' .
               \ s:_set_indent(&shiftwidth) . 'clk = 0;' .
               \ s:_set_indent(0) . 'forever #(CLK_PERIOD/2) clk = ~clk;' .
               \ s:_set_indent(-&shiftwidth) . 'end' .
               \ s:_set_indent(0) . 'initial begin' .
               \ s:_set_indent(&shiftwidth) . 'reset = 1;' .
               \ s:_set_indent(0) . '#100 reset = 0;' .
               \ s:_set_indent(-&shiftwidth) . 'end' .
               \ s:_set_indent(0) . 'initial begin' .
               \ s:_set_indent(&shiftwidth) . '@(negedge reset);' .
               \ s:_set_indent(0) . '##2; // Wait for 2 clock cycle' .
               \ s:_set_indent(0) . 'maa' .
               \ s:_set_indent(0) . '$finish;' .
               \ s:_set_indent(-&shiftwidth) . 'end' .
               \ s:_set_indent(-&shiftwidth) . printf('endmodule : %0s`aa', name)
  return l:str
endfun

"-------------------------------------------------------------------------------
" Function
"-------------------------------------------------------------------------------
" @param a:1 = keywords before 'function' keyword
" @param a:2 = return type
" @param a:3 = argument list
" @param a:4... = comments
fun! sv#sv#sv#function(name, ...)
  if exists('a:1')
    let l:pre_keyword = a:1 . ' '
  else
    let l:pre_keyword = ''
  endif

  if exists('a:2') && a:2 != ''
    let l:return_type = a:2 . " "
  else
    let l:return_type = ''
  endif

  if exists('a:3')
    let l:argument = a:3
  else
    let l:argument = ''
  endif

  let l:str = ''
  if exists('a:4') && exists('a:5')
    let l:type = a:4
    let l:name = a:5
    let l:str .= comments#block_comment#getComments(l:type, l:name)
  endif

  let l:str .= l:pre_keyword . 'function ' . l:return_type . a:name . '(' . l:argument . ');
                   \  maa
                   \endfunction : ' . a:name . 'mb`aa'
  return l:str
endfun

"-------------------------------------------------------------------------------
" Function : pre_randomize
"-------------------------------------------------------------------------------
function! sv#sv#sv#pre_randomize()
  let str = comments#block_comment#getComments('function', 'pre_randomize')
  let str .= 'function void pre_randomize();' .
    \ s:_set_indent(&shiftwidth) . 'maa' .
    \ s:_set_indent(0) . 'endfunction : pre_randomize`aa'

    return str
endfunction

"-------------------------------------------------------------------------------
" Function : post_randomize
"-------------------------------------------------------------------------------
function! sv#sv#sv#post_randomize()
  let str = comments#block_comment#getComments('function', 'post_randomize')
  let str .= 'function void post_randomize();' .
    \ s:_set_indent(&shiftwidth) . 'maa' .
    \ s:_set_indent(0) . 'endfunction : post_randomize`aa'

    return str
endfunction

"-------------------------------------------------------------------------------
" Task
"-------------------------------------------------------------------------------
" @param a:1 = keywords before 'task' keyword
" @param a:2 = argument list
" @param a:3... = comments
fun! sv#sv#sv#task(name, ...)
  if (exists('a:1'))
    let l:pre_keyword = a:1 . ' '
  else
    let l:pre_keyword = ''
  endif

  if exists('a:2')
    let l:arguments = a:2
  else
    let l:arguments = ''
  endif

  let l:task = ''
  if exists('a:3') && exists('a:4') 
    let l:type = a:3
    let l:name = a:4
    let l:task .= comments#block_comment#getComments(l:type, l:name)
  endif

  let l:task .= l:pre_keyword . 'task ' . a:name . '(' . l:arguments . ');
                   \  maa
                   \endtask : ' . a:name . 'mb`aa'
  return l:task
endfun

"-------------------------------------------------------------------------------
" Begin-End block
"-------------------------------------------------------------------------------
fun! sv#sv#sv#beginEnd()
  let l:str = 'begin ' .
              \ s:_set_indent(&shiftwidth) .  'maa' .
              \ s:_set_indent(0) . 'endmb`aa'
  return l:str
endfun

"-------------------------------------------------------------------------------
" Begin-End block
"-------------------------------------------------------------------------------
fun! sv#sv#sv#always_beginEnd()
  let l:str = printf('always @(maa%s %s) begin ', s:GetTemplete('a', '/posedge'), s:GetTemplete('a', '/clk')) .
              \ s:_set_indent(&shiftwidth) .  'mba' .
              \ s:_set_indent(0) . 'endmb`aa'
  return l:str
endfun

"-------------------------------------------------------------------------------
" Fork-Join block
"-------------------------------------------------------------------------------
fun! sv#sv#sv#forkJoin()
  let l:str = 'fork 
              \  maa
              \joinmb`aa'
  return l:str
endfun

"-------------------------------------------------------------------------------
" Fork-Join_any block
"-------------------------------------------------------------------------------
fun! sv#sv#sv#forkJoinAny()
  let l:str = 'fork begin
              \  fork 
              \  maa
              \join_any
              \disable fork;
              \end joinmb`aa'
  return l:str
endfun

"-------------------------------------------------------------------------------
" Fork-Join_none block
"-------------------------------------------------------------------------------
fun! sv#sv#sv#forkJoinNone()
  let l:str = 'fork 
              \  maa
              \join_nonemb`aa'
  return l:str
endfun

"-------------------------------------------------------------------------------
" If block (Procedural)
"-------------------------------------------------------------------------------
fun! sv#sv#sv#if()
  let l:str = 'if (mca) ' . sv#sv#sv#beginEnd() . '`ca'
  return l:str
endfun

"-------------------------------------------------------------------------------
" If block used in constraint (Declarative)
"-------------------------------------------------------------------------------
fun! sv#sv#sv#cif()
  let l:str = 'if (maa) {
              \  mba
              \}`aa'
  return l:str
endfun

"-------------------------------------------------------------------------------
" foreach block used in constraint (Declarative)
"-------------------------------------------------------------------------------
fun! sv#sv#sv#cforeach()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var != '')
    " save var name in recently used loop variables
    let g:_ = [var . "[maa]`aa"] + g:_
  endif

  if (var == '')
    let l:str = 'foreach (maa) {'
  else
    let l:str = 'foreach (' . var . '[maa]) {'
  endif

  let l:str .= '  mba
              \}`aa'

  return l:str
endfun

"-------------------------------------------------------------------------------
" Else-If block
"-------------------------------------------------------------------------------
fun! sv#sv#sv#elseif()
  let l:str = 'else if (mca) ' . sv#sv#sv#beginEnd() . '`ca'
  return l:str
endfun

"-------------------------------------------------------------------------------
" Else-If block used in constraint (Declarative)
"-------------------------------------------------------------------------------
fun! sv#sv#sv#celseif()
  let l:str = 'else if (maa) {
              \  mba
              \}`aa'
  return l:str
endfun

"-------------------------------------------------------------------------------
" Else block
"-------------------------------------------------------------------------------
fun! sv#sv#sv#else()
  let l:str = 'else ' . sv#sv#sv#beginEnd()
  return l:str
endfun

"-------------------------------------------------------------------------------
" Else block used in constraint (Declarative)
"-------------------------------------------------------------------------------
fun! sv#sv#sv#celse()
  let l:str = 'else {
              \  maa
              \}`aa'
  return l:str
endfun

"-------------------------------------------------------------------------------
" For block
"-------------------------------------------------------------------------------
fun! sv#sv#sv#for(var, increment)
  if (a:var != '')
    " save var name in recently used loop variables
    let g:_ = [a:var] + g:_
  endif

  if (a:increment == 1)
    let l:str = 'for (int ' . a:var . ' = 0; ' . a:var . ' <= mca; ' . a:var . '++) ' . sv#sv#sv#beginEnd() . '`ca'
  elseif (a:increment == 0)
    let l:str = 'for (int ' . a:var . ' = mca; ' . a:var . ' >= 0; ' . a:var . '--) ' . sv#sv#sv#beginEnd() . '`ca'
  endif

  return l:str
endfun

"-------------------------------------------------------------------------------
" Foreach block
"-------------------------------------------------------------------------------
fun! sv#sv#sv#foreach()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var != '')
    " save var name in recently used loop variables
    let g:_ = [var . "[maa]`aa"] + g:_
  endif

  if (var == '')
    let l:str = 'foreach (mca) ' . sv#sv#sv#beginEnd() . '`ca'
  else
    let l:str = 'foreach (' . var . '[mca]) ' . sv#sv#sv#beginEnd() . '`ca'
  endif

  return l:str
endfun

"-------------------------------------------------------------------------------
" repeat block
"-------------------------------------------------------------------------------
fun! sv#sv#sv#repeat()
  let l:str = 'repeat (mca) ' . sv#sv#sv#beginEnd() . '`ca'

  return l:str
endfun

"-------------------------------------------------------------------------------
" while block
"-------------------------------------------------------------------------------
fun! sv#sv#sv#while()
  let l:str = 'while (mca) ' . sv#sv#sv#beginEnd() . '`ca'

  return l:str
endfun

"-------------------------------------------------------------------------------
" do_while block
"-------------------------------------------------------------------------------
fun! sv#sv#sv#do_while()
  let l:str = 'do
              \begin
              \  maa
              \end
              \while (mba);`ba'
  return l:str
endfun

"-------------------------------------------------------------------------------
" case block
"-------------------------------------------------------------------------------
fun! sv#sv#sv#case()
  let l:str = 'case (maa)
              \  mba
                \default:
                \  mca
              \endcase`aa'
  return l:str
endfun

"-------------------------------------------------------------------------------
" `ifndef block
"-------------------------------------------------------------------------------
fun! sv#sv#sv#ifndef(name)
  " let l:str = '// Compiler directive to check for the definition of the text_macro_name.'
  let l:str = '`ifndef ' . toupper(a:name) . '`define ' . toupper(a:name) . 'maa`endif //' . toupper(a:name) . '`aa'

  return l:str
endfun

"-------------------------------------------------------------------------------
" `ifdef block
"-------------------------------------------------------------------------------
fun! sv#sv#sv#ifdef()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  " let l:str = '// Compiler directive to check for the definition of the text_macro_name.'
  let l:str = '`ifdef ' . toupper(var) . '' .
        \ s:_set_indent(&shiftwidth) . 'maa' .
        \ s:_set_indent(0) . '`else' . 
        \ s:_set_indent(&shiftwidth) . '' . 
        \ s:_set_indent(0) . '`endif`aa'

  return l:str
endfun

