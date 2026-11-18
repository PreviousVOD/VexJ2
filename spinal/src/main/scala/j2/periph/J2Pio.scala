package j2.periph

import j2.bus.J2Wishbone
import spinal.core._
import spinal.lib._
import spinal.lib.bus.wishbone.WishboneGpio
import spinal.lib.io.TriStateArray

final class J2Pio extends Component {
  val io = new Bundle {
    val bus  = slave(J2Wishbone())
    val gpio = master(TriStateArray(32))
  }
  private val controller = new WishboneGpio(J2Wishbone.config, 32)
  J2Wishbone.connectToWordAddressed(io.bus, controller.io.wb, io.bus.ADR(11 downto 0))
  io.gpio <> controller.io.gpio
}
