package j2

import j2.board.tang_primer.J2TangPrimer
import j2.board.BoardProfile
import j2.memory.MemoryBackend

object Generate_TangPrimer extends App {
  require(args.isEmpty || args.sameElements(Array("--sim")), "expected no arguments or --sim")
  private val forFpga = args.isEmpty
  private val profile = BoardProfile.load("tang-primer")
  private val socConfig =
    profile.socConfig(sys.env.getOrElse("J2_ROM_HEX", "../build/verilog/xip/j2_validation_rom.hex"))
  private val output = sys.env.getOrElse(
    "J2_SPINAL_OUT",
    if (forFpga) "../build/spinal/verilog-fpga" else "../build/spinal/verilog"
  )
  private val backend = if (forFpga) MemoryBackend.Eg4 else MemoryBackend.Inferred
  private val config  = backend.configure(Generate.config(output))
  Generate.core(config, exposeDebug = !forFpga)
  config.generateVerilog(new J2TangPrimer(socConfig, forFpga = forFpga, usePll = profile.usePll))
}
