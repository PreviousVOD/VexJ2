package j2.vendor.anlogic

import spinal.core._

final class Eg4SdramPhy extends BlackBox {
  val clk   = in Bool ()
  val ras_n = in Bool ()
  val cas_n = in Bool ()
  val we_n  = in Bool ()
  val addr  = in Bits (11 bits)
  val ba    = in Bits (2 bits)
  val dq    = inout(Analog(Bits(32 bits)))
  val cs_n  = in Bool ()
  val dm0   = in Bool ()
  val dm1   = in Bool ()
  val dm2   = in Bool ()
  val dm3   = in Bool ()
  val cke   = in Bool ()
  setDefinitionName("EG_PHY_SDRAM_2M_32")
}
