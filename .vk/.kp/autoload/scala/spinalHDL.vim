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
" Function : component
"-------------------------------------------------------------------------------
function! scala#spinalHDL#component()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  let str = comments#block_comment#getComments('Class', name)
  let str .= printf('class %0s(maa) extends Component {', name) .
           \ s:_set_indent(&shiftwidth) . 'val io = new Bundle {' .
           \ s:_set_indent(&shiftwidth) . printf('val %s = in Bool', s:GetTemplete('a', 'input')) .
           \ s:_set_indent(0) . printf('val %s = out UInt(8 bits)', s:GetTemplete('a', 'output')) .
           \ s:_set_indent(-&shiftwidth) . '}' .
           \ s:_set_indent(-&shiftwidth) . '}`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : function
"-------------------------------------------------------------------------------
function! scala#spinalHDL#function()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  let str = comments#block_comment#getComments('Method', var)
  let str .= printf('def %0s (maa) = new Area {', var) .
           \ s:_set_indent(&shiftwidth) . '' .
            \ s:_set_indent(0) . '}`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : m_bundle
"-------------------------------------------------------------------------------
function! scala#spinalHDL#m_bundle()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  let str = 'val io = new Bundle {' .
           \ s:_set_indent(&shiftwidth) . 'maa' .
            \ s:_set_indent(0) . '}`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : bundle
"-------------------------------------------------------------------------------
function! scala#spinalHDL#bundle()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  let str = comments#block_comment#getComments('Bundle', name)
  let str .= printf('case class %0s(maa) extends Bundle {', name) .
           \ s:_set_indent(&shiftwidth) . printf('// %s: Update code', s:GetTemplete('a', 'TODO')) .
           \ s:_set_indent(0) . 'val myvar = UInt(8 bits)' .
           \ s:_set_indent(-&shiftwidth) . '}`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : m_area
"-------------------------------------------------------------------------------
function! scala#spinalHDL#m_area()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  let str = 'val maa = new Area {' .
           \ s:_set_indent(&shiftwidth) . '' .
            \ s:_set_indent(0) . '}`aa'

  return str
endfunction


"-------------------------------------------------------------------------------
" Function : clock_domain
"-------------------------------------------------------------------------------
function! scala#spinalHDL#clock_domain()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  let str = 'val myClockDomain = ClockDomain(' .
          \ s:_set_indent(&shiftwidth) . 'clock  = io.clk,' .
          \ s:_set_indent(0) . 'reset  = io.resetn,' .
          \ s:_set_indent(0) . 'config = ClockDomainConfig(' .
          \ s:_set_indent(&shiftwidth) . 'clockEdge        = RISING,' .
          \ s:_set_indent(0) . 'resetKind        = ASYNC,' .
          \ s:_set_indent(0) . 'resetActiveLevel = LOW' .
          \ s:_set_indent(-&shiftwidth) . ')' .
          \ s:_set_indent(-&shiftwidth) . ')'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : clocking_area
"-------------------------------------------------------------------------------
function! scala#spinalHDL#clocking_area()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  let str = '// Define an Area which use myClockDomain' .
          \ s:_set_indent(0) . 'val myArea = new ClockingArea(myClockDomain) {' .
          \ s:_set_indent(&shiftwidth) . 'val myReg = Reg(UInt(4 bits)) init(7)' .
          \ s:_set_indent(0) . 'myReg := myReg + 1' .
          \ s:_set_indent(0) . 'io.result := myReg' .
          \ s:_set_indent(-&shiftwidth) . '}'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : slow_area
"-------------------------------------------------------------------------------
function! scala#spinalHDL#slow_area()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  let str = '// Slow the current clockDomain by 4' .
          \ s:_set_indent(0) . printf('val %0s = new SlowArea(4){', var) .
          \ s:_set_indent(&shiftwidth) . 'val counter = out(CounterFreeRun(16).value)' .
          \ s:_set_indent(-&shiftwidth) . '}'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : reset_area
"-------------------------------------------------------------------------------
function! scala#spinalHDL#reset_area()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  let str = '// The reset of this area is done with the specialReset signal' .
          \ s:_set_indent(0) . printf('val %s = new ResetArea(%s, false){', var, s:GetTemplete('a', 'specialReset')) .
          \ s:_set_indent(&shiftwidth) . 'val counter = out(CounterFreeRun(16).value)' .
          \ s:_set_indent(-&shiftwidth) . '}'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : clock_enable_area
"-------------------------------------------------------------------------------
function! scala#spinalHDL#clock_enable_area()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (var =~ '^\s*$')
    let var = s:GetTemplete('1', 'name')
  endif

  let str = '// Add a clock enable for this area' .
          \ s:_set_indent(0) . printf('val %0s = new ClockEnableArea(%s){', var, s:GetTemplete('a', 'clockEnable')) .
          \ s:_set_indent(&shiftwidth) . 'val counter = out(CounterFreeRun(16).value)' .
          \ s:_set_indent(-&shiftwidth) . '}'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : black_box
