package j2.bus

import spinal.core._
import spinal.lib._

/** Fair classic-Wishbone arbitration with ownership held for the whole cycle. STB can drop between
  * atomic transfers without releasing CYC/LOCK ownership.
  */
final class J2WishboneArbiter(inputCount: Int) extends Component {
  require(inputCount > 0)
  val io = new Bundle {
    val inputs = Vec(slave(J2Wishbone()), inputCount)
    val output = master(J2Wishbone())
  }
  if (inputCount == 1) {
    io.inputs(0) <> io.output
  } else {
    val grant    = RegInit(B(1, inputCount bits))
    val requests = Vec(io.inputs.map(port => port.CYC || port.LOCK))
    val held     = MuxOH(grant, requests)
    val priority = Vec(grant.asBools.last +: grant.asBools.take(inputCount - 1))
    val proposal = OHMasking.roundRobin(requests, priority).asBits
    when(!held && proposal.orR)(grant := proposal)

    io.output.CYC      := MuxOH(grant, Vec(io.inputs.map(_.CYC)))
    io.output.STB      := MuxOH(grant, Vec(io.inputs.map(_.STB)))
    io.output.WE       := MuxOH(grant, Vec(io.inputs.map(_.WE)))
    io.output.ADR      := MuxOH(grant, Vec(io.inputs.map(_.ADR)))
    io.output.DAT_MOSI := MuxOH(grant, Vec(io.inputs.map(_.DAT_MOSI)))
    io.output.SEL      := MuxOH(grant, Vec(io.inputs.map(_.SEL)))
    io.output.LOCK     := MuxOH(grant, Vec(io.inputs.map(_.LOCK)))
    for ((port, index) <- io.inputs.zipWithIndex) {
      port.DAT_MISO := io.output.DAT_MISO
      port.ACK      := grant(index) && port.CYC && port.STB && io.output.ACK
      port.ERR      := grant(index) && port.CYC && port.STB && io.output.ERR
    }
  }
}
