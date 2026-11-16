package j2.core

import spinal.core._

final class J2Status extends Bundle {
  val t             = Bool()
  val s             = Bool()
  val q             = Bool()
  val m             = Bool()
  val interruptMask = UInt(4 bits)

  def asUInt: UInt = {
    val value = U(0, 32 bits)
    value(0) := t
    value(1) := s
    value(4) := interruptMask(0)
    value(5) := interruptMask(1)
    value(6) := interruptMask(2)
    value(7) := interruptMask(3)
    value(8) := q
    value(9) := m
    value
  }
}

object J2Status {
  def fromUInt(value: UInt): J2Status = {
    val status = new J2Status
    status.t             := value(0)
    status.s             := value(1)
    status.interruptMask := value(7 downto 4)
    status.q             := value(8)
    status.m             := value(9)
    status
  }
}

final class J2Datapath extends Component {
  val io = new Bundle {
    val ex              = in(new J2ExControl)
    val exStall         = in(new J2ExStallControl)
    val regX            = in UInt (32 bits)
    val regY            = in UInt (32 bits)
    val reg0            = in UInt (32 bits)
    val pc              = in UInt (32 bits)
    val sr              = in(new J2Status)
    val mach            = in UInt (32 bits)
    val macl            = in UInt (32 bits)
    val wbus            = in UInt (32 bits)
    val yOverrideEnable = in Bool ()
    val yOverride       = in UInt (32 bits)

    val xbus             = out UInt (32 bits)
    val ybus             = out UInt (32 bits)
    val zbus             = out UInt (32 bits)
    val memoryAddress    = out UInt (32 bits)
    val memoryWriteData  = out UInt (32 bits)
    val arithmeticResult = out UInt (33 bits)
    val logicResult      = out UInt (32 bits)
    val shiftResult      = out UInt (32 bits)
    val shiftT           = out Bool ()
    val arithmeticSr     = out(new J2Status)
    val logicSr          = out(new J2Status)
  }

  io.xbus := io.ex.xSelect.mux(
    J2XBusSelect.IMM -> io.ex.immediate,
    J2XBusSelect.REG -> io.regX,
    J2XBusSelect.PC -> io.pc
  )
  private val selectedY = io.ex.ySelect.mux(
    J2YBusSelect.IMM -> io.ex.immediate,
    J2YBusSelect.REG -> io.regY,
    J2YBusSelect.MACH -> io.mach,
    J2YBusSelect.MACL -> io.macl,
    J2YBusSelect.PC -> io.pc,
    J2YBusSelect.SR -> io.sr.asUInt
  )
  io.ybus := Mux(io.yOverrideEnable, io.yOverride, selectedY)

  private val aluX = io.ex.aluX.mux(
    J2AluXSelect.XBUS -> io.xbus,
    J2AluXSelect.FC -> Cat(io.xbus(31 downto 2), U(0, 2 bits)).asUInt,
    J2AluXSelect.ROTCL -> Cat(io.xbus(30 downto 0), io.sr.t).asUInt,
    J2AluXSelect.ZERO -> U(0, 32 bits)
  )
  private val aluY = io.ex.aluY.mux(
    J2AluYSelect.YBUS -> io.ybus,
    J2AluYSelect.IMM -> io.ex.immediate,
    J2AluYSelect.R0 -> io.reg0
  )

  private val subtract = Mux(
    io.ex.arithSr === J2ArithSrFunc.DIV1,
    io.sr.q === io.sr.m,
    io.ex.arithFunc === J2ArithFunc.SUB
  )
  private val arithmeticB     = aluY ^ Mux(subtract, U(0xffffffffL, 32 bits), U(0, 32 bits))
  private val arithmeticCarry = subtract ^ (io.ex.arithCarry && io.sr.t)
  private val arithmeticWide  = aluX.resize(33) + arithmeticB.resize(33) + arithmeticCarry.asUInt
  private val arithmeticWithBorrow = Cat(arithmeticWide(32) ^ subtract, arithmeticWide(31 downto 0))
  io.arithmeticResult := arithmeticWithBorrow.asUInt

  io.logicResult := io.ex.logicFunc.mux(
    J2LogicFunc.LOGIC_OR -> (aluX | aluY),
    J2LogicFunc.LOGIC_XOR -> (aluX ^ aluY),
    J2LogicFunc.LOGIC_AND -> (aluX & aluY),
    J2LogicFunc.LOGIC_NOT -> ~aluY
  )

  private val manipResult = io.ex.manip.mux(
    J2AluManip.SWAP_BYTE -> Cat(
      io.ybus(31 downto 16),
      io.ybus(7 downto 0),
      io.ybus(15 downto 8)
    ).asUInt,
    J2AluManip.SWAP_WORD -> Cat(io.ybus(15 downto 0), io.ybus(31 downto 16)).asUInt,
    J2AluManip.EXTEND_UBYTE -> io.ybus(7 downto 0).resize(32),
    J2AluManip.EXTEND_UWORD -> io.ybus(15 downto 0).resize(32),
    J2AluManip.EXTEND_SBYTE -> io.ybus(7 downto 0).asSInt.resize(32).asUInt,
    J2AluManip.EXTEND_SWORD -> io.ybus(15 downto 0).asSInt.resize(32).asUInt,
    J2AluManip.EXTRACT -> Cat(io.ybus(15 downto 0), io.xbus(31 downto 16)).asUInt,
    J2AluManip.SET_BIT_7 -> Cat(io.ybus(31 downto 8), True, io.ybus(6 downto 0)).asUInt
  )

