package j2.execute

import j2.core._
import j2.bus.ahb5._
import spinal.core._
import spinal.lib.misc.plugin.FiberPlugin

final class J2MemoryPlugin extends FiberPlugin with J2MemoryService {
  val allocation = during build new Area {
    val port                           = new J2MemoryPort
    val wbData, maData                 = RegInit(U(0, 32 bits))
    val wbValid, maValid               = RegInit(True)
    val pending, active, locked, fault = RegInit(False)
    val addressSent                    = RegInit(False)
    val lockFinished                   = RegInit(False)
    val faultPc                        = RegInit(U(0, 32 bits))
    port.read      := wbData
    port.readValid := wbValid
    port.active    := active
    port.locked    := locked
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
    a.port.issued := issue
    a.port.entryFault := t.inService && ((a.active && a.addressSent && io.HREADY && io.HRESP) || (issue && misaligned))

    io.address.HADDR  := ma.address
    io.address.HWRITE := ma.write
    io.address.HSIZE := ma.size.mux(
      J2MemSize.BYTE -> U(0, 3 bits),
      J2MemSize.WORD -> U(1, 3 bits),
      J2MemSize.LONG -> U(2, 3 bits)
    )
    io.address.HBURST := Ahb5Burst.SINGLE
    // Memory may be cached; the peripheral aperture remains non-cacheable.
    io.address.HPROT     := Mux(ma.address(31 downto 24) === 0xff, B"0011", B"1011")
    io.address.HMASTER   := 1
    io.address.HMASTLOCK := a.locked
    io.address.HTRANS    := Mux(a.active && !a.addressSent, Ahb5Trans.NONSEQ, Ahb5Trans.IDLE)
    io.HWDATA := ma.size.mux(
      J2MemSize.BYTE -> Cat(
        ma.data(7 downto 0),
        ma.data(7 downto 0),
        ma.data(7 downto 0),
        ma.data(7 downto 0)
      ).asBits,
      J2MemSize.WORD -> Cat(ma.data(15 downto 0), ma.data(15 downto 0)).asBits,
      J2MemSize.LONG -> ma.data.asBits
    )
    when(a.active && !a.addressSent && io.HREADY)(a.addressSent := True)
    val byte = ma
      .address(1 downto 0)
      .mux(
        0 -> io.HRDATA(31 downto 24),
        1 -> io.HRDATA(23 downto 16),
        2 -> io.HRDATA(15 downto 8),
        3 -> io.HRDATA(7 downto 0)
      )
    val word = Mux(ma.address(1), io.HRDATA(15 downto 0), io.HRDATA(31 downto 16))
    val aligned = ma.size.mux(
      J2MemSize.BYTE -> byte.asSInt.resize(32).asUInt,
      J2MemSize.WORD -> word.asSInt.resize(32).asUInt,
      J2MemSize.LONG -> io.HRDATA.asUInt
    )
    // MA captures the final AHB response even while slots are stopped.
    // An ERROR result travels to WB without architectural writeback.
    when(a.active && a.addressSent && io.HREADY) {
      a.maValid := !io.HRESP
      // Release on completion, even when IF is waiting behind this reservation.
      // Suppress reassertion by the retained EX microstep until it advances.
      when(a.locked && (ma.write || io.HRESP)) {
        a.locked       := False
        a.lockFinished := True
      }
      when(io.HRESP)(a.fault := True)
      a.maData      := aligned
      a.pending     := True
      a.active      := False
      a.addressSent := False
    }
    when(s.advance) {
      // The same slot moves MA control/metadata into WB in J2PipelineLogic.
      when(a.pending) {
        a.wbData  := a.maData
        a.wbValid := a.maValid
        a.pending := False
      }
      when(issue) {
        a.active      := !misaligned
        a.addressSent := False
        when(misaligned) {
          a.fault   := True
          a.maValid := False
          a.pending := True
          a.maData  := 0
        }
        a.faultPc := s.state.exMetadata.resumePc
      }
      when(!ex.memoryLock) { a.locked := False; a.lockFinished := False }
        .elsewhen(!a.lockFinished)(a.locked := True)
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
