package j2.periph

import j2.bus.J2Apb
import spinal.core._
import spinal.lib._

/** SH7124/SH7125 two-channel CMT register layout, packed in BE32 APB words. The enclosing APB clock
  * is PCLK/Pphi. Divided clocks are clock enables only. CMF uses ordinary W0C semantics; reads have
  * no side effects.
  */
final class J2CMT extends Component {
  val io = new Bundle {
    val bus       = slave(J2Apb())
    val interrupt = out Bits (2 bits)
  }
  private val start   = Reg(Bits(2 bits)) init (0)
  private val divider = Reg(UInt(9 bits)) init (0)
  divider := divider + 1
  private val validAddress = io.bus.PADDR === 0 || io.bus.PADDR === 4 ||
    io.bus.PADDR === 8 || io.bus.PADDR === 12
  io.bus.PREADY  := True
  io.bus.PSLVERR := io.bus.access && !validAddress
  io.bus.PRDATA  := 0
  private val write                      = io.bus.fire && io.bus.PWRITE && validAddress
  private def shift(offset: Int): Int    = if ((offset & 2) == 0) 16 else 0
  private def data(offset: Int): Bits    = io.bus.PWDATA(shift(offset), 16 bits)
  private def strobes(offset: Int): Bits = io.bus.PSTRB(shift(offset) / 8, 2 bits)
  private def writing(offset: Int): Bool =
    write && io.bus.PADDR === (offset & ~3) && strobes(offset).orR
  private def read(offset: Int, value: Bits): Unit =
    when(io.bus.PADDR === (offset & ~3))(io.bus.PRDATA(shift(offset), 16 bits) := value)
  private def merge(offset: Int, previous: UInt): UInt = {
    val result = Bits(16 bits)
    for (byte <- 0 until 2)
      result(byte * 8, 8 bits) := Mux(
        strobes(offset)(byte),
        data(offset)(byte * 8, 8 bits),
        previous.asBits(byte * 8, 8 bits)
      )
    result.asUInt
  }
  when(writing(0) && strobes(0)(0))(start := data(0)(1 downto 0))
  read(0, start.resize(16))

  for (channel <- 0 until 2) {
    val csrOffset     = if (channel == 0) 2 else 8
    val cntOffset     = if (channel == 0) 4 else 10
    val corOffset     = if (channel == 0) 6 else 12
    val select        = Reg(UInt(2 bits)) init (0)
    val enabled, flag = RegInit(False)
    val count         = Reg(UInt(16 bits)) init (0)
    val compare       = Reg(UInt(16 bits)) init (0xffff)
    val tick = select.mux(
      0 -> (divider(2 downto 0) === 7),
      1 -> (divider(4 downto 0) === 31),
      2 -> (divider(6 downto 0) === 127),
      3 -> (divider === 511)
    )
    // Compare logic still operates when STR is clear (manual section 14.5.5).
    val matched = tick && count === compare
    val status  = B(0, 16 bits)
    status(7)          := flag
    status(6)          := enabled
    status(1 downto 0) := select.asBits
    read(csrOffset, status)
    read(cntOffset, count.asBits)
    read(corOffset, compare.asBits)
    when(writing(csrOffset) && strobes(csrOffset)(0)) {
      select  := data(csrOffset)(1 downto 0).asUInt
      enabled := data(csrOffset)(6)
      when(!data(csrOffset)(7))(flag := False)
    }
    when(writing(corOffset))(compare := merge(corOffset, compare))
    when(tick && start(channel))(count := count + 1)
    // A byte write suppresses the entire increment, preserving the other byte.
    when(writing(cntOffset))(count := merge(cntOffset, count))
    // Compare clear wins over any counter write. A new match wins over W0C.
    when(matched) { count := 0; flag := True }
    // Keep flag/enable changes off the core's half-cycle microcode address path.
    io.interrupt(channel) := RegNext(enabled && flag) init (False)
  }
}
