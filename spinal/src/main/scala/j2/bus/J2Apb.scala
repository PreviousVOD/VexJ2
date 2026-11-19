package j2.bus

import spinal.core._
import spinal.lib.bus.amba3.apb._

object J2Apb {
  val config        = Apb3Config(12, 32, useSlaveError = true)
  def apply(): Apb3 = Apb3(config)

  /** The APB matrix decodes the complete address before local offset truncation. */
  def connect(source: Apb3, target: Apb3): Unit = {
    target.PADDR     := source.PADDR.resized
    target.PSEL      := source.PSEL
    target.PENABLE   := source.PENABLE
    target.PWRITE    := source.PWRITE
    target.PWDATA    := source.PWDATA
    source.PREADY    := target.PREADY
    source.PRDATA    := target.PRDATA
    source.PSLVERROR := (if (target.config.useSlaveError) target.PSLVERROR else False)
  }
}
