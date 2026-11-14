package j2.bus

import spinal.core._
import spinal.lib._
import spinal.lib.bus.wishbone._

final class J2WbRouter(val ramBytes: BigInt) extends Component {
  require(ramBytes > 0)

  val io = new Bundle {
    val input = slave(J2Wishbone())
    val ram = master(J2Wishbone())
    val external = master(J2Wishbone())
  }

  private val toRam = io.input.ADR.resize(64) < U(ramBytes, 64 bits)

  private def idle(bus: Wishbone): Unit = {
    bus.CYC := False
    bus.STB := False
    bus.WE := False
    bus.ADR := 0
    bus.DAT_MOSI := B(0, 32 bits)
    bus.SEL := B"0000"
    bus.LOCK := False
  }

  idle(io.ram)
  idle(io.external)

  when(toRam) {
    io.ram.CYC := io.input.CYC
    io.ram.STB := io.input.STB
    io.ram.WE := io.input.WE
    io.ram.ADR := io.input.ADR
    io.ram.DAT_MOSI := io.input.DAT_MOSI
    io.ram.SEL := io.input.SEL
    io.ram.LOCK := io.input.LOCK
  } otherwise {
    io.external.CYC := io.input.CYC
    io.external.STB := io.input.STB
    io.external.WE := io.input.WE
    io.external.ADR := io.input.ADR
    io.external.DAT_MOSI := io.input.DAT_MOSI
    io.external.SEL := io.input.SEL
    io.external.LOCK := io.input.LOCK
  }

  io.input.ACK := Mux(toRam, io.ram.ACK, io.external.ACK)
  io.input.DAT_MISO := Mux(toRam, io.ram.DAT_MISO, io.external.DAT_MISO)
  io.input.ERR := Mux(toRam, io.ram.ERR, io.external.ERR)
  io.input.STALL := Mux(toRam, io.ram.STALL, io.external.STALL)
}
