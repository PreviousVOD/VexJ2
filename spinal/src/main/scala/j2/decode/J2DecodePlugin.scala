package j2.decode

import j2.microcode._
import j2.core._
import spinal.core._
import spinal.lib.misc.plugin.FiberPlugin

final class J2DecodePlugin(useEg4Rom: Boolean) extends FiberPlugin with J2DecodeService {
  val allocation = during build new Area {
    val port                    = new J2DecodePort
    val sequencer               = new J2Microsequencer
    val rom: J2MicrocodeRomPort = if (useEg4Rom) new Eg4MicrocodeRom else new J2MicrocodeRom
    val table                   = new J2MicrocodeTable
    port.control            := table.io.control
    port.operation          := sequencer.io.operation
    port.nextIdStall        := sequencer.io.nextIdStall
    port.instructionIssue   := sequencer.io.instructionIssue
    port.instructionAddress := sequencer.io.instructionAddress
    port.incrementPc        := sequencer.io.incrementPc
    port.eventAck           := sequencer.io.eventAck
    port.maskInterrupt      := sequencer.io.maskInterrupt
    port.delaySlot          := sequencer.io.delaySlot
    port.startInstruction   := sequencer.io.startInstruction
    port.interruptLevel     := sequencer.io.interruptLevel
  }
  override def decode: J2DecodePort = allocation.get.port

  val logic = during build new Area {
    val a       = allocation.get
    val f       = host[J2FetchService].fetch
    val s       = host[J2ScheduleService].schedule
    val pc      = host[J2ArchitecturalService].architectural
    val t       = host[J2TrapService].trap
    val mul     = host[J2MultiplyService].multiply
    val event   = host[J2ExternalService].external.event
    val hazards = new J2Hazards
    hazards.io.ex            := a.table.io.control.ex
    hazards.io.exStall       := a.table.io.control.exStall
    hazards.io.state         := s.state
    hazards.io.macStallSense := a.table.io.control.macStallSense
    hazards.io.macBusy       := mul.busy
    a.rom.io.clk             := ClockDomain.current.readClockWire
    a.rom.io.address         := a.sequencer.io.operation.address
    a.table.io.line          := a.rom.io.line
    a.table.io.opcode        := a.sequencer.io.operation.code
    a.table.io.tBcc          := pc.nextStatus.t
    a.table.io.nextIdStall   := a.sequencer.io.nextIdStall
    a.port.legal             := f.legal
    a.port.delaySlotIllegal  := f.delaySlotIllegal
    val q = a.sequencer.io
    val c = a.table.io.control
    q.slot                  := s.advance
    q.dispatch              := c.dispatch
    q.delayJump             := c.delayJump
    q.eventAcknowledge      := c.eventAcknowledge
    q.instruction           := f.opcode
    q.predecodeAddress      := f.predecodeAddress
    q.illegalInstruction    := !f.active && !f.legal
    q.illegalDelaySlot      := !f.active && f.delaySlotIllegal
    q.instructionStall      := False
    q.registerConflict      := hazards.io.registerConflict
    q.macStall              := hazards.io.macStall
    q.interruptBits         := pc.status.interruptMask
    q.interruptLevelCapture := c.interruptLevelCapture
    q.maskInterruptNext     := c.maskInterruptNext
    q.enterDebug            := False
    q.debug                 := c.debug
    q.eventValid            := event.valid || t.internalFault
    q.eventCommand          := Mux(t.internalFault, U(1, 2 bits), event.payload.command)
    q.eventVector           := Mux(t.internalFault, U(9, 8 bits), event.payload.vector)
    q.eventLevel            := event.payload.level
    q.eventBypassMask       := event.payload.bypassMask
    q.id                    := c.id
  }
}
