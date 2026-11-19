package j2.bus

import j2.bus.ahb5._
import spinal.core._
import spinal.lib._

/** System BIU at a shared bridge boundary, deliberately outside the AMBA IP. The current policy is
  * round-robin service with persistent atomic ownership. Protocol sequencing, bursts and HMASTLOCK
  * are implemented by the generic AHB arbiter. HMASTER reaches the bridge unchanged; no implicit
  * CPU pairing exists. Future system access policy belongs here, not in the AHB routing matrix.
  */
final class J2Biu(config: Ahb5Config, managerCount: Int) extends Component {
  val io = new Bundle {
    val managers    = Vec(slave(Ahb5(config)), managerCount)
    val subordinate = master(Ahb5(config))
  }
  private val arbiter = new Ahb5SubordinateArbiter(config, managerCount)
  arbiter.io.managers <> io.managers
  io.subordinate <> arbiter.io.subordinate
}
