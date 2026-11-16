package j2.core

import j2.bus.{J2Wishbone, J2WishboneArbiter}
import spinal.core._
import spinal.core.sim._
import spinal.lib._
import scala.collection.mutable

class J2AtomicBusSpec extends munit.FunSuite {
  test("TAS and CAS retain arbitration across read-modify-write gaps, bus waits, and reset") {
    class Probe extends Component {
      val io = new Bundle {
        val ibus, dbus        = master(J2Wishbone())
        val competitor        = slave(J2Wishbone())
        val cpuCycle, cpuLock = out Bool ()
      }
      val cpu = new J2MicrocodedCore(exposeDebug = false)
      cpu.io.event.valid := False
      cpu.io.event.payload.assignFromBits(B(0, cpu.io.event.payload.getBitsWidth bits))
      io.ibus <> cpu.io.ibus
      val arbiter = new J2WishboneArbiter(2)
      arbiter.io.inputs(0) <> cpu.io.dbus
      arbiter.io.inputs(1) <> io.competitor
      io.dbus <> arbiter.io.output
      io.cpuCycle := cpu.io.dbus.CYC
      io.cpuLock  := cpu.io.dbus.LOCK
    }
    val compiled = SimConfig.withVerilator.compile(new Probe)
    for (variant <- Seq("tas", "cas-success", "cas-fail"); latency <- Seq(0, 4)) compiled.doSim {
      dut =>
        val cas         = variant != "tas"
        val shouldWrite = variant != "cas-fail"
        val initial     = if (!cas) 0L else if (shouldWrite) 0x12345678L else 0x87654321L
        val code = Map[Long, Int](
          0x100L -> 0xd00b,
          0x102L -> 0xd10c,
          0x104L -> 0xd20c,
          0x106L -> (if (cas) 0x2123 else 0x401b),
          0x108L -> 0xd30c,
          0x10aL -> 0xe407,
          0x10cL -> 0x2342,
          0x10eL -> 0xaffe,
          0x110L -> 9
        )
        val memory = mutable.Map[Long, Long](
          0L -> 0x100L,
          4L -> 0x800L,
          0x130L -> 0x300L,
          0x134L -> 0x11223344L,
          0x138L -> 0x12345678L,
          0x13cL -> 0x400L,
          0x300L -> initial
        )
        dut.io.ibus.ACK            #= false
        dut.io.ibus.ERR            #= false
        dut.io.ibus.DAT_MISO       #= 0
        dut.io.dbus.ACK            #= false
        dut.io.dbus.ERR            #= false
        dut.io.dbus.DAT_MISO       #= 0
        dut.io.competitor.CYC      #= false
        dut.io.competitor.STB      #= false
        dut.io.competitor.WE       #= true
        dut.io.competitor.ADR      #= 0x900
        dut.io.competitor.DAT_MOSI #= 0x55aa
        dut.io.competitor.SEL      #= 15
        dut.io.competitor.LOCK     #= false
        def tick(): Unit = {
          dut.clockDomain.clockSim #= false
          sleep(5)
          dut.clockDomain.clockSim #= true
          sleep(5)
          dut.clockDomain.clockSim #= false
          sleep(1)
        }
        dut.clockDomain.clockSim #= false
        dut.clockDomain.assertReset()
        for (_ <- 0 until 4) tick()
        dut.clockDomain.deassertReset()
        sleep(1)
        var waits         = 0
        var readDone      = false
        var writeDone     = false
        var competingDone = false
        var cycles        = 0
        var resetInjected = false
        val transactions  = mutable.ArrayBuffer.empty[String]
        while ((memory.get(0x400L) != Some(7L) || !competingDone) && cycles < 3000) {
          if (cas && latency == 4 && readDone && !writeDone && !resetInjected) {
            dut.io.competitor.CYC #= false
            dut.io.competitor.STB #= false
            dut.io.ibus.ACK       #= false
            dut.io.dbus.ACK       #= false
            dut.clockDomain.assertReset()
            tick()
            tick()
            assert(
              !dut.io.cpuCycle.toBoolean && !dut.io.cpuLock.toBoolean,
              "reset must release an active atomic cycle"
            )
            assert(!dut.io.ibus.CYC.toBoolean, "reset must cancel instruction requests")
            dut.clockDomain.deassertReset()
            sleep(1)
            readDone      = false
            writeDone     = false
            competingDone = false
            waits         = 0
            transactions.clear()
            resetInjected = true
          }
          dut.io.ibus.ACK       #= false
          dut.io.dbus.ACK       #= false
          dut.io.competitor.CYC #= (readDone && !competingDone)
          dut.io.competitor.STB #= (readDone && !competingDone)
          sleep(1)
          if (shouldWrite && readDone && !writeDone) {
            assert(dut.io.cpuCycle.toBoolean, "atomic operation dropped CYC")
            assert(dut.io.cpuLock.toBoolean, "atomic operation dropped LOCK")
          }
          if (dut.io.ibus.STB.toBoolean) {
            dut.io.ibus.DAT_MISO #= code.getOrElse(dut.io.ibus.ADR.toLong, 9).toLong
            dut.io.ibus.ACK      #= true
          }
          if (dut.io.dbus.CYC.toBoolean && dut.io.dbus.STB.toBoolean) {
            if (waits == latency) {
              val address = dut.io.dbus.ADR.toLong
              if (address == 0x900) {
                assert(
                  writeDone || (!shouldWrite && !dut.io.cpuLock.toBoolean),
                  "competing master acquired the bus during the atomic operation"
                )
                transactions += "competitor"
                competingDone = true
              } else if (dut.io.dbus.WE.toBoolean) {
                var value  = memory.getOrElse(address, 0L)
                val data   = dut.io.dbus.DAT_MOSI.toLong
                val select = dut.io.dbus.SEL.toInt
                for (lane <- 0 until 4 if (select & (1 << lane)) != 0) {
                  val mask = 0xffL << (8 * lane)
                  value = (value & ~mask) | (data & mask)
                }
                memory(address) = value
                if (address == 0x300) { transactions += "atomic-write"; writeDone = true }
              } else if (address == 0x300) {
                transactions += "atomic-read"
                readDone = true
              }
              dut.io.dbus.DAT_MISO #= memory.getOrElse(address, 0L)
              dut.io.dbus.ACK      #= true
              waits = 0
            } else waits += 1
          }
          tick()
          cycles += 1
        }
        assertEquals(
          transactions.toSeq,
          if (shouldWrite) Seq("atomic-read", "atomic-write", "competitor")
          else Seq("atomic-read", "competitor")
        )
        assertEquals(
          memory.get(0x300L),
          Some(if (!shouldWrite) initial else if (cas) 0x11223344L else 0x80000000L)
        )
        assertEquals(memory.get(0x400L), Some(7L))
    }
  }
}
