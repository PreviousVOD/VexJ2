package j2.core

import spinal.core._
import spinal.lib.misc.pipeline._

object J2ControlDefaults {
  def ex(): J2ExControl = {
    val value = new J2ExControl
    value.immediate   := 0
    value.xSelect     := J2XBusSelect.IMM
    value.ySelect     := J2YBusSelect.IMM
    value.regZ        := 0
    value.regX        := 0
    value.regY        := 0
    value.manip       := J2AluManip.SWAP_BYTE
    value.aluX        := J2AluXSelect.XBUS
    value.aluY        := J2AluYSelect.YBUS
    value.arithFunc   := J2ArithFunc.ADD
    value.arithCarry  := False
    value.arithSr     := J2ArithSrFunc.ZERO
    value.logicFunc   := J2LogicFunc.LOGIC_NOT
    value.logicSr     := J2LogicSrFunc.ZERO
    value.macBusy     := False
    value.memoryWrite := False
    value.memoryLock  := False
    value.memorySize  := J2MemSize.BYTE
    value
  }

  def exStall(): J2ExStallControl = {
    val value = new J2ExStallControl
    value.pcWriteZ        := False
    value.srWriteZ        := False
    value.memoryIssue     := False
    value.prWritePc       := False
    value.zSelect         := J2ZBusSelect.ARITH
    value.srSelect        := J2SrSelect.PREV
    value.tSelect         := J2TSelect.CLEAR
    value.memoryAddress   := J2MemAddrSelect.XBUS
    value.memoryWriteData := J2MemWdataSelect.ZBUS
    value.regWriteZ       := False
    value.machWrite       := False
    value.maclWrite       := False
    value.shift           := J2ShiftFunc.LOGIC
    value.multiplyStart   := False
    value.multiplyCommand := J2MultiplyCommand.NOP
    value.macSelect1      := J2MacSelect1.XBUS
    value.macSelect2      := J2MacSelect2.YBUS
    value
  }

  def wb(): J2WbControl = {
    val value = new J2WbControl
    value.regW    := 0
    value.macBusy := False
    value
  }

  def wbStall(): J2WbStallControl = {
    val value = new J2WbStallControl
    value.multiplyStart   := False
    value.machWrite       := False
    value.maclWrite       := False
    value.regWriteW       := False
    value.srWriteW        := False
    value.macSelect1      := J2MacSelect1.XBUS
    value.macSelect2      := J2MacSelect2.YBUS
    value.multiplyCommand := J2MultiplyCommand.NOP
    value
  }
}

final class J2PipelineState extends Bundle {
  val ex1Metadata, wb1Metadata, wb2Metadata, wb3Metadata = new J2InstructionMetadata
  val ex1                                                = new J2ExControl
  val ex1Stall                                           = new J2ExStallControl
  val wb1                                                = new J2WbControl
  val wb2                                                = new J2WbControl
  val wb3                                                = new J2WbControl
  val wb1Stall                                           = new J2WbStallControl
  val wb2Stall                                           = new J2WbStallControl
  val wb3Stall                                           = new J2WbStallControl
}

final class J2Pipeline extends Component {
  val io = new Bundle {
    val slot        = in Bool ()
    val nextIdStall = in Bool ()
    // Kill the younger writeback paired with EX when a data access faults.
    val cancelWb1 = in Bool ()
    val ex        = in(new J2ExControl)
    val exStall   = in(new J2ExStallControl)
    val wb        = in(new J2WbControl)
    val wbStall   = in(new J2WbStallControl)
    val state     = out(new J2PipelineState)
  }

  private val metadata = new J2InstructionMetadata
  metadata.pc       := 0
  metadata.resumePc := 0
  private val graph = new J2PipelineLogic(
    io.slot,
    io.nextIdStall,
    io.cancelWb1,
    io.ex,
    io.exStall,
    io.wb,
    io.wbStall,
    metadata
  )
  io.state := graph.state
  graph.build()
}

/** Non-collapsing microstep pipeline shared by the CPU plugin and leaf tests. EX and WB1 occupy
  * parallel payload paths at node 1; only WB travels onward.
  */
