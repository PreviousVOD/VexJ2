package j2.periph

import j2.bus.J2Wishbone
import spinal.core._
import spinal.lib._
import spinal.lib.bus.wishbone.WishboneSlaveFactory
import spinal.lib.misc.Timer

final class J2Timer(clockHz: Int, tickHz: Int = 1000000, width: Int = 32) extends Component {
  require(clockHz > 0 && tickHz > 0 && clockHz % tickHz == 0)
  require(width > 0)

  val io = new Bundle {
    val bus       = slave(J2Wishbone())
    val interrupt = out Bool ()
  }

  private val wordBus = J2Wishbone()
  J2Wishbone.connectToWordAddressed(io.bus, wordBus, io.bus.ADR(11 downto 0))
  private val factory    = WishboneSlaveFactory(wordBus)
  private val timer      = new Timer(width)
  private val limitHit   = timer.io.value === timer.io.limit
  private val tickEnable = factory.createReadAndWrite(Bits(1 bits), 0x00, 0) init (0)
  factory.driveAndRead(timer.io.limit, 0x04)
  factory.read(timer.io.value, 0x08)
  private val interruptEnable = factory.createReadAndWrite(Bits(1 bits), 0x0c, 0) init (0)
  factory.read(limitHit, 0x0c, 8)

  private val busClearing = factory.isWriting(0x04) || factory.isWriting(0x08)
  private val divider     = clockHz / tickHz
  private val tick = if (divider == 1) {
    True
  } else {
    val prescaler = RegInit(U(0, log2Up(divider) bits))
    val pulse     = Bool()
    pulse := False
    when(prescaler === divider - 1) {
      prescaler := 0
      pulse     := True
    } otherwise {
      prescaler := prescaler + 1
    }
    pulse
  }

  timer.io.tick  := tick && tickEnable(0)
  timer.io.clear := busClearing || ClockDomain.current.isResetActive
  // Keep the timer comparator off the CPU's half-cycle microcode address path.
  // The level IRQ follows enable/limitHit by one system clock, including clears
  // and disables. The CSR still reports the current comparator result.
  io.interrupt := RegNext(interruptEnable(0) && limitHit) init (False)
}
