package j2.periph

import j2.bus.{J2WishboneReadCache, J2ReadCacheConfig, J2Wishbone}
import spinal.lib._
import spinal.lib.io.TriStateArray
import spinal.core._
import spinal.core.sim._
import scala.collection.mutable.ArrayBuffer

class J2CachedFlashFixture(baseAddress: BigInt = 0x10000000L) extends Component {
  val io = new Bundle {
    val control, cacheControl, xip = slave(J2Wishbone())
    val pauseRefill                = in Bool ()
    val spi = new Bundle {
      val cs, clk = out Bool ()
      val data    = master(TriStateArray(4))
    }
  }
  private val cache = new J2WishboneReadCache(
    J2ReadCacheConfig(baseAddress = baseAddress, rangeBytes = 0x100000)
  )
  private val flash = new J2SpiFlash
  io.xip <> cache.io.bus
  io.cacheControl <> cache.io.control
  val controlBridge = new J2WishboneToApb(j2.bus.J2Apb.config)
  io.control <> controlBridge.io.input
  controlBridge.io.output <> flash.io.control
  flash.io.xip.cmd.valid      := cache.io.refill.cmd.valid
  flash.io.xip.cmd.address    := cache.io.refill.cmd.address - U(baseAddress, 32 bits)
  flash.io.xip.cmd.length     := cache.io.refill.cmd.length
  cache.io.refill.cmd.ready   := flash.io.xip.cmd.ready
  cache.io.refill.rsp.valid   := flash.io.xip.rsp.valid && !io.pauseRefill
  cache.io.refill.rsp.payload := flash.io.xip.rsp.payload
  flash.io.xip.rsp.ready      := cache.io.refill.rsp.ready && !io.pauseRefill
  cache.io.hold               := flash.io.readHold
  cache.io.invalidate         := flash.io.invalidate
  flash.io.readBusy           := cache.io.busy
  io.spi <> flash.io.spi
}

