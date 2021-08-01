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
" Function : 
"-------------------------------------------------------------------------------
function! scala#spinalSIM#do_sim()

  "## let name = matchstr(getline("."), '^\s*\zs\w\+')
  "## call setline(".", repeat(' ', indent(".")))

  "## if (name =~ '^\s*$')
  "##   let name = sv#uvm#mapping#get_default_name()
  "## endif

   let str = 'val spinalConfig = SpinalConfig(defaultClockDomainFrequency = FixedFrequency(10 MHz))' .
           \ s:_set_indent( 00000000000) . 'SimConfig' .
           \ s:_set_indent( &shiftwidth) . '.withConfig(spinalConfig)' .
           \ s:_set_indent( 00000000000) . '.withWave' .
           \ s:_set_indent( 00000000000) . '.allOptimisation' .
           \ s:_set_indent( 00000000000) . '.workspacePath("~/tmp")' .
           \ s:_set_indent( 00000000000) . '.compile(new TopLevel)' .
           \ s:_set_indent( 00000000000) . '.doSim{ dut =>' .
           \ s:_set_indent( 00000000000) . 'maa//Simulation code here' .
           \ s:_set_indent(-&shiftwidth) . '}`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : 
"-------------------------------------------------------------------------------
function! scala#spinalSIM#do_sim_until_void()

   let str = 'val spinalConfig = SpinalConfig(defaultClockDomainFrequency = FixedFrequency(10 MHz))' .
           \ s:_set_indent( 00000000000) . 'val compiled = SimConfig' .
           \ s:_set_indent( &shiftwidth) . '.withConfig(spinalConfig)' .
           \ s:_set_indent( 00000000000) . '.withWave' .
           \ s:_set_indent( 00000000000) . '.allOptimisation' .
           \ s:_set_indent( 00000000000) . '.workspacePath("~/tmp")' .
           \ s:_set_indent( 00000000000) . '.compile(' .
           \ s:_set_indent( &shiftwidth) . printf('rtl = new %s', s:GetTemplete('a', 'DUT')) .
           \ s:_set_indent(-&shiftwidth) . ')' .
           \ s:_set_indent(-&shiftwidth) . 'compiled.doSimUntilVoid{ dut =>' .
           \ s:_set_indent( &shiftwidth) . 'maa//Simulation code here' .
           \ s:_set_indent(-&shiftwidth) . '}`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : 
"-------------------------------------------------------------------------------
function! scala#spinalSIM#do_sim_multiple_tests()

 let str = 'val compiled = SimConfig.withWave.compile(new Dut)' .
         \ s:_set_indent( 00000000000) . 'compiled.doSim("testA"){ dut =>' .
         \ s:_set_indent( &shiftwidth) . '//Simulation code here' .
         \ s:_set_indent(-&shiftwidth) . '}' .
         \ s:_set_indent( 00000000000) . 'compiled.doSim("testB"){ dut =>' .
         \ s:_set_indent( &shiftwidth) . '//Simulation code here' .
         \ s:_set_indent(-&shiftwidth) . '}'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : 
"-------------------------------------------------------------------------------
function! scala#spinalSIM#fork()

  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (name =~ '^\s*$')
    let name = s:GetTemplete('a', 'threadName')
  endif

  let str = printf('val maa%s = fork{', name) . 
          \ s:_set_indent( &shiftwidth) . 'mba' . 
          \ s:_set_indent(0) . '}`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : 
"-------------------------------------------------------------------------------
function! scala#spinalSIM#function()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  let str = comments#block_comment#getComments('Def', var)
  let str .= printf('def %0s (maa) : Unit@suspendable {', var) .
           \ s:_set_indent(&shiftwidth) . 'dut.io.a #= value' .
           \ s:_set_indent(0) . 'sleep(10)' .
           \ s:_set_indent(0) . 'dut.io.a #= value + 1' .
            \ s:_set_indent(-&shiftwidth) . '}`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : 
"-------------------------------------------------------------------------------
function! scala#spinalSIM#foreach()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('a', 'name')
  endif

  let str = printf('%s.suspendable.foreach{%s =>', s:GetTemplete('a', 'List'), var) .
           \ s:_set_indent(&shiftwidth) . printf('maasleep(%s)', var) .
            \ s:_set_indent(-&shiftwidth) . '}`aa'

  return str
endfunction