  private val shiftLeft = !io.ybus(31)
  private val shiftMagnitude =
    Mux(shiftLeft, io.ybus(4 downto 0), (U(0, 6 bits) - io.ybus(4 downto 0)).resize(5))
  private val shiftRightZero = shiftMagnitude === 0
  private val shiftLogical   = Mux(shiftRightZero, U(0, 32 bits), io.xbus >> shiftMagnitude)
  private val shiftArithmetic = Mux(
    shiftRightZero,
    Mux(io.xbus(31), U(0xffffffffL, 32 bits), U(0, 32 bits)),
    (io.xbus.asSInt >> shiftMagnitude).asUInt
  )
  private val rotatePlainLeft = (io.xbus << shiftMagnitude).resize(32) |
    (io.xbus >> (32 - shiftMagnitude)).resize(32)
  private val rotatePlainRight = (io.xbus >> shiftMagnitude).resize(32) |
    (io.xbus << (32 - shiftMagnitude)).resize(32)
  private val rotateThroughLeft  = Cat(io.xbus(30 downto 0), io.sr.t).asUInt
  private val rotateThroughRight = Cat(io.sr.t, io.xbus(31 downto 1)).asUInt
  private val shiftResult        = UInt(32 bits)
  shiftResult := io.xbus
  when(!shiftLeft) {
    shiftResult := io.exStall.shift.mux(
      J2ShiftFunc.LOGIC -> shiftLogical,
      J2ShiftFunc.ARITH -> shiftArithmetic,
      J2ShiftFunc.ROTATE -> rotatePlainRight,
      J2ShiftFunc.ROTC -> rotateThroughRight
    )
  } elsewhen (io.exStall.shift === J2ShiftFunc.ROTATE) {
    shiftResult := rotatePlainLeft
  } elsewhen (io.exStall.shift === J2ShiftFunc.ROTC) {
    shiftResult := rotateThroughLeft
  } otherwise {
    shiftResult := (io.xbus << shiftMagnitude).resize(32)
  }
  io.shiftResult := shiftResult
  io.shiftT      := Mux(shiftLeft, io.xbus(31), io.xbus(0))

  io.zbus := io.exStall.zSelect.mux(
    J2ZBusSelect.ARITH -> arithmeticWithBorrow(31 downto 0).asUInt,
    J2ZBusSelect.LOGIC -> io.logicResult,
    J2ZBusSelect.SHIFT -> io.shiftResult,
    J2ZBusSelect.MANIP -> manipResult,
    J2ZBusSelect.YBUS -> io.ybus,
    J2ZBusSelect.WBUS -> io.wbus
  )
  io.memoryAddress := io.exStall.memoryAddress.mux(
    J2MemAddrSelect.XBUS -> io.xbus,
    J2MemAddrSelect.YBUS -> io.ybus,
    J2MemAddrSelect.ZBUS -> io.zbus
  )
  io.memoryWriteData := Mux(
    io.exStall.memoryWriteData === J2MemWdataSelect.YBUS,
    io.ybus,
    io.zbus
  )

  private val arithmeticSr = new J2Status
  arithmeticSr := io.sr
  private val valueZero = arithmeticWithBorrow(31 downto 0).asUInt === 0
  private val aMsb      = io.xbus(31)
  private val bMsb      = io.ybus(31)
  private val valueMsb  = arithmeticWithBorrow(31)
  private val commonGreaterEqual =
    (!aMsb && !bMsb && !valueMsb) || (aMsb && bMsb && !valueMsb)
  private val signedGreaterEqual   = commonGreaterEqual || (!aMsb && bMsb)
  private val unsignedGreaterEqual = commonGreaterEqual || (aMsb && !bMsb)
  switch(io.ex.arithSr) {
    is(J2ArithSrFunc.ZERO) {
      arithmeticSr.t := valueZero
    }
    is(J2ArithSrFunc.OVERUNDERFLOW) {
      arithmeticSr.t := (!aMsb && !(bMsb ^ subtract) && valueMsb) ||
        (aMsb && (bMsb ^ subtract) && !valueMsb)
    }
    is(J2ArithSrFunc.UGRTER) {
      arithmeticSr.t := unsignedGreaterEqual && !valueZero
    }
    is(J2ArithSrFunc.UGRTER_EQ) {
      arithmeticSr.t := unsignedGreaterEqual
    }
    is(J2ArithSrFunc.SGRTER) {
      arithmeticSr.t := signedGreaterEqual && !valueZero
    }
    is(J2ArithSrFunc.SGRTER_EQ) {
      arithmeticSr.t := signedGreaterEqual
    }
    is(J2ArithSrFunc.DIV0S) {
      arithmeticSr.q := aMsb
      arithmeticSr.m := bMsb
      arithmeticSr.t := aMsb ^ bMsb
    }
    is(J2ArithSrFunc.DIV1) {
      arithmeticSr.q := aMsb ^ io.sr.m ^ arithmeticWithBorrow(32)
      arithmeticSr.t := !(arithmeticSr.q ^ io.sr.m)
    }
  }
  io.arithmeticSr := arithmeticSr

  private val logicSr = new J2Status
  logicSr := io.sr
  switch(io.ex.logicSr) {
    is(J2LogicSrFunc.ZERO) {
      logicSr.t := io.logicResult === 0
    }
    is(J2LogicSrFunc.BYTE_EQ) {
      logicSr.t := Seq(
        io.logicResult(31 downto 24),
        io.logicResult(23 downto 16),
        io.logicResult(15 downto 8),
        io.logicResult(7 downto 0)
      ).map(_ === 0).reduce(_ || _)
    }
  }
  io.logicSr := logicSr
}