final class J2PipelineLogic(
    advance: Bool,
    nextIdStall: Bool,
    cancelWb1: Bool,
    ex: J2ExControl,
    exStall: J2ExStallControl,
    wb: J2WbControl,
    wbStall: J2WbStallControl,
    metadata: J2InstructionMetadata
) extends Area {
  val EX        = Payload(new J2ExControl)
  val EX_ACTION = Payload(new J2ExStallControl)
  val WB        = Payload(new J2WbControl)
  val WB_ACTION = Payload(new J2WbStallControl)
  val METADATA  = Payload(new J2InstructionMetadata)
  val stages    = Vector.fill(4)(CtrlLink())
  val links = stages.zip(stages.tail).map { case (from, to) =>
    StageLink(from.down, to.up).withoutCollapse()
  }
  val id = stages(0)
  id.up.valid          := True
  id.up(EX)            := ex
  id.up(EX_ACTION)     := exStall
  id.up(WB)            := wb
  id.up(WB_ACTION)     := wbStall
  id.up(METADATA)      := metadata
  id.bypass(EX_ACTION) := Mux(nextIdStall, J2ControlDefaults.exStall(), id.up(EX_ACTION))
  id.bypass(WB_ACTION) := Mux(nextIdStall, J2ControlDefaults.wbStall(), id.up(WB_ACTION))
  // Kill only WB1 as it enters WB2. Older WB2 still enters WB3 on this edge.
  stages(1).bypass(WB_ACTION) :=
    Mux(cancelWb1, J2ControlDefaults.wbStall(), stages(1).up(WB_ACTION))
  stages.last.down.ready := advance

  val state = new J2PipelineState
  state.ex1         := stages(1).up(EX)
  state.ex1Stall    := stages(1).up(EX_ACTION)
  state.ex1Metadata := stages(1).up(METADATA)
  state.wb1         := stages(1).up(WB)
  state.wb2         := stages(2).up(WB)
  state.wb3         := stages(3).up(WB)
  state.wb1Stall    := stages(1).up(WB_ACTION)
  state.wb2Stall    := stages(2).up(WB_ACTION)
  state.wb3Stall    := stages(3).up(WB_ACTION)
  state.wb1Metadata := stages(1).up(METADATA)
  state.wb2Metadata := stages(2).up(METADATA)
  state.wb3Metadata := stages(3).up(METADATA)

  def build(): Unit = {
    Builder(links ++ stages)
    // Payloads are registers created by StageLink. Reset after Builder so reset
    // retains priority over movement, including when advance is asserted.
    when(ClockDomain.current.isResetActive) {
      stages(1).up(EX)        := J2ControlDefaults.ex()
      stages(1).up(EX_ACTION) := J2ControlDefaults.exStall()
      for (stage <- stages.tail) {
        stage.up(WB)                := J2ControlDefaults.wb()
        stage.up(WB_ACTION)         := J2ControlDefaults.wbStall()
        stage.up(METADATA).pc       := 0
        stage.up(METADATA).resumePc := 0
      }
    }
  }
}

final class J2Hazards extends Component {
  val io = new Bundle {
    val ex               = in(new J2ExControl)
    val exStall          = in(new J2ExStallControl)
    val state            = in(new J2PipelineState)
    val macStallSense    = in Bool ()
    val macBusy          = in Bool ()
    val registerConflict = out Bool ()
    val macStall         = out Bool ()
  }

  private val wbWrite    = io.state.wb1Stall.regWriteW
  private val wbAddress  = io.state.wb1.regW
  private val xConflict  = io.ex.xSelect === J2XBusSelect.REG && io.ex.regX === wbAddress
  private val yConflict  = io.ex.ySelect === J2YBusSelect.REG && io.ex.regY === wbAddress
  private val zConflict  = io.exStall.regWriteZ && io.ex.regZ === wbAddress
  private val r0Conflict = io.ex.aluY === J2AluYSelect.R0 && wbAddress === 0

  io.registerConflict := wbWrite && (xConflict || yConflict || zConflict || r0Conflict)
  io.macStall := io.macStallSense &&
    (io.state.wb1.macBusy || io.state.wb2.macBusy || io.state.wb3.macBusy ||
      io.state.ex1.macBusy || io.macBusy)
}
