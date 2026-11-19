package j2.periph

import j2.bus.J2Apb
import spinal.core._
import spinal.lib._
import j2.bus.apb.Apb4SlaveFactory
import spinal.lib.com.uart._

final class J2Uart(baudRate: Int) extends Component {
  val io = new Bundle {
    val bus  = slave(J2Apb())
    val uart = master(Uart())
  }
  private val config  = UartCtrlMemoryMappedConfig(baudRate, txFifoDepth = 32, rxFifoDepth = 32)
  private val uart    = new UartCtrl(config.uartCtrlConfig)
  private val factory = Apb4SlaveFactory(io.bus)
  factory.requireWriteStrobes(0, 1)
  uart.driveFrom32(factory, config)
  io.uart <> uart.io.uart
}
