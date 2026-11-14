package j2.core

import spinal.core._
import spinal.core.sim._
import scala.collection.mutable

class J2MicrocodedCoreSpec extends munit.FunSuite {
  test("reset vectors, W alignment, compare forwarding and branch delay slots with bus waits") {
    val compiled = SimConfig.withVerilator.compile(new J2MicrocodedCore)
    for (latency <- Seq(0, 1, 5)) compiled.doSim { dut =>
      val code = Map[Long, Int](
        0x100L -> 0xd107, // mov.l 0x120,r1
        0x102L -> 0x21f2, // mov.l r15,@r1
        0x104L -> 0xe000, // mov #0,r0
        0x106L -> 0x8800, // cmp/eq #0,r0
        0x108L -> 0x8901, // bt 0x10e (must see the preceding compare)
        0x10aL -> 0xe0ff,
        0x10cL -> 0xaffe, // failed compare loops here
        0x10eL -> 0xa001, // bra 0x114
        0x110L -> 0xe007, // delay slot: mov #7,r0
        0x112L -> 0xe0ff, // must be skipped
        0x114L -> 0x1101, // mov.l r0,@(4,r1)
        0x116L -> 0xaffe,
        0x118L -> 0x0009
      )
      val memory = mutable.Map[Long, Long](0L -> 0x100L, 4L -> 0x800L, 0x120L -> 0x400L)
      val reads = mutable.ArrayBuffer.empty[Long]
      dut.io.ibus.ACK #= false
      dut.io.ibus.ERR #= false
      dut.io.ibus.DAT_MISO #= 0
      dut.io.dbus.ACK #= false
      dut.io.dbus.ERR #= false
      dut.io.dbus.DAT_MISO #= 0
      dut.io.event.valid #= false
      dut.io.event.payload.command #= 0
      dut.io.event.payload.vector #= 0
      dut.io.event.payload.level #= 0
      dut.io.event.payload.bypassMask #= false
      def tick(): Unit = {
        dut.clockDomain.clockSim #= false
        sleep(5)
        dut.clockDomain.clockSim #= true
        sleep(5)
        dut.clockDomain.clockSim #= false
        sleep(1) // Let the falling-edge microcode ROM settle.
      }
      dut.clockDomain.clockSim #= false
      dut.clockDomain.assertReset()
      for (_ <- 0 until 4) tick()
      dut.clockDomain.deassertReset()
      sleep(1)
      var iw = 0
      var dw = 0
      var cycles = 0
      while (!memory.contains(0x404L) && cycles < 1000) {
        dut.io.ibus.ACK #= false
        dut.io.dbus.ACK #= false
        if (dut.io.ibus.STB.toBoolean) {
          if (iw == latency) {
            dut.io.ibus.DAT_MISO #= code.getOrElse(dut.io.ibus.ADR.toLong, 0x0009).toLong
            dut.io.ibus.ACK #= true
            iw = 0
          } else iw += 1
        }
        if (dut.io.dbus.STB.toBoolean) {
          // Different latencies exercise independently completing buses.
          if (dw == latency + 1) {
            val address = dut.io.dbus.ADR.toLong
            if (dut.io.dbus.WE.toBoolean) {
              assertEquals(dut.io.dbus.SEL.toInt, 15)
              memory(address) = dut.io.dbus.DAT_MOSI.toLong
            } else reads += address
            dut.io.dbus.DAT_MISO #= memory.getOrElse(address, 0L)
            dut.io.dbus.ACK #= true
            dw = 0
          } else dw += 1
        }
        tick()
        cycles += 1
      }
      assertEquals(reads.take(2).toSeq, Seq(0L, 4L))
      assertEquals(memory.get(0x400L), Some(0x800L), "reset SP must reach R15")
      assertEquals(memory.get(0x404L), Some(7L), "taken branch must execute its delay slot")
    }
  }
}
