package j2.soc

import j2.bus.J2WbLoopback
import spinal.core._

final class J2TangPrimer(val ramInit: Seq[BigInt] = Seq.empty) extends Component {
  val io = new Bundle {
    val clk24 = in Bool ()
    val rstN = in Bool ()
    val uartRx = in Bool ()
    val uartTx = out Bool ()
    val rgbLed = out Bits (3 bits)
    val pc = out UInt (32 bits)
    val retired = out Bool ()
  }

  private val resetArea = new ClockingArea(
    ClockDomain(clock = io.clk24, reset = !io.rstN)
  ) {
    val resetCount = Reg(UInt(2 bits)) init 3
    when(!io.rstN) {
      resetCount := 3
    } elsewhen (resetCount =/= 0) {
      resetCount := resetCount - 1
    }
    val reset = !io.rstN || resetCount =/= 0
  }

  private val area = new ClockingArea(
    ClockDomain(clock = io.clk24, reset = resetArea.reset)
  ) {
    val soc = new J2Soc(
      ramWords = 8192,
      ramInit = ramInit,
      clockHz = 24000000,
      baud = 19200
    )
    val loopback = new J2WbLoopback

    soc.io.external <> loopback.io.bus
    soc.io.event.valid := False
    soc.io.event.payload.command := 0
    soc.io.event.payload.vector := 0
    soc.io.event.payload.level := 0
    soc.io.event.payload.bypassMask := False
    soc.io.uartRx := io.uartRx
    soc.io.pioIn := 0

    io.uartTx := soc.io.uartTx
    io.rgbLed := soc.io.pioOut(2 downto 0).asBits
    io.pc := soc.io.pc
    io.retired := soc.io.retired
  }
}
