package j2.periph

import j2.bus.J2Apb
import spinal.core._
import spinal.lib._
import spinal.lib.com.uart.Uart

/** One SH7124/SH7125 SCI channel, asynchronous internal-PCLK mode. Byte registers at even offsets
  * are packed in BE32 APB words. Unsupported synchronous/external-clock/multiprocessor bits are
  * hard-wired inactive.
  */
final class J2SCI extends Component {
  val io = new Bundle {
    val bus  = slave(J2Apb())
    val uart = master(Uart())
    // ERI, RXI, TXI, TEI, in ascending SCI vector order.
    val interrupt = out Bits (4 bits)
  }
  private val smr                                       = Reg(Bits(8 bits)) init (0)
  private val brr                                       = Reg(UInt(8 bits)) init (255)
  private val scr                                       = Reg(Bits(8 bits)) init (0)
  private val tdr, rdr                                  = Reg(Bits(8 bits)) init (0)
  private val tdre, tend                                = RegInit(True)
  private val rdrf, orer, fer, per, msbFirst, errorOnly = RegInit(False)
  private val breakData                                 = RegInit(True)
  private val rxPin                                     = BufferCC(io.uart.rxd, init = True)
  private val validAddress = io.bus.PADDR === 0 || io.bus.PADDR === 4 ||
    io.bus.PADDR === 8 || io.bus.PADDR === 12
  io.bus.PREADY  := True
  io.bus.PSLVERR := io.bus.access && !validAddress
  io.bus.PRDATA  := 0
  private def shift(offset: Int): Int = if ((offset & 2) == 0) 24 else 8
  private def data(offset: Int): Bits = io.bus.PWDATA(shift(offset), 8 bits)
  private def writing(offset: Int): Bool = io.bus.fire && io.bus.PWRITE && validAddress &&
    io.bus.PADDR === (offset & ~3) && io.bus.PSTRB(shift(offset) / 8)
  private def read(offset: Int, value: Bits): Unit =
    when(io.bus.PADDR === (offset & ~3))(io.bus.PRDATA(shift(offset), 8 bits) := value)
  private val status = tdre ## rdrf ## orer ## fer ## per ## tend ## B(0, 2 bits)
  read(0, smr); read(2, brr.asBits); read(4, scr); read(6, tdr)
  read(8, status); read(10, rdr)
  read(12, B(0xf2, 8 bits) | (msbFirst.asBits.resize(8) |<< 3))
  read(14, errorOnly.asBits.resize(8) |<< 7) // Write-only port data reads as zero.
  when(writing(0))(smr := data(0) & B(0x7b, 8 bits))
  when(writing(2))(brr := data(2).asUInt)
  when(writing(4))(scr := data(4) & B(0xf4, 8 bits))
  when(writing(6))(tdr := data(6))
  when(writing(8)) {
    when(!data(8)(7) && scr(5))(tdre := False)
    when(!data(8)(6))(rdrf := False)
    when(!data(8)(5))(orer := False)
    when(!data(8)(4))(fer  := False)
    when(!data(8)(3))(per  := False)
  }
  when(writing(12))(msbFirst := data(12)(3))
  when(writing(14)) { errorOnly := data(14)(7); breakData := data(14)(0) }

