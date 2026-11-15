package j2.core

import spinal.core._

object J2ControlDefaults {
  def ex(): J2ExControl = {
    val value = new J2ExControl
    value.immediate := 0
    value.xSelect := J2XBusSelect.IMM
    value.ySelect := J2YBusSelect.IMM
    value.regZ := 0
    value.regX := 0
    value.regY := 0
    value.manip := J2AluManip.SWAP_BYTE
    value.aluX := J2AluXSelect.XBUS
    value.aluY := J2AluYSelect.YBUS
    value.arithFunc := J2ArithFunc.ADD
    value.arithCarry := False
    value.arithSr := J2ArithSrFunc.ZERO
    value.logicFunc := J2LogicFunc.LOGIC_NOT
    value.logicSr := J2LogicSrFunc.ZERO
    value.macBusy := False
    value.memoryWrite := False
    value.memoryLock := False
    value.memorySize := J2MemSize.BYTE
    value
  }

  def exStall(): J2ExStallControl = {
    val value = new J2ExStallControl
    value.pcWriteZ := False
    value.srWriteZ := False
    value.memoryIssue := False
    value.prWritePc := False
    value.zSelect := J2ZBusSelect.ARITH
    value.srSelect := J2SrSelect.PREV
    value.tSelect := J2TSelect.CLEAR
    value.memoryAddress := J2MemAddrSelect.XBUS
    value.memoryWriteData := J2MemWdataSelect.ZBUS
    value.regWriteZ := False
    value.machWrite := False
    value.maclWrite := False
    value.shift := J2ShiftFunc.LOGIC
    value.multiplyStart := False
    value.multiplyCommand := J2MultiplyCommand.NOP
    value.macSelect1 := J2MacSelect1.XBUS
    value.macSelect2 := J2MacSelect2.YBUS
    value
  }

  def wb(): J2WbControl = {
    val value = new J2WbControl
    value.regW := 0
    value.macBusy := False
    value
  }

  def wbStall(): J2WbStallControl = {
    val value = new J2WbStallControl
    value.multiplyStart := False
    value.machWrite := False
    value.maclWrite := False
    value.regWriteW := False
    value.srWriteW := False
    value.macSelect1 := J2MacSelect1.XBUS
    value.macSelect2 := J2MacSelect2.YBUS
    value.multiplyCommand := J2MultiplyCommand.NOP
    value
  }
}

final class J2PipelineState extends Bundle {
  val ex1 = new J2ExControl
  val ex1Stall = new J2ExStallControl
  val wb1 = new J2WbControl
  val wb2 = new J2WbControl
  val wb3 = new J2WbControl
  val wb1Stall = new J2WbStallControl
  val wb2Stall = new J2WbStallControl
  val wb3Stall = new J2WbStallControl
}

final class J2Pipeline extends Component {
  val io = new Bundle {
    val slot = in Bool ()
    val nextIdStall = in Bool ()
    // Kill the younger writeback paired with EX when a data access faults.
    val cancelWb1 = in Bool ()
    val ex = in(new J2ExControl)
    val exStall = in(new J2ExStallControl)
    val wb = in(new J2WbControl)
    val wbStall = in(new J2WbStallControl)
    val state = out(new J2PipelineState)
  }

  private val state = Reg(new J2PipelineState)

  when(io.slot) {
    state.wb3 := state.wb2
    state.wb2 := state.wb1
    state.wb1 := io.wb
    state.ex1 := io.ex
    state.wb3Stall := state.wb2Stall
    state.wb2Stall := state.wb1Stall
    when(io.cancelWb1) { state.wb2Stall := J2ControlDefaults.wbStall() }
    when(io.nextIdStall) {
      state.ex1Stall := J2ControlDefaults.exStall()
      state.wb1Stall := J2ControlDefaults.wbStall()
    } otherwise {
      state.ex1Stall := io.exStall
      state.wb1Stall := io.wbStall
    }
  }

  when(ClockDomain.current.isResetActive) {
    state.ex1 := J2ControlDefaults.ex()
    state.ex1Stall := J2ControlDefaults.exStall()
    state.wb1 := J2ControlDefaults.wb()
    state.wb2 := J2ControlDefaults.wb()
    state.wb3 := J2ControlDefaults.wb()
    state.wb1Stall := J2ControlDefaults.wbStall()
    state.wb2Stall := J2ControlDefaults.wbStall()
    state.wb3Stall := J2ControlDefaults.wbStall()
  }

  io.state := state
}

final class J2Hazards extends Component {
  val io = new Bundle {
    val ex = in(new J2ExControl)
    val exStall = in(new J2ExStallControl)
    val state = in(new J2PipelineState)
    val macStallSense = in Bool ()
    val macBusy = in Bool ()
    val registerConflict = out Bool ()
    val macStall = out Bool ()
  }

  private val wbWrite = io.state.wb1Stall.regWriteW
  private val wbAddress = io.state.wb1.regW
  private val xConflict = io.ex.xSelect === J2XBusSelect.REG && io.ex.regX === wbAddress
  private val yConflict = io.ex.ySelect === J2YBusSelect.REG && io.ex.regY === wbAddress
  private val zConflict = io.exStall.regWriteZ && io.ex.regZ === wbAddress
  private val r0Conflict = io.ex.aluY === J2AluYSelect.R0 && wbAddress === 0

  io.registerConflict := wbWrite && (xConflict || yConflict || zConflict || r0Conflict)
  io.macStall := io.macStallSense &&
    (io.state.wb1.macBusy || io.state.wb2.macBusy || io.state.wb3.macBusy ||
      io.state.ex1.macBusy || io.macBusy)
}
