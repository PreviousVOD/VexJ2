package j2.bus

import spinal.lib.bus.wishbone._

object J2Wishbone {
  val config: WishboneConfig = WishboneConfig(
    addressWidth = 32,
    dataWidth = 32,
    selWidth = 4,
    useSTALL = false,
    useLOCK = true,
    useERR = true
  )

  def apply(): Wishbone = Wishbone(config)
}
