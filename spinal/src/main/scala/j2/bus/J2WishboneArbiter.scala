package j2.bus

import spinal.core._
import spinal.lib._

/** Fair classic-Wishbone arbitration with ownership held for the whole cycle. STB can drop between
  * atomic transfers without releasing CYC/LOCK ownership.
  */
final class J2WishboneArbiter(inputCount: Int, instructionPairs: Map[Int, Int] = Map.empty)
    extends Component {
  require(inputCount > 0)
  // Map each CPU's data-owner index to its read-only instruction index.
  require(instructionPairs.forall { case (d, i) =>
    d >= 0 && d < inputCount && i >= 0 && i < inputCount && d != i
  })
  require(instructionPairs.values.toSet.size == instructionPairs.size)
  require(instructionPairs.keySet.intersect(instructionPairs.values.toSet).isEmpty)
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
    // Only the owning CPU's instruction port may borrow an idle atomic beat.
    // Keep the data grant and LOCK until the owner releases the cycle, and keep
    // the borrowed route stable until that instruction cycle ends (ACK or ERR).
    val route = cloneOf(grant)
    route := grant
    val borrowing = if (instructionPairs.nonEmpty) {
      val borrowed = Reg(Bits(inputCount bits)) init 0
      for ((owner, instruction) <- instructionPairs.toSeq.sortBy(_._1)) {
        val data  = io.inputs(owner)
        val fetch = io.inputs(instruction)
        when(
          !borrowed.orR && grant(owner) && data.CYC && data.LOCK && !data.STB &&
            fetch.CYC && fetch.STB && !fetch.WE
        ) {
          borrowed := B(BigInt(1) << instruction, inputCount bits)
        }
        when(borrowed(instruction) && !fetch.CYC)(borrowed := 0)
      }
      when(borrowed.orR)(route := borrowed)
      borrowed.orR
    } else False
    when(!held && !borrowing && proposal.orR)(grant := proposal)

    io.output.CYC := MuxOH(grant, Vec(io.inputs.map(_.CYC))) || MuxOH(
      route,
      Vec(io.inputs.map(_.CYC))
    )
    io.output.STB      := MuxOH(route, Vec(io.inputs.map(port => port.CYC && port.STB)))
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
