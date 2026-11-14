package j2.bus

import spinal.core._
import spinal.lib._
import spinal.lib.bus.wishbone._

final class J2SocBusRouter(val ramBytes: BigInt) extends Component {
  val io = new Bundle {
    val input = slave(J2Wishbone())
    val ram = master(J2Wishbone())
    val pio = master(J2Wishbone())
    val uart = master(J2Wishbone())
    val external = master(J2Wishbone())
  }

  private val address = io.input.ADR.resize(64)
  private val toRam = address < U(ramBytes, 64 bits)
  private val toPio = (address & U(0xfffffff0L, 64 bits)) === U(0xabcd0000L, 64 bits)
  private val toUart = (address & U(0xfffffff0L, 64 bits)) === U(0xabcd0100L, 64 bits)

  private def idle(bus: Wishbone): Unit = {
    bus.CYC := False
    bus.STB := False
    bus.WE := False
    bus.ADR := 0
    bus.DAT_MOSI := B(0, 32 bits)
    bus.SEL := B"0000"
    bus.LOCK := False
  }

  Seq(io.ram, io.pio, io.uart, io.external).foreach(idle)

  private def drive(bus: Wishbone): Unit = {
    bus.CYC := io.input.CYC
    bus.STB := io.input.STB
    bus.WE := io.input.WE
    bus.ADR := io.input.ADR
    bus.DAT_MOSI := io.input.DAT_MOSI
    bus.SEL := io.input.SEL
    bus.LOCK := io.input.LOCK
  }

  when(toRam)(drive(io.ram))
    .elsewhen(toPio)(drive(io.pio))
    .elsewhen(toUart)(drive(io.uart))
    .otherwise(drive(io.external))

  io.input.ACK := Mux(
    toRam,
    io.ram.ACK,
    Mux(toPio, io.pio.ACK, Mux(toUart, io.uart.ACK, io.external.ACK))
  )
  io.input.DAT_MISO := Mux(
    toRam,
    io.ram.DAT_MISO,
    Mux(toPio, io.pio.DAT_MISO, Mux(toUart, io.uart.DAT_MISO, io.external.DAT_MISO))
  )
  io.input.ERR :=
    Mux(toRam, io.ram.ERR, Mux(toPio, io.pio.ERR, Mux(toUart, io.uart.ERR, io.external.ERR)))
}
