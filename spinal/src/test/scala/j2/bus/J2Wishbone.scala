package j2.bus

import spinal.core._
import spinal.lib.bus.wishbone._

object J2Wishbone {
  val config: WishboneConfig = WishboneConfig(
    addressWidth = 32,
    dataWidth    = 32,
    selWidth     = 4,
    useSTALL     = false,
    useLOCK      = true,
    useERR       = true
  )

  def apply(): Wishbone = Wishbone(config)

  def connectToWordAddressed(source: Wishbone, target: Wishbone): Unit =
    connectToWordAddressed(source, target, source.ADR)

  def connectToWordAddressed(source: Wishbone, target: Wishbone, address: UInt): Unit = {
    target.CYC                                 := source.CYC
    target.STB                                 := source.STB
    target.WE                                  := source.WE
    target.ADR                                 := (address >> 2).resized
    target.DAT_MOSI                            := source.DAT_MOSI
    if (target.config.selWidth > 0) target.SEL := source.SEL
    if (target.config.useLOCK) target.LOCK     := source.LOCK
    source.ACK                                 := target.ACK
    source.DAT_MISO                            := target.DAT_MISO
    if (source.config.useERR) source.ERR       := (if (target.config.useERR) target.ERR else False)
  }
}
