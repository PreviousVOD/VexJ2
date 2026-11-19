package j2

import j2.core.isa._
import j2.core.microcode._
import j2.core._
import j2.soc._
import j2.board.tang_primer._
import j2.memory.MemoryBackend
import spinal.core._

object Generate extends App {
  private val forFpga = sys.env.get("J2_FPGA").contains("1")
  private val clockHz = sys.env.getOrElse("J2_CLOCK_HZ", "32000000").toInt
  private val usePll  = sys.env.getOrElse("J2_USE_PLL", "1") == "1"
  val config = SpinalConfig(
    targetDirectory = sys.env.getOrElse("J2_SPINAL_OUT", "../build/spinal/verilog"),
    mode            = Verilog
  ).withoutEnumString()
  config.generateVerilog(new J2Alu)
  config.generateVerilog(new J2Shifter)
  config.generateVerilog(new J2PipelineRegFile)
  val cpuConfig =
    if (forFpga)
      MemoryBackend.Eg4.configure(
        config.copy(
          targetDirectory = "../build/spinal/verilog-fpga",
          memBlackBoxers  = scala.collection.mutable.ArrayBuffer.empty
        )
      )
    else config
  cpuConfig.generateVerilog(
    new J2MicrocodedCore(
      J2CoreConfig(exposeDebug = !forFpga)
    )
  )
  config.generateVerilog(new J2TangPrimer(clockHz, forFpga = false))
  cpuConfig.generateVerilog(new J2TangPrimer(clockHz, forFpga = forFpga, usePll = usePll))
  config.generateVerilog(new J2MicrocodeRom)
  config.generateVerilog(new J2Predecoder)
  config.generateVerilog(new J2MicrocodeTable)
  config.generateVerilog(new J2Microsequencer)
  config.generateVerilog(new J2Pipeline)
  config.generateVerilog(new J2Hazards)
  config.generateVerilog(new J2Datapath)
  config.generateVerilog(new J2Multiply)
}
