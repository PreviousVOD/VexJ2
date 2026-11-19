package j2.core.intc

import j2.core._
import spinal.core._
import spinal.core.sim._
import scala.collection.mutable

class J2IntcCoreSpec extends munit.FunSuite {
  test("private INTC wakes SLEEP and retains accepted IRQ/NMI metadata through waited entry") {
    for (debug <- Seq(false, true)) {
      val compiled = SimConfig.withVerilator.compile(
        new J2WishboneCoreFixture(J2CoreConfig(exposeDebug = debug), J2CorePlugins.apply _, true)
      )
      for (mode <- Seq("irq", "nmi", "fault"); latency <- Seq(0, 3)) compiled.doSim { dut =>
        val nmi   = mode == "nmi"
        val fault = mode == "fault"
        val code  = mutable.Map[Long, Int]()
        val program =
          if (fault)
            Seq(0xd107, 0xd208, 0xe001, 0x1104, 0xe006, 0x2202, 0xd408, 0xe000, 0x400e, 0x6042,
              0xd304, 0xe04d, 0x2302, 0xaffe, 9)
          else
            Seq(
              0xd107,
              0xd208,
              0xe001,
              0x1104,
              0xe006,
              0x2202,
              if (nmi) 0xe0f0 else 0xe000,
              0x400e,
              0x001b,
              0xd305,
              0xe04d,
              0x2302,
              0xaffe,
              9
            )
        program.zipWithIndex.foreach { case (op, i) => code(0x1000L + 2 * i) = op }
        val handler = Seq(0x2f06, 0x2f16, 0xd108, 0x0002, 0x2102, 0x61f6, 0x60f6, 0x002b, 9)
        handler.zipWithIndex.foreach { case (op, i) => code(0x2000L + 2 * i) = op }
        val memory = mutable.Map[Long, Long](
          0L -> 0x1000L,
          4L -> 0x800L,
          0x100L -> 0x2000L,
          0x2cL -> 0x2000L,
          0x24L -> 0x2000L,
          0x1030L -> 0x300L,
          0x1020L -> 0xffffe900L,
          0x1024L -> 0xffffea00L,
          0x1028L -> 0x400L,
          0x2028L -> 0x500L
        )
        dut.io.ibus.ACK #= false; dut.io.ibus.ERR #= false; dut.io.ibus.DAT_MISO #= 0
        dut.io.dbus.ACK #= false; dut.io.dbus.ERR #= false; dut.io.dbus.DAT_MISO #= 0
        dut.io.event.valid              #= false; dut.io.event.payload.command #= 0
        dut.io.event.payload.vector     #= 0; dut.io.event.payload.level       #= 0
        dut.io.event.payload.bypassMask #= false
        dut.io.interrupts               #= 0; dut.io.nmi                       #= true
        dut.clockDomain.clockSim        #= false
        def edge(): Unit = {
          dut.clockDomain.clockSim #= true; sleep(5)
          dut.clockDomain.clockSim #= false; sleep(5)
        }
        dut.clockDomain.assertReset(); for (_ <- 0 until 4) edge()
        dut.clockDomain.deassertReset(); sleep(1)
        var instructionWait = 0
        var dataWait        = 0
        var ticks           = 0
        var triggered       = false
        val reads           = mutable.ArrayBuffer.empty[Long]
        val writes          = mutable.ArrayBuffer.empty[Long]
        while (!memory.contains(0x400L) && ticks < 2500) {
          dut.io.ibus.ACK #= false; dut.io.dbus.ACK #= false; dut.io.dbus.ERR #= false
          if (dut.io.ibus.STB.toBoolean) {
            if (instructionWait == latency) {
              val addr = dut.io.ibus.ADR.toLong
              dut.io.ibus.DAT_MISO #= J2InstructionMemory.word(code, addr)
              dut.io.ibus.ACK      #= true; instructionWait = 0
            } else instructionWait += 1
          }
          if (dut.io.dbus.STB.toBoolean) {
            if (dataWait == latency + 1) {
              val addr = dut.io.dbus.ADR.toLong
              assert((addr & 0xfffff000L) != 0xffffe000L, "PPB leaked onto the shared bus")
              if (dut.io.dbus.WE.toBoolean) {
                memory(addr) = dut.io.dbus.DAT_MOSI.toLong
                writes += addr
                if (addr == 0x7fc) dut.io.interrupts #= 0 // withdraw after acceptance, during entry
              } else reads += addr
              dut.io.dbus.DAT_MISO #= memory.getOrElse(addr, 0L)
              dut.io.dbus.ACK      #= true; dataWait = 0
              if (fault && addr == 0x300L) {
                dut.io.dbus.ACK   #= false
                dut.io.dbus.ERR   #= true
                dut.io.interrupts #= 1
                triggered = true
              }
            } else dataWait += 1
          }
          // By this point initialization has retired and SLEEP has stopped both buses.
          if (!fault && !triggered && ticks == 600) {
            if (debug) assert(dut.io.sleep.toBoolean)
            dut.io.interrupts   #= 1
            if (nmi) dut.io.nmi #= false
            triggered = true
          }
          edge(); ticks += 1
        }
        assertEquals(
          memory.get(0x400L),
          Some(77L),
          "handler must RTE to the correct continuation"
        )
        assertEquals(memory(0x500L) & 0xf0L, if (nmi) 0xf0L else if (fault) 0L else 0x60L)
        assertEquals(reads.count(_ == (if (nmi) 0x2cL else if (fault) 0x24L else 0x100L)), 1)
        assertEquals(writes.count(_ == 0x7fcL), 1, "no duplicate exception acceptance")
        assertEquals(memory(0x7fcL), if (nmi) 0x3f0L else 0L, "saved SR (MOV #-16 also sets Q/M)")
        assertEquals(memory(0x7f8L), if (fault) 0x1014L else 0x1012L, "saved PC")
        if (fault)
          assert(!reads.contains(0x100L), "pending IRQ must not displace the older data fault")
      }
    }
  }
}
