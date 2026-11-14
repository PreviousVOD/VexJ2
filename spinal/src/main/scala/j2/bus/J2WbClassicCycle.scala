package j2.bus

import spinal.core._
import spinal.lib._
import spinal.lib.bus.wishbone._

final class J2WbClassicCycle(bus: Wishbone, enable: Bool = True) extends Area {
  private val pending = RegInit(False)
  private val acknowledge = RegInit(False)

  val request = bus.CYC && bus.STB && enable
  val start = request && !pending
  val complete = request && pending

  when(ClockDomain.current.isResetActive) {
    pending := False
    acknowledge := False
  } otherwise {
    acknowledge := False
    when(request) {
      when(!pending) {
        pending := True
      } otherwise {
        pending := False
        acknowledge := True
      }
    } otherwise {
      pending := False
    }
  }

  bus.ACK := acknowledge
}
