package j2.periph

import spinal.core.sim._
import scala.language.reflectiveCalls

class J2PIOSpec extends munit.FunSuite {
  class Rig(val dut: J2PIO, initial: Long = 0) {
    val b = dut.io.bus
    b.PSEL                   #= 0;
    b.PENABLE                #= false;
    b.PWRITE                 #= false;
    b.PADDR                  #= 0
    b.PWDATA                 #= 0;
    b.PSTRB                  #= 0;
    b.PPROT                  #= 0
    dut.io.gpio.read         #= initial
    dut.clockDomain.clockSim #= false
    def tick(count: Int = 1): Unit =
      for (_ <- 0 until count) {
        dut.clockDomain.clockSim #= true;
        sleep(5)
        dut.clockDomain.clockSim #= false;
        sleep(5)
      }
    dut.clockDomain.assertReset();
    tick(3)
    dut.clockDomain.deassertReset();
    sleep(1)
    def read(address: Int): Long = {
      b.PADDR #= address;
      sleep(1);
      b.PRDATA.toLong
    }
    def write(address: Int, data: Long, mask: Int = 15, error: Boolean = false): Unit = {
      b.PADDR   #= address;
      b.PWDATA  #= data;
      b.PSTRB   #= mask
      b.PSEL    #= 1;
      b.PWRITE  #= true;
      b.PENABLE #= false;
      tick()
      b.PENABLE #= true;
      sleep(1)
      assert(b.PREADY.toBoolean);
      assertEquals(b.PSLVERR.toBoolean, error)
      tick();
      b.PSEL    #= 0;
      b.PENABLE #= false;
      sleep(1)
    }
    def input(value: Long): Unit = {
      dut.io.gpio.read #= value;
      tick(5)
    }
    def irq: Boolean = dut.io.interrupt.toBoolean
  }
  private def run(initial: Long = 0)(body: Rig => Unit): Unit = SimConfig.withVerilator
    .compile(new J2PIO)
    .doSim(d => body(new Rig(d, initial)))

  test("register reset, input readback, output-only writes and APB byte strobes") {
    run() { r =>
      for (address <- Seq(0, 4, 8, 12, 16, 20, 24, 4092))
        assertEquals(r.read(address), 0L)
      r.write(8, 0xffffffffL);
      assertEquals(r.dut.io.gpio.write.toLong, 0L)
      r.write(4, 0xff00ff00L)
      r.write(8, 0x12345678L);
      assertEquals(r.dut.io.gpio.write.toLong, 0x12005600L)
      r.input(0xabcdef01L);
      assertEquals(r.read(8), 0xabcdef01L)
      r.write(4, 0xffffffffL)
      r.write(8, 0xaabbccddL, 5);
      assertEquals(r.dut.io.gpio.write.toLong, 0x12bb56ddL)
      r.write(8, 0, 0);
      assertEquals(r.dut.io.gpio.write.toLong, 0x12bb56ddL)
      r.write(4, 0);
      r.write(8, 0xffffffffL)
      r.write(4, 0xffffffffL);
      assertEquals(r.dut.io.gpio.write.toLong, 0x12bb56ddL)
      for (byte <- 0 until 4) {
        r.write(4, 0, 1 << byte)
        assertEquals((r.read(4) >> (byte * 8)) & 255, 0L)
      }
      r.write(16, 0x12345678L);
      r.write(16, 0xaabbccddL, 12)
      assertEquals(r.read(16), 0xaabb5678L)
      r.write(20, 0xdeadbeefL);
      r.write(20, 0, 0);
      assertEquals(r.read(20), 0xdeadbeefL)
      r.write(0, 0xffffffffL, 8);
      assertEquals(r.read(0), 0L)
      r.write(0, 0xffffffffL, 1);
      assertEquals(r.read(0), 1L)
      r.write(24, 0xffffffffL);
      assertEquals(r.read(24), 0L)
      r.write(1, 0xffffffffL, error = true);
      assertEquals(r.read(0), 1L)
      r.b.PADDR   #= 9;
      r.b.PWRITE  #= false;
      r.b.PSEL    #= 1;
      r.b.PENABLE #= true
      sleep(1);
      assert(r.b.PSLVERR.toBoolean)
    }
  }

  test("all 32 pins select rising or falling edges, reserved mode disables capture") {
    run() { r =>
      for (
        pin <- 0 until 32;
        mode <- 0 to 3
      ) {
        r.write(16, 0);
        r.write(20, 0);
        r.write(12, 0xffffffffL)
        r.input(0)
        r.write(16 + (pin / 16) * 4, mode.toLong << ((pin % 16) * 2))
        r.input(1L << pin)
        assertEquals(
          r.read(12),
          if (mode == 1)
            1L << pin
          else
            0L
        )
        assert(!r.irq, "IE must not prevent capture, but must mask delivery")
        r.write(12, 0xffffffffL)
        r.input(0)
        assertEquals(
          r.read(12),
          if (mode == 2)
            1L << pin
          else
            0L
        )
      }
    }
  }

  test("sticky pending, IE and direction gating, partial W1C and independent pins") {
    run() { r =>
      r.write(16, 0x55555555L);
      r.write(20, 0x55555555L)
      r.input(0xffffffffL);
      assertEquals(r.read(12), 0xffffffffL);
      assert(!r.irq)
      r.write(0, 1);
      r.tick();
      assert(r.irq)
      r.write(12, 0xffffffffL, 5);
      r.tick();
      assertEquals(r.read(12), 0xff00ff00L)
      r.write(12, 0xffffffffL, 0);
      assertEquals(r.read(12), 0xff00ff00L)
      r.write(0, 0);
      r.tick();
      assert(!r.irq)
      r.write(0, 1);
      r.tick();
      assert(r.irq)
      r.write(16, 0xffffffffL);
      r.write(20, 0);
      r.tick();
      assert(!r.irq)
      assertEquals(r.read(12), 0xff00ff00L)
      r.write(16, 0x55555555L);
      r.tick();
      assert(r.irq)
      r.write(4, 0xffffffffL);
      r.tick();
      assert(!r.irq)
      r.input(0);
      r.input(0xffffffffL)
      assertEquals(r.read(12), 0xff00ff00L)
      r.write(12, 0xffffffffL);
      r.input(0);
      r.input(0xffffffffL)
      assertEquals(r.read(12), 0L, "output pin transitions cannot capture")
      r.write(4, 0);
      r.tick(5);
      assertEquals(r.read(12), 0L)
      r.input(0);
      r.input(0xffffffffL);
      assertEquals(r.read(12), 0xffffL)
      r.write(12, 0xffffL);
      r.tick();
      assert(!r.irq)
    }
  }

  test("initial high input is seeded, new edge wins simultaneous W1C") {
    run(1) { r =>
      r.write(16, 1);
      r.tick(5);
      assertEquals(r.read(12), 0L)
      r.write(0, 1)
      r.input(0)
      r.dut.io.gpio.read #= 1
      r.tick() // first synchronizer stage
      r.write(12, 1) // SETUP clocks stage two; ACCESS coincides with edge capture
      assertEquals(r.read(12), 1L)
      assert(!r.irq, "aggregate IRQ is registered")
      r.tick();
      assert(r.irq)
      r.write(12, 1);
      r.tick();
      assert(!r.irq)
      r.tick(5);
      assertEquals(r.read(12), 0L, "a steady input must not retrigger")
    }
  }
}
