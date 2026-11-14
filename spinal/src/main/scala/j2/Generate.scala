package j2

import j2.isa._
import j2.microcode._
import j2.core._
import j2.bus.J2WbRam
import j2.periph.{J2Pio, J2UartLite}
import j2.soc.{J2Soc, J2TangPrimer}
import spinal.core._

object Generate extends App {
  private def loadRom(): Seq[BigInt] =
    sys.env.get("J2_ROM") match {
      case Some(path) if path.nonEmpty =>
        val bytes = java.nio.file.Files.readAllBytes(java.nio.file.Paths.get(path))
        bytes
          .grouped(4)
          .map { group =>
            group.foldLeft(BigInt(0)) { case (word, byte) =>
              (word << 8) | BigInt(byte & 0xff)
            }
          }
          .toSeq
      case _ => Seq.empty
    }

  private val rom = loadRom()
  private val useEg4Rom = sys.env.get("J2_FPGA").contains("1")
  val config = SpinalConfig(
    targetDirectory = "../build/spinal/verilog",
    mode = Verilog
  ).withoutEnumString()
  config.generateVerilog(new J2Decoder)
  config.generateVerilog(new J2Alu)
  config.generateVerilog(new J2Shifter)
  config.generateVerilog(new J2RegFile)
  config.generateVerilog(new J2Core)
  config.generateVerilog(new J2PipelineRegFile)
  config.generateVerilog(new J2MicrocodedCore)
  config.generateVerilog(new J2MicrocodeRom)
  config.generateVerilog(new J2Predecoder)
  config.generateVerilog(new J2MicrocodeTable)
  config.generateVerilog(new J2Microsequencer)
  config.generateVerilog(new J2Pipeline)
  config.generateVerilog(new J2Hazards)
  config.generateVerilog(new J2Datapath)
  config.generateVerilog(new J2Multiply)
  config.generateVerilog(new J2WbRam)
  config.generateVerilog(new J2Pio)
  config.generateVerilog(new J2UartLite)
  config.generateVerilog(new J2Soc)
  config.generateVerilog(new J2TangPrimer(rom, useEg4Rom))
}
