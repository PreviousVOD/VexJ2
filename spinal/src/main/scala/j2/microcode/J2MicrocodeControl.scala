package j2.microcode

import j2.core._
import spinal.core._
import spinal.lib._

final class J2MicrocodeTable extends Component {
  val io = new Bundle {
    val line = in UInt (72 bits)
    val opcode = in UInt (16 bits)
    val tBcc = in Bool ()
    val nextIdStall = in Bool ()
    val control = out(new J2MicrocodeControl)
  }

  private def select[T <: Data](selector: UInt, default: T, choices: (Int, T)*): T = {
    val result = cloneOf(default)
    result := default
    switch(selector) {
      choices.foreach { case (value, output) =>
        is(value) {
          result := output
        }
      }
    }
    result
  }

  private def select[T <: SpinalEnum](
      selector: UInt,
      default: SpinalEnumElement[T],
      choices: (Int, SpinalEnumElement[T])*
  ): SpinalEnumCraft[T] = {
    val outputs = choices.map { case (value, output) => value -> output() }
    select(selector, default(), outputs: _*)
  }

  private val line = io.line
  private val opcode = io.opcode
  private val control = io.control

  control.exStall.pcWriteZ := select(
    line(2 downto 0),
    False,
    2 -> True,
    4 -> True,
    5 -> !io.tBcc,
    6 -> io.tBcc
  )
  control.exStall.srWriteZ := line(2 downto 0) === 3
  control.wbStall.srWriteW := line(2 downto 0) === 1
  control.exStall.prWritePc := line(2 downto 0) === 4

  control.wbStall.machWrite := line(6 downto 3) === 4
  control.exStall.machWrite := (line(6 downto 3) === 2) || (line(6 downto 3) === 1)
  control.exStall.multiplyCommand := select(
    line(6 downto 3),
    J2MultiplyCommand.NOP,
    10 -> J2MultiplyCommand.MULUW,
    9 -> J2MultiplyCommand.MULSW,
    8 -> J2MultiplyCommand.MULL,
    7 -> J2MultiplyCommand.DMULUL,
    6 -> J2MultiplyCommand.DMULSL
  )
  control.wbStall.multiplyCommand := select(
    line(6 downto 3),
    J2MultiplyCommand.NOP,
    12 -> J2MultiplyCommand.MACW,
    11 -> J2MultiplyCommand.MACL
  )
  control.wbStall.macSelect2 := select(
    line(6 downto 3),
    J2MacSelect2.YBUS,
    12 -> J2MacSelect2.WBUS,
    11 -> J2MacSelect2.WBUS,
    5 -> J2MacSelect2.WBUS
  )
  control.exStall.macSelect2 := select(
    line(6 downto 3),
    J2MacSelect2.YBUS,
    3 -> J2MacSelect2.ZBUS,
    1 -> J2MacSelect2.ZBUS
  )

  control.exStall.multiplyStart := line(9 downto 7) === 6
  control.wbStall.multiplyStart := line(9 downto 7) === 7
  control.wbStall.macSelect1 := select(
    line(9 downto 7),
    J2MacSelect1.XBUS,
    4 -> J2MacSelect1.WBUS,
    7 -> J2MacSelect1.WBUS
  )
  control.exStall.maclWrite := (line(9 downto 7) === 1) || (line(9 downto 7) === 3)
  control.exStall.macSelect1 := select(
    line(9 downto 7),
    J2MacSelect1.XBUS,
    1 -> J2MacSelect1.ZBUS,
    2 -> J2MacSelect1.ZBUS
  )
  control.wbStall.maclWrite := line(9 downto 7) === 5

  control.ex.memorySize := select(
    line(12 downto 10),
    J2MemSize.BYTE,
    1 -> J2MemSize.LONG,
    4 -> J2MemSize.LONG,
    5 -> J2MemSize.LONG,
    6 -> J2MemSize.WORD,
    7 -> J2MemSize.WORD
  )
  control.exStall.memoryIssue := select(
    line(12 downto 10),
    False,
    1 -> True,
    2 -> True,
    3 -> True,
    4 -> True,
    6 -> True,
    7 -> True,
    5 -> io.tBcc
  )
  control.ex.memoryWrite := Seq(3, 4, 5, 6).map(line(12 downto 10) === _).reduce(_ || _)

