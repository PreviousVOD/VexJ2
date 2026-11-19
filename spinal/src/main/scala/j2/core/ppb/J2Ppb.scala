package j2.core.ppb

import j2.bus.J2Ahb
import j2.bus.ahb5._
import j2.bus.apb._
import spinal.core._
import spinal.lib._
import spinal.lib.bus.misc.SizeMapping

object J2Ppb {
  val aperture = SizeMapping(BigInt("ffffe000", 16), 0x1000)
  val intc     = SizeMapping(BigInt("ffffe900", 16), 0x200)
}

/** Split the private aperture from an external manager port. Address selection and response
  * ownership are separate: a following address must not redirect an outstanding response.
  */
final class J2PpbRouter extends Component {
  val io = new Bundle {
    val input      = slave(J2Ahb.manager())
    val external   = master(J2Ahb.manager())
    val privateBus = master(J2Ahb.subordinate())
  }
  private val privateAddress         = J2Ppb.aperture.hit(io.input.address.HADDR)
  private val privateData            = RegInit(False)
  private val privateReady           = io.privateBus.HREADYOUT
  private val externalAddressAllowed = !privateAddress && (!privateData || privateReady)

  // Complete a private response and hand off the next external address on the same
  // edge only when the independent external manager port can accept that address.
  io.input.HREADY := Mux(
    privateData,
    privateReady && (privateAddress || io.external.HREADY),
    io.external.HREADY
  )
  io.input.HRESP  := Mux(privateData, io.privateBus.HRESP, io.external.HRESP)
  io.input.HRDATA := Mux(privateData, io.privateBus.HRDATA, io.external.HRDATA)
  when(io.input.HREADY)(privateData := privateAddress)

  io.privateBus.address := io.input.address
  io.privateBus.HWDATA  := io.input.HWDATA
  io.privateBus.HSEL    := privateAddress
  io.privateBus.HREADY  := io.input.HREADY

  io.external.address := io.input.address
  // This also suppresses IDLE reservations: the shared fabric observes HMASTLOCK even
  // without a transfer. A private TAS must never reserve a shared subordinate.
  when(!externalAddressAllowed) {
    io.external.address.HTRANS    := Ahb5Trans.IDLE
    io.external.address.HMASTLOCK := False
  }
  io.external.HWDATA := io.input.HWDATA
}

/** Core-local width/protection checks, followed by the project AHB/APB bridge and matrix. The INTC
  * port uses absolute addresses. Its registers are supplied by the next plan step.
  */
final class J2PpbFabric extends Component {
  val io = new Bundle {
    val bus  = slave(J2Ahb.subordinate())
    val intc = master(Apb4(Apb4Config(32, 32)))
  }
  private val bridge = new Ahb5ToApb4Bridge(J2Ahb.config, wordInvariantBigEndian = true)
  private val error  = new Ahb5DefaultSubordinate(J2Ahb.config)
  private val legal = J2Ppb.aperture.hit(io.bus.address.HADDR) &&
    io.bus.address.HPROT(0) && io.bus.address.HSIZE === 2 &&
    io.bus.address.HADDR(1 downto 0) === 0
  private val dataLegal = RegInit(False)
  when(io.bus.HREADY)(dataLegal := io.bus.HSEL && legal)
  for ((target, selected) <- Seq(bridge.io.ahb -> legal, error.io.bus -> !legal)) {
    target.address := io.bus.address
    target.HWDATA  := io.bus.HWDATA
    target.HREADY  := io.bus.HREADY
    target.HSEL    := io.bus.HSEL && selected
  }
  io.bus.HREADYOUT := Mux(dataLegal, bridge.io.ahb.HREADYOUT, error.io.bus.HREADYOUT)
  io.bus.HRESP     := Mux(dataLegal, bridge.io.ahb.HRESP, error.io.bus.HRESP)
  io.bus.HRDATA    := Mux(dataLegal, bridge.io.ahb.HRDATA, error.io.bus.HRDATA)

  private val matrix = new Apb4Matrix(bridge.apbConfig, Seq(J2Ppb.intc))
  matrix.io.input <> bridge.io.apb
  io.intc <> matrix.io.outputs(0)
}
