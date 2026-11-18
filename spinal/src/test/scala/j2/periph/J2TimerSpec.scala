package j2.periph

import spinal.core.sim._
import scala.language.reflectiveCalls

class J2TimerSpec extends munit.FunSuite {
  test("IRQ registers the enabled comparator level on assertion, disable, clear and rearm") {
    SimConfig.withVerilator.compile(new J2Timer(clockHz = 4, tickHz = 1, width = 8)).doSim { dut =>
      val bus = dut.io.bus
      bus.CYC                  #= false
      bus.STB                  #= false
      bus.WE                   #= false
      bus.ADR                  #= 0
      bus.DAT_MOSI             #= 0
      bus.SEL                  #= 15
      bus.LOCK                 #= false
      dut.clockDomain.clockSim #= false

      def tick(): Unit = {
        dut.clockDomain.clockSim #= false
        sleep(5)
        dut.clockDomain.clockSim #= true
        sleep(5)
      }

      def write(address: Int, value: Int): Unit = {
        bus.CYC      #= true
        bus.STB      #= true
        bus.WE       #= true
        bus.ADR      #= address
        bus.DAT_MOSI #= value
        sleep(1)
        var waitCycles = 0
        while (!bus.ACK.toBoolean && waitCycles < 20) {
          tick()
          waitCycles += 1
        }
        assert(bus.ACK.toBoolean)
        tick()
        bus.CYC #= false
        bus.STB #= false
        sleep(1)
      }

      // Peek at the combinational CSR read-data decode while the bus is idle,
      // so observing status does not move the clock under test.
      def status(): Long = {
        bus.WE  #= false
        bus.ADR #= 0x0c
        sleep(1)
        bus.DAT_MISO.toLong
      }

      dut.clockDomain.assertReset()
      for (_ <- 0 until 4) tick()
      dut.clockDomain.deassertReset()
      assert(!dut.io.interrupt.toBoolean)
      write(0x04, 3)
      write(0x00, 1)
      for (_ <- 0 until 20) tick()
      assertEquals(status() & 0x101, 0x100L)
      assert(!dut.io.interrupt.toBoolean)

      write(0x0c, 1)
      assert(!dut.io.interrupt.toBoolean)
      tick()
      assert(dut.io.interrupt.toBoolean)
      write(0x0c, 0)
      assert(dut.io.interrupt.toBoolean)
      tick()
      assert(!dut.io.interrupt.toBoolean)

      write(0x0c, 1)
      tick()
      assert(dut.io.interrupt.toBoolean)
      write(0x08, 0)
      assertEquals(status() & 0x100, 0L)
      assert(dut.io.interrupt.toBoolean)
      tick()
      assert(!dut.io.interrupt.toBoolean)

      // Check every clock through a fresh compare match, including the cycle
      // where CSR status has asserted but the registered IRQ has not yet risen.
      for (_ <- 0 until 20) {
        val enabledHit = (status() & 0x101) == 0x101
        tick()
        assertEquals(dut.io.interrupt.toBoolean, enabledHit)
      }
      assert(dut.io.interrupt.toBoolean)
      write(0x04, 4)
      assertEquals(status() & 0x100, 0L)
      assert(dut.io.interrupt.toBoolean)
      tick()
      assert(!dut.io.interrupt.toBoolean)
      dut.clockDomain.assertReset()
      sleep(1)
      assert(!dut.io.interrupt.toBoolean)
    }
  }

  test("Wishbone timer counts, stops, interrupts, clears, and rearms") {
    SimConfig.withVerilator.compile(new J2Timer(clockHz = 4, tickHz = 1, width = 8)).doSim { dut =>
      val bus = dut.io.bus
      bus.CYC                  #= false
      bus.STB                  #= false
      bus.WE                   #= false
      bus.ADR                  #= 0
      bus.DAT_MOSI             #= 0
      bus.SEL                  #= 15
      bus.LOCK                 #= false
      dut.clockDomain.clockSim #= false

      def tick(): Unit = {
        dut.clockDomain.clockSim #= false
        sleep(5)
        dut.clockDomain.clockSim #= true
        sleep(5)
      }

      def access(write: Boolean, address: Long, value: Long = 0): Long = {
        bus.CYC      #= true
        bus.STB      #= true
        bus.WE       #= write
        bus.ADR      #= address
        bus.DAT_MOSI #= value
        sleep(1)
        var waitCycles = 0
        while (!bus.ACK.toBoolean && waitCycles < 20) {
          tick()
          waitCycles += 1
        }
        assert(waitCycles < 20, s"timer bus access stalled at 0x${address.toHexString}")
        val result = bus.DAT_MISO.toLong
        tick()
        bus.CYC #= false
        bus.STB #= false
        tick()
        result
      }

      def write(address: Long, value: Long): Unit = access(true, address, value)
      def read(address: Long): Long               = access(false, address)

      dut.clockDomain.assertReset()
      for (_ <- 0 until 4) tick()
      dut.clockDomain.deassertReset()
      tick()

      assertEquals(read(0x08), 0L)
      write(0x04, 3)
      write(0x00, 0)
      for (_ <- 0 until 12) tick()
      assertEquals(read(0x08), 0L)

      write(0x04, 3)
      write(0x0c, 0)
      write(0x00, 1)
      for (_ <- 0 until 20) tick()
      assertEquals(read(0x0c) & 0x100, 0x100L)
      assert(!dut.io.interrupt.toBoolean)
      assertEquals(read(0x08), 3L)
      assertEquals(read(0x08), 3L)

      write(0x0c, 1)
      sleep(1)
      assert(dut.io.interrupt.toBoolean)
      write(0x08, 0)
      sleep(1)
      assert(!dut.io.interrupt.toBoolean)
      assertEquals(read(0x0c) & 0x100, 0L)

      write(0x04, 2)
      var waitCycles = 0
      while (!dut.io.interrupt.toBoolean && waitCycles < 40) {
        tick()
        waitCycles += 1
      }
      assert(waitCycles < 40, "timer did not rearm")
      assertEquals(read(0x08), 2L)
      write(0x04, 4)
      sleep(1)
      assert(!dut.io.interrupt.toBoolean)
    }
  }
}
