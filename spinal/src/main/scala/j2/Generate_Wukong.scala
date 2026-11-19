package j2

import j2.board.wukong_v1.J2Wukong
import j2.board.BoardProfile
import j2.memory.MemoryBackend

object Generate_Wukong extends App {
  require(args.isEmpty, "Generate_Wukong takes no arguments")
  private val profile = BoardProfile.load("wukong-v1")
  private val socConfig =
    profile.socConfig(sys.env.getOrElse("WUKONG_ROM_HEX", "../build/wukong-v1/rom/boot.hex"))
  private val output = sys.env.getOrElse("J2_SPINAL_OUT", "../build/wukong-v1/rtl")
  private val config = MemoryBackend.Xilinx.configure(Generate.config(output))
  Generate.core(config, exposeDebug = false)
  config.generateVerilog(new J2Wukong(socConfig))
}
