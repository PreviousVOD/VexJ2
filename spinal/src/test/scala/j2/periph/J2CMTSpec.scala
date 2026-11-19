package j2.periph

import spinal.core.sim._
import scala.language.reflectiveCalls

class J2CMTSpec extends munit.FunSuite {
  class Rig(val dut: J2CMT) {
    val b      = dut.io.bus
    var cycles = 0
    b.PSEL                   #= 0; b.PENABLE #= false; b.PWRITE #= false; b.PADDR #= 0
    b.PWDATA                 #= 0; b.PSTRB   #= 0; b.PPROT      #= 0
    dut.clockDomain.clockSim #= false
    def tick(): Unit = {
      dut.clockDomain.clockSim #= true; sleep(5)
      dut.clockDomain.clockSim #= false; sleep(5)
      cycles += 1
    }
    dut.clockDomain.assertReset(); for (_ <- 0 until 3) tick()
    dut.clockDomain.deassertReset(); cycles = 0; sleep(1)
    def peek(address: Int): Long = {
      b.PADDR #= address; sleep(1); b.PRDATA.toLong
    }
    def half(address: Int): Int =
      ((peek(address & ~3) >> (if ((address & 2) == 0) 16 else 0)) & 65535).toInt
    def access(
        address: Int,
        data: Long = 0,
        mask: Int = 0,
        write: Boolean = true,
        error: Boolean = false
    ): Long = {
      b.PADDR   #= address; b.PWRITE #= write; b.PWDATA #= data
      b.PSTRB   #= mask; b.PSEL      #= 1; b.PENABLE    #= false; tick()
      b.PENABLE #= true; sleep(1)
      assert(b.PREADY.toBoolean); assertEquals(b.PSLVERR.toBoolean, error)
      val value = b.PRDATA.toLong
      tick(); b.PSEL #= 0; b.PENABLE #= false; sleep(1)
      value
    }
    def word(address: Int, data: Int): Unit = {
      val shift = if ((address & 2) == 0) 16 else 0
      access(address & ~3, data.toLong << shift, 3 << (shift / 8))
    }
    def untilBefore(divisor: Int): Unit = while (cycles % divisor != divisor - 2) tick()
  }
  private def run(body: Rig => Unit): Unit =
    SimConfig.withVerilator.compile(new J2CMT).doSim(d => body(new Rig(d)))

  test("CMT reset map, reserved bits, byte lanes, paired writes and errors") {
    run { r =>
      assertEquals(r.peek(0), 0L); assertEquals(r.peek(4), 65535L)
      assertEquals(r.peek(8), 0L); assertEquals(r.peek(12), 0xffff0000L)
      r.access(0, 0xfffcffbfL, 15)
      assertEquals(r.peek(0), 3L) // STR=0, CMIE=0; writing CMF=1 cannot set it.
      r.access(4, 0x12345678L, 15)
      assertEquals(r.peek(4), 0x12345678L)
      r.access(4, 0xaabbccddL, 8); assertEquals(r.peek(4), 0xaa345678L)
      r.access(4, 0xaabbccddL, 4); assertEquals(r.peek(4), 0xaabb5678L)
      r.access(4, 0xaabbccddL, 2); assertEquals(r.peek(4), 0xaabbcc78L)
      r.access(4, 0xaabbccddL, 1); assertEquals(r.peek(4), 0xaabbccddL)
      r.access(4, 0, 0); assertEquals(r.peek(4), 0xaabbccddL)
      r.access(8, 0x00831234L, 15); assertEquals(r.peek(8), 0x00031234L)
      r.access(12, 0x5678ffffL, 15); assertEquals(r.peek(12), 0x56780000L)
      r.access(16, error = true); r.access(1, write = false, error = true)
    }
  }
  for ((divisor, cks) <- Seq(8, 32, 128, 512).zipWithIndex)
    test(s"CMT PCLK/$divisor count, compare period, stop/resume and independent channel") {
      run { r =>
        r.word(2, cks); r.word(6, 3); r.word(8, 3); r.word(12, 60000)
        r.word(0, 3)
        var count0 = 0; var count1 = 0; var flag = false
        for (_ <- 0 until divisor * 12) {
          if ((r.cycles + 1) % divisor == 0) {
            if (count0 == 3) { count0 = 0; flag = true }
            else count0 += 1
          }
          if ((r.cycles + 1) % 512 == 0) count1 += 1
          r.tick()
          assertEquals(r.half(4), count0)
          assertEquals(r.half(10), count1)
          assertEquals((r.half(2) & 128) != 0, flag)
        }
        r.word(0, 0)
        // If stopped exactly at compare, hardware still clears on the next tick.
        for (_ <- 0 until divisor) r.tick()
        val held0 = r.half(4); val held1 = r.half(10)
        for (_ <- 0 until 1024) r.tick()
        assertEquals(r.half(4), held0); assertEquals(r.half(10), held1)
        r.word(0, 2)
        for (_ <- 0 until 1024) r.tick()
        assertEquals(r.half(4), held0); assertEquals(r.half(10), held1 + 2)
      }
    }
  test("CMT CMF W0C, registered interrupts and stopped compare") {
    run { r =>
      r.word(6, 0) // Equality while stopped must still generate CMF.
      for (_ <- 0 until 9) r.tick()
      assertEquals(r.half(2), 128); assertEquals(r.dut.io.interrupt.toInt, 0)
      r.word(6, 7)
      r.word(2, 0xc0); r.tick()
      assertEquals(r.dut.io.interrupt.toInt, 1)
      r.access(0, 0, 2) // High CSR byte cannot clear CMF or CMIE.
      assertEquals(r.half(2), 0xc0)
      r.word(2, 0x80); r.tick(); assertEquals(r.dut.io.interrupt.toInt, 0)
      r.word(2, 0x40)
      assertEquals(r.half(2), 0x40); r.tick(); assertEquals(r.dut.io.interrupt.toInt, 0)
      r.word(12, 0); r.word(8, 0xc0)
      for (_ <- 0 until 9) r.tick()
      assertEquals(r.dut.io.interrupt.toInt, 2)
      r.word(12, 7); r.word(8, 0x40); r.tick()
      assertEquals(r.dut.io.interrupt.toInt, 0)
      // CMF clear on the same PCLK edge as a match loses to the new match.
      r.word(4, 7); r.untilBefore(8); r.word(2, 0x40)
      assertEquals(r.half(2), 0xc0); assertEquals(r.half(4), 0)
    }
  }
  test("CMT counter writes suppress increments, compare clear wins over writes") {
    run { r =>
      r.word(6, 0xffff); r.word(4, 0x12ff); r.word(0, 1)
      r.untilBefore(8)
      val before = r.half(4)
      r.access(4, 0xaa000000L, 8)
      assertEquals(r.half(4), 0xaa00 | (before & 255))
      r.untilBefore(8); r.word(4, 0x1234); assertEquals(r.half(4), 0x1234)
      r.word(0, 0); r.word(4, 7); r.word(6, 7)
      // Stopped equality clears at a divided-clock edge, even during a write.
      r.untilBefore(8); r.word(4, 42)
      assertEquals(r.half(4), 0)
      assertEquals(r.half(2) & 128, 128)
    }
  }
}
