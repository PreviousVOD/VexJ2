package j2.periph

import j2.bus.J2Apb
import spinal.core._
import spinal.lib._
import spinal.lib.bus.amba3.apb.Apb3SlaveFactory
import spinal.lib.io.TriStateArray

final class J2Pio extends Component {
  val io = new Bundle {
    val bus  = slave(J2Apb())
    val gpio = master(TriStateArray(32))
  }
  private val factory = Apb3SlaveFactory(io.bus)
  factory.read(io.gpio.read, 0)
  factory.driveAndRead(io.gpio.write, 4)
  factory.driveAndRead(io.gpio.writeEnable, 8)
  io.gpio.writeEnable.getDrivingReg() init (0)
}
