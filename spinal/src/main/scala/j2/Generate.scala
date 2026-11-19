package j2

import j2.core.isa._
import j2.core.microcode._
import j2.core._
import spinal.core._

/** Shared generation settings and board-independent, simulation-friendly RTL. */
object Generate {
  def config(targetDirectory: String): SpinalConfig =
    SpinalConfig(targetDirectory = targetDirectory, mode = Verilog).withoutEnumString()

  def core(config: SpinalConfig, exposeDebug: Boolean): Unit =
    config.generateVerilog(new J2MicrocodedCore(J2CoreConfig(exposeDebug = exposeDebug)))

  def main(args: Array[String]): Unit = {
    require(args.isEmpty, "Generate takes no arguments; use a board generator for board RTL")
    val config = Generate.config(sys.env.getOrElse("J2_SPINAL_OUT", "../build/spinal/verilog"))
    config.generateVerilog(new J2Alu)
    config.generateVerilog(new J2Shifter)
    config.generateVerilog(new J2PipelineRegFile)
    core(config, exposeDebug = true)
    config.generateVerilog(new J2MicrocodeRom)
    config.generateVerilog(new J2Predecoder)
    config.generateVerilog(new J2MicrocodeTable)
    config.generateVerilog(new J2Microsequencer)
    config.generateVerilog(new J2Pipeline)
    config.generateVerilog(new J2Hazards)
    config.generateVerilog(new J2Datapath)
    config.generateVerilog(new J2Multiply)
  }
}
