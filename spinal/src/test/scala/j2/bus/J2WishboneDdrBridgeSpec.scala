package j2.bus

import j2.board.MigModel
import spinal.core._
import spinal.core.sim._
import spinal.lib._

class DdrBridgeFixture extends Component {
  val io = new Bundle {
    val busClock, memoryClock, reset, calibrated = in Bool ()
    val bus                                      = slave(J2Wishbone())
    val native                                   = master(J2MigPort())
  }
  val busDomain    = ClockDomain(io.busClock, io.reset)
  val memoryDomain = ClockDomain(io.memoryClock, io.reset)
  val bridge       = new J2WishboneDdrBridge(busDomain, memoryDomain, timeoutBits = 8)
  bridge.io.bus <> io.bus; bridge.io.native <> io.native
  bridge.io.calibrated := io.calibrated
}
class J2WishboneDdrBridgeSpec extends munit.FunSuite {
  test("CDC, all byte masks and burst slots, held CYC/LOCK, abort, timeout and reset") {
    SimConfig.withVerilator.compile(new DdrBridgeFixture).doSim { dut =>
      fork { sleep(1000000); simFailure("DDR bridge regression timeout") }
      dut.io.bus.CYC #= false; dut.io.bus.STB #= false; dut.io.bus.WE #= false
      dut.io.bus.LOCK #= false; dut.io.bus.ADR #= 0; dut.io.bus.SEL #= 15; dut.io.bus.DAT_MOSI #= 0
      dut.io.calibrated #= false; dut.io.reset       #= true
      dut.io.busClock   #= false; dut.io.memoryClock #= false
      fork(while (true) { sleep(5); dut.io.busClock #= !dut.io.busClock.toBoolean })
      fork {
        sleep(1); while (true) { sleep(3); dut.io.memoryClock #= !dut.io.memoryClock.toBoolean }
      }
      val model = new MigModel(dut.io.native, dut.memoryDomain)
      model.start()
      sleep(100); dut.io.reset #= false; dut.io.calibrated #= true
      def access(
          address: Long,
          write: Boolean = false,
          data: Long = 0,
          select: Int = 15,
          error: Boolean = false,
          keepCycle: Boolean = false
      ): Long = {
        dut.busDomain.waitFallingEdge()
        dut.io.bus.CYC #= true; dut.io.bus.STB         #= true; dut.io.bus.WE  #= write
        dut.io.bus.ADR #= address; dut.io.bus.DAT_MOSI #= data; dut.io.bus.SEL #= select
        var cycles = 0
        sleep(1)
        while (!dut.io.bus.ACK.toBoolean && !dut.io.bus.ERR.toBoolean && cycles < 600) {
          dut.busDomain.waitFallingEdge(); sleep(1); cycles += 1
        }
        assert(cycles < 600, "bridge did not terminate")
        assertEquals(dut.io.bus.ERR.toBoolean, error)
        assertEquals(dut.io.bus.ACK.toBoolean, !error)
        val value = dut.io.bus.DAT_MISO.toLong
        dut.busDomain.waitSampling(); sleep(1)
        dut.io.bus.STB                 #= false
        if (!keepCycle) dut.io.bus.CYC #= false
        dut.busDomain.waitSampling(2)
        assert(!dut.io.bus.ACK.toBoolean && !dut.io.bus.ERR.toBoolean)
        value
      }
      for (slot <- 0 until 4; mask <- 1 to 15) {
        val address = 0x80000100L + slot * 4
        access(address, true, 0x10203040L, 15)
        access(address, true, 0xa1b2c3d4L, mask)
        val expected = (0 until 4).foldLeft(0L) { (v, b) =>
          val shift = (3 - b) * 8
          (v << 8) | ((if ((mask & (8 >> b)) != 0) 0xa1b2c3d4L else 0x10203040L) >> shift & 255)
        }
        assertEquals(access(address), expected)
        assertEquals(model.word(address - 0x80000000L), expected)
      }
      access(0x8ffffffcL, true, 0x98765432L)
      assertEquals(access(0x8ffffffcL), 0x98765432L)
      val before = model.commands
      access(0x7ffffffcL, error = true); access(0x90000000L, error = true)
      access(0x80000000L, true, 123, 0)
      assertEquals(model.commands, before)
      // STB pauses within an atomic CYC/LOCK must not replay any completed beat.
      dut.io.bus.LOCK #= true
      access(0x80000000L, true, 0, keepCycle = true)
      assertEquals(access(0x80000000L, keepCycle = true), 0L)
      val held = model.commands
      dut.busDomain.waitSampling(20); assertEquals(model.commands, held)
      access(0x80000000L, true, 0x80808080L, select = 8, keepCycle = true)
      assertEquals(access(0x80000000L, keepCycle = true), 0x80000000L)
      dut.io.bus.CYC #= false; dut.io.bus.LOCK #= false
      // Abort a read, then present a different transaction before its old reply.
      model.deliverReads = false
      dut.busDomain.waitFallingEdge()
      dut.io.bus.CYC #= true; dut.io.bus.STB #= true; dut.io.bus.WE #= false;
      dut.io.bus.ADR #= 0x80000100L
      val prior = model.readCommands
      waitUntil(model.readCommands > prior)
      dut.busDomain.waitFallingEdge(); dut.io.bus.CYC #= false; dut.io.bus.STB #= false
      dut.busDomain.waitSampling(2); model.deliverReads = true
      assertEquals(access(0x8ffffffcL), 0x98765432L)
      // The matrix can retain LOCK/CYC while a borrowed fetch drops STB.
      model.deliverReads = false
      dut.busDomain.waitFallingEdge()
      dut.io.bus.CYC #= true; dut.io.bus.STB #= true; dut.io.bus.ADR #= 0x80000100L
      val beforeStrobeAbort = model.readCommands
      waitUntil(model.readCommands > beforeStrobeAbort)
      dut.busDomain.waitFallingEdge(); dut.io.bus.STB #= false
      dut.busDomain.waitSampling(2); model.deliverReads = true
      assertEquals(access(0x8ffffffcL), 0x98765432L)
      // A read timeout poisons the bridge; a late response cannot match new work.
      model.deliverReads = false
      access(0x80000000L, error = true)
      val poisonedCount = model.commands
      model.deliverReads = true
      access(0x8ffffffcL, error = true)
      assertEquals(model.commands, poisonedCount)
      // Coordinated reset clears both mailbox epochs and the native controller.
      dut.io.reset #= true; model.reset(); sleep(100); dut.io.reset #= false
      assertEquals(access(0x8ffffffcL), 0x98765432L)
      // Reset with a read in flight: the common reset contract flushes MIG too.
      model.deliverReads = false
      dut.busDomain.waitFallingEdge()
      dut.io.bus.CYC #= true; dut.io.bus.STB #= true; dut.io.bus.ADR #= 0x80000100L
      val inFlight = model.readCommands
      waitUntil(model.readCommands > inFlight)
      dut.io.reset #= true; dut.io.bus.CYC #= false; dut.io.bus.STB #= false
      model.reset(); sleep(100); dut.io.reset #= false; model.deliverReads = true
      assertEquals(access(0x8ffffffcL), 0x98765432L)
      // Write data accepted without its command must poison future writes.
      model.commandsEnabled = false
      access(0x80000200L, true, 0x11223344L, error = true)
      assert(model.writes.nonEmpty)
      val writesBefore = model.writeCommands
      model.commandsEnabled = true
      access(0x80000204L, true, 0x55667788L, error = true)
      assertEquals(model.writeCommands, writesBefore)
      dut.io.reset #= true; model.reset(); sleep(100); dut.io.reset #= false
      access(0x80000204L, true, 0x55667788L)
      assertEquals(access(0x80000204L), 0x55667788L)
      // Calibration loss during an accepted read fails it and blocks late data.
      model.deliverReads = false
      val beforeCalibrationLoss = model.readCommands
      fork {
        waitUntil(model.readCommands > beforeCalibrationLoss)
        dut.memoryDomain.waitFallingEdge()
        dut.io.calibrated #= false
      }
      access(0x80000204L, error = true)
      val afterCalibrationLoss = model.commands
      dut.io.calibrated #= true; model.deliverReads = true
      access(0x80000204L, error = true)
      assertEquals(model.commands, afterCalibrationLoss)
      dut.io.reset #= true; model.reset(); sleep(100); dut.io.reset #= false
      assertEquals(access(0x80000204L), 0x55667788L)
      model.corruptEnd = true
      access(0x80000000L, error = true)
      model.corruptEnd = false
      access(0x8ffffffcL, error = true)
    }
  }
}
