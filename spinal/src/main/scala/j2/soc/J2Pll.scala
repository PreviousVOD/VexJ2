package j2.soc

import spinal.core._

final class Eg4Pll(feedbackDivider: Int, outputDivider: Int) extends BlackBox {
  require(feedbackDivider >= 1 && feedbackDivider <= 128)
  require(outputDivider >= 1 && outputDivider <= 128)
  val refclk = in Bool ()
  val reset = in Bool ()
  val load_reg = in Bool ()
  val stdby = in Bool ()
  val extlock = out Bool ()
  val fbclk = in Bool ()
  val clkc = out Bits (5 bits)
  val psdone = out Bool ()
  val psclk = in Bool ()
  val psdown = in Bool ()
  val psstep = in Bool ()
  val psclksel = in Bits (3 bits)
  val `do` = out Bits (8 bits)
  val dclk = in Bool ()
  val dcs = in Bool ()
  val dwe = in Bool ()
  val di = in Bits (8 bits)
  val daddr = in Bits (6 bits)
  setDefinitionName("EG_PHY_PLL")
  addGeneric("DPHASE_SOURCE", "DISABLE")
  addGeneric("DYNCFG", "DISABLE")
  addGeneric("FIN", "24.000")
  addGeneric("FEEDBK_MODE", "NORMAL")
  // The divider calculation assumes VCO feedback: Fout = Fin * FB / OUT.
  // CLKC0_EXT also multiplies the VCO by OUT, yielding Fin * FB at CLKC0.
  addGeneric("FEEDBK_PATH", "VCO_PHASE_0")
  addGeneric("STDBY_ENABLE", "ENABLE")
  addGeneric("PLLRST_ENA", "ENABLE")
  addGeneric("SYNC_ENABLE", "DISABLE")
  addGeneric("DERIVE_PLL_CLOCKS", "DISABLE")
  addGeneric("GEN_BASIC_CLOCK", "DISABLE")
  addGeneric("GMC_GAIN", 2)
  addGeneric("ICP_CURRENT", 9)
  addGeneric("KVCO", 2)
  addGeneric("LPF_CAPACITOR", 1)
  addGeneric("LPF_RESISTOR", 8)
  addGeneric("REFCLK_DIV", 1)
  addGeneric("FBCLK_DIV", feedbackDivider)
  addGeneric("CLKC0_ENABLE", "ENABLE")
  addGeneric("CLKC0_DIV", outputDivider)
  addGeneric("CLKC0_CPHASE", outputDivider - 1)
  addGeneric("CLKC0_FPHASE", 0)
}

final class Eg4Bufg extends BlackBox {
  val i = in Bool ()
  val o = out Bool ()
  setDefinitionName("EG_LOGIC_BUFG")
}
