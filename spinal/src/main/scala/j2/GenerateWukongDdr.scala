package j2

import j2.board.wukong.J2WukongDdrTest
import spinal.core._

object GenerateWukongDdr extends App {
  SpinalConfig(targetDirectory = "../build/wukong-v1/ddr/rtl", mode = Verilog)
    .withoutEnumString()
    .generateVerilog(new J2WukongDdrTest)
}
