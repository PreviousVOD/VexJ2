package j2.microcode

import spinal.core._
import spinal.core.sim._

class J2MicrosequencerSpec extends munit.FunSuite {
  private def driveDefaults(dut: J2Microsequencer): Unit = {
    dut.io.slot #= false
    dut.io.dispatch #= false
    dut.io.delayJump #= false
    dut.io.eventAcknowledge #= false
    dut.io.instruction #= 0x0009
    dut.io.predecodeAddress #= 3
    dut.io.illegalInstruction #= false
    dut.io.illegalDelaySlot #= false
    dut.io.instructionStall #= false
    dut.io.registerConflict #= false
    dut.io.macStall #= false
    dut.io.interruptBits #= 0
    dut.io.interruptLevelCapture #= false
    dut.io.maskInterruptNext #= false
    dut.io.enterDebug #= false
    dut.io.debug #= false
    dut.io.eventValid #= false
    dut.io.eventCommand #= 0
    dut.io.eventVector #= 0
    dut.io.eventLevel #= 0
    dut.io.eventBypassMask #= false
    dut.io.id.incrementPc #= false
    dut.io.id.instructionIssue #= false
    dut.io.id.instructionAddress #= false
  }

  test("reset, instruction sequencing, and register stalls") {
    SimConfig.withVerilator.compile(new J2Microsequencer).doSim { dut =>
      driveDefaults(dut)
      dut.clockDomain.forkStimulus(10)
      dut.clockDomain.assertReset()
      dut.clockDomain.waitSampling(2)
      dut.clockDomain.deassertReset()
      dut.clockDomain.waitSampling()
      sleep(1)

      assert(dut.io.operation.system.toBoolean)
      assertEquals(dut.io.operation.address.toInt, 0xda)
      assertEquals(dut.io.operation.code.toInt, 0x0300)

      dut.io.slot #= true
      dut.io.dispatch #= true
      dut.clockDomain.waitSampling()
      sleep(1)
      assert(!dut.io.operation.system.toBoolean)
      assertEquals(dut.io.operation.address.toInt, 3)

      dut.io.dispatch #= false
      dut.clockDomain.waitSampling()
      sleep(1)
      assertEquals(dut.io.operation.address.toInt, 4)
      assertEquals(dut.io.operation.code.toInt, 9)

      dut.io.registerConflict #= true
      dut.io.id.incrementPc #= true
      dut.io.id.instructionIssue #= true
      sleep(1)
      assert(dut.io.nextIdStall.toBoolean)
      assert(!dut.io.incrementPc.toBoolean)
      assert(!dut.io.instructionIssue.toBoolean)
      dut.clockDomain.waitSampling()
      sleep(1)
      assertEquals(dut.io.operation.address.toInt, 4)

      dut.io.registerConflict #= false
      dut.clockDomain.waitSampling()
      sleep(1)
      assertEquals(dut.io.operation.address.toInt, 5)
    }
  }

  test("interrupts, masking, and illegal instructions select system microcode") {
    SimConfig.withVerilator.compile(new J2Microsequencer).doSim { dut =>
      driveDefaults(dut)
      dut.clockDomain.forkStimulus(10)
      dut.clockDomain.assertReset()
      dut.clockDomain.waitSampling(2)
      dut.clockDomain.deassertReset()
      dut.clockDomain.waitSampling()
      sleep(1)

      dut.io.slot #= true
      dut.io.dispatch #= true
      dut.clockDomain.waitSampling()
      sleep(1)
      dut.io.dispatch #= false
      dut.io.interruptBits #= 3
      dut.io.eventValid #= true
      dut.io.eventCommand #= 0
      dut.io.eventLevel #= 5
      dut.io.eventVector #= 0x40
      sleep(1)
      assert(dut.io.operation.system.toBoolean)
      assertEquals(dut.io.operation.address.toInt, 0xe0)
      assertEquals(dut.io.operation.code.toInt, 0x40)

      dut.io.maskInterruptNext #= true
      dut.io.dispatch #= true
      dut.clockDomain.waitSampling()
      sleep(1)
      assert(dut.io.maskInterrupt.toBoolean)
      assert(!dut.io.operation.system.toBoolean)
      assertEquals(dut.io.operation.address.toInt, 3)

      dut.io.eventValid #= false
      dut.io.illegalInstruction #= true
      sleep(1)
      assert(dut.io.operation.system.toBoolean)
      assertEquals(dut.io.operation.address.toInt, 0xc9)
      assertEquals(dut.io.operation.code.toInt, 0x0704)
    }
  }
}
