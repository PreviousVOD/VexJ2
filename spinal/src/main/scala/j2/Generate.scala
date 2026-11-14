package j2

import j2.isa._
import j2.microcode._
import j2.core._
import spinal.core._

object Generate extends App {
  private val useEg4Rom = sys.env.get("J2_FPGA").contains("1")
  val config = SpinalConfig(
    targetDirectory = "../build/spinal/verilog",
    mode = Verilog
  ).withoutEnumString()
  config.generateVerilog(new J2Alu)
  config.generateVerilog(new J2Shifter)
  config.generateVerilog(new J2PipelineRegFile)
  val cpuConfig =
    if (useEg4Rom) config.copy(targetDirectory = "../build/spinal/verilog-fpga") else config
  cpuConfig.generateVerilog(new J2MicrocodedCore(useEg4Rom))
  config.generateVerilog(new J2MicrocodeRom)
  config.generateVerilog(new J2Predecoder)
  config.generateVerilog(new J2MicrocodeTable)
  config.generateVerilog(new J2Microsequencer)
  config.generateVerilog(new J2Pipeline)
  config.generateVerilog(new J2Hazards)
  config.generateVerilog(new J2Datapath)
  config.generateVerilog(new J2Multiply)
}
