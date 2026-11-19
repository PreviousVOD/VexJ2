package j2.periph

import j2.bus._
import spinal.core._
import spinal.lib._
import spinal.lib.memory.sdram.sdr.{EG4S20, SdramInterface}

/** AHB boundaries around proven leaf IP. The CPU and matrix never expose Wishbone. */
final class J2Rom(initFile: String) extends Component {
  val io             = new Bundle { val bus = slave(J2Ahb.subordinate()) }
  private val bridge = new J2AhbToWishbone
  private val memory = new J2WishboneRom(initFile)
  bridge.io.ahb <> io.bus
  memory.io.bus <> bridge.io.wb
}
final class J2Sram extends Component {
  val io             = new Bundle { val bus = slave(J2Ahb.subordinate()) }
  private val bridge = new J2AhbToWishbone
  private val memory = new J2WishboneSram
  bridge.io.ahb <> io.bus
  memory.io.bus <> bridge.io.wb
}
final class J2Sdram extends Component {
  val io = new Bundle {
    val bus   = slave(J2Ahb.subordinate())
    val sdram = master(SdramInterface(EG4S20.layout))
  }
  private val bridge = new J2AhbToWishbone
  private val memory = new J2WishboneSdram
  bridge.io.ahb <> io.bus
  memory.io.bus <> bridge.io.wb
  io.sdram <> memory.io.sdram
}
