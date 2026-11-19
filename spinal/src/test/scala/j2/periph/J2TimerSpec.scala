package j2.periph

import spinal.core.sim._
import scala.language.reflectiveCalls

class J2TimerSpec extends munit.FunSuite {
  test("IRQ registers the enabled comparator level on assertion, disable, clear and rearm") {
    val compiled =
      SimConfig.withVerilator.compile(new J2Timer(clockHz = 4, tickHz = 1, width = 8))
    compiled.doSim { dut =>
      val bus = dut.io.bus
      bus.PSEL    #= 0
      bus.PENABLE #= false
      bus.PWRITE  #= false
      bus.PADDR   #= 0
      bus.PWDATA  #= 0
      bus.PSTRB   #= 0
      bus.PPROT   #= 0

      dut.clockDomain.clockSim #= false

      def tick(): Unit = {
        dut.clockDomain.clockSim #= false
        sleep(5)
        dut.clockDomain.clockSim #= true
        sleep(5)
      }

      def write(address: Int, value: Int): Unit = {
        bus.PSEL    #= 1
        bus.PENABLE #= false
        bus.PWRITE  #= true
        bus.PSTRB   #= 15
        bus.PADDR   #= address
        bus.PWDATA  #= value
        tick() // SETUP
        bus.PENABLE #= true
        sleep(1)
        var waitCycles = 0
        while (!bus.PREADY.toBoolean && waitCycles < 20) {
          tick()
          waitCycles += 1
        }
        assert(bus.PREADY.toBoolean)
        tick()
        bus.PSEL    #= 0
        bus.PENABLE #= false
        sleep(1)
      }

      // Peek at the combinational CSR read-data decode while the bus is idle,
      // so observing status does not move the clock under test.
      def status(): Long = {
        bus.PWRITE #= false
        bus.PSTRB  #= 0
        bus.PADDR  #= 0x0c
        sleep(1)
        bus.PRDATA.toLong
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

  test("APB timer counts, stops, interrupts, clears, and rearms") {
    val compiled =
      SimConfig.withVerilator.compile(new J2Timer(clockHz = 4, tickHz = 1, width = 8))
    compiled.doSim { dut =>
      val bus = dut.io.bus
      bus.PSEL    #= 0
      bus.PENABLE #= false
      bus.PWRITE  #= false
      bus.PADDR   #= 0
      bus.PWDATA  #= 0
      bus.PSTRB   #= 0
      bus.PPROT   #= 0

      dut.clockDomain.clockSim #= false

      def tick(): Unit = {
        dut.clockDomain.clockSim #= false
        sleep(5)
        dut.clockDomain.clockSim #= true
        sleep(5)
      }

      def access(write: Boolean, address: Long, value: Long = 0, mask: Int = 15): Long = {
        bus.PSEL    #= 1
        bus.PENABLE #= false
        bus.PWRITE  #= write
        bus.PSTRB   #= (if (write) mask else 0)
        bus.PADDR   #= address
        bus.PWDATA  #= value
        tick() // SETUP
        bus.PENABLE #= true
        sleep(1)
        var waitCycles = 0
        while (!bus.PREADY.toBoolean && waitCycles < 20) {
          tick()
          waitCycles += 1
        }
        assert(waitCycles < 20, s"timer bus access stalled at 0x${address.toHexString}")
        val result = bus.PRDATA.toLong
        tick()
        bus.PSEL    #= 0
        bus.PENABLE #= false
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

      access(true, 0x08, 0, mask    = 0)
      access(true, 0x04, 0xff, mask = 8)
      assertEquals(read(0x08), 3L)
      assertEquals(read(0x04), 3L)
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