"-------------------------------------------------------------------------------
function! scala#spinalHDL#black_box()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  let str = '// Define a Ram as a BlackBox' .
      \ s:_set_indent(0) . 'class Ram_1w_1r(wordWidth: Int, wordCount: Int) extends BlackBox {' .
      \ s:_set_indent(&shiftwidth) . '// SpinalHDL will look at Generic classes to get attributes which' .
      \ s:_set_indent(0) . '// should be used ad VHDL gererics / Verilog parameter' .
      \ s:_set_indent(0) . '// You can use String Int Double Boolean and all SpinalHDL base types' .
      \ s:_set_indent(0) . '// as generic value' .
      \ s:_set_indent(0) . 'val generic = new Generic {' .
      \ s:_set_indent(&shiftwidth) . 'val wordCount = Ram_1w_1r.this.wordCount' .
      \ s:_set_indent(0) . 'val wordWidth = Ram_1w_1r.this.wordWidth' .
      \ s:_set_indent(-&shiftwidth) . '}' .
      \ s:_set_indent(0) . '// Define io of the VHDL entiry / Verilog module' .
      \ s:_set_indent(0) . 'val io = new Bundle {' .
      \ s:_set_indent(&shiftwidth) . 'val clk = in Bool' .
      \ s:_set_indent(0) . 'val wr = new Bundle {' .
      \ s:_set_indent(&shiftwidth) . 'val en   = in Bool' .
      \ s:_set_indent(0) . 'val addr = in UInt (log2Up(wordCount) bit)' .
      \ s:_set_indent(0) . 'val data = in Bits (wordWidth bit)' .
      \ s:_set_indent(-&shiftwidth) . '}' .
      \ s:_set_indent(0) . 'val rd = new Bundle {' .
      \ s:_set_indent(&shiftwidth) . 'val en   = in Bool' .
      \ s:_set_indent(0) . 'val addr = in UInt (log2Up(wordCount) bit)' .
      \ s:_set_indent(0) . 'val data = out Bits (wordWidth bit)' .
      \ s:_set_indent(-&shiftwidth) . '}' .
      \ s:_set_indent(-&shiftwidth) . '}' .
      \ s:_set_indent(0) . '//Map the current clock domain to the io.clk pin' .
      \ s:_set_indent(0) . 'mapClockDomain(clock=io.clk)' .
      \ s:_set_indent(-&shiftwidth) . '}'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : IMasterSlave
"-------------------------------------------------------------------------------
function! scala#spinalHDL#IMasterSlave()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  let str = comments#block_comment#getComments('IMasterSlave', name)
  let str .= printf('case class %0s(payloadWidth: Int) extends Bundle with IMasterSlave {maa', name) .
          \  s:_set_indent( &shiftwidth)  . 'val valid   = Bool' .
          \  s:_set_indent( 0          )  . 'val ready   = Bool' .
          \  s:_set_indent( 0          )  . 'val payload = Bits(payloadWidth bits)' .
          \  s:_set_indent( 0          )  . '// define the direction of the data in a master mode ' .
          \  s:_set_indent( 0          )  . 'override def asMaster(): Unit = {' .
          \  s:_set_indent( &shiftwidth)  . 'out(valid, payload)' .
          \  s:_set_indent( 0          )  . 'in(ready)' .
          \  s:_set_indent(-&shiftwidth)  . '}' .
          \  s:_set_indent( 0          )  . '// Connect that to this' .
          \  s:_set_indent( 0          )  . 'def <<(that: MyBus): Unit = {' .
          \  s:_set_indent( &shiftwidth)  . 'this.valid   := that.valid' .
          \  s:_set_indent( 0          )  . 'that.ready   := this.ready' .
          \  s:_set_indent( 0          )  . 'this.payload := that.payload' .
          \  s:_set_indent(-&shiftwidth)  . '}' .
          \  s:_set_indent( 0          )  . '// Connect this to the FIFO input, return the fifo output' .
          \  s:_set_indent( 0          )  . 'def queue(size: Int): MyBus = {' .
          \  s:_set_indent( &shiftwidth)  . 'val fifo = new MyBusFifo(payloadWidth, size)' .
          \  s:_set_indent( 0          )  . 'fifo.io.push << this' .
          \  s:_set_indent( 0          )  . 'return fifo.io.pop' .
          \  s:_set_indent(-&shiftwidth)  . '}' .
          \  s:_set_indent(-&shiftwidth)  . '}`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : when
"-------------------------------------------------------------------------------
function! scala#spinalHDL#when()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  let str = 'when (maa) {' .
           \ s:_set_indent(&shiftwidth) . '' .
            \ s:_set_indent(0) . '}`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : elsewhen
"-------------------------------------------------------------------------------
function! scala#spinalHDL#elsewhen()
  " let var = matchstr(getline("."), '^\s*\zs\w\+')
  " call setline(".", repeat(' ', indent(".")))

  let str = 'elsewhen (maa) {' .
           \ s:_set_indent(&shiftwidth) . '' .
            \ s:_set_indent(0) . '}`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : otherwise
