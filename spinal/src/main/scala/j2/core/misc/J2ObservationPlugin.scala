package j2.core.misc

import j2.core._
import spinal.core._
import spinal.lib.misc.plugin.FiberPlugin

final class J2ObservationPlugin(enabled: Boolean) extends FiberPlugin {
  val logic = during build new Area {
    if (enabled) {
      val io = host[J2ExternalService].external
      val s  = host[J2ScheduleService].schedule
      val pc = host[J2ArchitecturalService].architectural
      val d  = host[J2DecodeService].decode
      val f  = host[J2FetchService].fetch
      val t  = host[J2TrapService].trap
      io.pc                := pc.pc
      io.sr                := pc.status.asUInt
      io.sleep             := t.sleeping
      io.retired           := s.advance && d.control.dispatch
      io.illegal           := s.advance && !d.legal
      io.debugBreak        := s.advance && d.control.debug
      io.debugState        := 0
      io.debugOpcode       := f.opcode
      io.debugSlotIllegal  := d.delaySlotIllegal
      io.debugEventPending := t.internalFault
    }
  }
}
