package j2.core.microcode

import spinal.core._
import spinal.core.sim._

class J2MicrocodeTableSpec extends munit.FunSuite {
  test("all ROM lines decode direct controls and conditional dispatch") {
    SimConfig.withVerilator.compile(new J2MicrocodeTable).doSim { dut =>
      dut.io.opcode      #= 0
      dut.io.nextIdStall #= false

      for ((line, address) <- J2MicrocodeData.entries.zipWithIndex) {
        dut.io.line #= line
        for (tBcc <- Seq(false, true)) {
          dut.io.tBcc #= tBcc
          sleep(1)

          val dispatchCode = ((line >> 65) & 3).toInt
          val expectedDispatch = dispatchCode match {
            case 1 => true
            case 2 => tBcc
            case 3 => !tBcc
            case _ => false
          }
          assertEquals(dut.io.control.dispatch.toBoolean, expectedDispatch, s"dispatch at $address")
          assertEquals(dut.io.control.id.incrementPc.toBoolean, line.testBit(54), s"PC at $address")
          assertEquals(
            dut.io.control.exStall.regWriteZ.toBoolean,
            line.testBit(33),
            s"reg Z at $address"
          )
          assertEquals(
            dut.io.control.wbStall.regWriteW.toBoolean,
            line.testBit(34),
            s"reg W at $address"
          )
          assertEquals(dut.io.control.sleep.toBoolean, line.testBit(35), s"sleep at $address")
          assertEquals(
            dut.io.control.ex.memoryLock.toBoolean,
            line.testBit(46),
            s"lock at $address"
          )
          assertEquals(dut.io.control.delayJump.toBoolean, line.testBit(67), s"delay at $address")
          assertEquals(dut.io.control.debug.toBoolean, line.testBit(68), s"debug at $address")
          assertEquals(
            dut.io.control.ex.arithCarry.toBoolean,
            line.testBit(69),
            s"carry at $address"
          )
        }
      }
    }
  }

  test("MOV immediate selects the opcode register and signed value") {
    SimConfig.withVerilator.compile(new J2MicrocodeTable).doSim { dut =>
      dut.io.line        #= J2MicrocodeData.entries(200)
      dut.io.opcode      #= 0xe17f
      dut.io.tBcc        #= false
      dut.io.nextIdStall #= false
      sleep(1)

      assert(dut.io.control.dispatch.toBoolean)
      assert(dut.io.control.exStall.regWriteZ.toBoolean)
      assertEquals(dut.io.control.ex.regZ.toInt, 1)
      assertEquals(dut.io.control.ex.immediate.toBigInt, BigInt(127))
      assert(!dut.io.control.exStall.memoryIssue.toBoolean)
    }
  }
}
