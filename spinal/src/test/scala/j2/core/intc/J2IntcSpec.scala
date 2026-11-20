package j2.core.intc

import spinal.core._
import spinal.core.sim._

class J2IntcSpec extends munit.FunSuite {
  class Driver(val dut: J2Intc) {
    val b = dut.io.bus
    dut.clockDomain.clockSim #= false
    b.PSEL                   #= 0; b.PENABLE #= false; b.PADDR #= 0; b.PWRITE #= false
    b.PWDATA                 #= 0; b.PSTRB   #= 0; b.PPROT     #= 0
    if (dut.config.peripheralCount > 0) dut.io.requests #= 0
    dut.io.nmi #= true; dut.io.maskLevel #= 0; dut.io.accept #= false
    def edge(count: Int = 1): Unit = for (_ <- 0 until count) {
      dut.clockDomain.clockSim #= true; sleep(5)
      dut.clockDomain.clockSim #= false; sleep(5)
    }
    def reset(nmi: Boolean = true): Unit = {
      dut.io.nmi #= nmi
      dut.clockDomain.assertReset(); edge(4)
      dut.clockDomain.deassertReset(); edge(6)
    }
    def setup(address: Int, data: Long, strobes: Int = 15): Unit = {
      b.PSEL            #= 1; b.PENABLE  #= false; b.PADDR #= address; b.PWRITE #= true
      b.PWDATA          #= data; b.PSTRB #= strobes
      edge(); b.PENABLE #= true; sleep(1)
    }
    def finish(): Unit = {
      edge(); b.PSEL #= 0; b.PENABLE #= false; b.PSTRB #= 0; sleep(1)
    }
    def write(address: Int, data: Long, strobes: Int = 15): Unit = {
      setup(address, data, strobes)
      assert(b.PREADY.toBoolean); assert(!b.PSLVERR.toBoolean)
      finish()
    }
    def read(address: Int, error: Boolean = false): Long = {
      b.PSEL  #= 1; b.PENABLE         #= false; b.PADDR #= address; b.PWRITE #= false
      b.PSTRB #= 0; edge(); b.PENABLE #= true; sleep(1)
      assert(b.PREADY.toBoolean); assertEquals(b.PSLVERR.toBoolean, error)
      val result = b.PRDATA.toLong
      finish(); result
    }
    def candidate(vector: Int, level: Int, nmi: Boolean = false): Unit = {
      sleep(1)
      assert(dut.io.candidate.valid.toBoolean)
      assertEquals(dut.io.candidate.payload.vector.toInt, vector)
      assertEquals(dut.io.candidate.payload.level.toInt, level)
      assertEquals(dut.io.candidate.payload.nmi.toBoolean, nmi)
      if (!nmi) assertEquals(dut.io.candidate.payload.source.toInt, vector - 64)
    }
    def quiet(): Unit  = { sleep(1); assert(!dut.io.candidate.valid.toBoolean) }
    def accept(): Unit = { dut.io.accept #= true; edge(); dut.io.accept #= false; sleep(1) }
  }

  test("configuration bounds and generated register/source definitions") {
    assertEquals(
      java.nio.file.Files.readString(java.nio.file.Paths.get("../sw/include/j2_intc_regs.h")),
      IntcRegisters.registerHeader
    )
    for (count <- Seq(-1, 193, 256)) intercept[IllegalArgumentException](IntcConfig(count))
    val header =
      IntcRegisters.header(IntcConfig(6), Seq("CMT0", "CMT1", "ERI", "RXI", "TXI", "TEI"))
    assert(
      header.linesIterator.exists(l =>
        l.startsWith("#define J2_INTC_ISER_OFFSET ") && l.endsWith("UINT32_C(0x10)")
      )
    )
    assert(
      header.linesIterator.exists(l =>
        l.startsWith("#define J2_INTC_IPR_OFFSET ") && l.endsWith("UINT32_C(0x100)")
      )
    )
    assert(
      header.linesIterator.exists(l =>
        l.startsWith("#define J2_VECTOR_TEI ") && l.endsWith("UINT32_C(0x45)")
      )
    )
    intercept[IllegalArgumentException](IntcRegisters.header(IntcConfig(1), Seq("bad-name")))
    intercept[IllegalArgumentException](IntcRegisters.header(IntcConfig(2), Seq("IRQ", "IRQ")))
    intercept[IllegalArgumentException](IntcRegisters.header(IntcConfig(1), Seq("A", "B")))
  }

