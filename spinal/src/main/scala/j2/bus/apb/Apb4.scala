package j2.bus.apb

import spinal.core._
import spinal.lib._

/** IHI0024E APB4 profile: one select, PREADY, PSLVERR, PSTRB and PPROT are present. PCLK/PRESETn
  * are supplied by the enclosing Spinal clock domain. APB5 extensions are absent.
  */
case class Apb4Config(addressWidth: Int = 12, dataWidth: Int = 32) {
  require(addressWidth > 0 && addressWidth <= 32)
  require(Set(8, 16, 32)(dataWidth))
  require(addressWidth >= log2Up(dataWidth / 8))
  def bytes: Int = dataWidth / 8
}

case class Apb4(config: Apb4Config) extends Bundle with IMasterSlave {
  val PADDR           = UInt(config.addressWidth bits)
  val PSEL            = Bits(1 bits)
  val PENABLE, PWRITE = Bool()
  val PWDATA, PRDATA  = Bits(config.dataWidth bits)
  val PSTRB           = Bits(config.bytes bits)
  val PPROT           = Bits(3 bits)
  val PREADY, PSLVERR = Bool()
  def access: Bool    = PSEL(0) && PENABLE
  def fire: Bool      = access && PREADY
  override def asMaster(): Unit = {
    out(PADDR, PSEL, PENABLE, PWRITE, PWDATA, PSTRB, PPROT)
    in(PREADY, PRDATA, PSLVERR)
  }
}
