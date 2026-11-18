package j2.bus

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import spinal.lib.bus.misc.SizeMapping

class J2WishbonePairingSpec extends munit.FunSuite {
  class Master extends Component { val bus = master(J2Wishbone()).simPublic() }
  class Slave extends Component { val bus = slave(J2Wishbone()).simPublic() }
  class MatrixProbe(instructionFirst: Boolean = false, twoCpus: Boolean = false) extends Component {
    val data, other, instruction = new Master
    val instruction2             = if (twoCpus) new Master else null
    val ram                      = new Slave
    val matrix                   = J2WishboneIntercon()
    matrix.addSlave(ram.bus, SizeMapping(0x1000, 0x1000))
    if (instructionFirst) matrix.addInstructionMaster(instruction.bus, data.bus, Seq(ram.bus))
    matrix.addMaster(data.bus, Seq(ram.bus))
    matrix.addMaster(other.bus, Seq(ram.bus))
    if (!instructionFirst) matrix.addInstructionMaster(instruction.bus, data.bus, Seq(ram.bus))
    if (twoCpus) matrix.addInstructionMaster(instruction2.bus, other.bus, Seq(ram.bus))
  }
  def initialize(d: MatrixProbe): Unit = {
    for (
      b <- Seq(d.data.bus, d.other.bus, d.instruction.bus) ++ Option(d.instruction2).map(_.bus)
    ) {
      b.CYC #= false; b.STB  #= false; b.WE    #= false; b.LOCK #= false
      b.ADR #= 0x1000; b.SEL #= 15; b.DAT_MOSI #= 0
    }
    d.ram.bus.ACK          #= false; d.ram.bus.ERR #= false; d.ram.bus.DAT_MISO #= 0
    d.clockDomain.clockSim #= false
    d.clockDomain.assertReset()
    for (_ <- 0 until 4) edge(d)
    d.clockDomain.deassertReset(); sleep(1)
  }
  def edge(d: MatrixProbe): Unit = {
    d.clockDomain.clockSim #= true; sleep(5)
    d.clockDomain.clockSim #= false; sleep(5)
  }
  test("negating CYC releases a reservation even if LOCK remains asserted") {
    SimConfig.withVerilator.compile(new MatrixProbe).doSim { d =>
      initialize(d)
      d.data.bus.CYC #= true; d.data.bus.STB #= true; d.data.bus.LOCK #= true
      sleep(1); edge(d)
      d.ram.bus.ACK #= true; sleep(1)
      assert(d.data.bus.ACK.toBoolean)
      edge(d)
      // Wishbone defines reservation release on either CYC or LOCK negation.
      d.data.bus.CYC  #= false; d.data.bus.STB #= false
      d.other.bus.CYC #= true; d.other.bus.STB #= true; d.other.bus.WE #= true
      sleep(1)
      var released = false
      for (_ <- 0 until 4) {
        edge(d)
        released ||= d.other.bus.ACK.toBoolean
      }
      assert(released, "reservation survived the end of CYC")
    }
  }
  test("instruction registration order does not change matrix validity") {
    SimConfig.withVerilator.compile(new MatrixProbe(instructionFirst = true))
  }
  test("second CPU can fetch during its own locked RMW gap") {
    SimConfig.withVerilator.compile(new MatrixProbe(twoCpus = true)).doSim { d =>
      initialize(d)
      d.other.bus.CYC #= true; d.other.bus.STB #= true; d.other.bus.LOCK #= true
      sleep(1); edge(d); edge(d)
      d.ram.bus.ACK #= true; sleep(1)
      assert(d.other.bus.ACK.toBoolean)
      edge(d)
      d.other.bus.STB        #= false
      d.instruction2.bus.CYC #= true; d.instruction2.bus.STB #= true
      sleep(1)
      var completed = false
      for (_ <- 0 until 20) {
        edge(d)
        completed ||= d.instruction2.bus.ACK.toBoolean
      }
      assert(completed, "second CPU fetch deadlocks behind its own data lock")
    }
  }
  test("an instruction port must not borrow an unrelated data owner's lock") {
    SimConfig.withVerilator.compile(new MatrixProbe).doSim { d =>
      initialize(d)
      d.other.bus.CYC #= true; d.other.bus.STB #= true; d.other.bus.LOCK #= true
      sleep(1); edge(d); edge(d)
      d.ram.bus.ACK #= true; sleep(1)
      assert(d.other.bus.ACK.toBoolean)
      edge(d)
      d.other.bus.STB       #= false
      d.instruction.bus.CYC #= true; d.instruction.bus.STB #= true
      sleep(1)
      for (_ <- 0 until 4) {
        edge(d)
        assert(
          !d.instruction.bus.ACK.toBoolean,
          "unrelated instruction read bypassed another master's lock"
        )
      }
    }
  }