"-------------------------------------------------------------------------------
function! scala#spinalHDL#otherwise()
  " let var = matchstr(getline("."), '^\s*\zs\w\+')
  " call setline(".", repeat(' ', indent(".")))

  let str = 'otherwise {' .
           \ s:_set_indent(&shiftwidth) . 'maa' .
            \ s:_set_indent(0) . '}`aa'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : 
"-------------------------------------------------------------------------------
function! scala#spinalHDL#switch()
  let str = printf('switch (maa%s) {', s:GetTemplete('a', 'var')) .
           \ s:_set_indent(&shiftwidth) . printf('is(%s) { ', s:GetTemplete('a', '1')) .
            \ s:_set_indent(&shiftwidth) . '' .
            \ s:_set_indent(0) . '}' .
            \ s:_set_indent(-&shiftwidth) . '}`aa'

  return str
endfunction



"-------------------------------------------------------------------------------
" Function : 
"-------------------------------------------------------------------------------
function! scala#spinalHDL#state_machine()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  let str = 'val fsm = new StateMachine{' .
          \ s:_set_indent( &shiftwidth) . 'val counter = Reg(UInt(8 bits)) init (0)' .
          \ s:_set_indent( 00000000000) . 'io.result := False' .
          \ s:_set_indent( 00000000000) . 'val stateA : State = new State with EntryPoint{' .
          \ s:_set_indent( &shiftwidth) . 'whenIsActive (goto(stateB))' .
          \ s:_set_indent(-&shiftwidth) . '}' .
          \ s:_set_indent( 00000000000) . 'val stateB : State = new State{' .
          \ s:_set_indent( &shiftwidth) . 'onEntry(counter := 0)' .
          \ s:_set_indent( 00000000000) . 'whenIsActive {' .
          \ s:_set_indent( &shiftwidth) . 'counter := counter + 1' .
          \ s:_set_indent( 00000000000) . 'when(counter === 4){' .
          \ s:_set_indent( &shiftwidth) . 'goto(stateC)' .
          \ s:_set_indent(-&shiftwidth) . '}' .
          \ s:_set_indent(-&shiftwidth) . '}' .
          \ s:_set_indent( 00000000000) . 'onExit(io.result := True)' .
          \ s:_set_indent(-&shiftwidth) . '}' .
          \ s:_set_indent( 00000000000) . 'val stateC : State = new State{' .
          \ s:_set_indent( &shiftwidth) . 'whenIsActive (goto(stateA))' .
          \ s:_set_indent(-&shiftwidth) . '}' .
          \ s:_set_indent(-&shiftwidth) . '}'

  return str
endfunction

"-------------------------------------------------------------------------------
" Function : 
"-------------------------------------------------------------------------------
function! scala#spinalHDL#state_delay()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  let str = 'val stateG : State = new StateDelay(cyclesCount=40){' .
          \ s:_set_indent( &shiftwidth) . 'whenCompleted{' .
          \ s:_set_indent( &shiftwidth) . 'goto(stateH)' .
          \ s:_set_indent(-&shiftwidth) . '}' .
          \ s:_set_indent(-&shiftwidth) . '}'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : 
"-------------------------------------------------------------------------------
function! scala#spinalHDL#state_fsm()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  let str = 'val stateG : State = new StateFsm(fsm=internalFsm()){' .
          \ s:_set_indent( &shiftwidth) . 'whenCompleted{' .
          \ s:_set_indent( &shiftwidth) . 'goto(stateH)' .
          \ s:_set_indent(-&shiftwidth) . '}' .
          \ s:_set_indent(-&shiftwidth) . '}'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : 
"-------------------------------------------------------------------------------
function! scala#spinalHDL#state_parallel_fsm()
  let var = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  let str = 'val stateG : State = new StateParallelFSM(internalFsmA(), internalFsmB()){' .
          \ s:_set_indent( &shiftwidth) . 'whenCompleted{' .
          \ s:_set_indent( &shiftwidth) . 'goto(stateH)' .
          \ s:_set_indent(-&shiftwidth) . '}' .
          \ s:_set_indent(-&shiftwidth) . '}'
  return str
endfunction

"-------------------------------------------------------------------------------
" Function : 
"-------------------------------------------------------------------------------
function! scala#spinalHDL#spinal_enum()
  let name = matchstr(getline("."), '^\s*\zs\w\+')
  call setline(".", repeat(' ', indent(".")))

  if (name =~ '^\s*$')
    let name = sv#uvm#mapping#get_default_name()
  endif

  let str = comments#block_comment#getComments('SpinalEnum', name)
  let str .= printf('case class %0s(maa) extends SpinalEnum(binarySequential) {', name) .
           \ s:_set_indent(&shiftwidth) . printf('// %s: Update code', s:GetTemplete('a', 'TODO')) .
           \ s:_set_indent(0) . 'val s1, s2, s3, s4 = newElement()' .
           \ s:_set_indent(-&shiftwidth) . '}`aa'

  return str
endfunction





