package j2

import j2.board.wukong_v1.J2WukongDdrTest

object Generate_WukongDdr extends App {
  require(args.isEmpty, "Generate_WukongDdr takes no arguments")
  Generate
    .config(sys.env.getOrElse("J2_SPINAL_OUT", "../build/wukong-v1/ddr/rtl"))
    .generateVerilog(new J2WukongDdrTest)
}
