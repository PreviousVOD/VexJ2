package j2.core

import spinal.core._
import spinal.core.sim._

class J2PipelineSpec extends munit.FunSuite {
  test("EX, MA and WB controls advance and stalls insert write bubbles") {
    SimConfig.withVerilator.compile(new J2Pipeline).doSim { dut =>
      dut.io.slot              #= false
      dut.io.nextIdStall       #= false
      dut.io.cancelExWriteback #= false
      J2ControlDrive.ex(dut.io.ex)
      J2ControlDrive.memoryRequest(dut.io.memoryRequest)
      J2ControlDrive.exStall(dut.io.exStall)
      J2ControlDrive.wb(dut.io.wb)
      J2ControlDrive.wbStall(dut.io.wbStall)
      dut.clockDomain.forkStimulus(10)
      dut.clockDomain.assertReset()
      dut.clockDomain.waitSampling(2)
      dut.clockDomain.deassertReset()
      dut.clockDomain.waitSampling()

      dut.io.slot                  #= true
      dut.io.ex.regX               #= 3
      dut.io.exStall.memoryIssue   #= true
      dut.io.memoryRequest.address #= 0x300
      dut.io.memoryRequest.data    #= 0x12345678L
      dut.io.memoryRequest.write   #= true
      dut.io.memoryRequest.size    #= J2MemSize.LONG
      dut.io.exStall.regWriteZ     #= true
      dut.io.wb.regW               #= 5
      dut.io.wbStall.regWriteW     #= true
      dut.clockDomain.waitSampling()
      sleep(1)
      assertEquals(dut.io.state.ex.regX.toInt, 3)
      assert(dut.io.state.exAction.regWriteZ.toBoolean)
      assertEquals(dut.io.state.exWriteback.regW.toInt, 5)
      assert(dut.io.state.exWritebackAction.regWriteW.toBoolean)

      val frozenWb2 = dut.io.state.ma.regW.toInt
      val frozenWb3 = dut.io.state.wb.regW.toInt
      dut.io.slot    #= false
      dut.io.wb.regW #= 9
      dut.clockDomain.waitSampling(4)
      sleep(1)
      assertEquals(dut.io.state.exWriteback.regW.toInt, 5, "frozen slots must retain payloads")
      assertEquals(dut.io.state.ma.regW.toInt, frozenWb2, "bubbles must not collapse while frozen")
      assertEquals(dut.io.state.wb.regW.toInt, frozenWb3, "older slots must also freeze")
      dut.io.wb.regW #= 5
      dut.io.slot    #= true
      dut.clockDomain.waitSampling()
      sleep(1)
      assertEquals(dut.io.state.ma.regW.toInt, 5)
      assert(dut.io.state.maAction.regWriteW.toBoolean)
      assertEquals(dut.io.state.maRequest.address.toLong, 0x300L)
      assertEquals(dut.io.state.maRequest.data.toLong, 0x12345678L)
      assert(dut.io.state.maRequest.write.toBoolean)
      dut.io.slot                  #= false
      dut.io.memoryRequest.address #= 0x400
      dut.clockDomain.waitSampling(3)
      sleep(1)
      assertEquals(
        dut.io.state.maRequest.address.toLong,
        0x300L,
        "MA request must hold during waits"
      )
      dut.io.slot #= true

      dut.io.nextIdStall #= true
      dut.clockDomain.waitSampling()
      sleep(1)
      assertEquals(dut.io.state.wb.regW.toInt, 5)
      assert(dut.io.state.wbAction.regWriteW.toBoolean)
      assert(!dut.io.state.exAction.regWriteZ.toBoolean)
      assert(!dut.io.state.exWritebackAction.regWriteW.toBoolean)

      dut.io.nextIdStall #= false
      dut.clockDomain.waitSampling(2)
      dut.io.memoryRequest.address #= 0x500
      dut.io.cancelExWriteback     #= true
      dut.clockDomain.waitSampling()
      sleep(1)
      assertEquals(
        dut.io.state.maRequest.address.toLong,
        0x400L,
        "cancelled EX must not replace the MA request"
      )
      assert(!dut.io.state.maAction.regWriteW.toBoolean)
      assert(dut.io.state.wbAction.regWriteW.toBoolean, "older writeback must drain")
    }
  }

  test("hazards detect WB register conflicts and outstanding MAC operations") {
    SimConfig.withVerilator.compile(new J2Hazards).doSim { dut =>
      J2ControlDrive.ex(dut.io.ex)
      J2ControlDrive.exStall(dut.io.exStall)
      J2ControlDrive.state(dut.io.state)
      dut.io.macStallSense #= false
      dut.io.macBusy       #= false

      dut.io.state.exWriteback.regW            #= 7
      dut.io.state.exWritebackAction.regWriteW #= true
      dut.io.ex.regX                           #= 7
      dut.io.ex.xSelect                        #= J2XBusSelect.REG
      sleep(1)
      assert(dut.io.registerConflict.toBoolean)

      dut.io.ex.xSelect #= J2XBusSelect.IMM
      dut.io.ex.regY    #= 7
      dut.io.ex.ySelect #= J2YBusSelect.REG
      sleep(1)
      assert(dut.io.registerConflict.toBoolean)

      dut.io.ex.ySelect        #= J2YBusSelect.IMM
      dut.io.exStall.regWriteZ #= true
      dut.io.ex.regZ           #= 7
      sleep(1)
      assert(dut.io.registerConflict.toBoolean)

      dut.io.exStall.regWriteZ      #= false
      dut.io.ex.aluY                #= J2AluYSelect.R0
      dut.io.state.exWriteback.regW #= 0
      sleep(1)
      assert(dut.io.registerConflict.toBoolean)

      dut.io.ex.aluY          #= J2AluYSelect.YBUS
      dut.io.macStallSense    #= true
      dut.io.state.ma.macBusy #= true
      sleep(1)
      assert(!dut.io.registerConflict.toBoolean)
      assert(dut.io.macStall.toBoolean)
    }
  }
}
