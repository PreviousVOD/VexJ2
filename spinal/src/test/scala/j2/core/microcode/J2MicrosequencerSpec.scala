package j2.core.microcode

import spinal.core._
import spinal.core.sim._

class J2MicrosequencerSpec extends munit.FunSuite {
  private def driveDefaults(dut: J2Microsequencer): Unit = {
    dut.io.slot                  #= false
    dut.io.dispatch              #= false
    dut.io.delayJump             #= false
    dut.io.eventAcknowledge      #= false
    dut.io.instruction           #= 0x0009
    dut.io.predecodeAddress      #= 3
    dut.io.instructionLine       #= J2MicrocodeData.entries(3)
    dut.io.illegalInstruction    #= false
    dut.io.illegalDelaySlot      #= false
    dut.io.instructionStall      #= false
    dut.io.registerConflict      #= false
    dut.io.macStall              #= false
    dut.io.interruptBits         #= 0
    dut.io.interruptLevelCapture #= false
    dut.io.maskInterruptNext     #= false
    dut.io.enterDebug            #= false
    dut.io.debug                 #= false
    dut.io.eventValid            #= false
    dut.io.eventCommand          #= 0
    dut.io.eventVector           #= 0
    dut.io.eventLevel            #= 0
    dut.io.eventBypassMask       #= false
    dut.io.id.incrementPc        #= false
    dut.io.id.instructionIssue   #= false
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

      dut.io.slot     #= true
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

      dut.io.registerConflict    #= true
      dut.io.id.incrementPc      #= true
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

      dut.io.slot     #= true
      dut.io.dispatch #= true
      dut.clockDomain.waitSampling()
      sleep(1)
      dut.io.dispatch      #= false
      dut.io.interruptBits #= 3
      dut.io.eventValid    #= true
      dut.io.eventCommand  #= 0
      dut.io.eventLevel    #= 5
      dut.io.eventVector   #= 0x40
      sleep(1)
      assert(dut.io.operation.system.toBoolean)
      assertEquals(dut.io.operation.address.toInt, 0xe0)
      assertEquals(dut.io.operation.code.toInt, 0x40)

      dut.io.maskInterruptNext #= true
      dut.io.dispatch          #= true
      dut.clockDomain.waitSampling()
      sleep(1)
      assert(dut.io.maskInterrupt.toBoolean)
      assert(!dut.io.operation.system.toBoolean)
      assertEquals(dut.io.operation.address.toInt, 3)

      dut.io.eventValid         #= false
      dut.io.illegalInstruction #= true
      sleep(1)
      assert(dut.io.operation.system.toBoolean)
      assertEquals(dut.io.operation.address.toInt, 0xc9)
      assertEquals(dut.io.operation.code.toInt, 0x0704)
    }
  }
  test("direct first operation survives a hazard and continuation reads do not skip or restart") {
    SimConfig.withVerilator.compile(new J2Microsequencer).doSim { dut =>
      driveDefaults(dut)
      dut.clockDomain.forkStimulus(10)
      dut.clockDomain.assertReset()
      dut.clockDomain.waitSampling(2)
      dut.clockDomain.deassertReset()
      dut.clockDomain.waitSampling()
      sleep(1)
      dut.io.slot     #= true
      dut.io.dispatch #= true
      dut.clockDomain.waitSampling()
      sleep(1)
      assert(dut.io.directValid.toBoolean)
      assertEquals(dut.io.directLine.toBigInt, J2MicrocodeData.entries(3))
      dut.io.dispatch         #= false
      dut.io.registerConflict #= true
      sleep(1)
      assertEquals(dut.io.prefetchAddress.toInt, 3)
      dut.clockDomain.waitSampling()
      sleep(1)
      // IF accepts a different opcode while ID retries the first one.
      dut.io.instruction      #= 0xe105
      dut.io.predecodeAddress #= 0x30
      dut.io.instructionLine  #= 0x12345
      sleep(1)
      assertEquals(dut.io.operation.code.toInt, 9)
      assert(dut.io.directValid.toBoolean)
      assertEquals(dut.io.directLine.toBigInt, J2MicrocodeData.entries(3))
      dut.io.registerConflict #= false
      sleep(1)
      assertEquals(dut.io.prefetchAddress.toInt, 4)
      dut.clockDomain.waitSampling()
      sleep(1)
      assertEquals(dut.io.operation.address.toInt, 4)
      assert(!dut.io.directValid.toBoolean)
      dut.io.slot #= false
      sleep(1)
      assertEquals(dut.io.prefetchAddress.toInt, 4)
      dut.clockDomain.waitSampling(3)
      sleep(1)
      assertEquals(dut.io.operation.address.toInt, 4)
      // A level event remains asserted throughout entry; it must not reselect E0.
      dut.io.eventValid      #= true
      dut.io.eventBypassMask #= true
      dut.io.eventVector     #= 0x40
      dut.io.dispatch        #= true
      dut.io.slot            #= true
      dut.clockDomain.waitSampling()
      sleep(1)
      assertEquals(dut.io.operation.address.toInt, 0xe0)
      assert(!dut.io.directValid.toBoolean)
      dut.io.dispatch #= false
      sleep(1)
      assertEquals(dut.io.prefetchAddress.toInt, 0xe1)
      dut.clockDomain.waitSampling()
      sleep(1)
      assertEquals(dut.io.operation.address.toInt, 0xe1)
    }
  }

  test("accepted interrupt metadata survives retries and changing candidates") {
    SimConfig.withVerilator.compile(new J2Microsequencer).doSim { dut =>
      driveDefaults(dut)
      dut.clockDomain.forkStimulus(10)
      dut.clockDomain.assertReset(); dut.clockDomain.waitSampling(2)
      dut.clockDomain.deassertReset(); dut.clockDomain.waitSampling(); sleep(1)
      dut.io.slot #= true; dut.io.dispatch #= true
      dut.clockDomain.waitSampling(); sleep(1)
      dut.io.dispatch         #= false; dut.io.eventValid           #= true
      dut.io.eventVector      #= 64; dut.io.eventLevel              #= 5
      dut.io.registerConflict #= true; dut.io.interruptLevelCapture #= true
      sleep(1); assert(dut.io.eventStart.toBoolean)
      dut.clockDomain.waitSampling(); sleep(1)
      assertEquals(dut.io.interruptLevel.toInt, 5)
      dut.io.eventVector     #= 65; dut.io.eventLevel #= 15
      dut.io.eventBypassMask #= true
      for (_ <- 0 until 3) {
        sleep(1); assert(!dut.io.eventStart.toBoolean)
        assertEquals(dut.io.operation.code.toInt, 64)
        dut.clockDomain.waitSampling(); sleep(1)
        assertEquals(dut.io.interruptLevel.toInt, 5)
      }
      dut.io.eventValid #= false; dut.io.registerConflict #= false
      dut.clockDomain.waitSampling(); sleep(1)
      assertEquals(dut.io.operation.address.toInt, 0xe1)
      assertEquals(dut.io.operation.code.toInt, 64)
      assertEquals(dut.io.interruptLevel.toInt, 5)
    }
  }

  test("SH-2 illegal instructions and TRAPA precede maskable and NMI requests") {
    val compiled = SimConfig.withVerilator.compile(new J2Microsequencer)
    for (nmi <- Seq(false, true); trap <- Seq(false, true)) compiled.doSim { dut =>
      driveDefaults(dut)
      dut.clockDomain.forkStimulus(10)
      dut.clockDomain.assertReset(); dut.clockDomain.waitSampling(2)
      dut.clockDomain.deassertReset(); dut.clockDomain.waitSampling(); sleep(1)
      dut.io.slot #= true; dut.io.dispatch #= true
      dut.clockDomain.waitSampling(); sleep(1)
      dut.io.dispatch           #= false
      dut.io.eventValid         #= true; dut.io.eventLevel #= 15; dut.io.eventBypassMask #= nmi
      dut.io.eventVector        #= (if (nmi) 11 else 64)
      dut.io.instruction        #= (if (trap) 0xc320 else 0xffff)
      dut.io.illegalInstruction #= !trap
      sleep(1)
      assert(!dut.io.eventStart.toBoolean)
      if (trap) assert(!dut.io.operation.system.toBoolean)
      else assertEquals(dut.io.operation.address.toInt, 0xc9)
    }
  }

}
