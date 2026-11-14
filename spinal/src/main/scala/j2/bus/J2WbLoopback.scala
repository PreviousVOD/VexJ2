package j2.bus

import spinal.core._
import spinal.lib._
import spinal.lib.bus.wishbone._

final class J2WbLoopback extends Component {
  val io = new Bundle {
    val bus = slave(J2Wishbone())
  }

  private val pending = Reg(Bool()) init False
  private val ack = Reg(Bool()) init False
  private val request = io.bus.CYC && io.bus.STB

  when(ClockDomain.current.isResetActive) {
    pending := False
    ack := False
  } otherwise {
    ack := False
    when(request) {
      when(!pending) {
        pending := True
      } otherwise {
        pending := False
        ack := True
      }
    } otherwise {
      pending := False
    }
  }

  io.bus.ACK := ack
  io.bus.DAT_MISO := B(0, 32 bits)
  io.bus.ERR := False
  io.bus.STALL := False
}
