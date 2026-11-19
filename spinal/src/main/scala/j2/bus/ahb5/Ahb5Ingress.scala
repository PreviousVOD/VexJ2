package j2.bus.ahb5

import spinal.core._
import spinal.lib._

/** Manager-port ingress uses the same implementation with HSEL tied active. */
private[ahb5] class Ahb5Ingress(config: Ahb5Config) extends Component {
  val io = new Bundle {
    val bus       = slave(Ahb5Master(config))
    val transport = master(Ahb5Transport(config))
  }
  private val ingress = new Ahb5SubordinateIngress(config)
  ingress.io.bus.address                         := io.bus.address
  ingress.io.bus.HSEL                            := True
  ingress.io.bus.HREADY                          := ingress.io.bus.HREADYOUT
  ingress.io.bus.HWDATA                          := io.bus.HWDATA
  if (config.writeStrobes) ingress.io.bus.HWSTRB := io.bus.HWSTRB
  io.bus.HREADY                                  := ingress.io.bus.HREADYOUT
  io.bus.HRESP                                   := ingress.io.bus.HRESP
  io.bus.HRDATA                                  := ingress.io.bus.HRDATA
  io.transport <> ingress.io.transport
}

/** Ingress behind a decoder: selection and data completion use upstream HREADY. */
private[ahb5] class Ahb5SubordinateIngress(config: Ahb5Config) extends Component {
  val io = new Bundle {
    val bus       = slave(Ahb5(config))
    val transport = master(Ahb5Transport(config))
  }
  val busy               = RegInit(False)
  val haveData           = RegInit(False)
  val issued             = RegInit(False)
  val request            = Reg(Ahb5Request(config))
  val errorSecond        = RegInit(False)
  val reservation        = RegInit(False)
  val reservationControl = Reg(Ahb5Control(config))
  val continuing         = RegInit(False)

  val response = io.transport.response
  io.bus.HREADYOUT := !busy || (response.valid && (!response.error || errorSecond))
  io.bus.HRESP     := busy && response.valid && response.error
  io.bus.HRDATA    := response.data
  response.ready   := busy && io.bus.HREADY

  io.transport.request.valid      := busy && haveData && !issued
  io.transport.request.payload    := request
  io.transport.reservation        := reservation
  io.transport.reservationControl := reservationControl
  io.transport.continuing         := continuing

  when(busy && !haveData) {
    request.data                             := io.bus.HWDATA
    if (config.writeStrobes) request.strobes := io.bus.HWSTRB
    haveData                                 := True
  }
  when(io.transport.request.fire)(issued                     := True)
  when(busy && response.valid && response.error)(errorSecond := True)

  // The final response cycle may simultaneously accept the next address phase.
  when(io.bus.HREADY) {
    busy                            := io.bus.accepted
    haveData                        := False
    issued                          := False
    errorSecond                     := False
    when(io.bus.accepted)(request.control                     := io.bus.address)
    when(!io.bus.address.HMASTLOCK)(reservation               := False)
    when(io.bus.HSEL && io.bus.address.HMASTLOCK)(reservation := True)
    when(!reservation && io.bus.HSEL && io.bus.address.HMASTLOCK) {
      reservationControl := io.bus.address
    }
    continuing := io.bus.HSEL && (io.bus.address.HTRANS === Ahb5Trans.SEQ || io.bus.address.HTRANS === Ahb5Trans.BUSY)
  }
}
