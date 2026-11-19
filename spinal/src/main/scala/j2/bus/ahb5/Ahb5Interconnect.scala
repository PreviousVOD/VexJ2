package j2.bus.ahb5

import spinal.core._
import spinal.lib._
import spinal.lib.bus.misc.SizeMapping

/** Generic single-clock multilayer interconnect. Each mapping is one arbitration/lock domain, and
  * may feed a downstream peripheral decoder or memory bridge rather than one device.
  */
class Ahb5Interconnect(
    config: Ahb5Config,
    managerCount: Int,
    mappings: Seq[SizeMapping],
    connections: Seq[Set[Int]] = Nil
) extends Component {
  require(managerCount > 0 && mappings.nonEmpty)
  require(!SizeMapping.verifyOverlapping(mappings), "AHB5 destination regions overlap")
  require(
    mappings.forall(m =>
      m.base >= 0 && m.size > 0 && m.base + m.size <= (BigInt(1) << config.addressWidth)
    )
  )
  require(
    mappings.forall(m => m.base % 1024 == 0 && m.size % 1024 == 0),
    "IHI0033C section 4.2: subordinate regions must start/end on 1KB boundaries"
  )
  private val access =
    if (connections.isEmpty) Seq.fill(managerCount)(mappings.indices.toSet) else connections
  require(access.size == managerCount)
  require(access.forall(_.forall(i => i >= 0 && i < mappings.size)))
  val io = new Bundle {
    val managers     = Vec(slave(Ahb5Master(config)), managerCount)
    val subordinates = Vec(master(Ahb5(config)), mappings.size)
  }
  private val decoders = (0 until managerCount).map { index =>
    val ingress = new Ahb5Ingress(config)
    ingress.io.bus <> io.managers(index)
    val decoder = new Ahb5Router(config, mappings, access(index))
    decoder.io.input <> ingress.io.transport
    decoder
  }
  for (index <- mappings.indices) {
    val arbiter = new Ahb5ArbiterEngine(config, managerCount)
    arbiter.setName(s"arbiter_$index")
    for (manager <- 0 until managerCount)
      arbiter.io.inputs(manager) <> decoders(manager).io.outputs(index)
    io.subordinates(index) <> arbiter.io.output
  }
}