  control.ex.aluY := select(
    line(17 downto 13),
    J2AluYSelect.YBUS,
    14 -> J2AluYSelect.IMM,
    11 -> J2AluYSelect.IMM,
    24 -> J2AluYSelect.IMM,
    16 -> J2AluYSelect.IMM,
    13 -> J2AluYSelect.IMM,
    12 -> J2AluYSelect.IMM,
    19 -> J2AluYSelect.IMM,
    15 -> J2AluYSelect.IMM,
    25 -> J2AluYSelect.IMM,
    2 -> J2AluYSelect.IMM,
    22 -> J2AluYSelect.IMM,
    20 -> J2AluYSelect.R0,
    21 -> J2AluYSelect.R0
  )
  control.ex.regY := select(
    line(17 downto 13),
    U(0, 5 bits),
    24 -> U(19, 5 bits),
    10 -> U(19, 5 bits),
    16 -> U(18, 5 bits),
    3 -> U(18, 5 bits),
    13 -> U(17, 5 bits),
    7 -> U(17, 5 bits),
    12 -> U(16, 5 bits),
    6 -> U(16, 5 bits),
    1 -> U(20, 5 bits),
    19 -> opcode(7 downto 4).resize(5),
    20 -> opcode(7 downto 4).resize(5),
    18 -> opcode(7 downto 4).resize(5),
    17 -> opcode(11 downto 8).resize(5)
  )
  control.ex.ySelect := select(
    line(17 downto 13),
    J2YBusSelect.IMM,
    14 -> J2YBusSelect.MACH,
    8 -> J2YBusSelect.MACH,
    23 -> J2YBusSelect.REG,
    24 -> J2YBusSelect.REG,
    16 -> J2YBusSelect.REG,
    13 -> J2YBusSelect.REG,
    12 -> J2YBusSelect.REG,
    1 -> J2YBusSelect.REG,
    19 -> J2YBusSelect.REG,
    10 -> J2YBusSelect.REG,
    3 -> J2YBusSelect.REG,
    7 -> J2YBusSelect.REG,
    6 -> J2YBusSelect.REG,
    20 -> J2YBusSelect.REG,
    18 -> J2YBusSelect.REG,
    22 -> J2YBusSelect.REG,
    17 -> J2YBusSelect.REG,
    11 -> J2YBusSelect.SR,
    5 -> J2YBusSelect.SR,
    15 -> J2YBusSelect.MACL,
    9 -> J2YBusSelect.MACL,
    25 -> J2YBusSelect.PC
  )

  control.exStall.tSelect := select(
    line(22 downto 18),
    J2TSelect.CLEAR,
    7 -> J2TSelect.SHIFT,
    3 -> J2TSelect.SET,
    9 -> J2TSelect.CARRY
  )
  control.exStall.srSelect := select(
    line(22 downto 18),
    J2SrSelect.PREV,
    2 -> J2SrSelect.DIV0U,
    1 -> J2SrSelect.SET_T,
    7 -> J2SrSelect.SET_T,
    3 -> J2SrSelect.SET_T,
    9 -> J2SrSelect.SET_T,
    11 -> J2SrSelect.LOGIC,
    14 -> J2SrSelect.LOGIC,
    8 -> J2SrSelect.ZBUS,
    10 -> J2SrSelect.ARITH,
    13 -> J2SrSelect.ARITH,
    12 -> J2SrSelect.ARITH,
    5 -> J2SrSelect.ARITH,
    4 -> J2SrSelect.ARITH,
    15 -> J2SrSelect.ARITH,
    16 -> J2SrSelect.ARITH,
    6 -> J2SrSelect.ARITH,
    17 -> J2SrSelect.INT_MASK
  )
  control.ex.logicSr := select(
    line(22 downto 18),
    J2LogicSrFunc.ZERO,
    14 -> J2LogicSrFunc.BYTE_EQ
  )
  control.ex.arithSr := select(
    line(22 downto 18),
    J2ArithSrFunc.ZERO,
    10 -> J2ArithSrFunc.OVERUNDERFLOW,
    13 -> J2ArithSrFunc.UGRTER,
    12 -> J2ArithSrFunc.UGRTER_EQ,
    5 -> J2ArithSrFunc.SGRTER_EQ,
    4 -> J2ArithSrFunc.SGRTER,
    15 -> J2ArithSrFunc.DIV1,
    16 -> J2ArithSrFunc.DIV0S
  )

  control.ex.arithFunc := select(
    line(27 downto 23),
    J2ArithFunc.ADD,
    3 -> J2ArithFunc.SUB
  )
  control.ex.manip := select(
    line(27 downto 23),
    J2AluManip.SWAP_BYTE,
    9 -> J2AluManip.SET_BIT_7,
    10 -> J2AluManip.EXTEND_SBYTE,
    13 -> J2AluManip.EXTEND_UWORD,
    18 -> J2AluManip.EXTRACT,
    12 -> J2AluManip.EXTEND_UBYTE,
    17 -> J2AluManip.SWAP_WORD,
    11 -> J2AluManip.EXTEND_SWORD
  )
  control.exStall.shift := select(
    line(27 downto 23),
    J2ShiftFunc.LOGIC,
    8 -> J2ShiftFunc.ARITH,
    6 -> J2ShiftFunc.ROTC,
    5 -> J2ShiftFunc.ROTATE
  )
  control.ex.logicFunc := select(
    line(27 downto 23),
    J2LogicFunc.LOGIC_NOT,
    15 -> J2LogicFunc.LOGIC_OR,
    1 -> J2LogicFunc.LOGIC_XOR,
    4 -> J2LogicFunc.LOGIC_AND
  )

