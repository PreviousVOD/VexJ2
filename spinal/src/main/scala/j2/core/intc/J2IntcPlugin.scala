package j2.core.intc

import j2.bus.apb._
import j2.core._
import spinal.core._
import spinal.lib._
import spinal.lib.misc.plugin.FiberPlugin

final class J2IntcPlugin(config: J2CoreConfig) extends FiberPlugin with J2InterruptService {
  val allocation = during build new Area {
    val event = Stream(new J2Event)
    val bus   = Apb4(Apb4Config(9, 32))
  }
  override def interrupt = allocation.get.event
  override def registers = allocation.get.bus

  val logic = during build new Area {
    val external   = host[J2ExternalService].external
    val pc         = host[J2ArchitecturalService].architectural
    val controller = new J2Intc(IntcConfig(config.interruptCount))
    controller.io.bus <> registers
    controller.io.requests       := external.interrupts
    controller.io.nmi            := external.nmi
    controller.io.maskLevel      := pc.status.interruptMask
    interrupt.valid              := controller.io.candidate.valid
    interrupt.payload.command    := 0
    interrupt.payload.vector     := controller.io.candidate.payload.vector
    interrupt.payload.level      := controller.io.candidate.payload.level
    interrupt.payload.bypassMask := controller.io.candidate.payload.nmi
    controller.io.accept         := interrupt.fire
    // Keep ALU/writeback SR forwarding off the interrupt-to-ROM path.
    // An SR-writing slot defers interrupt acceptance until the new mask commits.
    val s = host[J2ScheduleService].schedule
    val m = host[J2MemoryService].memory
    val srWritePending = (s.state.wbAction.srWriteW && m.readValid) ||
      (!m.fault && (s.state.exAction.srSelect === J2SrSelect.ZBUS ||
        s.state.exAction.srSelect === J2SrSelect.WBUS ||
        s.state.exAction.srSelect === J2SrSelect.INT_MASK))
    when(srWritePending)(interrupt.valid := False)
    // Explicit test/debug configuration only; production cores expose source wires.
    if (config.eventInjection) {
      external.event.ready := interrupt.ready && interrupt.valid && external.event.valid
      external.eventAck    := external.event.fire
      when(external.event.valid) {
        interrupt.valid      := external.event.payload.command =/= 0 || !srWritePending
        interrupt.payload    := external.event.payload
        controller.io.accept := False
      }
    }
  }
}
