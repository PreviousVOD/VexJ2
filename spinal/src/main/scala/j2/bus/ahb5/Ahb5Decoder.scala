package j2.bus.ahb5

import spinal.core._
import spinal.lib._
import spinal.lib.bus.misc.SizeMapping

/** Per-manager routing. One outstanding request means its captured address also owns the response.
  * Reservation decoding is independent of transfer validity, so an IDLE unlock is never lost.
  */
private[ahb5] class Ahb5Router(config: Ahb5Config, mappings: Seq[SizeMapping], access: Set[Int])
    extends Component {
  require(mappings.nonEmpty)
  require(access.forall(i => i >= 0 && i < mappings.size))
  val io = new Bundle {
    val input   = slave(Ahb5Transport(config))
    val outputs = Vec(master(Ahb5Transport(config)), mappings.size)
  }
  val hits = mappings.zipWithIndex.map { case (mapping, index) =>
    if (access(index)) mapping.hit(io.input.request.control.HADDR) else False
  }
  val miss         = !hits.reduce(_ || _)
  val errorPending = RegInit(False)
  when(io.input.request.fire && miss)(errorPending := True)
  when(io.input.response.fire)(errorPending        := False)

  io.input.request.ready  := miss && !errorPending
  io.input.response.valid := errorPending
  io.input.response.data  := 0
  io.input.response.error := True
  for (((output, mapping), index) <- io.outputs.zip(mappings).zipWithIndex) {
    output.request.payload    := io.input.request.payload
    output.request.valid      := io.input.request.valid && hits(index)
    output.response.ready     := io.input.response.ready && hits(index)
    output.reservationControl := io.input.reservationControl
    output.reservation := io.input.reservation &&
      (if (access(index)) mapping.hit(io.input.reservationControl.HADDR) else False)
    output.continuing := io.input.continuing
    when(hits(index)) {
      io.input.request.ready    := output.request.ready
      io.input.response.valid   := output.response.valid
      io.input.response.payload := output.response.payload
    }
  }
}

/** Default subordinate (section 4.2): IDLE/BUSY get OKAY; real accesses get two-cycle ERROR. */
class Ahb5DefaultSubordinate(config: Ahb5Config) extends Component {
  val io      = new Bundle { val bus = slave(Ahb5(config)) }
  val pending = RegInit(False)
  val second  = RegInit(False)
  io.bus.HREADYOUT := !pending || second
  io.bus.HRESP     := pending
  io.bus.HRDATA    := 0
  when(pending)(second := True)
  when(io.bus.HREADY) {
    pending := io.bus.accepted
    second  := False
  }
}

/** Pipelined one-manager decoder with separate address and data selection (section 4.2). Unlike the
  * elastic matrix, this component adds no transfer buffering or wait cycles.
  */
class Ahb5Decoder(config: Ahb5Config, mappings: Seq[SizeMapping]) extends Component {
  require(mappings.nonEmpty && !SizeMapping.verifyOverlapping(mappings))
  require(
    mappings.forall(m =>
      m.base >= 0 && m.size > 0 &&
        m.base + m.size <= (BigInt(
          1
        ) << config.addressWidth) && m.base % 1024 == 0 && m.size % 1024 == 0
    )
  )
  val io = new Bundle {
    val input   = slave(Ahb5Master(config))
    val outputs = Vec(master(Ahb5(config)), mappings.size)
  }
  val default    = new Ahb5DefaultSubordinate(config)
  val outputs    = io.outputs.toSeq :+ default.io.bus
  val hits       = mappings.map(_.hit(io.input.address.HADDR))
  val selections = hits :+ !hits.reduce(_ || _)
  val dataSelect = Reg(UInt(log2Up(outputs.size) bits)) init (mappings.size)
  when(io.input.HREADY)(dataSelect := OHToUInt(selections))
  for ((output, selected) <- outputs.zip(selections)) {
    output.address                         := io.input.address
    output.HSEL                            := selected
    output.HREADY                          := io.input.HREADY
    output.HWDATA                          := io.input.HWDATA
    if (config.writeStrobes) output.HWSTRB := io.input.HWSTRB
  }
  io.input.HREADY := Vec(outputs.map(_.HREADYOUT))(dataSelect)
  io.input.HRESP  := Vec(outputs.map(_.HRESP))(dataSelect)
  io.input.HRDATA := Vec(outputs.map(_.HRDATA))(dataSelect)
}

/** Subordinate-facing decoder for a peripheral domain behind a BIU. The upstream HREADY qualifies
  * selection; HSEL is retained even for IDLE lock signaling.
  */
class Ahb5SubordinateDecoder(config: Ahb5Config, mappings: Seq[SizeMapping]) extends Component {
  require(mappings.nonEmpty && !SizeMapping.verifyOverlapping(mappings))
  require(
    mappings.forall(m =>
      m.base >= 0 && m.size > 0 &&
        m.base + m.size <= (BigInt(
          1
        ) << config.addressWidth) && m.base % 1024 == 0 && m.size % 1024 == 0
    )
  )
  val io = new Bundle {
    val input   = slave(Ahb5(config))
    val outputs = Vec(master(Ahb5(config)), mappings.size)
  }
  private val default    = new Ahb5DefaultSubordinate(config)
  private val outputs    = io.outputs.toSeq :+ default.io.bus
  private val hits       = mappings.map(_.hit(io.input.address.HADDR))
  private val selections = hits :+ !hits.reduce(_ || _)
  private val dataSelect = Reg(UInt(log2Up(outputs.size) bits)) init (mappings.size)
  when(io.input.HREADY) {
    dataSelect := mappings.size
    when(io.input.HSEL)(dataSelect := OHToUInt(selections))
  }
  for ((output, selected) <- outputs.zip(selections)) {
    output.address                         := io.input.address
    output.HSEL                            := selected && io.input.HSEL
    output.HREADY                          := io.input.HREADY
    output.HWDATA                          := io.input.HWDATA
    if (config.writeStrobes) output.HWSTRB := io.input.HWSTRB
  }
  io.input.HREADYOUT := Vec(outputs.map(_.HREADYOUT))(dataSelect)
  io.input.HRESP     := Vec(outputs.map(_.HRESP))(dataSelect)
  io.input.HRDATA    := Vec(outputs.map(_.HRDATA))(dataSelect)
}
