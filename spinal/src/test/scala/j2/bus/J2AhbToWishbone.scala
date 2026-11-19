package j2.bus

import j2.bus.ahb5._
import spinal.core._
import spinal.lib._

/** Compatibility boundary for existing leaf IP. Address and data are captured in their AHB phases,
  * exactly one classic request is issued, and ERR becomes the required two-cycle ERROR. Reservation
  * arbitration belongs to the AHB BIU; the sampled lock is also exposed for legacy verification
  * fixtures. No byte swapping or speculative accesses occur here.
  */
final class J2AhbToWishbone extends Component {
  val io = new Bundle {
    val ahb = slave(J2Ahb.subordinate())
    val wb  = master(J2Wishbone())
  }
  object State extends SpinalEnum { val IDLE, CAPTURE, ACCESS, RESPONSE, ERROR = newElement() }
  val state     = RegInit(State.IDLE)
  val address   = Reg(Ahb5Control(J2Ahb.config))
  val writeData = Reg(Bits(32 bits))
  val readData  = Reg(Bits(32 bits))
  val error     = RegInit(False)
  val locked    = RegInit(False)
  when(io.ahb.HREADY) {
    when(!io.ahb.address.HMASTLOCK)(locked               := False)
    when(io.ahb.HSEL && io.ahb.address.HMASTLOCK)(locked := True)
  }
  io.ahb.HREADYOUT := state === State.IDLE || state === State.RESPONSE
  io.ahb.HRESP     := state === State.ERROR || (state === State.RESPONSE && error)
  io.ahb.HRDATA    := readData
  io.wb.CYC        := state === State.ACCESS || locked
  io.wb.STB        := state === State.ACCESS
  io.wb.LOCK       := locked
  io.wb.ADR        := address.HADDR
  io.wb.WE         := address.HWRITE
  io.wb.SEL        := J2Ahb.select(address.HADDR, address.HSIZE)
  io.wb.DAT_MOSI   := writeData
  switch(state) {
    is(State.CAPTURE) { writeData := io.ahb.HWDATA; state := State.ACCESS }
    is(State.ACCESS) {
      when(io.wb.ACK || io.wb.ERR) {
        readData := io.wb.DAT_MISO
        error    := io.wb.ERR
        state    := Mux(io.wb.ERR, State.ERROR, State.RESPONSE)
      }
    }
    is(State.ERROR)(state := State.RESPONSE)
    is(State.RESPONSE)(when(io.ahb.HREADY)(state := State.IDLE))
  }
  when(io.ahb.accepted) {
    address := io.ahb.address
    error   := False
    state   := State.CAPTURE
  }
}
