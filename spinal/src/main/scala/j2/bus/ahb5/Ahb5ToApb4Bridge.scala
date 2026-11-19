package j2.bus.ahb5

import spinal.core._
import spinal.lib._
import j2.bus.apb._

/** Same-clock, non-posted AHB5 to APB4 bridge with matching bus widths. wordInvariantBigEndian
  * selects AHB word-invariant big-endian lanes (the SH-2 profile). Little-endian and BE8 use the
  * default lane selection. APB addresses are word aligned. Reads fetch the complete APB word; AHB
  * managers select lanes. HSIZE/HADDR determine active write lanes; optional HWSTRB further
  * restricts them.
  */
final class Ahb5ToApb4Bridge(config: Ahb5Config, wordInvariantBigEndian: Boolean = false)
    extends Component {
  require(Set(8, 16, 32)(config.dataWidth))
  require(!wordInvariantBigEndian || config.dataWidth == 32, "BE32 needs a 32-bit data bus")
  require(config.addressWidth <= 32)
  val apbConfig = Apb4Config(config.addressWidth, config.dataWidth)
  val io = new Bundle {
    val ahb = slave(Ahb5(config))
    val apb = master(Apb4(apbConfig))
  }
  private object State extends SpinalEnum {
    val IDLE, CAPTURE, SETUP, ACCESS, RESPONSE, ERROR = newElement()
  }
  private val state            = RegInit(State.IDLE)
  private val address          = Reg(UInt(config.addressWidth bits)) init (0)
  private val write            = RegInit(False)
  private val data, result     = Reg(Bits(config.dataWidth bits))
  private val protection       = Reg(Bits(3 bits)) init (0)
  private val lanes, strobes   = Reg(Bits(config.bytes bits)) init (0)
  private val supported, error = RegInit(False)
  private val offsetBits       = log2Up(config.bytes)
  private val legal            = Bool()
  private val activeLanes      = Bits(config.bytes bits)
  legal       := False
  activeLanes := 0
  for (size <- 0 to offsetBits; offset <- 0 until config.bytes by (1 << size)) {
    val hit =
      if (offsetBits == 0) True else io.ahb.address.HADDR(offsetBits - 1 downto 0) === offset
    when(io.ahb.address.HSIZE === size && hit) {
      legal := True
      val lane = if (wordInvariantBigEndian) config.bytes - (1 << size) - offset else offset
      activeLanes := B(((BigInt(1) << (1 << size)) - 1) << lane, config.bytes bits)
    }
  }
  io.ahb.HREADYOUT := state === State.IDLE || state === State.RESPONSE
  io.ahb.HRESP     := state === State.ERROR || (state === State.RESPONSE && error)
  io.ahb.HRDATA    := result
  io.apb.PADDR     := address
  io.apb.PWRITE    := write
  io.apb.PWDATA    := data
  io.apb.PSTRB     := strobes
  io.apb.PPROT     := protection
  io.apb.PSEL(0)   := state === State.SETUP || state === State.ACCESS
  io.apb.PENABLE   := state === State.ACCESS
  switch(state) {
    is(State.CAPTURE) {
      data    := io.ahb.HWDATA
      strobes := 0
      when(write) {
        strobes := (if (config.writeStrobes) lanes & io.ahb.HWSTRB else lanes)
      }
      when(supported)(state := State.SETUP)
        .otherwise { error := True; state := State.ERROR }
    }
    is(State.SETUP)(state := State.ACCESS)
    is(State.ACCESS) {
      when(io.apb.PREADY) {
        result := io.apb.PRDATA
        error  := io.apb.PSLVERR
        state  := Mux(io.apb.PSLVERR, State.ERROR, State.RESPONSE)
      }
    }
    is(State.ERROR)(state := State.RESPONSE)
    is(State.RESPONSE)(when(io.ahb.HREADY)(state := State.IDLE))
  }
  when(io.ahb.accepted) {
    address := io.ahb.address.HADDR & U(
      (BigInt(1) << config.addressWidth) - config.bytes,
      config.addressWidth bits
    )
    write         := io.ahb.address.HWRITE
    supported     := legal
    lanes         := activeLanes
    protection(0) := io.ahb.address.HPROT(1)
    protection(1) := (if (config.secureTransfers) io.ahb.address.HNONSEC else False)
    protection(2) := !io.ahb.address.HPROT(0)
    error         := False
    state         := State.CAPTURE
  }
}
