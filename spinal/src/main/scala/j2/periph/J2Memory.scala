package j2.periph

import j2.bus.J2Wishbone
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

final class Eg4Bram32 extends BlackBox {
  val dia   = in Bits (32 bits)
  val dib   = in Bits (32 bits)
  val addra = in UInt (13 bits)
  val addrb = in UInt (13 bits)
  val cea   = in Bool ()
  val ceb   = in Bool ()
  val ocea  = in Bool ()
  val oceb  = in Bool ()
  val clka  = in Bool ()
  val clkb  = in Bool ()
  val wea   = in Bool ()
  val web   = in Bool ()
  val rsta  = in Bool ()
  val rstb  = in Bool ()
  val bea   = in Bool ()
  val beb   = in Bool ()
  val doa   = out Bits (32 bits)
  val dob   = out Bits (32 bits)
  setDefinitionName("EG_LOGIC_BRAM")
  addGeneric("DATA_WIDTH_A", 32)
  addGeneric("DATA_WIDTH_B", 32)
  addGeneric("ADDR_WIDTH_A", 13)
  addGeneric("ADDR_WIDTH_B", 13)
  addGeneric("DATA_DEPTH_A", 8192)
  addGeneric("DATA_DEPTH_B", 8192)
  addGeneric("BYTE_ENABLE", 0)
  addGeneric("BYTE_A", 1)
  addGeneric("BYTE_B", 1)
  addGeneric("MODE", "SP")
  addGeneric("REGMODE_A", "NOREG")
  addGeneric("REGMODE_B", "NOREG")
  addGeneric("WRITEMODE_A", "NORMAL")
  addGeneric("WRITEMODE_B", "NORMAL")
  addGeneric("RESETMODE", "SYNC")
  addGeneric("IMPLEMENT", "32K")
  addGeneric("INIT_FILE", "j2_validation_rom.mif")
  addGeneric("FILL_ALL", "NONE")
}

final class J2Rom(useEg4Rom: Boolean = false) extends Component {
  val io = new Bundle {
    val bus = slave(J2Wishbone())
  }
  private val pending = RegInit(False)
  private val readData = if (useEg4Rom) {
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
