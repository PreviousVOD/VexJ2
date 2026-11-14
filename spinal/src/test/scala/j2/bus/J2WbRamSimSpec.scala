package j2.bus

import spinal.core._
import spinal.core.sim._
import scala.language.reflectiveCalls

class J2WbRamSimSpec extends munit.FunSuite {
  test("Wishbone configuration uses classic cycles") {
    assert(!J2Wishbone.config.isPipelined)
  }

  test("Wishbone data and instruction ports share one dual-port memory") {
    SimConfig.withVerilator.compile(new J2WbRam(words = 16)).doSim { dut =>
      dut.clockDomain.forkStimulus(10)

      def waitAck(ack: => Boolean): Unit = {
        var cycles = 0
        while (!ack) {
          dut.clockDomain.waitSampling()
          cycles += 1
          assert(cycles < 8, "Wishbone transaction timed out")
        }
      }

      dut.io.data.CYC #= false
      dut.io.data.STB #= false
      dut.io.data.WE #= false
      dut.io.data.ADR #= 0
      dut.io.data.SEL #= 0
      dut.io.data.DAT_MOSI #= 0
      dut.io.instruction.CYC #= false
      dut.io.instruction.STB #= false
      dut.io.instruction.WE #= false
      dut.io.instruction.ADR #= 0

      dut.clockDomain.assertReset()
      dut.clockDomain.waitSampling(2)
      dut.clockDomain.deassertReset()

      def write(address: Long, data: Long, sel: Int): Unit = {
        dut.io.data.ADR #= address
        dut.io.data.DAT_MOSI #= data
        dut.io.data.SEL #= sel
        dut.io.data.WE #= true
        dut.io.data.CYC #= true
        dut.io.data.STB #= true
        waitAck(dut.io.data.ACK.toBoolean)
        dut.io.data.CYC #= false
        dut.io.data.STB #= false
        dut.io.data.WE #= false
        dut.clockDomain.waitSampling()
      }

      def readData(address: Long): Long = {
        dut.io.data.ADR #= address
        dut.io.data.WE #= false
        dut.io.data.CYC #= true
        dut.io.data.STB #= true
        waitAck(dut.io.data.ACK.toBoolean)
        val value = dut.io.data.DAT_MISO.toLong
        dut.io.data.CYC #= false
        dut.io.data.STB #= false
        dut.clockDomain.waitSampling()
        value
      }

      def readInstruction(address: Long): Long = {
        dut.io.instruction.ADR #= address
        dut.io.instruction.WE #= false
        dut.io.instruction.CYC #= true
        dut.io.instruction.STB #= true
        waitAck(dut.io.instruction.ACK.toBoolean)
        val value = dut.io.instruction.DAT_MISO.toLong
        dut.io.instruction.CYC #= false
        dut.io.instruction.STB #= false
        dut.clockDomain.waitSampling()
        value
      }

      write(0x4, 0x11223344L, 0xf)
      assertEquals(readData(0x4), 0x11223344L)
      assertEquals(readInstruction(0x4), 0x1122L)
      assertEquals(readInstruction(0x6), 0x3344L)

      write(0x8, 0, 0xf)
      write(0x8, 0xaa000000L, 0x8)
      assertEquals(readData(0x8), 0xaa000000L)
    }
  }
}
