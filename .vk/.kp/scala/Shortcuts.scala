
//-------------------------------------------------------------------------------
// <M-f> Shortcuts
//-------------------------------------------------------------------------------

// p%[rintln]<M-f>
println ("");

// p%[rint]f<M-f>
printf ("");


//-------------------------------------------------------------------------------
// <M-k> Shortcuts
//-------------------------------------------------------------------------------

// b%[reak]<M-k>
break

// c%[ontinue]<M-k>
continue

// ^r%[eturn]<M-k>
return


//-------------------------------------------------------------------------------
// OOPS: <M-o> Shortcuts
// Object Oriented Programmings
//-------------------------------------------------------------------------------

// c%[lass]<M-o>
class <CLASS_NAME>() {
  
}

// d%[ef]<M-o>
def <FUNCTION_NAME> () {
  
}


//-------------------------------------------------------------------------------
// <M-j> Shortcuts
//-------------------------------------------------------------------------------

// o%[bject]<M-j>
object <OBJ_NAME> {
  def main(args: Array[String]) {
    
  }
}

// p%[ackage]<M-j>
package <PKG_NAME> {
  
}

// f%[unction]<M-j>
def <FUNC_NAME> () {
  
}

// f%[unction]r%[eturns]<M-j>
def <FUNC_NAME> () : <RETURN_TYPE> = {
  
}

// i%[f]<M-j>
if () {
  
}

// e%[lse]<M-j>
else {
  
}

// e%[lse]%[i]f<M-j>
else if () {
  
}

// w%[hile]<M-j>
while () {
  
}

// d%[o]w%[hile]<M-j>
do {
  
} while () 

// f%[or]<M-j>
for (<VAR_NAME> <- <ARRAY_NAME>) {
  
}

//-------------------------------------------------------------------------------
// <M-4>
//-------------------------------------------------------------------------------

// i%[nt]<M-4>
var <VAR_NAME>: Int

// b%[oolean]<M-4>
var <VAR_NAME>: Boolean

// u%[nit]<M-4>
var <VAR_NAME>: Unit

// c%[har]<M-4>
var <VAR_NAME>: Char

// d%[ouble]<M-4>
var <VAR_NAME>: Double

// f%[loat]<M-4>
var <VAR_NAME>: Float

// l%[ong]<M-4>
var <VAR_NAME>: Long

// s%[tring]<M-4>
var <VAR_NAME>: String

// s%[hort]<M-4>
var <VAR_NAME>: Short

// b%[yte]<M-4>
var <VAR_NAME>: Byte

// n%[ull]<M-4>
var <VAR_NAME>: Null

// n%[othing]<M-4>
var <VAR_NAME>: Nothing

// a%[ny]<M-4>
var <VAR_NAME>: Any

// a%[ny]r%[ef]<M-4>
var <VAR_NAME>: AnyRef

//-------------------------------------------------------------------------------
// <M-2> Shortcuts
//-------------------------------------------------------------------------------

// i%[int]<M-2>
var <VAR_NAME> = Array[Int]()

// b%[oolean]<M-2>
var <VAR_NAME> = Array[Boolean]()

// u%[nit]<M-2>
var <VAR_NAME> = Array[Unit]()

// c%[har]<M-2>
var <VAR_NAME> = Array[Char]()

// d%[ouble]<M-2>
var <VAR_NAME> = Array[Double]()

// f%[loat]<M-2>
var <VAR_NAME> = Array[Float]()

// l%[ong]<M-2>
var <VAR_NAME> = Array[Long]()

// s%[tring]<M-2>
var <VAR_NAME> = Array[String]()

// s%[hort]<M-2>
var <VAR_NAME> = Array[Short]()

// b%[yte]<M-2>
var <VAR_NAME> = Array[Byte]()

// n%[ull]<M-2>
var <VAR_NAME> = Array[Null]()

// n%[othing]<M-2>
var <VAR_NAME> = Array[Nothing]()

// a%[ny]<M-2>
var <VAR_NAME> = Array[Any]()

// a%[ny]r%[ef]<M-2>
var <VAR_NAME> = Array[AnyRef]()


