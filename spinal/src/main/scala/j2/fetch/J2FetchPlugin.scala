package j2.fetch

import j2.isa.J2Predecoder
import j2.core._
import spinal.core._
import spinal.lib.misc.plugin.FiberPlugin

final class J2FetchPlugin extends FiberPlugin with J2FetchService {
  val allocation = during build new Area {
    val port          = new J2FetchPort
    val instruction   = RegInit(U(0, 16 bits))
    val instructionPc = RegInit(U(0, 32 bits))
    val next          = RegInit(U(0, 16 bits))
    val predecoder    = new J2Predecoder
    predecoder.io.instruction := next
    val predecodeAddress        = RegInit(U(0, 8 bits))
    val legal, delaySlotIllegal = RegInit(False)
    val pending, active         = RegInit(False)
    val address                 = RegInit(U(0, 32 bits))
    val fault, nextFault        = RegInit(False)
    val faultPc                 = RegInit(U(0, 32 bits))
    port.opcode           := instruction
    port.predecodeAddress := predecodeAddress
    port.legal            := legal
    port.delaySlotIllegal := delaySlotIllegal
    port.pc               := instructionPc
    port.active           := active
    port.fault            := fault
    port.faultPc          := faultPc
  }
  override def fetch: J2FetchPort = allocation.get.port

  val logic = during build new Area {
    val a       = allocation.get
    val io      = host[J2ExternalService].external.ibus
    val d       = host[J2DecodeService].decode
    val s       = host[J2ScheduleService].schedule
    val e       = host[J2ExecuteService].execute
    val pc      = host[J2ArchitecturalService].architectural
    val t       = host[J2TrapService].trap
    val issue   = s.advance && d.instructionIssue && !a.active
    val address = Mux(d.instructionAddress, e.zbus, pc.sequentialPc)
    a.port.issued := issue
    a.port.entryFault := t.inService &&
      ((a.active && io.ERR) || (issue && address(0)))

    io.CYC      := a.active
    io.STB      := a.active
    io.WE       := False
    io.ADR      := a.address
    io.SEL      := B"1111"
    io.DAT_MOSI := 0
    io.LOCK     := False
    when(a.active && (io.ACK || io.ERR)) {
      a.nextFault := io.ERR
      a.next      := Mux(io.ERR, U(0x0009, 16 bits), io.DAT_MISO(15 downto 0).asUInt)
      a.pending   := True
      a.active    := False
    }
    when(s.advance) {
      when(d.startInstruction && a.fault && d.delaySlot) {
        a.faultPc := pc.metadata.resumePc
      }
      // A response is consumed only when ID advances, including fault metadata.
      when(a.pending) {
        a.instruction := a.next
        // The response buffer is stable before ID consumes it. Classify there
        // and latch with the opcode, keeping decode off the half-cycle ROM path.
        a.predecodeAddress := a.predecoder.io.address
        a.legal            := a.predecoder.io.legal
        a.delaySlotIllegal := a.predecoder.io.delaySlotIllegal
        a.instructionPc    := a.address
        when(a.nextFault) {
          a.fault   := True
          a.faultPc := a.address
        }
        a.pending := False
      }
      when(issue) {
        a.address := address
        a.active  := !address(0)
        when(address(0)) {
          a.next      := 0x0009
          a.nextFault := True
          a.pending   := True
        }
      }
      when(t.acceptInternal)(a.fault := False)
    }
    when(t.halted)(a.active := False)
  }
}
