package j2.microcode

import spinal.core._

import scala.io.Source

object J2MicrocodeData {
  private[j2] def resourceLines(name: String): Vector[String] = {
    val stream = Option(getClass.getResourceAsStream(name)).getOrElse {
      throw new IllegalStateException(s"missing $name resource")
    }
    val source = Source.fromInputStream(stream)
    try
      source.getLines().filter(_.nonEmpty).toVector
    finally
      source.close()
  }

  val entries: Vector[BigInt] = {
    val data = resourceLines("/j2_microcode.hex").map(BigInt(_, 16))
    require(data.length == 256, s"expected 256 microcode entries, got ${data.length}")
    data
  }
}

final class J2MicrocodeRomIo extends Bundle {
  val clk = in Bool ()
  val address = in UInt (8 bits)
  val line = out UInt (72 bits)
}

trait J2MicrocodeRomPort {
  val io: J2MicrocodeRomIo
}

final class J2MicrocodeRom extends Component with J2MicrocodeRomPort {
  val io = new J2MicrocodeRomIo

  private val memory = Mem(UInt(72 bits), 256)
  memory.initBigInt(J2MicrocodeData.entries)
  io.address.addTag(crossClockDomain)
  private val readArea = new ClockingArea(
    ClockDomain(clock = io.clk, config = ClockDomainConfig(clockEdge = FALLING))
  ) {
    val line = memory.readSync(io.address)
    line.addTag(crossClockDomain)
  }
  io.line := readArea.line
  io.line.addTag(crossClockDomain)
}

final class Eg4MicrocodeRom(
    initFile: String = "../../microcode/j2_microcode.mif"
) extends BlackBox
    with J2MicrocodeRomPort {
  val io = new J2MicrocodeRomIo

  setName("j2_microcode_rom")
  noIoPrefix()
  addGeneric("INIT_FILE", initFile)
}
