package j2.core

import spinal.core._
import spinal.core.sim._

class J2PipelineSpec extends munit.FunSuite {
  test("EX and WB controls advance and stalls insert write bubbles") {
    SimConfig.withVerilator.compile(new J2Pipeline).doSim { dut =>
      dut.io.slot #= false
      dut.io.nextIdStall #= false
      J2ControlDrive.ex(dut.io.ex)
      J2ControlDrive.exStall(dut.io.exStall)
      J2ControlDrive.wb(dut.io.wb)
      J2ControlDrive.wbStall(dut.io.wbStall)
      dut.clockDomain.forkStimulus(10)
      dut.clockDomain.assertReset()
      dut.clockDomain.waitSampling(2)
      dut.clockDomain.deassertReset()
      dut.clockDomain.waitSampling()

      dut.io.slot #= true
      dut.io.ex.regX #= 3
      dut.io.exStall.regWriteZ #= true
      dut.io.wb.regW #= 5
      dut.io.wbStall.regWriteW #= true
      dut.clockDomain.waitSampling()
      sleep(1)
      assertEquals(dut.io.state.ex1.regX.toInt, 3)
      assert(dut.io.state.ex1Stall.regWriteZ.toBoolean)
      assertEquals(dut.io.state.wb1.regW.toInt, 5)
      assert(dut.io.state.wb1Stall.regWriteW.toBoolean)

      dut.clockDomain.waitSampling()
      sleep(1)
      assertEquals(dut.io.state.wb2.regW.toInt, 5)
      assert(dut.io.state.wb2Stall.regWriteW.toBoolean)

      dut.io.nextIdStall #= true
      dut.clockDomain.waitSampling()
      sleep(1)
      assertEquals(dut.io.state.wb3.regW.toInt, 5)
      assert(dut.io.state.wb3Stall.regWriteW.toBoolean)
      assert(!dut.io.state.ex1Stall.regWriteZ.toBoolean)
      assert(!dut.io.state.wb1Stall.regWriteW.toBoolean)
    }
  }

  test("hazards detect WB register conflicts and outstanding MAC operations") {
    SimConfig.withVerilator.compile(new J2Hazards).doSim { dut =>
      J2ControlDrive.ex(dut.io.ex)
      J2ControlDrive.exStall(dut.io.exStall)
      J2ControlDrive.state(dut.io.state)
      dut.io.macStallSense #= false
      dut.io.macBusy #= false

      dut.io.state.wb1.regW #= 7
      dut.io.state.wb1Stall.regWriteW #= true
      dut.io.ex.regX #= 7
      dut.io.ex.xSelect #= J2XBusSelect.REG
      sleep(1)
      assert(dut.io.registerConflict.toBoolean)

      dut.io.ex.xSelect #= J2XBusSelect.IMM
      dut.io.ex.regY #= 7
      dut.io.ex.ySelect #= J2YBusSelect.REG
      sleep(1)
      assert(dut.io.registerConflict.toBoolean)

      dut.io.ex.ySelect #= J2YBusSelect.IMM
      dut.io.exStall.regWriteZ #= true
      dut.io.ex.regZ #= 7
      sleep(1)
      assert(dut.io.registerConflict.toBoolean)

      dut.io.exStall.regWriteZ #= false
      dut.io.ex.aluY #= J2AluYSelect.R0
      dut.io.state.wb1.regW #= 0
      sleep(1)
      assert(dut.io.registerConflict.toBoolean)

      dut.io.ex.aluY #= J2AluYSelect.YBUS
      dut.io.macStallSense #= true
      dut.io.state.wb2.macBusy #= true
      sleep(1)
      assert(!dut.io.registerConflict.toBoolean)
      assert(dut.io.macStall.toBoolean)
    }
  }
}
