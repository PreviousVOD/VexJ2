package j2.misc

import j2.core._
import spinal.core._
import spinal.lib.misc.plugin.FiberPlugin

final class J2TrapPlugin extends FiberPlugin with J2TrapService {
  val allocation = during build new Area {
    val port                        = new J2TrapPort
    val sleeping, inService, halted = RegInit(False)
    port.sleeping  := sleeping
    port.inService := inService
    port.halted    := halted
  }
  override def trap: J2TrapPort = allocation.get.port

  val logic = during build new Area {
    val a        = allocation.get
    val io       = host[J2ExternalService].external
    val s        = host[J2ScheduleService].schedule
    val m        = host[J2MemoryService].memory
    val f        = host[J2FetchService].fetch
    val d        = host[J2DecodeService].decode
    val pc       = host[J2ArchitecturalService].architectural
    val internal = m.fault || f.fault
    val wake = io.event.valid && (io.event.payload.command =/= 0 ||
      (!d.maskInterrupt && (io.event.payload.bypassMask ||
        io.event.payload.level > pc.status.interruptMask)))
    a.port.internalFault  := internal
    a.port.acceptInternal := internal && d.eventAck
    a.port.enterSleep     := d.control.sleep && !wake && !internal
    io.event.ready        := d.eventAck && !internal && !a.inService
    io.eventAck           := io.event.ready
    when(s.advance) {
      when(a.port.enterSleep)(a.sleeping                  := True)
      when(a.port.acceptInternal)(a.inService             := True)
      when(a.inService && d.control.dispatch)(a.inService := False)
    }
    when(a.sleeping && (wake || internal))(a.sleeping := False)
    // A second fault while entering the handler must quiesce until reset.
    when(m.entryFault || f.entryFault)(a.halted := True)
  }
}