  for (count <- Seq(0, 1, 6, 7, 8, 9, 31, 32, 33, 191, 192))
    test(s"$count sources: reset, fixed banks, alias masks and reserved extension holes") {
      SimConfig.withVerilator.compile(new J2Intc(IntcConfig(count))).doSim { dut =>
        val d = new Driver(dut)
        d.reset(); d.quiet()
        for (addr <- 0 until 512 by 4) assertEquals(d.read(addr), if (addr == 0) 1L else 0L)
        for (word <- 0 until 8) {
          val bits   = math.max(0, math.min(32, count - word * 32))
          val mask   = (1L << bits) - 1
          val offset = word * 4
          d.write(0x10 + offset, 0xffffffffL)
          assertEquals(d.read(0x10 + offset), mask)
          assertEquals(d.read(0x30 + offset), mask)
          d.write(0x10 + offset, 0)
          d.write(0x30 + offset, 0)
          assertEquals(d.read(0x10 + offset), mask)
          d.write(0x50 + offset, 0xffffffffL)
          assertEquals(d.read(0x50 + offset), mask)
          assertEquals(d.read(0x70 + offset), mask)
          d.write(0x30 + offset, 0xffffffffL)
          assertEquals(d.read(0x10 + offset), 0L)
          assertEquals(d.read(0x50 + offset), mask, "disable must preserve pending")
          d.write(0x70 + offset, 0xffffffffL)
          assertEquals(d.read(0x50 + offset), 0L)
        }
        for (word <- 0 until 32) {
          val fields = math.max(0, math.min(8, count - word * 8))
          val mask   = (1L << (fields * 4)) - 1
          d.write(0x100 + 4 * word, 0xffffffffL)
          assertEquals(d.read(0x100 + 4 * word), mask)
        }
        for (addr <- (4 until 0x10 by 4) ++ (0x90 until 0x100 by 4) ++ (0x180 until 0x200 by 4)) {
          d.write(addr, 0xffffffffL); assertEquals(d.read(addr), 0L)
        }
        d.read(0x11, error = true)
        d.setup(0x11, 0xffffffffL)
        assert(d.b.PSLVERR.toBoolean); d.finish()
        assertEquals(d.read(0x10), 0L)
        if (count > 0) {
          val last = count - 1
          d.write(0x10 + (last / 32) * 4, 1L << (last % 32))
          d.write(0x50 + (last / 32) * 4, 1L << (last % 32))
          d.edge(2); d.candidate(64 + last, 15)
          d.accept(); d.quiet()
        }
        d.reset(nmi = false); d.quiet() // initial low pin must not manufacture an edge
        assertEquals(d.read(0), 0L)
      }
    }

  test("strobes, held levels, software pend/accept races and stale-candidate rejection") {
    SimConfig.withVerilator.compile(new J2Intc(IntcConfig(33))).doSim { dut =>
      val d = new Driver(dut)
      d.reset()
      var enabled  = 0L
      var pending  = 0L
      var priority = 0L
      for (strobe <- 0 until 16) {
        val mask = (0 until 4)
          .filter(i => (strobe & (1 << i)) != 0)
          .map(i => 255L << (8 * i))
          .foldLeft(0L)(_ | _)
        val data = (0x1020304L * (strobe + 1)) & 0xffffffffL
        d.write(0x10, data, strobe); enabled |= data & mask
        d.write(0x50, data, strobe); pending |= data & mask
        d.write(0x100, data, strobe); priority = (priority & ~mask) | (data & mask)
        assertEquals(d.read(0x30), enabled)
        assertEquals(d.read(0x70), pending)
        assertEquals(d.read(0x100), priority)
        d.write(0x30, data, strobe); enabled &= ~(data & mask)
        d.write(0x70, data, strobe); pending &= ~(data & mask)
        assertEquals(d.read(0x10), enabled)
        assertEquals(d.read(0x50), pending)
      }
      d.reset()
      d.write(0x100, 0xaaa) // priorities 10 for IRQ0..2
      d.write(0x50, 7); d.edge(2); d.quiet() // pending while disabled
      d.write(0x10, 7); d.edge(2); d.candidate(64, 10)
      dut.io.maskLevel            #= 10; d.quiet() // immediate recheck of SR.I
      d.edge(2); dut.io.maskLevel #= 9; d.edge(2); d.candidate(64, 10)
      // ICER on the acceptance edge prevents acknowledging the stale candidate.
      d.setup(0x30, 1); dut.io.accept #= true; d.quiet(); d.finish()
      dut.io.accept                   #= false; d.edge(2); d.candidate(65, 10)
      assertEquals(d.read(0x50), 7L)
      d.accept(); d.edge(2); d.candidate(66, 10)
      d.setup(0x70, 4); dut.io.accept #= true; d.quiet(); d.finish()
      dut.io.accept                   #= false; d.edge(2); d.quiet()
      // ISPR wins a simultaneous acceptance of that same source.
      d.write(0x10, 1); d.edge(2); d.candidate(64, 10)
      d.setup(0x50, 1); dut.io.accept #= true; d.candidate(64, 10); d.finish()
      dut.io.accept                   #= false; d.edge(2); d.candidate(64, 10)
      d.accept(); d.quiet(); assertEquals(d.read(0x50), 0L)
      // A held hardware request survives ICPR/acceptance, but withdrawal leaves no sticky copy.
      dut.io.requests #= 2; d.edge(2); d.candidate(65, 10)
      d.write(0x70, 2); d.edge(2); d.candidate(65, 10)
      d.accept(); d.edge(2); d.candidate(65, 10)
      dut.io.requests #= 0; d.quiet(); d.edge(2); d.quiet()
      // Software pending is independent of the pin, including withdrawal after ISPR.
      dut.io.requests                   #= 4; d.edge(2); d.candidate(66, 10)
      d.write(0x50, 4); dut.io.requests #= 0; d.edge(2); d.candidate(66, 10)
      // Priority write invalidates old level metadata before it can enter the core.
      d.setup(0x100, 0xbaa); dut.io.accept #= true; d.quiet(); d.finish()
      dut.io.accept                        #= false; d.quiet(); d.edge(2); d.candidate(66, 11)
      d.accept(); d.edge(2); d.quiet()
      dut.io.maskLevel #= 0
      for (level <- 0 to 15) {
        d.write(0x100, level); d.write(0x50, 1); d.edge(2)
        if (level == 0) d.quiet() else d.candidate(64, level)
        dut.io.maskLevel #= level; d.quiet(); dut.io.maskLevel #= 0
        d.write(0x70, 1)
      }
    }
  }

