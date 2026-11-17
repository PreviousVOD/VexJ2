package j2.bus

import spinal.core._
import spinal.lib._

case class J2ReadResponse() extends Bundle {
  val data  = Bits(32 bits)
  val error = Bool()
}

/** Target-independent, ordered read bursts. Addresses are byte addresses; length is the number of
  * 32-bit words minus one. One burst may be outstanding. The producer holds each response until
  * accepted; last terminates the burst, including an early error. The consumer drains errors
  * through last.
  */
case class J2ReadBurst(lengthWidth: Int) extends Bundle with IMasterSlave {
  val cmd = Stream(new Bundle {
    val address = UInt(32 bits)
    val length  = UInt(lengthWidth bits)
  })
  val rsp = Stream(Fragment(J2ReadResponse()))
  override def asMaster(): Unit = {
    master(cmd)
    slave(rsp)
  }
}
