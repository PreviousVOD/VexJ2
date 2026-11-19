package j2.periph

import spinal.core.sim._
import scala.collection.mutable.ArrayBuffer
import scala.language.reflectiveCalls

class J2SCISpec extends munit.FunSuite {
  class Rig(val dut: J2SCI) {
    val b      = dut.io.bus
    var cycles = 0
    val tx     = ArrayBuffer[Boolean]()
    b.PSEL          #= 0; b.PENABLE                   #= false; b.PWRITE #= false; b.PADDR #= 0
    b.PWDATA        #= 0; b.PSTRB                     #= 0; b.PPROT      #= 0
    dut.io.uart.rxd #= true; dut.clockDomain.clockSim #= false
    def tick(n: Int = 1): Unit = for (_ <- 0 until n) {
      dut.clockDomain.clockSim #= true; sleep(5)
      dut.clockDomain.clockSim #= false; sleep(5)
      tx += dut.io.uart.txd.toBoolean; cycles += 1
    }
    dut.clockDomain.assertReset(); tick(3); dut.clockDomain.deassertReset(); sleep(1)
    def access(
        address: Int,
        data: Long = 0,
        mask: Int = 0,
        write: Boolean = true,
        error: Boolean = false
    ): Long = {
      b.PADDR   #= address; b.PWDATA #= data; b.PSTRB #= mask; b.PWRITE #= write
      b.PSEL    #= 1; b.PENABLE      #= false; tick()
      b.PENABLE #= true; sleep(1)
      assert(b.PREADY.toBoolean); assertEquals(b.PSLVERR.toBoolean, error)
      val result = b.PRDATA.toLong
      tick(); b.PSEL #= 0; b.PENABLE #= false; sleep(1)
      result
    }
    def write(offset: Int, value: Int): Unit = {
      val shift = if ((offset & 2) == 0) 24 else 8
      access(offset & ~3, value.toLong << shift, 1 << (shift / 8))
    }
    def read(offset: Int): Int = {
      val shift = if ((offset & 2) == 0) 24 else 8
      ((access(offset & ~3, write = false) >> shift) & 255).toInt
    }
    def configure(
        mode: Int = 0,
        rate: Int = 0,
        control: Int = 0x30,
        reverse: Boolean = false
    ): Unit = {
      write(4, 0); write(0, mode); write(2, rate); write(12, if (reverse) 0xfa else 0xf2)
      write(8, 0xff); write(4, control); tick()
    }
    def queue(value: Int): Unit = { assert((read(8) & 128) != 0); write(6, value); write(8, 0x7f) }
    def receive(
        value: Int,
        period: Int = 32,
        seven: Boolean = false,
        parity: Int = -1,
        reverse: Boolean = false,
        badParity: Boolean = false,
        badStop: Boolean = false
    ): Unit = {
      def bit(value: Boolean): Unit = { dut.io.uart.rxd #= value; tick(period) }
      bit(false)
      val bits = if (seven) 7 else 8
      for (i <- 0 until bits) bit(((value >> (if (reverse && !seven) 7 - i else i)) & 1) != 0)
      if (parity >= 0)
        bit(((Integer.bitCount(value & ((1 << bits) - 1)) + parity) & 1) != 0 ^ badParity)
      bit(!badStop)
      dut.io.uart.rxd #= true; tick(period)
    }
    def checkFrame(
        start: Int,
        value: Int,
        period: Int,
        bits: Int = 8,
        parity: Int = -1,
        stops: Int = 1,
        reverse: Boolean = false
    ): Unit = {
      val data =
        (0 until bits).map(i => ((value >> (if (reverse && bits == 8) 7 - i else i)) & 1) != 0)
      val p =
        if (parity < 0) Seq.empty
        else Seq(((Integer.bitCount(value & ((1 << bits) - 1)) + parity) & 1) != 0)
      val expected = Seq(false) ++ data ++ p ++ Seq.fill(stops)(true)
      for ((bit, i) <- expected.zipWithIndex)
        assertEquals(tx(start + i * period + period / 2), bit, s"wire bit $i")
    }
  }
  private def run(body: Rig => Unit): Unit =
    SimConfig.withVerilator.compile(new J2SCI).doSim(d => body(new Rig(d)))
  test("SCI reset, packed byte registers, hard-wired modes, no-op strobes and errors") {
    run { r =>
      assertEquals(r.read(0), 0); assertEquals(r.read(2), 255); assertEquals(r.read(4), 0)
      assertEquals(r.read(8), 0x84); assertEquals(r.read(12), 0xf2)
      r.write(0, 255); assertEquals(r.read(0), 0x7b)
      r.write(4, 0xff); assertEquals(r.read(4), 0xf4)
      r.write(4, 0x0b); assertEquals(r.read(4), 0)
      r.write(12, 255); assertEquals(r.read(12), 0xfa)
      r.write(12, 0); assertEquals(r.read(12), 0xf2)
      r.write(10, 255); assertEquals(r.read(10), 0)
      r.write(14, 255); assertEquals(r.read(14), 0x80)
      r.access(0, 0, 0); assertEquals(r.read(0), 0x7b)
      r.access(0, 0, 5); assertEquals(r.read(0), 0x7b); assertEquals(r.read(2), 255)
      r.write(8, 0xff); assertEquals(r.read(8), 0x84)
      r.access(16, error = true); r.access(1, write = false, error = true)
      r.write(14, 0); assert(!r.dut.io.uart.txd.toBoolean)
      r.write(14, 1); assert(r.dut.io.uart.txd.toBoolean)
    }
  }
  test("SCI TDR requires TDRE clear, double buffering, TEND and TX interrupt sources") {
    run { r =>
      r.configure(control = 0xa4)
      assertEquals(r.dut.io.interrupt.toInt, 12)
      r.write(6, 0x41); r.tick(40); assert(r.dut.io.uart.txd.toBoolean)
      val first = r.tx.size
      r.write(8, 0x7f); r.tick(8)
      val start = r.tx.indexWhere(v => !v, first)
      assert(start >= 0); assertEquals(r.read(8) & 0x84, 128)
      r.queue(0x96); assertEquals(r.read(8) & 0x84, 0)
      r.tick(700)
      r.checkFrame(start, 0x41, 32)
      r.checkFrame(start + 320, 0x96, 32)
      assertEquals(r.read(8) & 0x84, 0x84)
      r.tick(); assertEquals(r.dut.io.interrupt.toInt, 12)
      r.write(4, 0); r.tick(); assertEquals(r.dut.io.interrupt.toInt, 0)
    }
  }
  test("SCI asynchronous formats, MSB direction and PCLK baud divisors") {
    run { r =>
      for (
        (mode, rate, value, bits, parity, stops, reverse) <- Seq(
          (0x68, 0, 0x55, 7, 0, 2, false),
          (0x30, 1, 0xa6, 8, 1, 1, false),
          (0x00, 0, 0x96, 8, -1, 1, true),
          (0x01, 0, 0xa5, 8, -1, 1, false),
          (0x02, 0, 0x35, 8, -1, 1, false),
          (0x03, 0, 0x63, 8, -1, 1, false)
        )
      ) {
        r.configure(mode, rate, reverse = reverse)
        val period = 32 * (rate + 1) * (1 << (2 * (mode & 3)))
        val before = r.tx.size
        r.queue(value); r.tick(period * (bits + stops + 3))
        val start = r.tx.indexWhere(v => !v, before)
        assert(start >= 0); r.checkFrame(start, value, period, bits, parity, stops, reverse)
        r.receive(value, period, bits == 7, parity, reverse)
        assertEquals(r.read(8) & 0x78, 0x40); assertEquals(r.read(10), value)
        assertEquals(r.read(8) & 0x40, 0x40) // RDR reads do not pop data.
        r.write(8, 0xbf)
      }
    }
  }
  test("SCI receive overrun, parity/framing errors, W0C, EIO and receive disable") {
    run { r =>
      r.configure(control = 0x50)
      r.receive(0xa5)
      assertEquals(r.read(10), 0xa5); assertEquals(r.dut.io.interrupt.toInt, 2)
      r.write(14, 0x81); r.tick(); assertEquals(r.dut.io.interrupt.toInt, 0)
      r.receive(0x5a); assertEquals(r.read(10), 0xa5)
      assertEquals(r.read(8) & 0x60, 0x60); assertEquals(r.dut.io.interrupt.toInt, 1)
      r.write(4, 0); assertEquals(r.read(8) & 0x60, 0x60)
      r.write(8, 0x9f); assertEquals(r.read(8) & 0x78, 0)
      r.configure(mode       = 0x20, control = 0x50)
      r.receive(0x35, parity = 0, badParity  = true)
      assertEquals(r.read(8) & 0x78, 8); assertEquals(r.read(10), 0x35)
      r.receive(0x42, parity = 0); assertEquals(r.read(10), 0x35) // Error blocks RX.
      r.write(8, 0xf7); assertEquals(r.read(8) & 8, 0)
      r.receive(0x69, parity = 0, badStop = true)
      assertEquals(r.read(8) & 0x78, 16); assertEquals(r.read(10), 0x69)
      r.write(8, 0xef); r.receive(0x42, parity = 0)
      assertEquals(r.read(8) & 0x78, 0x40); assertEquals(r.read(10), 0x42)
    }
  }
}