//###############################################################################
// SpinalHDL
//###############################################################################

//-------------------------------------------------------------------------------
// <M-l> Shortcuts
//-------------------------------------------------------------------------------

// %[spinal]h%[dl]<M-l>
import spinal.core._
import spinal.lib._

// %[spinal]s%[im]<M-l>
import spinal.sim._
import spinal.core._
import spinal.core.sim._

//-------------------------------------------------------------------------------
// <M-.> Shortcuts
//-------------------------------------------------------------------------------

// t%[his]<M-.>
this.

// i%[o]<M-.>
io.


//-------------------------------------------------------------------------------
// <M-v> Shortcuts
//-------------------------------------------------------------------------------

// i%[n]u%[int]<M-v>
val <VAR_NAME> = in UInt(8 bits)

// i%[n]b%[oolean]<M-v>
val <VAR_NAME> = in Bool

// o%[ut]u%[int]<M-v>
val <VAR_NAME> = out UInt(8 bits)

// o%[ut]b%[oolean]<M-v>
val <VAR_NAME> = out Bool

// r%[eg]b%[its]<M-v>
val <VAR_NAME> : Reg(Bits(8 bits))

// r%[eg]b%[ool]<M-v>
val <VAR_NAME> : Reg(Bits(8 bits))

// r%[eg]u%[int]<M-v>
val <VAR_NAME> : Reg(UInt(8 bits))

// v%[ec]b%[its]<M-v>
val <VAR_NAME> : Vec(Bits(8 bits))

// v%[ec]b%[ool]<M-v>
val <VAR_NAME> : Vec(Bool)

// v%[ec]u%[int]<M-v>
val <VAR_NAME> : Vec(UInt(8 bits))

//-------------------------------------------------------------------------------
// <M-J> shortcuts
//-------------------------------------------------------------------------------

// w%[hen]<M-J>
when () {
  
}

// e%[lse]w%[hen]<M-J>
elsewhen () {
  
}

// o%[ther]%[wise]<M-j>
otherwise {
  
}

// s%[witch]<M-J>
switch (<VAR_NAME>) {
  is(<VALUE>) { 
    
  }
}


//-------------------------------------------------------------------------------
// SpinalHDL Completions <C-Tab>
//-------------------------------------------------------------------------------
// %[spinal]%[hdl]c%[omponent]<C-Tab>
class <CLASS_NAME>() extends Component {

  val io = new Bundle {
    val <VAR_NAME1> = in Bool
    val <VAR_NAME2> = out UInt(8 bits)
  }

}

// %[spinal]%[hdl]d%[ef]<C-Tab>
def <FUN_NAME> () = new Area {
  
}

// %[spinal]%[hdl]n%[ew]b%[undle]<C-Tab>
val io = new Bundle {
  
}

// %[spinal]%[hdl]b%[undle]<C-Tab>
case class <FUN_NAME>() extends Bundle {
  val myvar = UInt(8 bits)
}

// %[spinal]%[hdl]n%[ew]a%[rea]<C-Tab>
val <VAR_NAME> = new Area {
  
}

// %[spinal]%[hdl]c%[lock]d%[omain]<C-Tab>
val myClockDomain = ClockDomain(
  clock  = io.clk,
  reset  = io.resetn,
  config = ClockDomainConfig(
    clockEdge        = RISING,
    resetKind        = ASYNC,
    resetActiveLevel = LOW
  )
)

// %[spinal]%[hdl]c%[locking]a%[rea]<C-Tab>
// Define an Area which use myClockDomain
val myArea = new ClockingArea(myClockDomain) {
  val myReg = Reg(UInt(4 bits)) init(7)

  myReg := myReg + 1

  io.result := myReg
}

// %[spinal]%[hdl]s%[low]a%[rea]<C-Tab>
// Slow the current clockDomain by 4
val <VAR_NAME> = new SlowArea(4){
  val counter = out(CounterFreeRun(16).value)
}

