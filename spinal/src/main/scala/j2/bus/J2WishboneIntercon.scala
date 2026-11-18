package j2.bus

import spinal.core._
import spinal.lib.bus.misc.AddressMapping
import spinal.lib.bus.wishbone.{Wishbone, WishboneDecoder}
import scala.collection.mutable
import scala.collection.Seq

/** Declarative decoder/arbiter matrix with J2 atomic-cycle preservation. */
case class J2WishboneIntercon() {
  private case class MasterModel(dataMaster: Option[Wishbone])
  private case class SlaveModel(mapping: AddressMapping)
  private case class ConnectionModel(m: Wishbone, s: Wishbone)

  private val masters     = mutable.LinkedHashMap[Wishbone, MasterModel]()
  private val slaves      = mutable.LinkedHashMap[Wishbone, SlaveModel]()
  private val connections = mutable.ArrayBuffer[ConnectionModel]()

  def addSlave(bus: Wishbone, mapping: AddressMapping): this.type = {
    require(!slaves.contains(bus), "slave already registered")
    slaves(bus) = SlaveModel(mapping)
    this
  }

  def addSlaves(specs: (Wishbone, AddressMapping)*): this.type = {
    specs.foreach(spec => addSlave(spec._1, spec._2))
    this
  }

  private def addMaster(
      bus: Wishbone,
      accesses: Seq[Wishbone],
      dataMaster: Option[Wishbone]
  ): this.type = {
    require(accesses.nonEmpty, "a matrix master needs at least one slave")
    require(!masters.contains(bus), "master already registered")
    require(accesses.distinct.size == accesses.size, "duplicate slave connection")
    masters(bus) = MasterModel(dataMaster)
    accesses.foreach(slave => connections += ConnectionModel(bus, slave))
    this
  }

  def addMaster(bus: Wishbone, accesses: Seq[Wishbone]): this.type =
    addMaster(bus, accesses, dataMaster = None)

  def addInstructionMaster(
      bus: Wishbone,
      dataMaster: Wishbone,
      accesses: Seq[Wishbone]
  ): this.type =
    addMaster(bus, accesses, dataMaster = Some(dataMaster))

  private def connect(source: Wishbone, target: Wishbone): Unit = {
    target.CYC      := source.CYC
    target.STB      := source.STB
    target.WE       := source.WE
    target.ADR      := source.ADR
    target.DAT_MOSI := source.DAT_MOSI
    target.SEL      := source.SEL
    target.LOCK     := source.LOCK && source.CYC
    source.ACK      := target.ACK
    source.ERR      := target.ERR
    source.DAT_MISO := target.DAT_MISO
  }

  def build(): Unit = {
    // Validate after registration so instruction/data declaration order is irrelevant.
    val owners = masters.values.flatMap(_.dataMaster).toSeq
    require(
      owners.distinct.size == owners.size,
      "a data master may have only one instruction partner"
    )
    for ((bus, model) <- masters; owner <- model.dataMaster) {
      require(
        owner != bus && masters.contains(owner),
        "instruction partner must be a registered data master"
      )
      require(
        masters(owner).dataMaster.isEmpty,
        "instruction partner cannot itself be an instruction master"
      )
    }
    require(connections.forall(c => slaves.contains(c.s)), "connection to an unregistered slave")
    val decoded = mutable.HashMap[ConnectionModel, Wishbone]()
    for ((bus, model) <- masters) {
      val busConnections = connections.filter(_.m == bus).toSeq
      val decoder = new WishboneDecoder(
        bus.config,
        busConnections.map(connection => slaves(connection.s).mapping)
      )
      decoder.setCompositeName(bus, "decoder")
      bus >> decoder.io.input
      for ((connection, output) <- busConnections.zip(decoder.io.outputs))
        decoded(connection) = output
    }

    for ((bus, _) <- slaves) {
      val busConnections = connections.filter(_.s == bus).toSeq
      if (busConnections.size == 1) {
        connect(decoded(busConnections.head), bus)
      } else if (busConnections.nonEmpty) {
        // Resolve roles in this slave's local input list, not global registration order.
        // If a CPU's data port cannot reach this slave, its instruction port
        // arbitrates normally and cannot borrow another master's lock.
        val pairs = busConnections.zipWithIndex.flatMap { case (connection, instructionIndex) =>
          masters(connection.m).dataMaster.flatMap { owner =>
            val ownerIndex = busConnections.indexWhere(_.m == owner)
            if (ownerIndex >= 0) Some(ownerIndex -> instructionIndex) else None
          }
        }.toMap
        val arbiter = new J2WishboneArbiter(busConnections.size, pairs)
        arbiter.setCompositeName(bus, "arbiter")
        arbiter.io.output >> bus
        for ((connection, input) <- busConnections.zip(arbiter.io.inputs))
          connect(decoded(connection), input)
      }
    }
  }

  Component.current.addPrePopTask(build)
}
