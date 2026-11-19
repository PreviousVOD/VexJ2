package j2.bus.ahb5

import spinal.core._
import spinal.lib._
import spinal.lib.bus.amba3.apb._

/** Same-clock, non-posted AHB5 to APB3 bridge. APB3 has no byte strobes, so only naturally aligned
  * full-width accesses are supported. Unsupported requests complete with ERROR without touching
  * APB. Arbitration/locks belong upstream.
  */
final class Ahb5ToApb3Bridge(config: Ahb5Config) extends Component {
  require(Set(8, 16, 32)(config.dataWidth), "APB supports 8, 16 or 32 data bits")
  require(config.addressWidth <= 32, "APB address width is at most 32 bits")
  val apbConfig = Apb3Config(config.addressWidth, config.dataWidth, useSlaveError = true)
  val io = new Bundle {
    val ahb = slave(Ahb5(config))
    val apb = master(Apb3(apbConfig))
  }
  private object State extends SpinalEnum {
    val IDLE, CAPTURE, SETUP, ACCESS, RESPONSE, ERROR = newElement()
  }
  private val state            = RegInit(State.IDLE)
  private val address          = Reg(UInt(config.addressWidth bits))
  private val write            = Reg(Bool())
  private val data, result     = Reg(Bits(config.dataWidth bits))
  private val supported, error = RegInit(False)
  private val size             = log2Up(config.dataWidth / 8)
  io.ahb.HREADYOUT := state === State.IDLE || state === State.RESPONSE
  io.ahb.HRESP     := state === State.ERROR || (state === State.RESPONSE && error)
  io.ahb.HRDATA    := result
  io.apb.PADDR     := address
  io.apb.PWRITE    := write
  io.apb.PWDATA    := data
  io.apb.PSEL(0)   := state === State.SETUP || state === State.ACCESS
  io.apb.PENABLE   := state === State.ACCESS
  switch(state) {
    is(State.CAPTURE) {
      data := io.ahb.HWDATA
      val strobesOk = if (config.writeStrobes) !write || io.ahb.HWSTRB.andR else True
      when(supported && strobesOk)(state := State.SETUP)
        .otherwise { error := True; state := State.ERROR }
    }
    is(State.SETUP)(state := State.ACCESS)
    is(State.ACCESS) {
      when(io.apb.PREADY) {
        result := io.apb.PRDATA
        error  := io.apb.PSLVERROR
        state  := Mux(io.apb.PSLVERROR, State.ERROR, State.RESPONSE)
      }
    }
    is(State.ERROR)(state := State.RESPONSE)
    is(State.RESPONSE)(when(io.ahb.HREADY)(state := State.IDLE))
  }
  when(io.ahb.accepted) {
    address := io.ahb.address.HADDR
    write   := io.ahb.address.HWRITE
    supported := io.ahb.address.HSIZE === size &&
      (if (size == 0) True else io.ahb.address.HADDR(size - 1 downto 0) === 0)
    error := False
    state := State.CAPTURE
  }
}