  // baud = PCLK / (32 * (BRR+1) * 4^CKS). No generated clock domain.
  private val divisor = brr.resize(20) + 1
  private val period = smr(1 downto 0).mux(
    B"00" -> (divisor |<< 5),
    B"01" -> (divisor |<< 7),
    B"10" -> (divisor |<< 9),
    B"11" -> (divisor |<< 11)
  )
  private object State extends SpinalEnum { val IDLE, START, DATA, PARITY, STOP = newElement() }
  private val txState                                                  = RegInit(State.IDLE)
  private val txTimer, txPeriod                                        = Reg(UInt(20 bits)) init (0)
  private val txData                                                   = Reg(Bits(8 bits)) init (0)
  private val txIndex                                                  = Reg(UInt(3 bits)) init (0)
  private val txSeven, txParityEnable, txParity, txTwoStops, txReverse = RegInit(False)
  private val txLastStop                                               = RegInit(False)
  private val txPin                                                    = RegInit(True)
  io.uart.txd := Mux(scr(5), txPin, breakData)
  private def transmit(): Unit = {
    txState        := State.START
    txPin          := False
    txData         := tdr
    txIndex        := 0
    txPeriod       := period
    txTimer        := period - 1
    txSeven        := smr(6)
    txParityEnable := smr(5)
    txParity       := Mux(smr(6), tdr(6 downto 0).xorR, tdr.xorR) ^ smr(4)
    txTwoStops     := smr(3)
    txReverse      := msbFirst && !smr(6)
    tdre           := True
  }
  when(txState =/= State.IDLE) {
    when(txTimer =/= 0)(txTimer := txTimer - 1)
      .otherwise(txTimer := txPeriod - 1)
  }
  switch(txState) {
    is(State.IDLE)(when(scr(5) && !tdre)(transmit()))
    is(State.START) {
      when(txTimer === 0) {
        txState := State.DATA
        txPin   := Mux(txReverse, txData(7), txData(0))
      }
    }
    is(State.DATA) {
      when(txTimer === 0) {
        when(txIndex === Mux(txSeven, U(6, 3 bits), U(7, 3 bits))) {
          when(txParityEnable) { txState := State.PARITY; txPin := txParity }
            .otherwise {
              txState := State.STOP; txPin := True; txLastStop := !txTwoStops
              when(!txTwoStops && tdre)(tend := True)
            }
        } otherwise {
          txIndex := txIndex + 1
          val next = txIndex + 1
          txPin := txData(Mux(txReverse, U(7, 3 bits) - next, next))
        }
      }
    }
    is(State.PARITY) {
      when(txTimer === 0) {
        txState := State.STOP; txPin := True; txLastStop := !txTwoStops
        when(!txTwoStops && tdre)(tend := True)
      }
    }
    is(State.STOP) {
      when(txTimer === 0) {
        when(!txLastStop) {
          txLastStop := True
          when(tdre)(tend := True)
        } otherwise
          when(scr(5) && !tdre)(transmit())
            .otherwise(txState := State.IDLE)
      }
    }
  }
  // A software submission during the final stop bit cancels a concurrent TEND set.
  when(writing(8) && !data(8)(7) && scr(5))(tend := False)
  when(!scr(5)) { txState := State.IDLE; txPin := True; tdre := True; tend := True }

  private val rxState                                                = RegInit(State.IDLE)
  private val rxTimer, rxPeriod                                      = Reg(UInt(20 bits)) init (0)
  private val rxData                                                 = Reg(Bits(8 bits)) init (0)
  private val rxIndex                                                = Reg(UInt(3 bits)) init (0)
  private val rxSeven, rxParityEnable, rxOdd, rxReverse, rxParityBad = RegInit(False)
  when(rxState =/= State.IDLE) {
    when(rxTimer =/= 0)(rxTimer := rxTimer - 1)
      .otherwise(rxTimer := rxPeriod - 1)
  }
  switch(rxState) {
    is(State.IDLE) {
      when(scr(4) && !rxPin && !(orer || fer || per)) {
        rxState   := State.START
        rxTimer   := (period |>> 1) - 1
        rxPeriod  := period
        rxSeven   := smr(6); rxParityEnable := smr(5); rxOdd  := smr(4)
        rxReverse := msbFirst && !smr(6)
        rxData    := 0; rxIndex             := 0; rxParityBad := False
      }
    }
    is(State.START) {
      when(rxTimer === 0) {
        rxState := Mux(rxPin, State.IDLE, State.DATA)
      }
    }
    is(State.DATA) {
      when(rxTimer === 0) {
        rxData(Mux(rxReverse, U(7, 3 bits) - rxIndex, rxIndex)) := rxPin
        when(rxIndex === Mux(rxSeven, U(6, 3 bits), U(7, 3 bits))) {
          rxState := Mux(rxParityEnable, State.PARITY, State.STOP)
        } otherwise { rxIndex := rxIndex + 1 }
      }
    }
    is(State.PARITY) {
      when(rxTimer === 0) {
        rxParityBad := (rxData.xorR ^ rxPin) =/= rxOdd
        rxState     := State.STOP
      }
    }
    is(State.STOP) {
      when(rxTimer === 0) {
        // Errors stop subsequent reception until software clears them. Overrun
        // preserves the old RDR; parity/framing errors retain the received byte.
        when(rdrf)(orer := True) otherwise { rdr := rxData }
        when(!rxPin)(fer                          := True)
        when(rxParityBad)(per                     := True)
        when(!rdrf && rxPin && !rxParityBad)(rdrf := True)
        rxState := State.IDLE
      }
    }
  }
  when(!scr(4))(rxState := State.IDLE)
  io.interrupt(0) := RegNext(scr(6) && (orer || fer || per)) init (False)
  io.interrupt(1) := RegNext(scr(6) && rdrf && !errorOnly) init (False)
  io.interrupt(2) := RegNext(scr(7) && tdre) init (False)
  io.interrupt(3) := RegNext(scr(2) && tend) init (False)
}
