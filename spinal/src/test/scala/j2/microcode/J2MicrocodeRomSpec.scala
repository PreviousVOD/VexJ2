package j2.microcode

import spinal.core._
import spinal.core.sim._

class J2MicrocodeRomSpec extends munit.FunSuite {
  test("ROM returns all 256 reference entries on enabled rising edges") {
    SimConfig.withVerilator.compile(new J2MicrocodeRom).doSim { dut =>
      dut.io.clk     #= false
      dut.io.address #= 0
      dut.io.enable  #= true
      sleep(1)

      for ((expected, address) <- J2MicrocodeData.entries.zipWithIndex) {
        dut.io.address #= address
        dut.io.clk     #= true
        sleep(1)
        assertEquals(dut.io.line.toBigInt, expected, s"microcode address $address")
        dut.io.clk     #= false
        dut.io.address #= (address ^ 0xff)
        sleep(1)
        assertEquals(dut.io.line.toBigInt, expected, "falling edge must not read")
        dut.io.enable #= false
        dut.io.clk    #= true
        sleep(1)
        assertEquals(dut.io.line.toBigInt, expected, "disabled read must hold")
        dut.io.clk    #= false
        dut.io.enable #= true
        sleep(1)
      }
    }
  }
}
