package j2.bus.ahb5

import spinal.core._
import spinal.lib._
import spinal.lib.bus.misc.SizeMapping

/** Routing-only matrix. Independent manager decoders expose one subordinate-side port per
  * manager/destination. Integrators explicitly attach arbiters or their own system BIUs; no
  * arbitration or system policy is hidden in this component.
  */
final class Ahb5RoutingMatrix(
    config: Ahb5Config,
    managerCount: Int,
    mappings: Seq[SizeMapping],
    connections: Seq[Set[Int]]
) extends Component {
  require(managerCount > 0 && connections.size == managerCount)
  require(mappings.nonEmpty && !SizeMapping.verifyOverlapping(mappings))
  require(connections.forall(c => c.nonEmpty && c.forall(i => i >= 0 && i < mappings.size)))
  val io = new Bundle {
    val managers     = Vec(slave(Ahb5Master(config)), managerCount)
    val destinations = Vec(Vec(master(Ahb5(config)), managerCount), mappings.size)
  }
  for (manager <- 0 until managerCount) {
    val reachable = connections(manager).toSeq.sorted
    val decoder   = new Ahb5Decoder(config, reachable.map(mappings))
    decoder.io.input <> io.managers(manager)
    for ((destination, port) <- reachable.zipWithIndex)
      io.destinations(destination)(manager) <> decoder.io.outputs(port)
    for (destination <- mappings.indices if !connections(manager)(destination)) {
      val output = io.destinations(destination)(manager)
      output.address.assignFromBits(B(0, output.address.getBitsWidth bits))
      output.HSEL                            := False
      output.HREADY                          := True
      output.HWDATA                          := 0
      if (config.writeStrobes) output.HWSTRB := 0
    }
  }
}
