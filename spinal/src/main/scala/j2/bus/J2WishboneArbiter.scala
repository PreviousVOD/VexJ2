package j2.bus

import spinal.core._
import spinal.lib._

/** Fair classic-Wishbone arbitration with ownership held for the whole cycle. STB can drop between
  * atomic transfers without releasing CYC/LOCK ownership.
  */
final class J2WishboneArbiter(inputCount: Int, instructionInput: Option[Int] = None)
    extends Component {
  require(inputCount > 0)
  // When supplied, input 0 is this CPU's data port; the designated input is
  // its instruction port, never a second CPU or a general-purpose reader.
  require(instructionInput.forall(i => i > 0 && i < inputCount))
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
    // The CPU freezes its microsequencer on an outstanding fetch. Its own
    // read-only instruction port must therefore be able to use an idle beat
    // inside its data atomic cycle. Retain ownership (and downstream LOCK)
    // throughout; unrelated masters must still wait for the atomic to finish.
    val route = cloneOf(grant)
    route := grant
    val borrowing = instructionInput match {
      case Some(index) =>
        val borrowed    = RegInit(False)
        val ownerStrobe = MuxOH(grant, Vec(io.inputs.map(_.STB)))
        val ownerLock   = MuxOH(grant, Vec(io.inputs.map(_.LOCK)))
        when(
          !borrowed && grant(0) && ownerLock && !ownerStrobe &&
            io.inputs(index).CYC && !io.inputs(index).WE
        ) {
          borrowed := True
        }
        when(borrowed && !io.inputs(index).CYC)(borrowed := False)
        when(borrowed)(route := B(BigInt(1) << index, inputCount bits))
        borrowed
      case None => False
    }
    when(!held && !borrowing && proposal.orR)(grant := proposal)

    io.output.CYC := MuxOH(grant, Vec(io.inputs.map(_.CYC))) || MuxOH(
      route,
      Vec(io.inputs.map(_.CYC))
    )
    io.output.STB      := MuxOH(route, Vec(io.inputs.map(_.STB)))
    io.output.WE       := MuxOH(route, Vec(io.inputs.map(_.WE)))
    io.output.ADR      := MuxOH(route, Vec(io.inputs.map(_.ADR)))
    io.output.DAT_MOSI := MuxOH(route, Vec(io.inputs.map(_.DAT_MOSI)))
    io.output.SEL      := MuxOH(route, Vec(io.inputs.map(_.SEL)))
    io.output.LOCK     := MuxOH(grant, Vec(io.inputs.map(_.LOCK)))
    for ((port, index) <- io.inputs.zipWithIndex) {
      port.DAT_MISO := io.output.DAT_MISO
      port.ACK      := route(index) && port.CYC && port.STB && io.output.ACK
      port.ERR      := route(index) && port.CYC && port.STB && io.output.ERR
    }
  }
}
