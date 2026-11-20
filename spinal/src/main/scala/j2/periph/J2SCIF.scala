package j2.periph

import j2.bus.J2Apb
import spinal.core._
import spinal.lib._
import spinal.lib.com.uart.Uart

/** Asynchronous SH7265 SCIF register interface. Zero depth uses one holding register per direction;
  * positive depth specifies FIFO capacity, excluding the transmit shift register.
  */
final class J2SCIF(val fifoDepth: Int = 0) extends Component {
  require(fifoDepth >= 0 && fifoDepth <= 255, "SCIF FIFO depth must be 0–255")
  val capacity = fifoDepth.max(1)
  val io = new Bundle {
    val bus  = slave(J2Apb())
    val uart = master(Uart())
    // Board wiring chooses vector order: ERI, RXI, TXI, BRI (there is no SCIF TEI).
    val interrupt = out Bits (4 bits)
  }

  /** No fall-through: an empty read never consumes a concurrent arrival. A full queue can accept a
    * replacement on the same edge as a pop. Reset wins over either.
    */
  private class Fifo(width: Int) extends Area {
    val push, pop, flush = Bool()
    val input            = Bits(width bits)
    val count            = Reg(UInt(log2Up(capacity + 1) bits)) init (0)
    val valid            = count =/= 0 && !flush
    val popFire          = pop && valid
    val pushFire         = push && !flush && (count =/= capacity || popFire)
    val head             = Bits(width bits)
    if (capacity == 1) {
      val holding = Reg(Bits(width bits))
      when(pushFire)(holding := input)
      head := Mux(valid, holding, B(0, width bits))
    } else {
      val memory                    = Mem(Bits(width bits), capacity)
      val readPointer, writePointer = Reg(UInt(log2Up(capacity) bits)) init (0)
      head := Mux(valid, memory.readAsync(readPointer), B(0, width bits))
      when(pushFire) {
        memory.write(writePointer, input)
        writePointer := Mux(writePointer === capacity - 1, U(0), writePointer + 1)
      }
      when(popFire)(readPointer := Mux(readPointer === capacity - 1, U(0), readPointer + 1))
      when(flush) { readPointer := 0; writePointer := 0 }
    }
    when(pushFire =/= popFire) {
      when(pushFire)(count := count + 1).otherwise(count := count - 1)
    }
    when(flush)(count := 0)
  }
  private val txFifo                       = new Fifo(8)
  private val rxFifo                       = new Fifo(10) // PER, FER, data, in FIFO order.
  private val smr                          = Reg(Bits(8 bits)) init (0)
  private val brr                          = Reg(UInt(8 bits)) init (255)
  private val scr, fcr                     = Reg(Bits(8 bits)) init (0)
  private val portOutput, portData         = RegInit(False)
  private val tdfe, tend                   = RegInit(True)
  private val rdf, dr, er, brk, orer       = RegInit(False)
  private val previousFraming, breakActive = RegInit(False)
  private val rxComplete                   = False
  private val rxPin                        = BufferCC(io.uart.rxd, init = True)
  private val validAddress                 = io.bus.PADDR(1 downto 0) === 0 && io.bus.PADDR <= 0x28
  io.bus.PREADY  := True
  io.bus.PSLVERR := io.bus.access && !validAddress
  io.bus.PRDATA  := 0
  private def writing(offset: Int, lane: Int): Bool =
    io.bus.fire && io.bus.PWRITE && io.bus.PADDR === offset && io.bus.PSTRB(lane)
  // BE32: halfwords occupy lanes 3/2; bytes occupy lane 3. Lower lanes are holes.
  private def lowWrite(offset: Int): Bool = writing(offset, 2)
  private val lowData                     = io.bus.PWDATA(23 downto 16)
  private def read16(offset: Int, value: Bits): Unit =
    when(io.bus.PADDR === offset)(io.bus.PRDATA(31 downto 16) := value.resize(16))
  private def read8(offset: Int, value: Bits): Unit =
    when(io.bus.PADDR === offset)(io.bus.PRDATA(31 downto 24) := value)
  read16(0, smr); read8(4, brr.asBits); read16(8, scr)
  // Write-only SCFTDR reads as zero; only reading its separate SCFRDR word pops.
  read8(0x14, rxFifo.head(7 downto 0))
  read16(0x18, fcr)
  read16(0x1c, txFifo.count.asBits.resize(8) ## rxFifo.count.asBits.resize(8))
  read16(0x20, B(0x50, 16 bits) | (portOutput.asBits.resize(16) |<< 1) | rxPin.asBits.resize(16))
  read16(0x24, orer.asBits)
  // SCEMR, synchronous/external clocks, modem control and loopback are unsupported.
  when(lowWrite(0))(smr    := lowData & B(0x7b, 8 bits))
  when(writing(4, 3))(brr  := io.bus.PWDATA(31 downto 24).asUInt)
  when(lowWrite(8))(scr    := lowData & B(0xf8, 8 bits))
  when(lowWrite(0x18))(fcr := lowData & B(0xf6, 8 bits))
  when(lowWrite(0x20)) { portOutput := lowData(1); portData := lowData(0) }
  when(lowWrite(0x24) && !lowData(0))(orer := False)
  when(lowWrite(0x10)) {
    when(!lowData(7))(er   := False)
    when(!lowData(6))(tend := False)
    when(!lowData(5))(tdfe := False)
    when(!lowData(4))(brk  := False)
    when(!lowData(1))(rdf  := False)
    when(!lowData(0))(dr   := False)
  }
  txFifo.flush := fcr(2) || (lowWrite(0x18) && lowData(2))
  rxFifo.flush := fcr(1) || (lowWrite(0x18) && lowData(1))
  txFifo.push  := writing(0x0c, 3)
  txFifo.input := io.bus.PWDATA(31 downto 24)
  txFifo.pop   := False
  rxFifo.pop   := io.bus.fire && !io.bus.PWRITE && io.bus.PADDR === 0x14

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
  io.uart.txd := Mux(scr(5), txPin, Mux(portOutput, portData, True))
  private def transmit(): Unit = {
    txState        := State.START
    txPin          := False
    txData         := txFifo.head
    txIndex        := 0
    txPeriod       := period
    txTimer        := period - 1
    txSeven        := smr(6)
    txParityEnable := smr(5)
    txParity       := Mux(smr(6), txFifo.head(6 downto 0).xorR, txFifo.head.xorR) ^ smr(4)
    txTwoStops     := smr(3)
    txReverse      := False
    txFifo.pop     := True
  }
  when(txState =/= State.IDLE) {
    when(txTimer =/= 0)(txTimer := txTimer - 1)
      .otherwise(txTimer := txPeriod - 1)
  }
  switch(txState) {
    is(State.IDLE)(when(scr(5) && txFifo.valid)(transmit()))
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
              when(!txTwoStops && !txFifo.valid)(tend := True)
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
        when(!txTwoStops && !txFifo.valid)(tend := True)
      }
    }
    is(State.STOP) {
      when(txTimer === 0) {
        when(!txLastStop) {
          txLastStop := True
          when(!txFifo.valid)(tend := True)
        } otherwise
          when(scr(5) && txFifo.valid)(transmit())
            .otherwise(txState := State.IDLE)
      }
    }
  }
  when(!scr(5)) { txState := State.IDLE; txPin := True; tend := True }

  private val rxState           = RegInit(State.IDLE)
  private val rxTimer, rxPeriod = Reg(UInt(20 bits)) init (0)
  private val rxData            = Reg(Bits(8 bits)) init (0)
  private val rxIndex           = Reg(UInt(3 bits)) init (0)
  private val rxSeven, rxParityEnable, rxOdd, rxReverse, rxParityBad, rxTwoStops = RegInit(False)
  when(rxState =/= State.IDLE) {
    when(rxTimer =/= 0)(rxTimer := rxTimer - 1)
      .otherwise(rxTimer := rxPeriod - 1)
  }
  switch(rxState) {
    is(State.IDLE) {
      when(scr(4) && !rxPin && !orer && !breakActive) {
        rxState    := State.START
        rxTimer    := (period |>> 1) - 1
        rxPeriod   := period
        rxTwoStops := smr(3)
        rxSeven    := smr(6); rxParityEnable := smr(5); rxOdd  := smr(4)
        rxReverse  := False
        rxData     := 0; rxIndex             := 0; rxParityBad := False
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
        rxComplete := True
        rxState    := State.IDLE
      }
    }
  }
  when(!scr(4))(rxState := State.IDLE)

  // Receive error metadata follows each byte. Errors do not halt SCIF reception;
  // only overrun blocks new frames until software acknowledges SCLSR.ORER.
  private val receiveBreak = rxComplete && previousFraming && !rxPin && rxData === 0
  when(rxPin)(breakActive := False)
  when(rxComplete) {
    previousFraming := !rxPin
    when(receiveBreak) { brk := True; breakActive := True }
    when(!rxFifo.flush) {
      when(!rxPin || rxParityBad)(er               := True)
      when(!receiveBreak && !rxFifo.pushFire)(orer := True)
    }
  }
  rxFifo.push  := rxComplete && !receiveBreak
  rxFifo.input := rxParityBad ## !rxPin ## rxData
  private val parityCount, framingCount = Reg(UInt(log2Up(capacity + 1) bits)) init (0)
  private def countErrors(counter: UInt, bit: Int): Unit = {
    val add    = rxFifo.pushFire && rxFifo.input(bit)
    val remove = rxFifo.popFire && rxFifo.head(bit)
    when(add =/= remove) {
      when(add)(counter := counter + 1).otherwise(counter := counter - 1)
    }
    when(rxFifo.flush)(counter := 0)
  }
  countErrors(parityCount, 9); countErrors(framingCount, 8)
  // The manual specifies modulo-16 error counts (sixteen errors reads zero).
  private val status = parityCount.asBits.resize(4) ## framingCount.asBits.resize(4) ##
    er ## tend ## tdfe ## brk ## rxFifo.head(8) ## rxFifo.head(9) ## rdf ## dr
  read16(0x10, status)

  // At depth 16 these are precisely SH7265's 8/4/2/0 and 1/4/8/14 triggers.
  private val txTrigger =
    fcr(5 downto 4).muxList(Seq(capacity / 2, capacity / 4, capacity / 8, 0).zipWithIndex.map {
      case (value, index) => index -> U(value, 8 bits)
    })
  private val rxTrigger = fcr(7 downto 6).muxList(
    Seq(1, (capacity + 3) / 4, (capacity + 1) / 2, (capacity * 7 + 7) / 8).zipWithIndex.map {
      case (value, index) => index -> U(value, 8 bits)
    }
  )
  // Threshold flags are sticky W0C and reassert while their conditions hold.
  when(txFifo.count <= txTrigger || txFifo.flush)(tdfe := True)
  when(rxFifo.count >= rxTrigger && !rxFifo.flush)(rdf := True)
  private val timeout      = Reg(UInt(24 bits)) init (0)
  private val timeoutArmed = RegInit(False)
  when(rxComplete) {
    // Fifteen bit periods after the end of the configured final stop bit.
    timeout := (rxPeriod.resize(24) |<< 4) - rxPeriod.resize(24) + (rxPeriod.resize(
      24
    ) |>> 1) + Mux(rxTwoStops, rxPeriod.resize(24), U(0, 24 bits))
    timeoutArmed := True
  } elsewhen (timeoutArmed && timeout =/= 0) {
    timeout := timeout - 1
  }
  when(timeoutArmed && timeout === 0 && rxFifo.valid && rxFifo.count < rxTrigger)(dr := True)
  when((!rxFifo.valid && !rxFifo.pushFire) || rxFifo.flush)(timeoutArmed             := False)
  io.interrupt(0) := RegNext((scr(6) || scr(3)) && er) init (False)
  io.interrupt(1) := RegNext(scr(6) && (rdf || dr)) init (False)
  io.interrupt(2) := RegNext(scr(7) && tdfe) init (False)
  io.interrupt(3) := RegNext((scr(6) || scr(3)) && (brk || orer)) init (False)
}