  control.exStall.zSelect := select(
    line(30 downto 28),
    J2ZBusSelect.ARITH,
    0 -> J2ZBusSelect.LOGIC,
    2 -> J2ZBusSelect.WBUS,
    3 -> J2ZBusSelect.YBUS,
    4 -> J2ZBusSelect.SHIFT,
    5 -> J2ZBusSelect.MANIP
  )
  control.ex.xSelect := select(
    line(32 downto 31),
    J2XBusSelect.IMM,
    1 -> J2XBusSelect.REG,
    3 -> J2XBusSelect.PC
  )
  control.exStall.regWriteZ := line(33)
  control.wbStall.regWriteW := line(34)
  control.sleep := line(35)

  control.ex.regZ := select(
    line(38 downto 36),
    U(0, 5 bits),
    0 -> U(15, 5 bits),
    1 -> opcode(11 downto 8).resize(5),
    2 -> U(16, 5 bits),
    3 -> U(17, 5 bits),
    4 -> U(18, 5 bits),
    5 -> U(19, 5 bits),
    6 -> opcode(7 downto 4).resize(5)
  )
  control.ex.regX := select(
    line(41 downto 39),
    U(0, 5 bits),
    0 -> U(20, 5 bits),
    1 -> U(15, 5 bits),
    2 -> opcode(11 downto 8).resize(5),
    4 -> opcode(7 downto 4).resize(5),
    5 -> U(16, 5 bits),
    6 -> U(19, 5 bits),
    7 -> U(17, 5 bits)
  )
  control.wb.regW := select(
    line(44 downto 42),
    U(0, 5 bits),
    0 -> U(19, 5 bits),
    1 -> U(16, 5 bits),
    2 -> U(17, 5 bits),
    3 -> U(18, 5 bits),
    4 -> opcode(11 downto 8).resize(5),
    6 -> U(20, 5 bits),
    7 -> U(15, 5 bits)
  )
  control.exStall.memoryWriteData := select(
    line(45).asUInt,
    J2MemWdataSelect.ZBUS,
    1 -> J2MemWdataSelect.YBUS
  )
  control.ex.memoryLock := line(46)
  control.exStall.memoryAddress := select(
    line(48 downto 47),
    J2MemAddrSelect.XBUS,
    1 -> J2MemAddrSelect.ZBUS,
    2 -> J2MemAddrSelect.YBUS
  )
  control.maskInterruptNext := line(49)
  control.macStallSense := line(50)
  control.macSLatch := line(51)

  control.ex.macBusy := (line(53 downto 52) === 2) && !io.nextIdStall
  control.wb.macBusy := (line(53 downto 52) === 3) ||
    ((line(53 downto 52) === 1) && !io.nextIdStall)
  control.id.incrementPc := line(54)

  private val immediate8Signed = opcode(7 downto 0).asSInt.resize(32).asUInt
  private val immediate8ShiftSigned = (opcode(7 downto 0).asSInt << 1).resize(32).asUInt
  private val immediate12ShiftSigned = (opcode(11 downto 0).asSInt << 1).resize(32).asUInt
  control.ex.immediate := select(
    line(59 downto 55),
    U(0, 32 bits),
    3 -> U(0xffffffffL, 32 bits),
    2 -> U(1, 32 bits),
    5 -> U(0xfffffffeL, 32 bits),
    4 -> U(2, 32 bits),
    0 -> U(4, 32 bits),
    7 -> U(0xfffffff8L, 32 bits),
    6 -> U(8, 32 bits),
    9 -> U(0xfffffff0L, 32 bits),
    8 -> U(16, 32 bits),
    17 -> immediate12ShiftSigned,
    13 -> opcode(7 downto 0).resize(32),
    14 -> (opcode(7 downto 0) << 1).resize(32),
    15 -> (opcode(7 downto 0) << 2).resize(32),
    18 -> immediate8Signed,
    16 -> immediate8ShiftSigned,
    10 -> opcode(3 downto 0).resize(32),
    11 -> (opcode(3 downto 0) << 1).resize(32),
    12 -> (opcode(3 downto 0) << 2).resize(32)
  )

  control.interruptLevelCapture := line(60)
  control.id.instructionAddress := line(61)
  control.id.instructionIssue := select(
    line(63 downto 62),
    False,
    1 -> True,
    2 -> io.tBcc,
    3 -> !io.tBcc
  )
  control.eventAcknowledge := line(64)
  control.dispatch := select(
    line(66 downto 65),
    False,
    1 -> True,
    2 -> io.tBcc,
    3 -> !io.tBcc
  )
  control.delayJump := line(67)
  control.debug := line(68)
  control.ex.arithCarry := line(69)
  control.ex.aluX := select(
    line(71 downto 70),
    J2AluXSelect.XBUS,
    1 -> J2AluXSelect.ZERO,
    2 -> J2AluXSelect.ROTCL,
    3 -> J2AluXSelect.FC
  )
}