// %[spinal]%[hdl]r%[eset]a%[rea]<C-Tab>
// The reset of this area is done with the specialReset signal
val <VAR_NAME> = new ResetArea(<SPECIALRESET>, false){
  val counter = out(CounterFreeRun(16).value)
}

// %[spinal]%[hdl]c%[lock]e%[nable]a%[rea]<C-Tab>
// Add a clock enable for this area
val <VAR_NAME> = new ClockEnableArea(<CLOCKENABLE>){
  val counter = out(CounterFreeRun(16).value)
}

// %[spinal]%[hdl]b%[lack]b%[ox]<C-Tab>
// Define a Ram as a BlackBox
class Ram_1w_1r(wordWidth: Int, wordCount: Int) extends BlackBox {

  // SpinalHDL will look at Generic classes to get attributes which
  // should be used ad VHDL gererics / Verilog parameter
  // You can use String Int Double Boolean and all SpinalHDL base types
  // as generic value
  val generic = new Generic {
    val wordCount = Ram_1w_1r.this.wordCount
    val wordWidth = Ram_1w_1r.this.wordWidth
  }

  // Define io of the VHDL entiry / Verilog module
  val io = new Bundle {
    val clk = in Bool
    val wr = new Bundle {
      val en   = in Bool
      val addr = in UInt (log2Up(wordCount) bit)
      val data = in Bits (wordWidth bit)
    }
    val rd = new Bundle {
      val en   = in Bool
      val addr = in UInt (log2Up(wordCount) bit)
      val data = out Bits (wordWidth bit)
    }
  }

  //Map the current clock domain to the io.clk pin
  mapClockDomain(clock=io.clk)
}

// %[spinal]%[hdl]i%[master]%[slave]<C-Tab>
case class Shortcuts(payloadWidth: Int) extends Bundle with IMasterSlave {

  val valid   = Bool
  val ready   = Bool
  val payload = Bits(payloadWidth bits)

  // define the direction of the data in a master mode 
  override def asMaster(): Unit = {
    out(valid, payload)
    in(ready)
  }

  // Connect that to this
  def <<(that: MyBus): Unit = {
    this.valid   := that.valid
    that.ready   := this.ready
    this.payload := that.payload
  }

  // Connect this to the FIFO input, return the fifo output
  def queue(size: Int): MyBus = {
    val fifo = new MyBusFifo(payloadWidth, size)
    fifo.io.push << this
    return fifo.io.pop
  }
}

// %[spinal]%[hdl]s%[tate]m%[achine]<C-Tab>
val fsm = new StateMachine{
  val counter = Reg(UInt(8 bits)) init (0)
  io.result := False

  val stateA : State = new State with EntryPoint{
    whenIsActive (goto(stateB))
  }
  val stateB : State = new State{
    onEntry(counter := 0)
    whenIsActive {
      counter := counter + 1
      when(counter === 4){
        goto(stateC)
      }
    }
    onExit(io.result := True)
  }
  val stateC : State = new State{
    whenIsActive (goto(stateA))
  }
}

// %[spinal]%[hdl]s%[tate]d%[elay]<C-Tab>
val stateG : State = new StateDelay(cyclesCount=40){
  whenCompleted{
    goto(stateH)
  }
}

// %[spinal]%[hdl]s%[tate]p%[arallel]f%[sm]<C-Tab>
val stateG : State = new StateParallelFSM(internalFsmA(), internalFsmB()){
  whenCompleted{
    goto(stateH)
  }
}

// %[spinal]%[hdl]s%[tate]f%[sm]<C-Tab>
val stateG : State = new StateFsm(fsm=internalFsm()){
  whenCompleted{
    goto(stateH)
  }
}


// %[spinal]%[hdl]%[spinal]e%[num]<C-Tab>
case class Shortcuts() extends SpinalEnum(binarySequential) {
  val s1, s2, s3, s4 = newElement()
}

//-------------------------------------------------------------------------------
// SpinalSIM Shortcuts <S-Space>
//-------------------------------------------------------------------------------

// %[spinal]%[sim]d%[o]s%[im]<S-Space>
val spinalConfig = SpinalConfig(defaultClockDomainFrequency = FixedFrequency(10 MHz))

