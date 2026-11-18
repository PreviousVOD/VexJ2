package j2.misc

import j2.core._
import spinal.core._
import spinal.lib.misc.plugin.FiberPlugin

final class J2ArchitecturalPlugin extends FiberPlugin with J2ArchitecturalService {
  val allocation = during build new Area {
    val port                           = new J2ArchitecturalPort
    val pc                             = RegInit(U(0, 32 bits))
    val status                         = Reg(new J2Status)
    val operationResumePc, operationPc = RegInit(U(0, 32 bits))
    port.pc           := pc
    port.sequentialPc := pc + 2
    port.status       := status
  }
  override def architectural: J2ArchitecturalPort = allocation.get.port

  val logic = during build new Area {
    val a          = allocation.get
    val nextStatus = a.port.nextStatus
    val s          = host[J2ScheduleService].schedule
    val m          = host[J2MemoryService].memory
    val f          = host[J2FetchService].fetch
    val d          = host[J2DecodeService].decode
    val e          = host[J2ExecuteService].execute
    val t          = host[J2TrapService].trap
    nextStatus := a.status
    val srSelect = Mux(
      s.state.wbAction.srWriteW && m.readValid,
      J2SrSelect.WBUS,
      Mux(m.fault, J2SrSelect.PREV, s.state.exAction.srSelect)
    )

    switch(srSelect) {
      is(J2SrSelect.WBUS) {
        nextStatus := J2Status.fromUInt(m.read)
      }
      is(J2SrSelect.ZBUS) {
        nextStatus := J2Status.fromUInt(e.zbus)
      }
      is(J2SrSelect.DIV0U) {
        nextStatus.m := False
        nextStatus.q := False
        nextStatus.t := False
      }
      is(J2SrSelect.ARITH) {
        nextStatus := e.arithmeticSr
      }
      is(J2SrSelect.LOGIC) {
        nextStatus := e.logicSr
      }
      is(J2SrSelect.INT_MASK) {
        nextStatus.interruptMask := d.interruptLevel
      }
      is(J2SrSelect.SET_T) {
        switch(s.state.exAction.tSelect) {
          is(J2TSelect.CLEAR)(nextStatus.t := False)
          is(J2TSelect.SET)(nextStatus.t   := True)
          is(J2TSelect.SHIFT)(nextStatus.t := e.shiftT)
          is(J2TSelect.CARRY)(nextStatus.t := e.arithmeticResult(32))
        }
      }
      default {}
    }

    // Architectural addresses remain distinct from the speculative microcode PC.
    val resumePc = Mux(d.delaySlot, Mux(s.state.exAction.pcWriteZ, e.zbus, a.pc), f.pc + 2)
    a.port.metadata.resumePc := Mux(d.startInstruction, resumePc, a.operationResumePc)
    a.port.metadata.pc       := Mux(d.startInstruction, f.pc, a.operationPc)
    when(s.advance) {
      when(d.startInstruction) {
        a.operationResumePc := resumePc
        a.operationPc       := f.pc
      }
      when(s.state.exAction.pcWriteZ && !m.fault) {
        a.pc := e.zbus
      } elsewhen (d.incrementPc) {
        a.pc := a.port.sequentialPc
      }
      a.status := nextStatus
      when(t.acceptInternal) {
        // ERROR microcode subtracts two in its first EX slot.
        a.pc := Mux(m.fault, m.faultPc, f.faultPc) + 2
      }
    }
    when(ClockDomain.current.isResetActive) {
      a.status.t             := False
      a.status.s             := False
      a.status.q             := False
      a.status.m             := False
      a.status.interruptMask := 0xf
    }
  }
}
