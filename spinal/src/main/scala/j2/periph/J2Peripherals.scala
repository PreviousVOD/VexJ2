package j2.periph

import j2.bus.{J2WbClassicCycle, J2Wishbone}
import spinal.core._
import spinal.lib._

final class J2Pio extends Component {
  val io = new Bundle {
    val bus = slave(J2Wishbone())
    val pins = in UInt (32 bits)
    val outputs = out UInt (32 bits)
    val irq = out Bool ()
  }

  private val outputs = Reg(UInt(32 bits)) init 0x80000000L
  private val inputMask = Reg(UInt(32 bits)) init 0
  private val edgeMask = Reg(UInt(32 bits)) init 0
  private val changes = Reg(UInt(32 bits)) init 0
  private val previousPins = RegNext(io.pins, U(0, 32 bits))

  private val busCycle = new J2WbClassicCycle(io.bus)
  private val readData = Reg(UInt(32 bits)) init 0
  private val registerSelect = io.bus.ADR(5 downto 2)

  private val changedNow =
    (previousPins & ~io.pins) | (edgeMask & io.pins & ~previousPins)
  changes := changes | changedNow

  io.bus.DAT_MISO := readData.asBits
  io.bus.ERR := False

  io.outputs := outputs
  io.irq := (inputMask & changes).orR

  when(busCycle.start) {
    readData := io.pins
    switch(registerSelect) {
      is(1)(readData := inputMask)
      is(2)(readData := edgeMask)
      is(3)(readData := changes)
      default {}
    }
    when(io.bus.WE) {
      switch(registerSelect) {
        is(0) {
          when(io.bus.SEL(3))(outputs(31 downto 24) := io.bus.DAT_MOSI(31 downto 24).asUInt)
          when(io.bus.SEL(2))(outputs(23 downto 16) := io.bus.DAT_MOSI(23 downto 16).asUInt)
          when(io.bus.SEL(1))(outputs(15 downto 8) := io.bus.DAT_MOSI(15 downto 8).asUInt)
          when(io.bus.SEL(0))(outputs(7 downto 0) := io.bus.DAT_MOSI(7 downto 0).asUInt)
        }
        is(1)(inputMask := io.bus.DAT_MOSI.asUInt)
        is(2)(edgeMask := io.bus.DAT_MOSI.asUInt)
        default {}
      }
    } elsewhen (registerSelect === 3) {
      changes := 0
    }
  }
}

final class J2UartLite(val clockHz: Int = 24000000, val baud: Int = 19200) extends Component {
  val io = new Bundle {
    val bus = slave(J2Wishbone())
    val rx = in Bool ()
    val tx = out Bool ()
  }

  private val divider = clockHz / baud
  require(divider > 0)

  private val busCycle = new J2WbClassicCycle(io.bus)
  private val readData = Reg(UInt(32 bits)) init 0
  private val txBusy = Reg(Bool()) init False
  private val txLine = Reg(Bool()) init True
  private val shift = Reg(UInt(8 bits)) init 0
  private val bitIndex = Reg(UInt(4 bits)) init 0
  private val clockCounter = Reg(UInt(Math.max(1, log2Up(divider)) bits)) init 0
  private val baudTick =
    txBusy && clockCounter === divider - 1

  io.bus.DAT_MISO := readData.asBits
  io.bus.ERR := False
  io.tx := txLine

  when(ClockDomain.current.isResetActive) {
    txBusy := False
    txLine := True
    clockCounter := 0
  } otherwise {
    when(busCycle.start) {
      readData := Mux(
        io.bus.ADR(3),
        Mux(txBusy, U(0x08, 32 bits), U(0x04, 32 bits)),
        U(0, 32 bits)
      )
      when(io.bus.WE && !io.bus.ADR(3) && !txBusy) {
        txBusy := True
        txLine := False
        shift := io.bus.DAT_MOSI(7 downto 0).asUInt
        bitIndex := 0
        clockCounter := 0
      }
    }

    when(txBusy) {
      when(baudTick) {
        clockCounter := 0
        switch(bitIndex) {
          is(0) {
            txLine := shift(0)
            shift := (shift >> 1).resize(8)
            bitIndex := 1
          }
          is(1, 2, 3, 4, 5, 6, 7) {
            txLine := shift(0)
            shift := (shift >> 1).resize(8)
            bitIndex := bitIndex + 1
          }
          is(8) {
            txLine := True
            bitIndex := 9
          }
          default {
            txBusy := False
            txLine := True
          }
        }
      } otherwise {
        clockCounter := clockCounter + 1
      }
    }
  }
}
