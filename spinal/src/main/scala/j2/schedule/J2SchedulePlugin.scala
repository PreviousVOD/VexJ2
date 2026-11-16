package j2.schedule

import j2.core._
import spinal.core._
import spinal.lib.misc.plugin.FiberPlugin
import spinal.core.fiber.Retainer

/** The builder is the only consumer of this construction-time service. */
trait J2PipelineService { def buildPipeline(): Unit }

final class J2PipelineBuilderPlugin extends FiberPlugin {
  val elaborationLock = Retainer()
  val logic = during build new Area {
    elaborationLock.await()
    host[J2PipelineService].buildPipeline()
  }
}

final class J2SchedulePlugin extends FiberPlugin with J2ScheduleService with J2PipelineService {
  val allocation = during build new Area {
    val port                   = new J2SchedulePort
    val advance                = RegInit(False)
    val control                = new J2MicrocodeControl
    val metadata               = new J2InstructionMetadata
    val nextIdStall, cancelWb1 = Bool()
    val graph = new J2PipelineLogic(
      advance,
      nextIdStall,
      cancelWb1,
      control.ex,
      control.exStall,
      control.wb,
      control.wbStall,
      metadata
    )
    port.advance := advance
    port.state   := graph.state
  }
  override def schedule: J2SchedulePort = allocation.get.port
  override def buildPipeline(): Unit    = allocation.get.graph.build()

  val logic = during setup new Area {
    val builderLock = host[J2PipelineBuilderPlugin].elaborationLock()
    awaitBuild()
    val a  = allocation.get
    val d  = host[J2DecodeService].decode
    val f  = host[J2FetchService].fetch
    val m  = host[J2MemoryService].memory
    val pc = host[J2ArchitecturalService].architectural
    val t  = host[J2TrapService].trap
    a.control     := d.control
    a.metadata    := pc.metadata
    a.nextIdStall := d.nextIdStall
    a.cancelWb1   := m.fault
    when(!m.active && !f.active && !t.sleeping && !t.halted) {
      a.advance := True
    } otherwise { a.advance := False }
    // Stop on the issue edge; waiting for registered busy would move one extra slot.
    when(m.issued || f.issued || (a.advance && t.enterSleep))(a.advance := False)
    when(t.halted)(a.advance                                            := False)
    builderLock.release()
  }
}
