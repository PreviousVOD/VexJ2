package j2.bus

import spinal.core._
import spinal.lib._

/** Preserve the validated CDC/MIG backend while changing its system-side protocol. */
final class J2AhbDdrBridge(
    busClock: ClockDomain,
    memoryClock: ClockDomain,
    base: BigInt = 0x80000000L,
    size: BigInt = 0x10000000L,
    timeoutBits: Int = 20
) extends Component {
  val io = new Bundle {
    val bus        = slave(J2Ahb.subordinate())
    val native     = master(J2MigPort())
    val calibrated = in Bool ()
  }
  private val adapter = busClock(new J2AhbToWishbone)
  private val bridge  = new J2WishboneDdrBridge(busClock, memoryClock, base, size, timeoutBits)
  adapter.io.ahb <> io.bus
  bridge.io.bus <> adapter.io.wb
  io.native <> bridge.io.native
  bridge.io.calibrated := io.calibrated
}
