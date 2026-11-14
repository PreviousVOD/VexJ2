package j2

import j2.isa.Sh2Decoder
import j2.core.{Sh2Alu, Sh2Core, Sh2RegFile, Sh2Shifter}
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
  val config = SpinalConfig(
    targetDirectory = "../build/spinal/verilog",
    mode = Verilog
  ).withoutEnumString()
  config.generateVerilog(new Sh2Decoder)
  config.generateVerilog(new Sh2Alu)
  config.generateVerilog(new Sh2Shifter)
  config.generateVerilog(new Sh2RegFile)
  config.generateVerilog(new Sh2Core)
  config.generateVerilog(new J2WbRam)
  config.generateVerilog(new J2Pio)
  config.generateVerilog(new J2UartLite)
  config.generateVerilog(new J2Soc)
  config.generateVerilog(new J2TangPrimer(rom))
}
