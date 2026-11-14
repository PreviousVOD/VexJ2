package j2.soc

import j2.bus.{J2SocBusRouter, J2WbRam, J2Wishbone}
import j2.core.{J2Event, J2MicrocodedCore}
import j2.periph.{J2Pio, J2UartLite}
import spinal.core._
import spinal.lib._

final class J2Soc(
    val ramWords: Int = 8192,
    val ramInit: Seq[BigInt] = Seq.empty,
    val clockHz: Int = 24000000,
    val baud: Int = 19200,
    val useEg4Rom: Boolean = false
) extends Component {
  require(ramWords > 0 && (ramWords & (ramWords - 1)) == 0)

  val io = new Bundle {
    val external = master(J2Wishbone())
    val event = slave(Stream(new J2Event()))
    val uartRx = in Bool ()
    val uartTx = out Bool ()
    val pioIn = in UInt (32 bits)
    val pioOut = out UInt (32 bits)
    val pc = out UInt (32 bits)
    val retired = out Bool ()
    val sleep = out Bool ()
  }

  private val core = new J2MicrocodedCore(useEg4Rom)
  private val ram = new J2WbRam(ramWords, ramInit)
  private val router = new J2SocBusRouter(BigInt(ramWords) * 4)
  private val pio = new J2Pio
  private val uart = new J2UartLite(clockHz, baud)

  core.io.ibus <> ram.io.instruction
  router.io.input <> core.io.dbus
  router.io.ram <> ram.io.data
  router.io.pio <> pio.io.bus
  router.io.uart <> uart.io.bus
  router.io.external <> io.external

  pio.io.pins := io.pioIn
  io.pioOut := pio.io.outputs
  uart.io.rx := io.uartRx
  io.uartTx := uart.io.tx

  core.io.event.valid := io.event.valid
  core.io.event.payload := io.event.payload
  io.event.ready := core.io.event.ready

  io.pc := core.io.pc
  io.retired := core.io.retired
  io.sleep := core.io.sleep
}
