package j2.board.wukong_v1

import spinal.core._

final class XilinxBufg extends BlackBox {
  val I = in Bool ()
  val O = out Bool ()
  setDefinitionName("BUFG")
}

/** 50 MHz input, 900 MHz VCO, fractional divide by 12.5: exactly 72 MHz. */
final class WukongSocMmcm extends BlackBox {
  val CLKIN1, CLKFBIN, PWRDWN, RST = in Bool ()
  val CLKOUT0, CLKFBOUT, LOCKED    = out Bool ()
  setDefinitionName("MMCME2_BASE")
  addGeneric("CLKIN1_PERIOD", 20.0)
  addGeneric("DIVCLK_DIVIDE", 1)
  addGeneric("CLKFBOUT_MULT_F", 18.0)
  addGeneric("CLKOUT0_DIVIDE_F", 12.5)
  addGeneric("STARTUP_WAIT", "FALSE")
}

/** 50 MHz input, 1 GHz VCO: 166.667 MHz MIG input and 200 MHz IDELAY reference. */
final class WukongDdrMmcm extends BlackBox {
  val CLKIN1, CLKFBIN, PWRDWN, RST       = in Bool ()
  val CLKOUT0, CLKOUT1, CLKFBOUT, LOCKED = out Bool ()
  setDefinitionName("MMCME2_BASE")
  addGeneric("CLKIN1_PERIOD", 20.0)
  addGeneric("DIVCLK_DIVIDE", 1)
  addGeneric("CLKFBOUT_MULT_F", 20.0)
  addGeneric("CLKOUT0_DIVIDE_F", 6.0)
  addGeneric("CLKOUT1_DIVIDE", 5)
  addGeneric("STARTUP_WAIT", "FALSE")
}
