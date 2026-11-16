package j2.core

import spinal.core._
import spinal.core.sim._
import scala.collection.mutable

class J2SleepFaultSpec extends munit.FunSuite {
  test("sleep wakeup and synchronous faults preserve the exception boundary") {
    case class Scenario(
        name: String,
        instruction: Int = 0x6012,
        address: Long = 0x301,
        dataError: Boolean = false,
        fetchError: Boolean = false,
        sleepTest: Boolean = false,
        delaySlot: Boolean = false,
        ackAndError: Boolean = false,
        oddFetch: Boolean = false,
        irqSleep: Boolean = false,
        healthyValue: Option[Long] = None,
        youngerBranch: Boolean = false,
        entryError: Boolean = false
    )
    val scenarios = Seq(
      Scenario(
        "valid byte load",
        instruction  = 0x6010,
        address      = 0x301,
        healthyValue = Some(0x34L)
      ),
      Scenario(
        "valid word load",
        instruction  = 0x6011,
        address      = 0x302,
        healthyValue = Some(0x5678L)
      ),
      Scenario("valid long load", address = 0x300, healthyValue = Some(0x12345678L)),
      Scenario("fault before delayed branch", youngerBranch = true),
      Scenario("unaligned long load"),
      Scenario("halfword-aligned long load", address       = 0x302),
      Scenario("fault during exception entry", entryError  = true),
      Scenario("unaligned word load", instruction          = 0x6011),
      Scenario("unaligned long store", instruction         = 0x2102),
      Scenario("unaligned word store", instruction         = 0x2101),
      Scenario("unaligned postincrement load", instruction = 0x6016),
      Scenario("failed SR load", instruction               = 0x4107),
      Scenario("failed MACH load", instruction             = 0x4106),
      Scenario("SR load ERR", instruction           = 0x4107, address  = 0x300, dataError = true),
      Scenario("MACH load ERR", instruction         = 0x4106, address  = 0x300, dataError = true),
      Scenario("MACL load ERR", instruction         = 0x4116, address  = 0x300, dataError = true),
      Scenario("store ERR without ACK", instruction = 0x2102, address  = 0x300, dataError = true),
      Scenario("odd instruction target", oddFetch   = true),
      Scenario("data ERR without ACK", address      = 0x300, dataError = true),
      Scenario(
        "ERR takes priority over ACK",
        address     = 0x300,
        dataError   = true,
        ackAndError = true
      ),
      Scenario("instruction ERR without ACK", instruction = 0x0009, fetchError = true),
      Scenario("delay slot data fault", delaySlot         = true),
      Scenario("delay slot fetch fault", instruction      = 9, fetchError = true, delaySlot = true),
      Scenario("SLEEP and masked IRQ then NMI", sleepTest = true),
      Scenario("SLEEP and unmasked IRQ", sleepTest = true, irqSleep = true)
    )
    for (exposeDebug <- Seq(true, false)) {
      val compiled =
        SimConfig.withVerilator.compile(new J2MicrocodedCore(exposeDebug = exposeDebug))
      for (scenario <- scenarios; latency <- Seq(0, 3))
        compiled.doSim(scenario.name.replace(' ', '_') + latency) { dut =>
          val code = mutable.Map[Long, Int](
            0x100L -> 0xe04d, // mov #77,r0
            0x102L -> 0xd107, // mov.l 0x120,r1
            0x104L -> 0xd207, // mov.l 0x124,r2
            0x106L -> scenario.instruction,
            0x108L -> 0x2202, // store r0 at 0x400 after RTE
            0x10aL -> 0xaffe,
            0x10cL -> 0x0009,
            0x200L -> 0xd60f, // handler: destination 0x600
            0x202L -> 0x67f2, // saved PC
            0x204L -> 0x2672,
            0x206L -> 0x57f1, // saved SR
            0x208L -> 0x1671,
            0x20aL -> 0x1602, // r0 at handler entry
            0x20cL -> 0x070a, // sts mach,r7
            0x20eL -> 0x1673, // save MACH
            0x210L -> 0x071a, // sts macl,r7
            0x212L -> 0x1674, // save MACL
            0x214L -> 0x002b, // rte
            0x216L -> 0x0009
          )
          if (scenario.sleepTest) code(0x106) = 0x001b
          if (scenario.irqSleep) {
            code(0x102) = 0xe100 // R1=0
            code(0x104) = 0x410e // SR=R1
            code(0x108) = 0xd206 // reload result destination after wakeup
            code(0x10a) = 0x2202
            code(0x10c) = 0xaffe
            code(0x10e) = 9
          }
          if (scenario.delaySlot) {
            code(0x106) = 0xa003 // bra 0x110
            code(0x108) = scenario.instruction
            code(0x10a) = 0xe0ff
            code(0x110) = 0x2202
            code(0x112) = 0xaffe
            code(0x114) = 0x0009
          }
          if (scenario.youngerBranch) {
            code(0x108) = 0xa002 // resumed branch targets 0x110
            code(0x10a) = 9
            code(0x110) = 0x2202
            code(0x112) = 0xaffe
            code(0x114) = 9
          }
          if (scenario.oddFetch) {
            code(0x106) = 0x412b // jmp @r1 (0x301)
            code(0x108) = 9
            code(0x110) = 0x2202
            code(0x112) = 0xaffe
            code(0x114) = 9
            // Handler records the bad target then repairs the frame before RTE.
            code(0x20c) = 0xd70d
            code(0x20e) = 0x2f72
            code(0x210) = 0x002b
            code(0x212) = 9
          }
          val memory = mutable.Map[Long, Long](
            0L -> 0x100L,
            4L -> 0x800L,
            0x24L -> 0x200L,
            0x2cL -> 0x200L,
            0x120L -> scenario.address,
            0x124L -> 0x400L,
            0x240L -> 0x600L,
            0x244L -> 0x110L,
            0x300L -> 0x12345678L
          )
          dut.io.ibus.ACK                 #= false
          dut.io.ibus.ERR                 #= false
          dut.io.ibus.DAT_MISO            #= 0
          dut.io.dbus.ACK                 #= false
          dut.io.dbus.ERR                 #= false
          dut.io.dbus.DAT_MISO            #= 0
          dut.io.event.valid              #= false
          dut.io.event.payload.command    #= 0
          dut.io.event.payload.vector     #= 11
          dut.io.event.payload.level      #= 1 // masked by reset SR.I=15
          dut.io.event.payload.bypassMask #= false
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
          var iw                 = 0
          var dw                 = 0
          var sleepCycles        = 0
          var eventAcks          = 0
          var eventSent          = false
          var faultInjected      = false
          var entryErrorInjected = false
          var quietCycles        = 0
          val reads              = mutable.ArrayBuffer.empty[Long]
          val writes             = mutable.ArrayBuffer.empty[Long]
          var cycles             = 0
          while (!memory.contains(0x400L) && cycles < 1500) {
            dut.io.ibus.ACK #= false
            dut.io.ibus.ERR #= false
            dut.io.dbus.ACK #= false
            dut.io.dbus.ERR #= false
            val asleep = scenario.sleepTest && (if (exposeDebug) dut.io.sleep.toBoolean
                                                else cycles >= 300 && !eventSent)
            if (asleep) {
              sleepCycles += 1
              assert(!dut.io.ibus.STB.toBoolean && !dut.io.dbus.STB.toBoolean)
              if (sleepCycles == 10) {
                dut.io.event.valid #= true
                if (scenario.irqSleep) eventSent = true
              }
              if (sleepCycles == 30) {
                dut.io.event.payload.bypassMask #= true
                eventSent = true
              }
            }
            if (dut.io.ibus.STB.toBoolean) {
              if (iw == latency) {
                val addr = dut.io.ibus.ADR.toLong
                assertEquals(addr & 1L, 0L, "odd fetch reached bus")
                val error = scenario.fetchError && addr == (if (scenario.delaySlot) 0x108
                                                            else 0x106) && !faultInjected
                if (!scenario.sleepTest && addr == 0x106) dut.io.event.valid #= true
                dut.io.ibus.DAT_MISO #= code.getOrElse(addr, 0x0009).toLong
                dut.io.ibus.ERR      #= error
                dut.io.ibus.ACK      #= !error
                if (error) faultInjected = true
                iw                       = 0
              } else iw += 1
            }
            if (dut.io.dbus.STB.toBoolean) {
              if (dw == latency + 1) {
                val addr = dut.io.dbus.ADR.toLong
                if (scenario.healthyValue.isEmpty)
                  assertEquals(addr & 3L, 0L, s"misaligned bus request in ${scenario.name}")
                val entryError = scenario.entryError && addr == 0x7fc
                if (entryError) entryErrorInjected = true
                val error = entryError || (scenario.dataError && addr == 0x300 && !faultInjected)
                if (error) faultInjected = true
                else if (dut.io.dbus.WE.toBoolean) {
                  memory(addr) = dut.io.dbus.DAT_MOSI.toLong
                  writes += addr
                } else reads += addr
                dut.io.dbus.DAT_MISO #= (if (error) 0xdeadbeefL
                                         else memory.getOrElse(addr & ~3L, 0L))
                dut.io.dbus.ERR #= error
                dut.io.dbus.ACK #= (!error || scenario.ackAndError)
                dw = 0
              } else dw += 1
            }
            sleep(1)
            val ack = dut.io.eventAck.toBoolean && dut.io.event.valid.toBoolean
            tick()
            if (ack) {
              eventAcks += 1
              dut.io.event.valid #= false
            }
            if (entryErrorInjected && !dut.io.ibus.CYC.toBoolean && !dut.io.dbus.CYC.toBoolean)
              quietCycles += 1
            else quietCycles = 0
            cycles += 1
          }
          if (scenario.entryError) {
            assert(entryErrorInjected && quietCycles > 100, "nested fault must quiesce both buses")
            assert(!memory.contains(0x400L), "nested fault resumed normal execution")
          } else if (scenario.healthyValue.nonEmpty) {
            assertEquals(memory.get(0x400L), scenario.healthyValue)
            assert(!reads.contains(0x24L), "aligned access raised an exception")
          } else {
            val expectedPc =
              if (scenario.oddFetch) 0x301L
              else if (scenario.delaySlot) 0x110L
              else if (scenario.fetchError) 0x106L
              else 0x108L
            assertEquals(memory.get(0x600L), Some(expectedPc), s"saved PC: ${scenario.name}")
            assertEquals(
              memory.get(0x604L),
              Some(if (scenario.irqSleep) 0L else 0xf0L),
              s"saved SR: ${scenario.name}"
            )
            if (!scenario.oddFetch) {
              assertEquals(memory.get(0x60cL), Some(0L), "failed load changed MACH")
              assertEquals(memory.get(0x610L), Some(0L), "failed load changed MACL")
            }
            assertEquals(memory.get(0x608L), Some(77L), s"failed load changed R0: ${scenario.name}")
            assertEquals(memory.get(0x400L), Some(77L), s"RTE did not resume: ${scenario.name}")
            if (scenario.sleepTest) {
              assert(eventSent && sleepCycles >= (if (scenario.irqSleep) 10 else 30))
              assertEquals(eventAcks, 1)
            } else {
              assert(reads.contains(0x24L), "CPU address-error vector 9 was not read")
              assertEquals(eventAcks, 0)
              assert(!writes.contains(scenario.address), "faulting store reached the bus")
            }
          }
        }
    }
  }
}
