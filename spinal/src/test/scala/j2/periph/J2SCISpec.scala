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
      val byte = offset == 4 || offset == 12 || offset == 20
      access(offset, value.toLong << (if (byte) 24 else 16), if (byte) 8 else 12)
    }
    def read(offset: Int): Int = {
      val byte = offset == 4 || offset == 12 || offset == 20
      ((access(offset, write = false) >> (if (byte) 24 else 16)) & (if (byte) 255 else 65535)).toInt
    }
    def configure(mode: Int = 0, rate: Int = 0, control: Int = 0x30, triggers: Int = 0): Unit = {
      write(8, 0); write(0, mode); write(4, rate)
      write(24, triggers | 6); write(24, triggers)
      write(16, 0); write(36, 0); write(8, control); tick()
    }
    def queue(value: Int): Unit = { write(12, value); write(16, 0xff9f) }
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
  private def run(depth: Int = 0)(body: Rig => Unit): Unit =
    SimConfig.withVerilator.compile(new J2SCI(depth)).doSim(d => body(new Rig(d)))

  test("SCIF register layout at depth zero, strobes and hard-wired modes") {
    run() { r =>
      assertEquals(r.read(0), 0); assertEquals(r.read(4), 255); assertEquals(r.read(8), 0)
      assertEquals(r.read(16), 0x60); assertEquals(r.read(24), 0); assertEquals(r.read(28), 0)
      assertEquals(r.read(32), 0x51); assertEquals(r.read(36), 0); assertEquals(r.read(40), 0)
      r.write(0, 65535); assertEquals(r.read(0), 0x7b)
      r.write(8, 65535); assertEquals(r.read(8), 0xf8)
      r.write(8, 0)
      r.write(24, 65535); assertEquals(r.read(24), 0xf6)
      r.write(40, 65535); assertEquals(r.read(40), 0)
      r.write(16, 65535); assertEquals(r.read(16), 0x60)
      r.access(0, 0, 3); assertEquals(r.read(0), 0x7b)
      r.access(0, 0, 8); assertEquals(r.read(0), 0x7b)
      r.access(0, 0, 0); assertEquals(r.read(0), 0x7b)
      r.access(4, 0, 4); assertEquals(r.read(4), 255)
      r.access(44, error = true); r.access(1, write = false, error = true)
      r.write(32, 2); assert(!r.dut.io.uart.txd.toBoolean)
      r.write(32, 3); assert(r.dut.io.uart.txd.toBoolean)
    }
  }

  for (depth <- Seq(0, 1, 3, 4, 16, 255))
    test(s"SCIF depth $depth: capacity, full writes, automatic TX, flush and wrap") {
      run(depth) { r =>
        val capacity = depth.max(1)
        r.configure(control = 0, triggers = 0x30)
        val values   = (0 until capacity).map(i => (i * 37 + 0x41) & 255)
        for (value <- values) r.write(12, value)
        assertEquals(r.read(28), capacity << 8)
        r.write(12, 0xee); assertEquals(r.read(28), capacity << 8)
        r.write(16, 0xff9f); assertEquals(r.read(16) & 0x60, 0x40)
        val before = r.tx.size
        r.write(8, 0xa0); r.write(16, 0xff9f)
        r.tick(320 * capacity + 40)
        val first = r.tx.indexWhere(v => !v, before)
        assert(first >= 0)
        for ((value, index) <- values.zipWithIndex) r.checkFrame(first + index * 320, value, 32)
        assertEquals(r.read(28), 0); assertEquals(r.read(16) & 0x60, 0x60)
        assertEquals(r.dut.io.interrupt.toInt, 4)
        r.write(8, 0); r.write(12, 0x55); r.write(24, 4)
        assertEquals(r.read(28), 0)
        r.write(12, 0xaa); assertEquals(r.read(28), 0)
        r.write(24, 0); r.write(8, 0x30)
        for (i <- 0 until capacity + 3) {
          r.receive(i & 255); assertEquals(r.read(28) & 255, 1)
          assertEquals(r.read(20), i & 255)
          assertEquals(r.read(28) & 255, 0)
        }
      }
    }

  test("SCIF asynchronous formats and PCLK baud divisors") {
    run(16) { r =>
      for (
        (mode, rate, value, bits, parity, stops) <- Seq(
          (0x68, 0, 0x55, 7, 0, 2),
          (0x30, 1, 0xa6, 8, 1, 1),
          (0x00, 0, 0x96, 8, -1, 1),
          (0x01, 0, 0xa5, 8, -1, 1),
          (0x02, 0, 0x35, 8, -1, 1),
          (0x03, 0, 0x63, 8, -1, 1)
        )
      ) {
        r.configure(mode, rate)
        val period = 32 * (rate + 1) * (1 << (2 * (mode & 3)))
        val before = r.tx.size
        r.queue(value); r.tick(period * (bits + stops + 3))
        val first = r.tx.indexWhere(v => !v, before)
        r.checkFrame(first, value, period, bits, parity, stops)
        r.receive(value, period, bits == 7, parity)
        assertEquals(r.read(16) & 0x8f, 2)
        assertEquals(r.read(20), value); assertEquals(r.read(20), 0)
        r.write(16, 0xfffc); assertEquals(r.read(16) & 3, 0)
      }
    }
  }

  test("SCIF RX threshold, short-packet timeout, sticky W0C and error-only IRQ enable") {
    run(16) { r =>
      r.configure(control = 0x50, triggers = 0x40)
      r.receive(0x11); r.tick(200)
      assertEquals(r.read(16) & 3, 0); assertEquals(r.dut.io.interrupt.toInt, 0)
      r.tick(400); assertEquals(r.read(16) & 3, 1); assertEquals(r.dut.io.interrupt.toInt, 2)
      assertEquals(r.read(20), 0x11)
      r.write(16, 0xffff); assertEquals(r.read(16) & 1, 1)
      r.write(16, 0xfffe); assertEquals(r.read(16) & 1, 0)
      for (i <- 0 until 4) r.receive(0x20 + i)
      assertEquals(r.read(16) & 2, 2)
      r.write(16, 0xfffd); assertEquals(r.read(16) & 2, 2)
      assertEquals(r.read(20), 0x20); r.write(16, 0xfffd)
      assertEquals(r.read(16) & 2, 0)
      r.configure(mode       = 0x20, control = 0x18)
      r.receive(0x35, parity = 0, badParity  = true)
      assertEquals(r.dut.io.interrupt.toInt, 1)
      r.receive(0x42, parity = 0)
      assertEquals(r.read(28) & 255, 2); assertEquals(r.read(16) & 0xf00c, 0x1004)
      assertEquals(r.read(20), 0x35); assertEquals(r.read(16) & 0xf00c, 0)
      assertEquals(r.read(20), 0x42)
      r.write(16, 0xff7c); r.tick(); assertEquals(r.dut.io.interrupt.toInt, 0)
    }
  }

  test("SCIF overrun preserves FIFO, BRI, framing metadata, break suppression and recovery") {
    run(3) { r =>
      r.configure(control = 0x50)
      for (value <- Seq(1, 2, 3, 4)) r.receive(value)
      assertEquals(r.read(36), 1); assertEquals(r.dut.io.interrupt.toInt & 8, 8)
      for (value <- Seq(1, 2, 3)) assertEquals(r.read(20), value)
      r.receive(5); assertEquals(r.read(28) & 255, 0)
      r.write(36, 0xffff); assertEquals(r.read(36), 1)
      r.write(36, 0); r.receive(6); assertEquals(r.read(20), 6)
      r.write(16, 0)
      r.receive(0x45, badStop = true)
      assertEquals(r.read(16) & 0x0f8c, 0x0188)
      assertEquals(r.read(20), 0x45); assertEquals(r.read(16) & 0x0f0c, 0)
      r.write(16, 0)
      r.dut.io.uart.rxd #= false; r.tick(1000)
      assertEquals(r.read(16) & 0x10, 0x10)
      val count = r.read(28) & 255
      r.tick(640); assertEquals(r.read(28) & 255, count)
      r.dut.io.uart.rxd #= true; r.tick(64)
      r.write(24, 2); r.write(24, 0); r.write(16, 0); r.write(36, 0)
      r.receive(0x77); assertEquals(r.read(20), 0x77)
    }
  }
  test("SCIF threshold choices and per-entry error counters survive FIFO reset") {
    run(16) { r =>
      for ((trigger, code) <- Seq(8, 4, 2, 0).zipWithIndex) {
        r.configure(control = 0, triggers = code << 4)
        for (count <- 1 to 16) {
          r.write(12, count); r.write(16, 0xffdf)
          assertEquals((r.read(16) & 0x20) != 0, count <= trigger)
        }
      }
      for ((trigger, code) <- Seq(1, 4, 8, 14).zipWithIndex) {
        r.configure(control = 0x10, triggers = code << 6)
        for (count <- 1 to trigger) {
          r.receive(count)
          assertEquals((r.read(16) & 2) != 0, count >= trigger)
        }
      }
      r.configure(mode = 0x20, control = 0x10)
      for (i <- 0 until 16) r.receive(i, parity = 0, badParity = true)
      assertEquals(r.read(28) & 255, 16)
      assertEquals(r.read(16) & 0xf084, 0x84) // modulo-16 count, head still invalid
      assertEquals(r.read(20), 0)
      assertEquals(r.read(16) & 0xf004, 0xf004)
      r.write(24, 2)
      assertEquals(r.read(28), 0); assertEquals(r.read(16) & 0xff0c, 0)
      assertEquals(r.read(16) & 0x80, 0x80) // buffer reset does not acknowledge ER
    }
  }

  for (depth <- Seq(0, 3))
    test(s"SCIF depth $depth full receive/pop collision and APB setup isolation") {
      run(depth) { r =>
        var accepted = 0
        var overrun  = 0
        for (phase <- 0 until 32) {
          r.configure(control = 0x10)
          for (i <- 0 until depth.max(1)) r.receive(0x40 + i)
          r.b.PSEL            #= 1; r.b.PENABLE #= false; r.b.PWRITE #= false; r.b.PADDR #= 20
          r.tick(3); r.b.PSEL #= 0
          assertEquals(r.read(28) & 255, depth.max(1))
          r.dut.io.uart.rxd #= false; r.tick(32)
          for (bit <- 0 until 8) { r.dut.io.uart.rxd #= ((0xa5 >> bit) & 1) != 0; r.tick(32) }
          r.dut.io.uart.rxd #= true; r.tick(phase)
          assertEquals(r.read(20), 0x40)
          r.tick(64)
          val lost = r.read(36) != 0
          if (lost) overrun += 1 else accepted += 1
          for (i <- 1 until depth.max(1)) assertEquals(r.read(20), 0x40 + i)
          assertEquals(r.read(28) & 255, if (lost) 0 else 1)
          if (!lost) assertEquals(r.read(20), 0xa5)
        }
        assert(accepted > 0 && overrun > 0)
      }
    }

}
