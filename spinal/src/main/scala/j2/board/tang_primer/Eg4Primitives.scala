package j2.board.tang_primer

import spinal.core._

final class Eg4GpioPad extends BlackBox {
  val ipad   = in Bool ()
  val opad   = out Bool ()
  val bpad   = inout(Analog(Bool()))
  val rst    = in Bool ()
  val ce     = in Bool ()
  val isclk  = in Bool ()
  val ipclk  = in Bool ()
  val osclk  = in Bool ()
  val opclk  = in Bool ()
  val ts     = in Bool ()
  val doData = in Bits (4 bits)
  doData.setName("do")
  val di  = out Bool ()
  val diq = out Bits (4 bits)
  setDefinitionName("EG_PHY_PAD")
  addGeneric("MODE", "BI")
  addGeneric("TSMUX", "TS")
  addGeneric("IOTYPE", "LVCMOS33")
  addGeneric("DRIVE", "12")
}

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
