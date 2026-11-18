package j2.bus

import spinal.core._
import spinal.core.sim._
import spinal.lib._
import spinal.lib.bus.misc.SizeMapping
import spinal.lib.bus.wishbone.Wishbone

class J2WishboneInterconSpec extends munit.FunSuite {
  test("matrix routes masters and locks only data ownership at the selected slave") {
    class MasterEndpoint extends Component {
      val bus = master(J2Wishbone()).simPublic()
    }
    class SlaveEndpoint extends Component {
      val bus = slave(J2Wishbone()).simPublic()
    }
    class Probe extends Component {
      val data, other, instruction = new MasterEndpoint
      val rom, ram, uart           = new SlaveEndpoint
      val matrix                   = J2WishboneIntercon()
      matrix.addSlaves(
        rom.bus -> SizeMapping(0x0000, 0x1000),
        ram.bus -> SizeMapping(0x1000, 0x1000),
        uart.bus -> SizeMapping(0xff001000L, 0x1000)
      )
      matrix.addMaster(data.bus, Seq(rom.bus, ram.bus, uart.bus))
      matrix.addMaster(other.bus, Seq(rom.bus, ram.bus, uart.bus))
      matrix.addInstructionMaster(instruction.bus, data.bus, Seq(rom.bus, ram.bus))
    }

    SimConfig.withVerilator.compile(new Probe).doSim { dut =>
      val masters = Seq(dut.data.bus, dut.other.bus, dut.instruction.bus)
      val slaves  = Seq(dut.rom.bus, dut.ram.bus, dut.uart.bus)
      for (bus <- masters) {
        bus.CYC      #= false; bus.STB #= false; bus.WE #= false; bus.ADR #= 0
        bus.DAT_MOSI #= 0; bus.SEL     #= 15; bus.LOCK  #= false
      }
      for (bus <- slaves) {
        bus.ACK #= false; bus.ERR #= false; bus.DAT_MISO #= 0
      }
      def edge(): Unit = {
        dut.clockDomain.clockSim #= true; sleep(5)
        dut.clockDomain.clockSim #= false; sleep(5)
      }
      def step(): Unit = {
        for (bus <- slaves) bus.ACK #= bus.CYC.toBoolean && bus.STB.toBoolean
        sleep(1)
        edge()
      }
      def start(bus: Wishbone, address: Long, lock: Boolean = false): Unit = {
        bus.ADR #= address; bus.CYC #= true; bus.STB #= true; bus.LOCK #= lock
      }
      def stop(bus: Wishbone): Unit = {
        bus.CYC #= false; bus.STB #= false; bus.LOCK #= false
      }
      def awaitAck(bus: Wishbone): Unit = {
        var cycles = 0
        while (!bus.ACK.toBoolean && cycles < 20) { step(); cycles += 1 }
        assert(cycles < 20, "matrix request timed out")
      }

      dut.clockDomain.clockSim #= false
      dut.clockDomain.assertReset()
      for (_ <- 0 until 4) edge()
      dut.clockDomain.deassertReset()
      sleep(1)

      start(dut.data.bus, 0x1004)
      start(dut.instruction.bus, 0x0020)
      awaitAck(dut.data.bus)
      awaitAck(dut.instruction.bus)
      assert(dut.data.bus.ACK.toBoolean && dut.instruction.bus.ACK.toBoolean)
      assert(!dut.uart.bus.CYC.toBoolean)
      stop(dut.data.bus); stop(dut.instruction.bus); step()

      start(dut.data.bus, 0xff001000L)
      dut.data.bus.WE #= true
      awaitAck(dut.data.bus)
      assert(dut.uart.bus.CYC.toBoolean)
      stop(dut.data.bus); dut.data.bus.WE #= false; step()

      start(dut.other.bus, 0x0000)
      dut.other.bus.WE #= true
      start(dut.data.bus, 0x0000, lock = true)
      awaitAck(dut.data.bus)
      dut.data.bus.STB #= false
      start(dut.instruction.bus, 0x0040)
      var instructionDone = false
      for (_ <- 0 until 20 if !instructionDone) {
        step()
        assert(!dut.other.bus.ACK.toBoolean, "competing data master entered an atomic cycle")
        assert(dut.rom.bus.LOCK.toBoolean, "selected slave lost the data lock")
        assert(!dut.ram.bus.LOCK.toBoolean, "unselected slave was locked")
        instructionDone = dut.instruction.bus.ACK.toBoolean
      }
      assert(instructionDone, "read-only instruction bus remained locked")
      stop(dut.instruction.bus)
      dut.data.bus.STB #= true; dut.data.bus.WE #= true
      awaitAck(dut.data.bus)
      assert(!dut.other.bus.ACK.toBoolean)
      stop(dut.data.bus)
      awaitAck(dut.other.bus)
      stop(dut.other.bus)
    }
  }
}
