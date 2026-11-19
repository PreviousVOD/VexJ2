package j2.periph

import j2.bus.J2Wishbone
import spinal.core._
import spinal.lib._
import scala.io.Source

object J2RomData {
  def words(path: String): Seq[BigInt] = {
    val source = Source.fromFile(path)
    val values =
      try
        source.getLines().map(_.trim).filter(_.nonEmpty).map(line => BigInt(line, 16)).toVector
      finally source.close()
    require(values.length <= 8192, s"ROM contains ${values.length} words")
    values.padTo(8192, BigInt(0))
  }
}

final class J2WishboneRom(initFile: String) extends Component {
  val io = new Bundle {
    val bus = slave(J2Wishbone())
  }
  private val pending = RegInit(False)
  private val memory  = Mem(UInt(32 bits), 8192)
  memory.setTechnology(ramBlock)
  memory.initBigInt(J2RomData.words(initFile))
  private val readData = memory.readSync(io.bus.ADR(14 downto 2)).asBits

  when(io.bus.CYC && io.bus.STB) {
    pending := !pending
  } otherwise {
    pending := False
  }
  io.bus.ACK      := pending
  io.bus.DAT_MISO := readData
  io.bus.ERR      := False
}

final class J2WishboneSram extends Component {
  val io = new Bundle {
    val bus = slave(J2Wishbone())
  }
  private val banks = Seq.fill(4)(Mem(Bits(8 bits), 8192))
  banks.foreach(_.setTechnology(ramBlock))
  banks.foreach(_.initBigInt(Seq.fill(8192)(BigInt(0))))
  private val pending = RegInit(False)
  private val readData = Cat(
    banks(3).readSync(io.bus.ADR(14 downto 2)),
    banks(2).readSync(io.bus.ADR(14 downto 2)),
    banks(1).readSync(io.bus.ADR(14 downto 2)),
    banks(0).readSync(io.bus.ADR(14 downto 2))
  )
  private val request = io.bus.CYC && io.bus.STB
  private val start   = request && !pending

  when(request) {
    pending := !pending
  } otherwise {
    pending := False
  }
  for (index <- 0 until 4)
    when(start && io.bus.WE && io.bus.SEL(index)) {
      banks(index).write(io.bus.ADR(14 downto 2), io.bus.DAT_MOSI(index * 8 + 7 downto index * 8))
    }
  io.bus.ACK      := pending
  io.bus.DAT_MISO := readData
  io.bus.ERR      := False
}
