package j2.core.misc

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
    val event    = host[J2InterruptService].interrupt
    val s        = host[J2ScheduleService].schedule
    val m        = host[J2MemoryService].memory
    val f        = host[J2FetchService].fetch
    val d        = host[J2DecodeService].decode
    val pc       = host[J2ArchitecturalService].architectural
    val internal = m.fault || f.fault
    val wake = event.valid && (event.payload.command =/= 0 ||
      (!d.maskInterrupt && (event.payload.bypassMask ||
        event.payload.level > pc.status.interruptMask)))
    a.port.internalFault  := internal
    a.port.acceptInternal := internal && d.eventStart && !a.inService
    a.port.enterSleep     := d.control.sleep && !wake && !internal
    event.ready           := d.eventStart && !internal && !a.inService
    when(s.advance) {
      when(a.port.enterSleep)(a.sleeping := True)
      when(d.systemStart || (d.startInstruction && f.opcode(15 downto 8) === 0xc3))(
        a.inService := True
      )
      when(a.inService && d.control.dispatch && !d.nextIdStall)(a.inService := False)
    }
    when(a.sleeping && (wake || internal))(a.sleeping := False)
    // A second fault while entering the handler must quiesce until reset.
    when(m.entryFault || f.entryFault)(a.halted := True)
  }
}
