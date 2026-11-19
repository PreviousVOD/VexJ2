package j2.core
import j2.bus._
import j2.bus.ahb5._
import spinal.lib.bus.misc.SizeMapping
import spinal.core._
import spinal.core.sim._
import spinal.lib._
import scala.collection.mutable
class J2ReviewRegressionSpec extends munit.FunSuite {
  test(
    "AHB TAS releases its domain before fetching and preserves an immediate conditional branch"
  ) {
    class SharedMemory extends Component {
      val io = new Bundle {
        val bus                                     = master(J2Wishbone())
        val pc                                      = out UInt (32 bits)
        val instructionPending, dataPending, locked = out Bool ()
        val competitor                              = slave(J2Ahb.manager())
      }
      val cpu = new J2MicrocodedCore
      cpu.io.interrupts := 0
      cpu.io.nmi        := True
      val matrix = new Ahb5Interconnect(J2Ahb.config, 3, Seq(SizeMapping(0, 0x1000)))
      matrix.io.managers(0) <> cpu.io.ibus
      matrix.io.managers(1) <> cpu.io.dbus
      matrix.io.managers(2) <> io.competitor
      val target = new J2AhbToWishbone
      target.io.ahb <> matrix.io.subordinates(0)
      io.bus <> target.io.wb
      io.pc                 := cpu.io.pc
      io.instructionPending := cpu.io.ibus.address.HTRANS(1)
      io.dataPending        := cpu.io.dbus.address.HTRANS(1)
      io.locked             := cpu.io.dbus.address.HMASTLOCK
    }
    val completed = mutable.ArrayBuffer.empty[Boolean]
    val compiled  = SimConfig.withVerilator.compile(new SharedMemory)
    for (latency <- Seq(0, 4); initial <- Seq(0L, 0x55000000L))
      compiled.doSim(s"tas-wait-$latency-initial-$initial") { dut =>
        val code = Seq(
          0xd00b,
          0xd10c,
          0xd20c,
          9,
          0x401b,
          (if (initial == 0) 0x8901 else 0x8b01), // immediately consume TAS T
          0xaffe,
          9, // wrong T loops here
          0xd30a,
          0xe407,
          0x2342,
          0xaffe,
          9
        )
        val mem = mutable.Map[Long, Long](
          0L -> 0x100L,
          4L -> 0xf00L,
          0x130L -> 0x300L,
          0x134L -> 0x11223344L,
          0x138L -> 0x12345678L,
          0x13cL -> 0x600L,
          0x300L -> initial
        )
        code.zipWithIndex.foreach { case (op, index) =>
          val addr = 0x100L + index * 2
          val base = addr & ~3L

          val shift = if ((addr & 2) == 0) 16 else 0

          mem(base) = mem.getOrElse(base, 0L) | (op.toLong << shift)
        }
        def tick(): Unit = {
          dut.clockDomain.clockSim #= false
          sleep(5)
          dut.clockDomain.clockSim #= true
          sleep(5)

          dut.clockDomain.clockSim #= false
          sleep(1)
        }
        dut.io.competitor.address.HTRANS    #= 0
        dut.io.competitor.address.HADDR     #= 0x900
        dut.io.competitor.address.HWRITE    #= true
        dut.io.competitor.address.HSIZE     #= 2
        dut.io.competitor.address.HBURST    #= 0
        dut.io.competitor.address.HPROT     #= 3
        dut.io.competitor.address.HMASTER   #= 2
        dut.io.competitor.address.HMASTLOCK #= false
        dut.io.competitor.HWDATA            #= 123
        var competitorIssued = false
        var atomicRead       = false
        var atomicWrite      = false
        var competingDone    = false
        var waits            = 0
        dut.io.bus.ACK           #= false
        dut.io.bus.ERR           #= false
        dut.io.bus.DAT_MISO      #= 0
        dut.clockDomain.clockSim #= false
        dut.clockDomain.assertReset()

        for (_ <- 0 until 4) tick()
        dut.clockDomain.deassertReset()
        sleep(1)
        for (cycle <- 0 until 3000 if !mem.contains(0x600L) || !competingDone) {
          dut.io.competitor.address.HTRANS #= (if (atomicRead && !competitorIssued) 2 else 0)
          sleep(1)
          dut.io.bus.ACK #= false
          if (dut.io.bus.CYC.toBoolean && dut.io.bus.STB.toBoolean) {
            if (waits < latency) waits += 1
            else {
              waits = 0
              val addr = dut.io.bus.ADR.toLong & ~3L
              if (addr == 0x300) {
                if (dut.io.bus.WE.toBoolean) atomicWrite = true else atomicRead = true
              }
              if (addr == 0x900) {
                assert(
                  atomicWrite,
                  "competitor entered the locked cycle"
                )
                competingDone = true
              }
              if (dut.io.bus.WE.toBoolean) {
                var value = mem.getOrElse(addr, 0L)
                val data  = dut.io.bus.DAT_MOSI.toLong

                val sel = dut.io.bus.SEL.toInt

                for (lane <- 0 until 4 if (sel & (1 << lane)) != 0) {
                  val mask = 0xffL << (lane * 8)
                  value = (value & ~mask) | (data & mask)
                }
                mem(addr) = value
              }
              dut.io.bus.DAT_MISO #= mem.getOrElse(addr, 0L)
              dut.io.bus.ACK      #= true
            }
          }
          if (dut.io.competitor.address.HTRANS.toInt == 2 && dut.io.competitor.HREADY.toBoolean)
            competitorIssued = true
          tick()
        }
        println(
          s"shared atomic TAS latency=$latency result=${mem.get(0x600L)} pc=${dut.io.pc.toLong.toHexString} I=${dut.io.instructionPending.toBoolean} D=${dut.io.dataPending.toBoolean} lock=${dut.io.locked.toBoolean}"
        )
        assertEquals(
          mem.get(0x300L),
          Some(initial | 0x80000000L)
        )
        assert(competingDone)
        completed += (mem.get(0x600L) == Some(7L))
      }
    assert(completed.forall(identity))
  }
  test("load-use stalls preserve the faulting instruction resume PC") {
    val compiled = SimConfig.withVerilator.compile(new J2WishboneCoreFixture)
    for (padded <- Seq(true, false); latency <- Seq(0, 3); busError <- Seq(false, true))
      compiled.doSim(s"fault-padded-$padded-wait-$latency-error-$busError") { dut =>
        val prefix =
          if (padded)
            Map[Long, Int](
              0x100L -> 0xd107,
              0x102L -> 9,
              0x104L -> 9,
              0x106L -> 0x6212,
              0x108L -> 9,
              0x10aL -> 9,
              0x10cL -> 0x6022,
              0x10eL -> 0xaffe,
              0x110L -> 9
            )
          else
            Map[Long, Int](
              0x100L -> 0xd107,
              0x102L -> 0x6212,
              0x104L -> 0x6022,
              0x106L -> 0xaffe,
              0x108L -> 9
            )
        val code = prefix ++ Map[Long, Int](
          0x200L -> 0xd607,
          0x202L -> 0x67f2,
          0x204L -> 0x2672,
          0x206L -> 0xaffe,
          0x208L -> 9
        )
        val mem = mutable.Map[Long, Long](
          0L -> 0x100L,
          4L -> 0xf00L,
          0x120L -> 0x700L,
          0x700L -> (if (busError) 0x300L else 0x301L),
          0x24L -> 0x200L,
          0x220L -> 0x600L
        )
        dut.io.ibus.ACK              #= false
        dut.io.ibus.ERR              #= false
        dut.io.ibus.DAT_MISO         #= 0
        dut.io.dbus.ACK              #= false
        dut.io.dbus.ERR              #= false
        dut.io.dbus.DAT_MISO         #= 0
        dut.io.event.valid           #= false
        dut.io.event.payload.command #= 0

        dut.io.event.payload.level  #= 0
        dut.io.event.payload.vector #= 0

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
        var instructionWaits = 0
        var dataWaits        = 0
        for (cycle <- 0 until 1500 if !mem.contains(0x600L)) {
          dut.io.ibus.ACK #= false
          dut.io.dbus.ACK #= false
          dut.io.dbus.ERR #= false
          if (dut.io.ibus.STB.toBoolean) {
            if (instructionWaits < latency) instructionWaits += 1
            else {
              instructionWaits = 0
              dut.io.ibus.ACK      #= true
              dut.io.ibus.DAT_MISO #= J2InstructionMemory.word(code, dut.io.ibus.ADR.toLong)
            }
          }
          if (dut.io.dbus.STB.toBoolean) {
            if (dataWaits < latency) dataWaits += 1
            else {
              dataWaits = 0
              val addr   = dut.io.dbus.ADR.toLong
              val failed = busError && addr == 0x300L
              dut.io.dbus.ACK #= !failed
              dut.io.dbus.ERR #= failed
              if (!failed && dut.io.dbus.WE.toBoolean) mem(addr) = dut.io.dbus.DAT_MOSI.toLong
              dut.io.dbus.DAT_MISO #= mem.getOrElse(addr, 0L)
            }
          }
          tick()
        }
        println(s"load-use padded=$padded fault stacked PC=${mem.get(0x600L)}")
        assertEquals(mem.get(0x600L), Some(if (padded) 0x10eL else 0x106L))
      }
  }
}
