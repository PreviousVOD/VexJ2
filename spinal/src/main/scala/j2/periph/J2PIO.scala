package j2.periph

import j2.bus.J2Apb
import j2.bus.apb.Apb4SlaveFactory
import spinal.core._
import spinal.lib._
import spinal.lib.io.TriStateArray

/** 32-pin GPIO with synchronized input reads and sticky, input-only edge interrupts. */
final class J2PIO extends Component {
  val io = new Bundle {
    val bus       = slave(J2Apb())
    val gpio      = master(TriStateArray(32))
    val interrupt = out Bool ()
  }
  private val factory   = Apb4SlaveFactory(io.bus)
  private val enabled   = RegInit(False)
  private val direction = Reg(Bits(32 bits)) init 0
  private val output    = Reg(Bits(32 bits)) init 0
  private val pending   = Reg(Bits(32 bits)) init 0
  private val modes     = Vec.fill(32)(Reg(Bits(2 bits)) init 0)
  private val sampled   = BufferCC(io.gpio.read, init = B(0, 32 bits), bufferDepth = 2)
  private val previous  = RegNext(sampled) init 0
  // Seed history after both synchronizer stages have filled. An initially high
  // input is a starting level, not a rising edge.
  private val settled = Reg(Bits(3 bits)) init 0
  settled := settled(1 downto 0) ## True

  io.gpio.write       := output
  io.gpio.writeEnable := direction
  factory.readAndWrite(enabled, 0, 0)
  factory.readAndWrite(direction, 4)
  factory.read(sampled, 8)
  factory.read(pending, 12)
  private val eligible = Bits(32 bits)
  for (pin <- 0 until 32) {
    factory.readAndWrite(modes(pin), 16 + (pin / 16) * 4, (pin % 16) * 2)
    when(factory.isWriting(8) && io.bus.PSTRB(pin / 8) && direction(pin)) {
      output(pin) := io.bus.PWDATA(pin)
    }
    when(factory.isWriting(12) && io.bus.PSTRB(pin / 8) && io.bus.PWDATA(pin)) {
      pending(pin) := False
    }
    val rising  = sampled(pin) && !previous(pin)
    val falling = !sampled(pin) && previous(pin)
    val armed   = !direction(pin) && (modes(pin) === B"01" || modes(pin) === B"10")
    val event = settled.andR && !direction(pin) &&
      ((modes(pin) === B"01" && rising) || (modes(pin) === B"10" && falling))
    // Events win over a simultaneous W1C; IE gates delivery, not capture.
    when(event)(pending(pin) := True)
    eligible(pin) := armed && pending(pin)
  }
  io.interrupt := RegNext(enabled && eligible.orR) init False
}
