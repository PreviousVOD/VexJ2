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

/** EX output held in MA until the bus response completes. Holding the address between requests also
  * preserves the decoder selection during TAS lock gaps.
  */
final class J2MemoryRequest extends Bundle {
  val address, data = UInt(32 bits)
  val write         = Bool()
  val size          = J2MemSize()
}

final class J2PipelineState extends Bundle {
  val maRequest                          = new J2MemoryRequest
  val exMetadata, maMetadata, wbMetadata = new J2InstructionMetadata
  val ex                                 = new J2ExControl
  val exAction                           = new J2ExStallControl
  val exWriteback                        = new J2WbControl
  val ma                                 = new J2WbControl
  val wb                                 = new J2WbControl
  val exWritebackAction                  = new J2WbStallControl
  val maAction                           = new J2WbStallControl
  val wbAction                           = new J2WbStallControl
}

final class J2Pipeline extends Component {
  val io = new Bundle {
    val slot        = in Bool ()
    val nextIdStall = in Bool ()
    // Kill the younger writeback paired with EX when a data access faults.
    val cancelExWriteback = in Bool ()
    val ex                = in(new J2ExControl)
    val exStall           = in(new J2ExStallControl)
    val wb                = in(new J2WbControl)
    val wbStall           = in(new J2WbStallControl)
    val memoryRequest     = in(new J2MemoryRequest)
    val state             = out(new J2PipelineState)
  }

  private val metadata = new J2InstructionMetadata
  metadata.pc       := 0
  metadata.resumePc := 0
  private val graph = new J2PipelineLogic(
    io.slot,
    io.nextIdStall,
    io.cancelExWriteback,
    io.ex,
    io.exStall,
    io.wb,
    io.wbStall,
    metadata,
    io.memoryRequest
  )
  io.state := graph.state
  graph.build()
}

/** SH-2 ID -> EX -> MA -> WB slot pipeline; IF is owned by J2FetchPlugin. ALU results finish in EX.
  * Memory controls and instruction metadata continue through MA and WB. External waits freeze
  * slots, not the multiplier clock.
  */
final class J2PipelineLogic(
    advance: Bool,
    nextIdStall: Bool,
    cancelExWriteback: Bool,
    ex: J2ExControl,
    exStall: J2ExStallControl,
    wb: J2WbControl,
    wbStall: J2WbStallControl,
    metadata: J2InstructionMetadata,
    memoryRequest: J2MemoryRequest
) extends Area {
  val EX        = Payload(new J2ExControl)
  val EX_ACTION = Payload(new J2ExStallControl)
  val WB        = Payload(new J2WbControl)
  val WB_ACTION = Payload(new J2WbStallControl)
  val MEMORY    = Payload(new J2MemoryRequest)
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
  // EX creates the MA request. Hold unused payloads across bubbles, especially
  // while TAS retains its AHB lock reservation between its read and write.
  stages(1).down(MEMORY) := Mux(
    stages(1).up(EX_ACTION).memoryIssue && !cancelExWriteback,
    memoryRequest,
    stages(2).up(MEMORY)
  )
  // Cancel younger EX writeback on a data fault; the older MA result drains to WB.
  stages(1).bypass(WB_ACTION) :=
    Mux(cancelExWriteback, J2ControlDefaults.wbStall(), stages(1).up(WB_ACTION))
  stages.last.down.ready := advance

  val state = new J2PipelineState
  state.maRequest         := stages(2).up(MEMORY)
  state.ex                := stages(1).up(EX)
  state.exAction          := stages(1).up(EX_ACTION)
  state.exMetadata        := stages(1).up(METADATA)
  state.exWriteback       := stages(1).up(WB)
  state.ma                := stages(2).up(WB)
  state.wb                := stages(3).up(WB)
  state.exWritebackAction := stages(1).up(WB_ACTION)
  state.maAction          := stages(2).up(WB_ACTION)
  state.wbAction          := stages(3).up(WB_ACTION)
  state.maMetadata        := stages(2).up(METADATA)
  state.wbMetadata        := stages(3).up(METADATA)

  def build(): Unit = {
    Builder(links ++ stages)
    // Payloads are registers created by StageLink. Reset after Builder so reset
    // retains priority over movement, including when advance is asserted.
    when(ClockDomain.current.isResetActive) {
      stages(2).up(MEMORY).assignFromBits(B(0, stages(2).up(MEMORY).getBitsWidth bits))
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

  private val wbWrite    = io.state.exWritebackAction.regWriteW
  private val wbAddress  = io.state.exWriteback.regW
  private val xConflict  = io.ex.xSelect === J2XBusSelect.REG && io.ex.regX === wbAddress
  private val yConflict  = io.ex.ySelect === J2YBusSelect.REG && io.ex.regY === wbAddress
  private val zConflict  = io.exStall.regWriteZ && io.ex.regZ === wbAddress
  private val r0Conflict = io.ex.aluY === J2AluYSelect.R0 && wbAddress === 0

  io.registerConflict := wbWrite && (xConflict || yConflict || zConflict || r0Conflict)
  io.macStall := io.macStallSense &&
    (io.state.exWriteback.macBusy || io.state.ma.macBusy || io.state.wb.macBusy ||
      io.state.ex.macBusy || io.macBusy)
}