  test("192-source arbitration agrees with an independent priority model") {
    SimConfig.withVerilator.compile(new J2Intc(IntcConfig(192))).doSim { dut =>
      val d          = new Driver(dut)
      val random     = new scala.util.Random(0x494e5443L)
      val priorities = Array.fill(192)(random.nextInt(16))
      d.reset()
      for (word <- 0 until 24) {
        val value =
          (0 until 8).map(i => priorities(8 * word + i).toLong << (4 * i)).foldLeft(0L)(_ | _)
        d.write(0x100 + 4 * word, value)
      }
      for (_ <- 0 until 100) {
        val enabled = BigInt(192, random)
        val pending = BigInt(192, random)
        val mask    = random.nextInt(16)
        for (word <- 0 until 6) {
          d.write(0x30 + 4 * word, 0xffffffffL)
          d.write(0x10 + 4 * word, ((enabled >> (32 * word)) & 0xffffffffL).toLong)
        }
        dut.io.requests  #= pending
        dut.io.maskLevel #= mask
        d.edge(2)
        val expected = (0 until 192)
          .filter(n => enabled.testBit(n) && pending.testBit(n) && priorities(n) > mask)
          .sortBy(n => (-priorities(n), n))
          .headOption
        expected match {
          case Some(n) => d.candidate(64 + n, priorities(n))
          case None    => d.quiet()
        }
      }
    }
  }

  test("NMI synchronization, edge selection, pending acceptance and new-edge priority") {
    SimConfig.withVerilator.compile(new J2Intc(IntcConfig(1))).doSim { dut =>
      val d = new Driver(dut)
      d.reset(nmi = false); d.quiet()
      dut.io.maskLevel #= 15
      dut.io.nmi #= true; d.edge(6); d.quiet()
      dut.io.nmi #= false; d.edge(6); d.candidate(11, 15, nmi = true)
      assertEquals(d.read(0), 0L)
      for (addr <- Seq(0x30, 0x70, 0x100)) d.write(addr, 0xffffffffL)
      d.candidate(11, 15, nmi = true)
      d.accept(); d.edge(3); d.quiet()
      d.write(0, 2, strobes   = 0); assertEquals(d.read(0), 0L)
      d.write(0, 2, strobes   = 1); assertEquals(d.read(0), 2L)
      dut.io.nmi   #= true; d.edge(6); d.candidate(11, 15, nmi = true)
      dut.io.nmi   #= false; d.edge(6) // falling edge ignored in rising mode
      d.candidate(11, 15, nmi = true)
      // BufferCC is two stages; its new sample sets pending on the third edge.
      dut.io.nmi    #= true; d.edge(2)
      dut.io.accept #= true; d.edge(); dut.io.accept #= false
      d.edge(2); d.candidate(11, 15, nmi = true) // new edge wins acceptance
      d.accept(); d.edge(3); d.quiet()
      assertEquals(d.read(0), 3L)
      // NMI supersedes an eligible ordinary source even at priority 15.
      dut.io.maskLevel #= 0
      d.write(0x100, 15); d.write(0x10, 1); d.write(0x50, 1)
      d.edge(2); d.candidate(64, 15)
      dut.io.nmi #= false; d.edge(6); dut.io.nmi #= true; d.edge(6)
      d.candidate(11, 15, nmi = true); d.accept(); d.edge(2); d.candidate(64, 15)
      assertEquals(d.read(0x50), 1L, "NMI acceptance must not consume a maskable source")
    }
  }
}
