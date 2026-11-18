package j2.execute

import j2.core._
import spinal.core._
import spinal.lib.misc.plugin.FiberPlugin

final class J2MemoryPlugin extends FiberPlugin with J2MemoryService {
  val allocation = during build new Area {
    val port                           = new J2MemoryPort
    val wbData, maData                 = RegInit(U(0, 32 bits))
    val wbValid, maValid               = RegInit(True)
    val pending, active, locked, fault = RegInit(False)
    val faultPc                        = RegInit(U(0, 32 bits))
    port.read      := wbData
    port.readValid := wbValid
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
    val ma    = s.state.maRequest
    val ex    = s.state.ex
    val issue = s.advance && s.state.exAction.memoryIssue && !a.active && !a.fault
    val misaligned =
      (ex.memorySize === J2MemSize.WORD && e.memoryAddress(0)) ||
        (ex.memorySize === J2MemSize.LONG && e.memoryAddress(1 downto 0) =/= 0)
    a.port.issued     := issue
    a.port.entryFault := t.inService && ((a.active && io.ERR) || (issue && misaligned))

    io.CYC  := a.active || a.locked
    io.STB  := a.active
    io.WE   := ma.write
    io.ADR  := ma.address
    io.LOCK := a.locked
    io.DAT_MOSI := ma.size.mux(
      J2MemSize.BYTE -> Cat(
        ma.data(7 downto 0),
        ma.data(7 downto 0),
        ma.data(7 downto 0),
        ma.data(7 downto 0)
      ).asBits,
      J2MemSize.WORD -> Cat(ma.data(15 downto 0), ma.data(15 downto 0)).asBits,
      J2MemSize.LONG -> ma.data.asBits
    )
    io.SEL := ma.size.mux(
      J2MemSize.BYTE -> (U(8, 4 bits) >> ma.address(1 downto 0)).asBits,
      J2MemSize.WORD -> Mux(ma.address(1), B"0011", B"1100"),
      J2MemSize.LONG -> B"1111"
    )
    val byte = ma
      .address(1 downto 0)
      .mux(
        0 -> io.DAT_MISO(31 downto 24),
        1 -> io.DAT_MISO(23 downto 16),
        2 -> io.DAT_MISO(15 downto 8),
        3 -> io.DAT_MISO(7 downto 0)
      )
    val word = Mux(ma.address(1), io.DAT_MISO(15 downto 0), io.DAT_MISO(31 downto 16))
    val aligned = ma.size.mux(
      J2MemSize.BYTE -> byte.asSInt.resize(32).asUInt,
      J2MemSize.WORD -> word.asSInt.resize(32).asUInt,
      J2MemSize.LONG -> io.DAT_MISO.asUInt
    )
    // MA captures the response even while slots are stopped. ERR wins over ACK;
    // its invalid result travels to WB without architectural writeback.
    when(a.active && (io.ACK || io.ERR)) {
      a.maValid := !io.ERR
      when(io.ERR)(a.fault := True)
      a.maData  := aligned
      a.pending := True
      a.active  := False
    }
    when(s.advance) {
      // The same slot moves MA control/metadata into WB in J2PipelineLogic.
      when(a.pending) {
        a.wbData  := a.maData
        a.wbValid := a.maValid
        a.pending := False
      }
      when(issue) {
        a.active := !misaligned
        when(misaligned) {
          a.fault   := True
          a.maValid := False
          a.pending := True
          a.maData  := 0
        }
        a.faultPc := s.state.exMetadata.resumePc
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
