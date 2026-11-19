package j2

import j2.board.wukong.{J2Wukong, WukongV1}
import j2.memory.MemoryBackend
import spinal.core._

object GenerateWukong extends App {
  val config = WukongV1.load(
    "../fpga/wukong-v1/board.properties",
    sys.env.getOrElse("WUKONG_ROM_HEX", "../build/wukong-v1/rom/boot.hex")
  )
  MemoryBackend.Xilinx
    .configure(
      SpinalConfig(targetDirectory = "../build/wukong-v1/rtl", mode = Verilog)
    )
    .withoutEnumString()
    .generateVerilog(new J2Wukong(config))
}
