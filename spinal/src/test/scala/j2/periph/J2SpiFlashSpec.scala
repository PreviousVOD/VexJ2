package j2.periph

import spinal.core._
import spinal.core.sim._
import scala.collection.mutable.ArrayBuffer

class J2SpiFlashSpec extends munit.FunSuite {
  test("mode-0 flash changes MISO on falling edges without shifting JEDEC ID") {
    SimConfig.withVerilator.compile(new J2SpiFlash).doSim { dut =>
      for (bus <- Seq(dut.io.control, dut.io.xip)) {
        bus.CYC #= false
        bus.STB #= false
        bus.WE #= false
        bus.ADR #= 0
        bus.DAT_MOSI #= 0
        bus.SEL #= 15
        bus.LOCK #= false
      }
      dut.io.spi.miso #= true
      dut.clockDomain.clockSim #= false
      var previousClock = false
      var bits = 0
      var command = 0
      val commands = ArrayBuffer.empty[Int]
      def flashPins(): Unit = {
        val clk = dut.io.spi.clk.toBoolean
        if (dut.io.spi.cs.toBoolean) {
          bits = 0
          command = 0
          dut.io.spi.miso #= true
        } else if (!previousClock && clk) {
          command = ((command << 1) | (if (dut.io.spi.mosi.toBoolean) 1 else 0)) & 255
          bits += 1
          if (bits % 8 == 0) commands += command
        } else if (previousClock && !clk && bits >= 8) {
          // Real mode-0 flash launches bit 23 just after the command's final
          // falling edge, before the first rising edge of the response byte.
          val index = bits - 8
          dut.io.spi.miso #= (index < 24 && ((0xef4014 >> (23 - index)) & 1) != 0)
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
        dut.io.control.CYC #= true
        dut.io.control.STB #= true
        dut.io.control.WE #= write
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
}
