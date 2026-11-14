package j2.bus

import spinal.core._
import spinal.lib._
import spinal.lib.bus.wishbone._

final class J2WbLoopback extends Component {
  val io = new Bundle {
    val bus = slave(J2Wishbone())
  }

  private val cycle = new J2WbClassicCycle(io.bus)

  io.bus.DAT_MISO := B(0, 32 bits)
  io.bus.ERR := False
}
