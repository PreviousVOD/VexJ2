package j2.bus

import spinal.core._
import j2.bus.apb._

object J2Apb {
  val config        = Apb4Config(12, 32)
  def apply(): Apb4 = Apb4(config)

  /** The APB matrix decodes the complete address before local offset truncation. */
  def connect(source: Apb4, target: Apb4): Unit = {
    require(source.config.dataWidth == target.config.dataWidth)
    target.PSTRB   := source.PSTRB
    target.PPROT   := source.PPROT
    target.PADDR   := source.PADDR.resized
    target.PSEL    := source.PSEL
    target.PENABLE := source.PENABLE
    target.PWRITE  := source.PWRITE
    target.PWDATA  := source.PWDATA
    source.PREADY  := target.PREADY
    source.PRDATA  := target.PRDATA
    source.PSLVERR := target.PSLVERR
  }
}
