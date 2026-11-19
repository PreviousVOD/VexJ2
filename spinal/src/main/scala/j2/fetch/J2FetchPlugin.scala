package j2.fetch

import j2.isa.J2Predecoder
import j2.core._
import j2.bus.ahb5._
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
    val firstLine               = RegInit(U(0, 72 bits))
    val legal, delaySlotIllegal = RegInit(False)
    val pending, active         = RegInit(False)
    val addressSent             = RegInit(False)
    val address                 = RegInit(U(0, 32 bits))
    val word                    = RegInit(B(0, 32 bits))
    val wordAddress             = RegInit(U(0, 30 bits))
    val wordValid               = RegInit(False)
    val fault, nextFault        = RegInit(False)
    val faultPc                 = RegInit(U(0, 32 bits))
    port.firstLine        := firstLine
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
    val memory  = host[J2MemoryService].memory
    val issue   = s.advance && d.instructionIssue && !a.active
    val address = Mux(d.instructionAddress, e.zbus, pc.sequentialPc)
    // Retain only the unused lower half of a successful sequential word fetch.
    // A redirect always refetches, including a target in the same word; this is
    // a prefetch buffer, not an instruction cache with persistent stale lines.
    val hit = a.wordValid && address(31 downto 2) === a.wordAddress &&
      address(1) && !address(0) && !d.instructionAddress
    a.port.issued := issue && !hit
    a.port.entryFault := t.inService &&
      ((a.active && a.addressSent && io.HREADY && io.HRESP) || (issue && address(0)))

    io.address.HADDR  := a.address & U(0xfffffffcL, 32 bits)
    io.address.HWRITE := False
    io.address.HSIZE  := 2
    io.address.HBURST := Ahb5Burst.SINGLE
    // Cacheable, non-bufferable, privileged instruction access.
    io.address.HPROT     := B"1010"
    io.address.HMASTER   := 0
    io.address.HMASTLOCK := False
    // A pending prefetch must not enter the fabric behind our own TAS reservation.
    io.address.HTRANS := Mux(
      a.active && !a.addressSent && !memory.locked,
      Ahb5Trans.NONSEQ,
      Ahb5Trans.IDLE
    )
    io.HWDATA := 0
    when(a.active && !a.addressSent && !memory.locked && io.HREADY)(a.addressSent := True)
    when(a.active && a.addressSent && io.HREADY) {
      a.nextFault := io.HRESP
      a.next := Mux(
        io.HRESP,
        U(0x0009, 16 bits),
        Mux(a.address(1), io.HRDATA(15 downto 0), io.HRDATA(31 downto 16)).asUInt
      )
      a.word        := io.HRDATA
      a.wordAddress := a.address(31 downto 2)
      a.wordValid   := !io.HRESP && !a.address(1)
      a.pending     := True
      a.active      := False
      a.addressSent := False
    }
    when(s.advance) {
      when(d.startInstruction && a.fault && d.delaySlot) {
        a.faultPc := pc.metadata.resumePc
      }
      // A response is consumed only when ID advances, including fault metadata.
      when(a.pending) {
        a.instruction := a.next
        // The response buffer is stable before ID consumes it. Classify there
        // and latch the first operation with its opcode for direct ID issue.
        a.firstLine        := a.predecoder.io.firstLine
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
        a.address     := address
        a.active      := !hit && !address(0)
        a.addressSent := False
        a.wordValid   := False
        // A non-delayed redirect discards the prefetched fallthrough instruction,
        // including its error. Delayed redirects must retain the slot's fault.
        when(d.instructionAddress && !d.control.delayJump) {
          a.fault := False
        }
        when(hit) {
          a.next      := a.word(15 downto 0).asUInt
          a.nextFault := False
          a.pending   := True
        }
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
