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

final class Eg4GpioPad extends BlackBox {
  val ipad   = in Bool ()
  val opad   = out Bool ()
  val bpad   = inout(Analog(Bool()))
  val rst    = in Bool ()
  val ce     = in Bool ()
  val isclk  = in Bool ()
  val ipclk  = in Bool ()
  val osclk  = in Bool ()
  val opclk  = in Bool ()
  val ts     = in Bool ()
  val doData = in Bits (4 bits)
  doData.setName("do")
  val di  = out Bool ()
  val diq = out Bits (4 bits)
  setDefinitionName("EG_PHY_PAD")
  addGeneric("MODE", "BI")
  addGeneric("TSMUX", "TS")
  addGeneric("IOTYPE", "LVCMOS33")
  addGeneric("DRIVE", "12")
}
