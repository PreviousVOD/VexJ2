package j2.board.wukong_v1

import spinal.core._

/** Independent MIG native-interface qualification before attaching the CPU bus. Addresses are DDR
  * words (two bytes); each UI transfer covers one BL8 burst.
  */
final class WukongDdrBist extends Component {
  val io = new Bundle {
    val calibrated                  = in Bool ()
    val addr                        = out UInt (28 bits)
    val cmd                         = out Bits (3 bits)
    val en, wren, wend              = out Bool ()
    val wdata                       = out Bits (128 bits)
    val mask                        = out Bits (16 bits)
    val ready, wready, rvalid, rend = in Bool ()
    val rdata                       = in Bits (128 bits)
    val done, failed                = out Bool ()
  }
  val index                             = Reg(UInt(10 bits)) init 0
  val phase                             = Reg(UInt(2 bits)) init 0
  val active, waiting, finished, failed = RegInit(False)
  val cmdSent, dataSent                 = RegInit(False)
  val watchdog                          = Reg(UInt(24 bits)) init 0
  val address                           = UInt(28 bits)
  address   := (index.resize(28) << 3).resized
  when(index >= 512)(address   := ((index.resize(28) - 511) << 18).resized)
  when(index === 1023)(address := U(0x07fffff8, 28 bits))
  val pattern = Bits(128 bits)
  for (lane <- 0 until 4)
    pattern(lane * 32, 32 bits) := address.resize(32).asBits ^ B(
      BigInt("12345678", 16) + BigInt("10203040", 16) * lane,
      32 bits
    )
  val expected = Bits(128 bits)
  for (byte <- 0 until 16)
    expected(
      byte * 8,
      8 bits
    ) := (if (byte % 2 == 0) Mux(phase(1), ~pattern(byte * 8, 8 bits), pattern(byte * 8, 8 bits))
          else pattern(byte * 8, 8 bits))
  io.addr := address
  io.cmd  := Mux(phase(0), B"001", B"000")
  // UG586 limits write-data delay after a command to two UI cycles.
  // Buffer the complete burst first, then issue its write command.
  io.en     := active && !waiting && !cmdSent && (phase(0) || dataSent)
  io.wren   := active && !phase(0) && !dataSent
  io.wend   := True
  io.wdata  := Mux(phase(1), ~pattern, pattern)
  io.mask   := Mux(phase(1), B(0xaaaa, 16 bits), B(0, 16 bits))
  io.done   := finished
  io.failed := failed

  def advance(): Unit = {
    cmdSent := False; dataSent := False; waiting := False; watchdog := 0
    index   := index + 1
    when(index === 1023) {
      phase := phase + 1
      when(phase === 3) { active := False; finished := True }
    }
  }
  when(!active && !finished && io.calibrated)(active := True)
  when(active) {
    watchdog := watchdog + 1
    when(io.en && io.ready) { cmdSent := True; when(phase(0))(waiting := True) }
    when(io.wren && io.wready)(dataSent := True)
    when(!phase(0) && (cmdSent || (io.en && io.ready)) && (dataSent || (io.wren && io.wready))) {
      advance()
    }
    when(waiting && io.rvalid) {
      advance()
      when(!io.rend || io.rdata =/= expected) { failed := True; finished := True; active := False }
    }
    when(watchdog.andR || !io.calibrated) { failed := True; finished := True; active := False }
  }
}