  test(
    "both CPU pairs retain response ownership through waits and errors with instruction input zero"
  ) {
    val compiled =
      SimConfig.withVerilator.compile(new MatrixProbe(instructionFirst = true, twoCpus = true))
    for (ownerIndex <- 0 until 2; error <- Seq(false, true)) compiled.doSim { d =>
      initialize(d)
      val data           = Seq(d.data.bus, d.other.bus)
      val instructions   = Seq(d.instruction.bus, d.instruction2.bus)
      val owner          = data(ownerIndex)
      val fetch          = instructions(ownerIndex)
      val competitor     = data(1 - ownerIndex)
      val unrelatedFetch = instructions(1 - ownerIndex)
      owner.ADR #= 0x1100; owner.CYC #= true; owner.STB #= true; owner.LOCK #= true
      sleep(1)
      for (_ <- 0 until 3) edge(d)
      assertEquals(d.ram.bus.ADR.toLong, 0x1100L)
      d.ram.bus.ACK #= true; sleep(1)
      assert(owner.ACK.toBoolean)
      edge(d)
      d.ram.bus.ACK      #= false; owner.STB           #= false
      competitor.ADR     #= 0x1200; competitor.CYC     #= true; competitor.STB     #= true;
      competitor.WE      #= true
      unrelatedFetch.ADR #= 0x1300; unrelatedFetch.CYC #= true; unrelatedFetch.STB #= true
      fetch.ADR          #= 0x1400; fetch.CYC          #= true; fetch.STB          #= true
      sleep(1); edge(d)
      for (waitCycle <- 0 until 5) {
        assert(d.ram.bus.CYC.toBoolean && d.ram.bus.STB.toBoolean && d.ram.bus.LOCK.toBoolean)
        assertEquals(d.ram.bus.ADR.toLong, 0x1400L)
        assert(!d.ram.bus.WE.toBoolean)
        assert(!competitor.ACK.toBoolean && !unrelatedFetch.ACK.toBoolean && !owner.ACK.toBoolean)
        // An independently progressing owner may request its write before the
        // borrowed fetch finishes. It must not change that pending transfer.
        if (waitCycle == 1) { owner.STB #= true; owner.WE #= true }
        edge(d)
      }
      d.ram.bus.DAT_MISO #= 0x12345678
      d.ram.bus.ERR      #= error; d.ram.bus.ACK #= !error
      sleep(1)
      assertEquals(fetch.ACK.toBoolean, !error)
      assertEquals(fetch.ERR.toBoolean, error)
      assertEquals(fetch.DAT_MISO.toLong, 0x12345678L)
      for (port <- Seq(owner, competitor, unrelatedFetch))
        assert(
          !port.ACK.toBoolean && !port.ERR.toBoolean,
          "borrowed response leaked to another master"
        )
      edge(d)
      d.ram.bus.ERR #= false; d.ram.bus.ACK #= false
      fetch.CYC     #= false; fetch.STB     #= false
      sleep(1); edge(d)
      assertEquals(d.ram.bus.ADR.toLong, 0x1100L)
      assert(d.ram.bus.WE.toBoolean && d.ram.bus.LOCK.toBoolean)
      d.ram.bus.ACK #= true; sleep(1)
      assert(owner.ACK.toBoolean && !competitor.ACK.toBoolean && !unrelatedFetch.ACK.toBoolean)
      edge(d)
      owner.CYC #= false; owner.STB #= false; owner.LOCK #= false
      sleep(1)
      var competitorDone  = false
      var instructionDone = false
      for (_ <- 0 until 12) {
        edge(d)
        if (competitor.ACK.toBoolean) {
          competitorDone = true
          edge(d); competitor.CYC #= false; competitor.STB #= false
        }
        if (unrelatedFetch.ACK.toBoolean) {
          instructionDone = true
          edge(d); unrelatedFetch.CYC #= false; unrelatedFetch.STB #= false
        }
        sleep(1)
      }
      assert(
        competitorDone && instructionDone,
        "pending masters were not served after lock release"
      )
    }
  }

  test("a sparse slave with instruction input zero cannot borrow an unrelated owner's lock") {
    class SparseProbe extends Component {
      val data, instruction, other = new Master
      val rom, ram                 = new Slave
      val matrix                   = J2WishboneIntercon()
      matrix.addSlaves(rom.bus -> SizeMapping(0, 0x1000), ram.bus -> SizeMapping(0x1000, 0x1000))
      matrix.addMaster(data.bus, Seq(ram.bus))
      matrix.addInstructionMaster(instruction.bus, data.bus, Seq(rom.bus, ram.bus))
      matrix.addMaster(other.bus, Seq(rom.bus, ram.bus))
    }
    SimConfig.withVerilator.compile(new SparseProbe).doSim { d =>
      for (b <- Seq(d.data.bus, d.instruction.bus, d.other.bus)) {
        b.CYC #= false; b.STB #= false; b.WE    #= false; b.LOCK #= false
        b.ADR #= 0; b.SEL     #= 15; b.DAT_MOSI #= 0
      }
      for (b <- Seq(d.rom.bus, d.ram.bus)) { b.ACK #= true; b.ERR #= false; b.DAT_MISO #= 0 }
      def tick(): Unit = {
        d.clockDomain.clockSim #= true; sleep(5)
        d.clockDomain.clockSim #= false; sleep(5)
      }
      d.clockDomain.clockSim #= false
      d.clockDomain.assertReset(); for (_ <- 0 until 4) tick()
      d.clockDomain.deassertReset()
      d.other.bus.CYC #= true; d.other.bus.STB #= true; d.other.bus.LOCK #= true
      sleep(1); tick(); tick()
      assert(d.other.bus.ACK.toBoolean)
      d.other.bus.STB       #= false
      d.instruction.bus.CYC #= true; d.instruction.bus.STB #= true
      sleep(1)
      for (_ <- 0 until 5) {
        tick()
        assert(!d.instruction.bus.ACK.toBoolean)
        assert(d.rom.bus.LOCK.toBoolean && !d.ram.bus.LOCK.toBoolean)
      }
      d.other.bus.CYC #= false; d.other.bus.LOCK #= false
      sleep(1); tick(); tick()
      assert(d.instruction.bus.ACK.toBoolean)
    }
  }
}
