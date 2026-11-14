package j2.core

import spinal.core.sim._
import scala.language.reflectiveCalls

class Sh2RegFileSimSpec extends munit.FunSuite {
  test("register-file writes, read forwarding and writable r0") {
    SimConfig.withVerilator.compile(new Sh2RegFile).doSim { dut =>
      dut.clockDomain.forkStimulus(10)
      dut.io.readA.address #= 0
      dut.io.readB.address #= 0
      dut.io.writeW.enable #= false
      dut.io.writeW.address #= 0
      dut.io.writeW.data #= 0
      dut.io.writeZ.enable #= false
      dut.io.writeZ.address #= 0
      dut.io.writeZ.data #= 0

      dut.clockDomain.assertReset()
      dut.clockDomain.waitSampling(2)
      dut.clockDomain.deassertReset()

      dut.io.writeW.enable #= true
      dut.io.writeW.address #= 1
      dut.io.writeW.data #= 0x12345678L
      dut.io.readA.address #= 1
      dut.clockDomain.waitSampling()
      assertEquals(dut.io.readA.data.toLong, 0x12345678L)

      dut.io.writeW.enable #= false
      dut.clockDomain.waitSampling()
      assertEquals(dut.io.readA.data.toLong, 0x12345678L)

      dut.io.writeZ.enable #= true
      dut.io.writeZ.address #= 2
      dut.io.writeZ.data #= 0x89abcdefL
      dut.io.readB.address #= 2
      dut.clockDomain.waitSampling()
      assertEquals(dut.io.readB.data.toLong, 0x89abcdefL)

      dut.io.writeZ.enable #= false
      dut.io.writeW.enable #= true
      dut.io.writeW.address #= 0
      dut.io.writeW.data #= 0xffffffffL
      dut.clockDomain.waitSampling()
      dut.io.writeW.enable #= false
      dut.io.readA.address #= 0
      dut.clockDomain.waitSampling()
      assertEquals(dut.io.readA.data.toLong, 0xffffffffL)
    }
  }
}