class J2SpiFlashSpec extends munit.FunSuite {
  test("mode-0 flash changes MISO on falling edges without shifting JEDEC ID") {
    SimConfig.withVerilator.compile(new J2CachedFlashFixture).doSim { dut =>
      for (bus <- Seq(dut.io.control, dut.io.cacheControl, dut.io.xip)) {
        bus.CYC      #= false
        bus.STB      #= false
        bus.WE       #= false
        bus.ADR      #= 0
        bus.DAT_MOSI #= 0
        bus.SEL      #= 15
        bus.LOCK     #= false
      }
      dut.io.spi.data.read     #= 0xf
      dut.io.pauseRefill       #= false
      dut.clockDomain.clockSim #= false
      var previousClock = false
      var bits          = 0
      var command       = 0
      val commands      = ArrayBuffer.empty[Int]
      def flashPins(): Unit = {
        val clk = dut.io.spi.clk.toBoolean

        if (dut.io.spi.cs.toBoolean) {
          bits    = 0
          command = 0
          dut.io.spi.data.read #= 0xf
        } else if (!previousClock && clk) {
          command = ((command << 1) | (if ((dut.io.spi.data.write.toInt & 1) != 0) 1 else 0)) & 255
          bits += 1
          if (bits % 8 == 0) commands += command
        } else if (previousClock && !clk && bits >= 8) {
          // Real mode-0 flash launches bit 23 just after the command's final
          // falling edge, before the first rising edge of the response byte.
          val index = bits - 8
          dut.io.spi.data.read #= (if (index < 24 && ((0xef4014 >> (23 - index)) & 1) != 0) 0xf
                                   else 0xd)
        }
        previousClock = clk
      }
      def tick(): Unit = {
        dut.clockDomain.clockSim #= false
        sleep(5)
        flashPins()
        dut.clockDomain.clockSim #= true
        sleep(5)
        flashPins()
      }
      dut.clockDomain.assertReset()
      for (_ <- 0 until 4) tick()
      dut.clockDomain.deassertReset()
      tick()

      def access(write: Boolean, value: Int = 0): Long = {
        dut.io.control.CYC      #= true
        dut.io.control.STB      #= true
        dut.io.control.WE       #= write
        dut.io.control.DAT_MOSI #= value
        sleep(1)
        var waitCycles = 0
        while (!dut.io.control.ACK.toBoolean && waitCycles < 100) {
          tick()
          waitCycles += 1
        }
        assert(waitCycles < 100, "SPI control bus stalled")
        val result = dut.io.control.DAT_MISO.toLong
        tick()
        dut.io.control.CYC #= false
        dut.io.control.STB #= false
        tick()
        result
      }
      access(true, 0x881) // assert CS0
      access(true, 0x39f) // read/write 0x9f
      for (_ <- 0 until 3) access(true, 0x300)
      access(true, 0x800) // release CS0
      for (_ <- 0 until 200) tick()
      val response = (0 until 4).map(_ => access(false))
      assertEquals(commands.toSeq, Seq(0x9f, 0, 0, 0))
      assert(response.forall(value => (value & 0x80000000L) == 0), "missing SPI response")
      assertEquals(response.drop(1).map(_ & 255), Seq(0xefL, 0x40L, 0x14L))
    }
  }

  for (baseAddress <- Seq(0x10000000L, 0x24000100L)) {
    test(
      s"quad refills at ${baseAddress.toHexString}: ways, control serialization and invalidation"
    ) {
      SimConfig.withVerilator.compile(new J2CachedFlashFixture(baseAddress)).doSim { dut =>
        for (bus <- Seq(dut.io.control, dut.io.cacheControl, dut.io.xip)) {
          bus.CYC #= false; bus.STB  #= false; bus.WE #= false
          bus.ADR #= 0; bus.DAT_MOSI #= 0; bus.SEL    #= 15; bus.LOCK #= false
        }
        dut.io.spi.data.read     #= 15
        dut.io.pauseRefill       #= false
        dut.clockDomain.clockSim #= false
        var previousClock      = false
        var previousCs         = true
        var clocks             = 0
        var opcode             = 0
        var address            = 0L
        var salt               = 0
        var checking           = false
        val reads              = ArrayBuffer.empty[Long]
        def byte(a: Long): Int = (((a * 37) ^ (a >> 7) ^ 0xa5).toInt & 255) ^ salt
        def expected(a: Long): Long =
          (0 until 4).foldLeft(0L)((v, i) => (v << 8) | byte((a & ~3L) + i))
        def pins(): Unit = {
          val clk = dut.io.spi.clk.toBoolean
          val cs  = dut.io.spi.cs.toBoolean
          if (checking && !previousCs && cs)
            assert(clocks >= 84, "refill ended before 32 payload bytes")
          if (cs) {
            clocks = 0; opcode = 0; address = 0
            dut.io.spi.data.read #= 15
          } else if (!previousClock && clk) {
            val data = dut.io.spi.data.write.toInt
            if (clocks < 8) opcode = (opcode << 1) | (data & 1)
            else if (clocks < 14) {
              address = (address << 4) | (data & 15)
              if (clocks == 13) {
                assertEquals(opcode, 0xeb)
                reads += address
              }
            }
            clocks += 1
          } else if (previousClock && !clk && clocks >= 20) {
            val nibble = clocks - 20
            val data   = byte(address + nibble / 2)
            dut.io.spi.data.read #= (if (nibble % 2 == 0) data >> 4 else data & 15)
          }
          previousClock = clk
          previousCs    = cs
        }
        def tick(): Unit = {
          dut.clockDomain.clockSim #= false; sleep(5); pins()
          dut.clockDomain.clockSim #= true; sleep(5); pins()
          sleep(1)
        }
        dut.clockDomain.assertReset()
        for (_ <- 0 until 4) tick()
        dut.clockDomain.deassertReset()
        tick()
        checking = true
        def mapped(a: Long): Long = a - 0x10000000L + baseAddress
        def read(a: Long, pauseCycles: Int = 0): Unit = {
          dut.io.pauseRefill #= (pauseCycles > 0)
          dut.io.xip.ADR     #= mapped(a); dut.io.xip.CYC #= true; dut.io.xip.STB #= true
          sleep(1)
          var cycles = 0
          while (!dut.io.xip.ACK.toBoolean && cycles < 1500) {
            tick(); cycles += 1
            if (cycles <= pauseCycles)
              assert(!dut.io.xip.ACK.toBoolean, "response escaped backpressure")
            if (cycles == pauseCycles) dut.io.pauseRefill #= false
          }
          assert(cycles < 1500)
          assertEquals(dut.io.xip.DAT_MISO.toLong, expected(a))
          tick()
          dut.io.xip.CYC #= false; dut.io.xip.STB #= false
          for (_ <- 0 until 12) tick()
        }
        read(0x1000001c)
        for (offset <- 0 until 32 by 2) read(0x10000000L + offset)
        assertEquals(reads.toSeq, Seq(0L), "hits must not assert SPI CS")
        read(0x10000800)
        read(0x10000000)
        assertEquals(reads.toSeq, Seq(0L, 0x800L))

        // Start a control write while a miss is already on the serial bus.
        dut.io.xip.ADR #= mapped(0x10000100); dut.io.xip.CYC #= true; dut.io.xip.STB #= true
        var cycles = 0
        while (dut.io.spi.cs.toBoolean && cycles < 100) { tick(); cycles += 1 }
        assert(!dut.io.spi.cs.toBoolean)
        dut.io.control.ADR      #= 0x44
        dut.io.control.DAT_MOSI #= 0x02ff01ebL
        dut.io.control.WE       #= true; dut.io.control.CYC #= true; dut.io.control.STB #= true
        var dataDone    = false
        var controlDone = false
        cycles = 0
        while (!controlDone && cycles < 1500) {
          sleep(1)
          val dataAck    = dut.io.xip.ACK.toBoolean
          val controlAck = dut.io.control.ACK.toBoolean
          if (dataAck) assertEquals(dut.io.xip.DAT_MISO.toLong, expected(0x100))
          if (controlAck) {
            assert(dataDone, "control write overtook the refill")
            assert(dut.io.spi.cs.toBoolean, "control changed configuration before CS release")
          }
          tick()
          if (dataAck) {
            dut.io.xip.CYC #= false; dut.io.xip.STB #= false; dataDone = true
          }
          if (controlAck) {
            dut.io.control.CYC #= false; dut.io.control.STB #= false; controlDone = true
          }
          cycles += 1
        }
        assert(controlDone)
        salt = 0x5a // Model a flash update via the control path.
        for (_ <- 0 until 3) tick()
        val before = reads.size
        read(0x10000000)
        read(0x10000800)
        read(0x10000100)
        assertEquals(reads.size, before + 3, "control write did not invalidate cached data")

        // Hold the generic response while the SPI receive FIFO fills. No word
        // may be lost or overwritten when the burst consumer resumes.
        read(0x10000140, pauseCycles = 500)

        // Explicit software invalidation also reaches the cache in front of XIP.
        dut.io.cacheControl.CYC #= true; dut.io.cacheControl.STB      #= true
        dut.io.cacheControl.WE  #= true; dut.io.cacheControl.DAT_MOSI #= 1
        sleep(1)
        assert(dut.io.cacheControl.ACK.toBoolean)
        tick()
        dut.io.cacheControl.CYC #= false; dut.io.cacheControl.STB #= false
        tick()
        salt ^= 0x25
        val beforeExplicit = reads.size
        read(0x10000100)
        assertEquals(reads.size, beforeExplicit + 1)

        dut.io.control.WE  #= false; dut.io.control.ADR #= 4
        dut.io.control.CYC #= true; dut.io.control.STB  #= true
        sleep(1)
        cycles = 0
        while (!dut.io.control.ACK.toBoolean && cycles < 100) { tick(); cycles += 1 }
        assert(cycles < 100)
        tick()
        dut.io.control.CYC #= false; dut.io.control.STB #= false
        for (_ <- 0 until 3) tick()
        val beforeStatus = reads.size
        read(0x10000100)
        assertEquals(reads.size, beforeStatus, "control reads must not invalidate")
      }
    }
  }
}
