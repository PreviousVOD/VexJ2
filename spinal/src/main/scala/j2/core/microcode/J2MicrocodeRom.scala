package j2.core.microcode

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
  val clk     = in Bool ()
  val address = in UInt (8 bits)
  val enable  = in Bool ()
  val line    = out UInt (72 bits)
}

final class J2MicrocodeRom extends Component {
  val io = new J2MicrocodeRomIo

  private val memory = Mem(UInt(72 bits), 256)
  memory.setTechnology(ramBlock)
  memory.initBigInt(J2MicrocodeData.entries)
  io.address.addTag(crossClockDomain)
  io.enable.addTag(crossClockDomain)
  private val readArea = new ClockingArea(
    ClockDomain(clock = io.clk, config = ClockDomainConfig(clockEdge = RISING))
  ) {
    val line = memory.readSync(io.address, io.enable)
    line.addTag(crossClockDomain)
  }
  io.line := readArea.line
  io.line.addTag(crossClockDomain)
}
