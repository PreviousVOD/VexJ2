package j2.execute

import j2.core._
import spinal.core._
import spinal.lib.misc.plugin.FiberPlugin

final class J2MemoryPlugin extends FiberPlugin with J2MemoryService {
  val allocation = during build new Area {
    val port                           = new J2MemoryPort
    val read, next                     = RegInit(U(0, 32 bits))
    val readValid, nextValid           = RegInit(True)
    val pending, active, locked, fault = RegInit(False)
    val address, writeData, faultPc    = RegInit(U(0, 32 bits))
    val write                          = RegInit(False)
    val size                           = RegInit(J2MemSize.BYTE)
    port.read      := read
    port.readValid := readValid
    port.active    := active
    port.fault     := fault
    port.faultPc   := faultPc
  }
  override def memory: J2MemoryPort = allocation.get.port

  val logic = during build new Area {
    val a     = allocation.get
    val io    = host[J2ExternalService].external.dbus
    val s     = host[J2ScheduleService].schedule
    val e     = host[J2ExecuteService].execute
    val t     = host[J2TrapService].trap
    val ex    = s.state.ex1
    val issue = s.advance && s.state.ex1Stall.memoryIssue && !a.active && !a.fault
    val misaligned =
      (ex.memorySize === J2MemSize.WORD && e.memoryAddress(0)) ||
        (ex.memorySize === J2MemSize.LONG && e.memoryAddress(1 downto 0) =/= 0)
    a.port.issued     := issue
    a.port.entryFault := t.inService && ((a.active && io.ERR) || (issue && misaligned))

    io.CYC  := a.active || a.locked
    io.STB  := a.active
    io.WE   := a.write
    io.ADR  := a.address
    io.LOCK := a.locked
    io.DAT_MOSI := a.size.mux(
      J2MemSize.BYTE -> Cat(
        a.writeData(7 downto 0),
        a.writeData(7 downto 0),
        a.writeData(7 downto 0),
        a.writeData(7 downto 0)
      ).asBits,
      J2MemSize.WORD -> Cat(a.writeData(15 downto 0), a.writeData(15 downto 0)).asBits,
      J2MemSize.LONG -> a.writeData.asBits
    )
    io.SEL := a.size.mux(
      J2MemSize.BYTE -> (U(8, 4 bits) >> a.address(1 downto 0)).asBits,
      J2MemSize.WORD -> Mux(a.address(1), B"0011", B"1100"),
      J2MemSize.LONG -> B"1111"
    )
    val byte = a
      .address(1 downto 0)
      .mux(
        0 -> io.DAT_MISO(31 downto 24),
        1 -> io.DAT_MISO(23 downto 16),
        2 -> io.DAT_MISO(15 downto 8),
        3 -> io.DAT_MISO(7 downto 0)
      )
    val word = Mux(a.address(1), io.DAT_MISO(15 downto 0), io.DAT_MISO(31 downto 16))
    val aligned = a.size.mux(
      J2MemSize.BYTE -> byte.asSInt.resize(32).asUInt,
      J2MemSize.WORD -> word.asSInt.resize(32).asUInt,
      J2MemSize.LONG -> io.DAT_MISO.asUInt
    )
    // ERR terminates the request and wins over ACK; invalid W never writes back.
    when(a.active && (io.ACK || io.ERR)) {
      a.nextValid := !io.ERR
      when(io.ERR)(a.fault := True)
      a.next      := aligned
      a.pending   := True
      a.active    := False
    }
    when(s.advance) {
      when(a.pending) {
        a.read      := a.next
        a.readValid := a.nextValid
        a.pending   := False
      }
      when(issue) {
        a.active := !misaligned
        when(misaligned) {
          a.fault     := True
          a.nextValid := False
          a.pending   := True
          a.next      := 0
        }
        a.faultPc   := s.state.ex1Metadata.resumePc
        a.address   := e.memoryAddress
        a.write     := ex.memoryWrite
        a.writeData := e.memoryWriteData
        a.size      := ex.memorySize
      }
      a.locked := ex.memoryLock
      when(t.acceptInternal) {
        a.fault  := False
        a.locked := False
      }
    }
    when(t.halted) {
      a.active := False
      a.locked := False
    }
  }
}