SimConfig
  .withConfig(spinalConfig)
  .withWave
  .allOptimisation
  .workspacePath("~/tmp")
  .compile(new TopLevel)
  .doSim{ dut =>
  //Simulation code here
}

// %[spinal]%[sim]d%[o]s%[im]%[tests]<C-Space>
val compiled = SimConfig.withWave.compile(new Dut)
compiled.doSim("testA"){ dut =>
  //Simulation code here
}


// %[spinal]%[sim]d%[o]s%[im]%[until]%[void]<C-Space>
val spinalConfig = SpinalConfig(defaultClockDomainFrequency = FixedFrequency(10 MHz))

val compiled = SimConfig
  .withConfig(spinalConfig)
  .withWave
  .allOptimisation
  .workspacePath("~/tmp")
  .compile(
    rtl = new <DUT>
  )

compiled.doSimUntilVoid{ dut =>
  //Simulation code here
}

// %[spinal]%[sim]f%[ork]s%[timulus]<C-Space>
dut.clockDomain.forkStimulus(period = 10)

// %[spinal]%[sim]a%[ssert]r%[eset]<C-Space>
dut.clockDomain.assertReset()

// %[spinal]%[sim]f%[alling]e%[dge]<C-Space>
dut.clockDomain.fallingEdge()

// %[spinal]%[sim]c%[lock]t%[oggle]<C-Space>
dut.clockDomain.clockToggle()

// %[spinal]%[sim]d%[is]%[assert]r%[eset]<C-Space>
dut.clockDomain.disassertReset()


// %[spinal]%[sim]a%[ssert]c%[lock]e%[nable]<C-Space>
dut.clockDomain.assertClockEnable()

// %[spinal]%[sim]d%[is]%[assert]c%[lock]e%[nable]<C-Space>
dut.clockDomain.disassertClockEnable()

// %[spinal]%[sim]a%[ssert]s%[oft]r%[eset]<C-Space>
dut.clockDomain.assertSoftReset()


// %[spinal]%[sim]d%[is]%[assert]s%[oft]r%[eset]<C-Space>
dut.clockDomain.disassertSoftReset()

// %[spinal]%[sim]w%[ait]s%[ampling]<C-Space>
dut.clockDomain.waitSampling(cyclesCount = 1)

// %[spinal]%[sim]w%[ait]r%[ising]%[edge]<C-Space>
dut.clockDomain.waitRisingEdge(cyclesCount = 1)

// %[spinal]%[sim]w%[ait]f%[alling]%[edge]<C-Space>
dut.clockDomain.waitFallingEdge(cyclesCount = 1)

// %[spinal]%[sim]w%[ait]a%[ctive]%[edge]<C-Space>
dut.clockDomain.waitActiveEdge(cyclesCount = 1)

// %[spinal]%[sim]w%[ait]r%[ising]%[edge]w%[here]<C-Space>
dut.clockDomain.waitRisingEdgeWhere()

// %[spinal]%[sim]w%[ait]f%[alling]%[edge]w%[here]<C-Space>
dut.clockDomain.waitFallingEdgeWhere()

// %[spinal]%[sim]w%[ait]a%[ctive]%[edge]w%[here]<C-Space>
dut.clockDomain.waitActiveEdgeWhere()

// %[spinal]%[sim]w%[ait]u%[ntil]<C-Space>
waitUntil()

// %[spinal]%[sim]s%[leep]<C-Space>
sleep()

// %[spinal]%[sim]d%[ef]<C-Space>
def <FUN_NAME> () : Unit@suspendable {
  dut.io.a #= value
  sleep(10)
  dut.io.a #= value + 1
}

// %[spinal]%[sim]f%[ork]<C-Space>
val <VAR_NAME> = fork{
  
}

// %[spinal]%[sim]f%[or]e%[ach]<C-Space>
<List>.suspendable.foreach{<NAME> =>
  sleep(<NAME>)
}






//-------------------------------------------------------------------------------
// Other shortcuts
//-------------------------------------------------------------------------------

// <M-;>
<SPACE>:=<SPACE>



