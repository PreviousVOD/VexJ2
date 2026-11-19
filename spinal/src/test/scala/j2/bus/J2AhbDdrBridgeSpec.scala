package j2.bus

import j2.board.wukong_v1._

import j2.board.MigModel
import spinal.core._
import spinal.core.sim._
import spinal.lib._

class AhbDdrFixture extends Component {
  val io = new Bundle {
    val busClock, memoryClock, reset, calibrated = in Bool ()
    val bus                                      = slave(J2Ahb.subordinate())
    val native                                   = master(J2MigPort())
  }
  val busDomain    = ClockDomain(io.busClock, io.reset)
  val memoryDomain = ClockDomain(io.memoryClock, io.reset)
  val bridge       = new J2AhbDdrBridge(busDomain, memoryDomain, timeoutBits = 8)
  bridge.io.bus <> io.bus; bridge.io.native <> io.native
  bridge.io.calibrated := io.calibrated
}

class J2AhbDdrBridgeSpec extends munit.FunSuite {
  test("AHB DDR CDC, byte lanes, phase ownership, locks, errors, poisoning and coordinated reset") {
    SimConfig.withVerilator.compile(new AhbDdrFixture).doSim { dut =>
      dut.io.busClock #= false; dut.io.memoryClock #= false
      dut.io.reset    #= true; dut.io.calibrated   #= false
      fork(while (true) { sleep(3); dut.io.memoryClock #= !dut.io.memoryClock.toBoolean })
      def edge(): Unit = { dut.io.busClock #= true; sleep(5); dut.io.busClock #= false; sleep(5) }
      val master       = new AhbMemoryDriver(dut.io.bus, () => edge())
      master.init()
      val model = new MigModel(dut.io.native, dut.memoryDomain)
      model.start()
      def reset(): Unit = {
        dut.io.reset #= true; master.init(); model.reset()
        for (_ <- 0 until 10) edge()
        dut.io.reset #= false; dut.io.calibrated #= true
        for (_ <- 0 until 10) master.tick()
      }
      reset()
      for (slot <- 0 until 4; size <- 0 to 2; offset <- 0 until 4 by (1 << size)) {
        val address = 0x80000100L + slot * 4
        master.access(address, true, 0x10203040L)
        master.access(address + offset, true, 0xa1b2c3d4L, size)
        val mask     = ((BigInt(1) << (8 * (1 << size))) - 1) << ((4 - offset - (1 << size)) * 8)
        val expected = (BigInt(0x10203040L) & ~mask) | (BigInt(0xa1b2c3d4L) & mask)
        assertEquals(master.access(address), expected)
        assertEquals(BigInt(model.word(address - 0x80000000L)), expected)
      }
      master.access(0x8ffffffcL, true, 0x98765432L)
      assertEquals(master.access(0x8ffffffcL), BigInt(0x98765432L))
      val before             = model.commands
      master.access(0x7ffffffcL, error             = true); master.access(0x90000000L, error = true)
      master.access(0x80000001L, true, 0, 1, error = true)
      master.access(0x80000002L, true, 0, 2, error = true)
      master.access(0x80000000L, true, 0, 3, error = true)
      assertEquals(model.commands, before)
      dut.io.bus.address.HMASTLOCK #= true
      master.access(0x80000000L, true, 0)
      assertEquals(master.access(0x80000000L), BigInt(0))
      val locked = model.commands
      for (_ <- 0 until 20) master.tick()
      assertEquals(model.commands, locked)
      master.access(0x80000000L, true, 0x80808080L, 0)
      assertEquals(master.access(0x80000000L), BigInt(0x80000000L))
      dut.io.bus.address.HMASTLOCK #= false
      // A future unselected address cannot cancel an already accepted read.
      model.deliverReads = false
      val reads = model.readCommands
      master.start(0x8ffffffcL)
      while (model.readCommands == reads) master.tick()
      for (_ <- 0 until 10) master.tick()
      model.deliverReads = true
      assertEquals(master.finish(), BigInt(0x98765432L))
      // Timeout must drain/poison late data, never match it to a new address.
      model.deliverReads = false
      master.access(0x80000000L, error = true)
      val poisoned = model.commands
      model.deliverReads = true
      master.access(0x8ffffffcL, error = true)
      assertEquals(model.commands, poisoned)
      reset()
      assertEquals(master.access(0x8ffffffcL), BigInt(0x98765432L))
      model.deliverReads = false
      val inFlight = model.readCommands
      master.start(0x8ffffffcL)
      while (model.readCommands == inFlight) master.tick()
      reset(); model.deliverReads = true
      assertEquals(master.access(0x8ffffffcL), BigInt(0x98765432L))
      model.commandsEnabled = false
      master.access(0x80000200L, true, 0x11223344L, error = true)
      assert(model.writes.nonEmpty)
      val writes = model.writeCommands
      model.commandsEnabled = true
      master.access(0x80000204L, true, 0x55667788L, error = true)
      assertEquals(model.writeCommands, writes)
      reset()
      master.access(0x80000204L, true, 0x55667788L)
      model.deliverReads = false
      val prior = model.readCommands
      fork { waitUntil(model.readCommands > prior); dut.io.calibrated #= false }
      master.access(0x80000204L, error = true)
      dut.io.calibrated #= true; model.deliverReads = true
      master.access(0x80000204L, error = true)
      reset()
      assertEquals(master.access(0x80000204L), BigInt(0x55667788L))
      model.corruptEnd = true
      master.access(0x80000000L, error = true)
      model.corruptEnd = false
      master.access(0x8ffffffcL, error = true)
    }
  }
}
