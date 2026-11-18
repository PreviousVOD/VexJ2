package j2.periph

import j2.bus.J2Wishbone
import j2.board.tang_primer.Eg4Bram32
import spinal.core._
import spinal.lib._
import scala.io.Source

object J2RomData {
  def words: Seq[BigInt] = {
    val path = sys.env.getOrElse("J2_ROM_HEX", "../build/verilog/xip/j2_validation_rom.hex")
    val values = Source
      .fromFile(path)
      .getLines()
      .map(_.trim)
      .filter(_.nonEmpty)
      .map(line => BigInt(line, 16))
      .toSeq
    require(values.length <= 8192, s"ROM contains ${values.length} words")
    values.padTo(8192, BigInt(0))
  }
}

final class J2Rom(useBramRom: Boolean = false) extends Component {
  val io = new Bundle {
    val bus = slave(J2Wishbone())
  }
  private val pending = RegInit(False)
  private val readData = if (useBramRom) {
    val memory = new Eg4Bram32
    memory.dia   := 0
    memory.dib   := 0
    memory.addra := io.bus.ADR(14 downto 2)
    memory.addrb := 0
    memory.cea   := True
    memory.ceb   := False
    memory.ocea  := False
    memory.oceb  := False
    memory.clka  := ClockDomain.current.readClockWire
    memory.clkb  := False
    memory.wea   := False
    memory.web   := False
    memory.rsta  := False
    memory.rstb  := False
    memory.bea   := False
    memory.beb   := False
    memory.doa
  } else {
    val memory = Mem(UInt(32 bits), 8192)
    memory.initBigInt(J2RomData.words)
    memory.readSync(io.bus.ADR(14 downto 2)).asBits
  }

  when(io.bus.CYC && io.bus.STB) {
    pending := !pending
  } otherwise {
    pending := False
  }
  io.bus.ACK      := pending
  io.bus.DAT_MISO := readData
  io.bus.ERR      := False
}

final class J2Sram extends Component {
  val io = new Bundle {
    val bus = slave(J2Wishbone())
  }
  private val banks = Seq.fill(4)(Mem(Bits(8 bits), 8192))
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
