package j2.bus

import j2.bus.ahb5.Ahb5
import spinal.core.sim._

/** Cycle driver for memory subordinates. The callback advances one clock and services any backend
  * model; HREADY is the selected subordinate's response.
  */
class AhbMemoryDriver(val bus: Ahb5, edge: () => Unit) {
  def init(): Unit = {
    bus.HSEL            #= false; bus.HREADY        #= true; bus.HWDATA          #= 0
    bus.address.HADDR   #= 0; bus.address.HWRITE    #= false; bus.address.HTRANS #= 0
    bus.address.HSIZE   #= 2; bus.address.HBURST    #= 0; bus.address.HPROT      #= 11
    bus.address.HMASTER #= 1; bus.address.HMASTLOCK #= false
  }
  def tick(): Unit = {
    sleep(1); bus.HREADY #= bus.HREADYOUT.toBoolean; sleep(1); edge()
  }
  def start(
      address: BigInt,
      write: Boolean = false,
      data: BigInt = 0,
      size: Int = 2,
      transfer: Int = 2
  ): Unit = {
    assert(bus.HREADYOUT.toBoolean)
    bus.HSEL          #= true; bus.address.HADDR  #= address; bus.address.HWRITE #= write
    bus.address.HSIZE #= size; bus.address.HTRANS #= transfer
    bus.HWDATA        #= 0xdeadbeefL // Previous transaction during address phase.
    tick()
    bus.HWDATA #= data
    // This is the next address phase, not cancellation of the accepted transfer.
    bus.HSEL #= false; bus.address.HTRANS #= 0; bus.address.HADDR #= 0x76543210L
  }
  def finish(error: Boolean = false, limit: Int = 2000): BigInt = {
    sleep(1)
    var cycles     = 0
    var errorWaits = 0
    while (!bus.HREADYOUT.toBoolean && cycles < limit) {
      if (bus.HRESP.toBoolean) errorWaits += 1
      tick(); cycles += 1
    }
    assert(cycles < limit, "AHB memory transfer timed out")
    assert(bus.HRESP.toBoolean == error)
    assert(errorWaits == (if (error) 1 else 0), "ERROR must have exactly one not-ready phase")
    val result = bus.HRDATA.toBigInt
    tick()
    result
  }
  def access(
      address: BigInt,
      write: Boolean = false,
      data: BigInt = 0,
      size: Int = 2,
      error: Boolean = false
  ): BigInt = {
    start(address, write, data, size); finish(error)
  }
}
