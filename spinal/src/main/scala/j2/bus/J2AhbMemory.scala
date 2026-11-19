package j2.bus

import spinal.core._
import spinal.lib._

/** Internal one-word memory operation, not an external bus protocol. */
case class J2MemoryRequest() extends Bundle {
  val address = UInt(32 bits)
  val data    = Bits(32 bits)
  val mask    = Bits(4 bits)
  val write   = Bool()
}
case class J2MemoryResponse() extends Bundle {
  val data  = Bits(32 bits)
  val error = Bool()
}
case class J2MemoryPort() extends Bundle with IMasterSlave {
  val cmd                       = Stream(J2MemoryRequest())
  val rsp                       = Stream(J2MemoryResponse())
  override def asMaster(): Unit = { master(cmd); slave(rsp) }
}

/** AHB data-phase owner for a blocking memory leaf. Address acceptance and write data capture are
  * separate; accepted transfers cannot be canceled by HSEL or HTRANS of the following address
  * phase. Locks belong to the upstream arbiter.
  */
final class J2AhbMemoryEndpoint extends Component {
  val io = new Bundle {
    val ahb    = slave(J2Ahb.subordinate())
    val memory = master(J2MemoryPort())
  }
  object State extends SpinalEnum { val IDLE, DATA, ISSUE, WAIT, ERROR, RESPONSE = newElement() }
  private val state    = RegInit(State.IDLE)
  private val request  = Reg(J2MemoryRequest())
  private val invalid  = Reg(Bool())
  private val response = Reg(J2MemoryResponse())
  private val error    = RegInit(False)
  io.ahb.HREADYOUT      := state === State.IDLE || state === State.RESPONSE
  io.ahb.HRESP          := state === State.ERROR || (state === State.RESPONSE && error)
  io.ahb.HRDATA         := response.data
  io.memory.cmd.valid   := state === State.ISSUE
  io.memory.cmd.payload := request
  io.memory.rsp.ready   := state === State.WAIT
  switch(state) {
    is(State.DATA) {
      request.data := io.ahb.HWDATA
      when(invalid) { error := True; state := State.ERROR }
        .otherwise(state := State.ISSUE)
    }
    is(State.ISSUE)(when(io.memory.cmd.fire)(state := State.WAIT))
    is(State.WAIT) {
      when(io.memory.rsp.fire) {
        response := io.memory.rsp.payload
        error    := io.memory.rsp.error
        state    := Mux(io.memory.rsp.error, State.ERROR, State.RESPONSE)
      }
    }
    is(State.ERROR)(state := State.RESPONSE)
    is(State.RESPONSE)(when(io.ahb.HREADY)(state := State.IDLE))
  }
  when(io.ahb.accepted) {
    request.address := io.ahb.address.HADDR
    request.write   := io.ahb.address.HWRITE
    request.mask    := J2Ahb.select(io.ahb.address.HADDR, io.ahb.address.HSIZE)
    invalid := io.ahb.address.HSIZE > 2 ||
      (io.ahb.address.HSIZE === 1 && io.ahb.address.HADDR(0)) ||
      (io.ahb.address.HSIZE === 2 && io.ahb.address.HADDR(1 downto 0) =/= 0)
    error := False
    state := State.DATA
  }
}
