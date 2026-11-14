package j2.periph

import spinal.core._
import spinal.core.sim._

import scala.language.reflectiveCalls

class J2PeripheralSimSpec extends munit.FunSuite {
  private def waitAck(clockDomain: ClockDomain)(ack: => Boolean): Unit = {
    var cycles = 0
    while (!ack) {
      clockDomain.waitSampling()
      cycles += 1
      assert(cycles < 16, "Wishbone slave timed out")
    }
  }

  test("PIO output register is writable and readable") {
    SimConfig.withVerilator.compile(new J2Pio).doSim { dut =>
      dut.clockDomain.forkStimulus(10)
      dut.io.pins #= 0x12345678L
      dut.io.bus.CYC #= false
      dut.io.bus.STB #= false
      dut.io.bus.WE #= false
      dut.io.bus.ADR #= 0
      dut.io.bus.SEL #= 0
      dut.io.bus.DAT_MOSI #= 0
      dut.io.bus.LOCK #= false
      dut.clockDomain.assertReset()
      dut.clockDomain.waitSampling(2)
      dut.clockDomain.deassertReset()

      dut.io.bus.ADR #= 0
      dut.io.bus.SEL #= 0xf
      dut.io.bus.DAT_MOSI #= 0x89abcdefL
      dut.io.bus.WE #= true
      dut.io.bus.CYC #= true
      dut.io.bus.STB #= true
      waitAck(dut.clockDomain)(dut.io.bus.ACK.toBoolean)
      dut.io.bus.CYC #= false
      dut.io.bus.STB #= false
      dut.io.bus.WE #= false
      dut.clockDomain.waitSampling()

      assertEquals(dut.io.outputs.toLong, 0x89abcdefL)
    }
  }

  test("UART transmits an 8N1 byte") {
    SimConfig.withVerilator.compile(new J2UartLite(clockHz = 1000, baud = 100)).doSim { dut =>
      dut.clockDomain.forkStimulus(10)
      dut.io.rx #= true
      dut.io.bus.CYC #= false
      dut.io.bus.STB #= false
      dut.io.bus.WE #= false
      dut.io.bus.ADR #= 0
      dut.io.bus.SEL #= 0xf
      dut.io.bus.DAT_MOSI #= 0
      dut.io.bus.LOCK #= false
      dut.clockDomain.assertReset()
      dut.clockDomain.waitSampling(2)
      dut.clockDomain.deassertReset()

      dut.io.bus.ADR #= 0
      dut.io.bus.SEL #= 0xf
      dut.io.bus.DAT_MOSI #= 0x41L
      dut.io.bus.WE #= true
      dut.io.bus.CYC #= true
      dut.io.bus.STB #= true
      waitAck(dut.clockDomain)(dut.io.bus.ACK.toBoolean)
      dut.io.bus.CYC #= false
      dut.io.bus.STB #= false
      dut.io.bus.WE #= false

      var timeout = 0
      while (dut.io.tx.toBoolean && timeout < 32) {
        dut.clockDomain.waitSampling()
        timeout += 1
      }
      assert(!dut.io.tx.toBoolean, "UART start bit did not appear")

      dut.clockDomain.waitSampling(10)
      sleep(1)
      var value = 0
      for (bit <- 0 until 8) {
        if (dut.io.tx.toBoolean) value |= 1 << bit
        dut.clockDomain.waitSampling(10)
        sleep(1)
      }
      assert(dut.io.tx.toBoolean, "UART stop bit was not high")
      assertEquals(value, 0x41)
    }
  }
}
