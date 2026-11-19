package j2.bus

import j2.bus.ahb5._
import spinal.core._
import spinal.lib._

/** SH-2 system profile: byte-addressed, BE32 lanes, one ID per CPU port. */
object J2Ahb {
  val config                = Ahb5Config(addressWidth = 32, dataWidth = 32, masterWidth = 4)
  def manager(): Ahb5Master = Ahb5Master(config)
  def subordinate(): Ahb5   = Ahb5(config)
  def select(address: UInt, size: UInt): Bits = size.mux(
    U(0, 3 bits) -> (U(8, 4 bits) >> address(1 downto 0)).asBits,
    U(1, 3 bits) -> Mux(address(1), B"0011", B"1100"),
    default -> B"1111"
  )
  def connect(source: Ahb5Master, target: Ahb5): Unit = {
    target.address := source.address
    target.HSEL    := True
    target.HREADY  := target.HREADYOUT
    target.HWDATA  := source.HWDATA
    source.HREADY  := target.HREADYOUT
    source.HRESP   := target.HRESP
    source.HRDATA  := target.HRDATA
  }
}
