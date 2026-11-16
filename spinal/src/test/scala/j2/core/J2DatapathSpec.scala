package j2.core

import spinal.core._
import spinal.core.sim._

class J2DatapathSpec extends munit.FunSuite {
  private def defaults(dut: J2Datapath): Unit = {
    J2ControlDrive.ex(dut.io.ex)
    J2ControlDrive.exStall(dut.io.exStall)
    dut.io.regX             #= 0
    dut.io.regY             #= 0
    dut.io.reg0             #= 0
    dut.io.pc               #= 0
    dut.io.sr.t             #= false
    dut.io.sr.s             #= false
    dut.io.sr.q             #= false
    dut.io.sr.m             #= false
    dut.io.sr.interruptMask #= 0
    dut.io.mach             #= 0
    dut.io.macl             #= 0
    dut.io.wbus             #= 0
    dut.io.yOverrideEnable  #= false
    dut.io.yOverride        #= 0
  }

  test("shared buses, arithmetic, flags, and memory controls") {
    SimConfig.withVerilator.compile(new J2Datapath).doSim { dut =>
      defaults(dut)
      dut.io.ex.xSelect      #= J2XBusSelect.IMM
      dut.io.ex.ySelect      #= J2YBusSelect.REG
      dut.io.ex.aluX         #= J2AluXSelect.XBUS
      dut.io.ex.aluY         #= J2AluYSelect.YBUS
      dut.io.exStall.zSelect #= J2ZBusSelect.ARITH
      dut.io.ex.immediate    #= 5
      dut.io.regY            #= 3
      sleep(1)
      assertEquals(dut.io.zbus.toBigInt, BigInt(8))
      assert(!dut.io.arithmeticSr.t.toBoolean)

      dut.io.ex.arithFunc #= J2ArithFunc.SUB
      sleep(1)
      assertEquals(dut.io.zbus.toBigInt, BigInt(2))
      assert(!dut.io.arithmeticSr.t.toBoolean)

      dut.io.regY #= 5
      sleep(1)
      assertEquals(dut.io.zbus.toBigInt, BigInt(0))
      assert(dut.io.arithmeticSr.t.toBoolean)

      dut.io.ex.immediate #= 0x7fffffffL
      dut.io.regY         #= 1
      dut.io.ex.arithFunc #= J2ArithFunc.ADD
      dut.io.ex.arithSr   #= J2ArithSrFunc.OVERUNDERFLOW
      sleep(1)
      assert(dut.io.arithmeticSr.t.toBoolean)

      dut.io.exStall.memoryAddress   #= J2MemAddrSelect.YBUS
      dut.io.exStall.memoryWriteData #= J2MemWdataSelect.ZBUS
      sleep(1)
      assertEquals(dut.io.memoryAddress.toBigInt, BigInt(1))
      assertEquals(dut.io.memoryWriteData.toBigInt, BigInt(0x80000000L))
    }
  }

  test("shift, rotate, and rotate-through-carry match reference cases") {
    SimConfig.withVerilator.compile(new J2Datapath).doSim { dut =>
      defaults(dut)
      dut.io.ex.xSelect      #= J2XBusSelect.IMM
      dut.io.ex.ySelect      #= J2YBusSelect.REG
      dut.io.exStall.zSelect #= J2ZBusSelect.SHIFT

      def check(
          x: BigInt,
          y: BigInt,
          t: Boolean,
          op: SpinalEnumElement[J2ShiftFunc.type],
          expected: BigInt
      ): Unit = {
        dut.io.ex.immediate  #= x
        dut.io.regY          #= y
        dut.io.sr.t          #= t
        dut.io.exStall.shift #= op
        sleep(1)
        assertEquals(dut.io.zbus.toBigInt, expected & 0xffffffffL, f"x=$x%x y=$y%x op=$op")
      }

      check(0x80000000L, 0xffffffffL, false, J2ShiftFunc.LOGIC, 0x40000000L)
      check(0x80000000L, 0xffffffe0L, false, J2ShiftFunc.LOGIC, 0)
      check(0x80000000L, 0xffffffffL, false, J2ShiftFunc.ARITH, 0xc0000000L)
      check(0xf0000000L, 1, false, J2ShiftFunc.ROTATE, 0xe0000001L)
      check(0xf0000000L, 0xffffffffL, false, J2ShiftFunc.ROTATE, 0x78000000L)
      check(0x0f000000L, 1, true, J2ShiftFunc.ROTC, 0x1e000001L)
      check(0x0f000000L, 0xffffffffL, true, J2ShiftFunc.ROTC, 0x87800000L)
      check(1, 4, false, J2ShiftFunc.LOGIC, 0x10)
    }
  }

  test("manipulation operations implement byte and word transforms") {
    SimConfig.withVerilator.compile(new J2Datapath).doSim { dut =>
      defaults(dut)
      dut.io.ex.ySelect      #= J2YBusSelect.REG
      dut.io.exStall.zSelect #= J2ZBusSelect.MANIP
      dut.io.regY            #= 0x80abcdefL
      dut.io.ex.manip        #= J2AluManip.SWAP_BYTE
      sleep(1)
      assertEquals(dut.io.zbus.toBigInt, BigInt(0x80abefcdL))

      dut.io.ex.manip #= J2AluManip.SWAP_WORD
      sleep(1)
      assertEquals(dut.io.zbus.toBigInt, BigInt(0xcdef80abL))

      dut.io.regY     #= 0x80
      dut.io.ex.manip #= J2AluManip.EXTEND_SBYTE
      sleep(1)
      assertEquals(dut.io.zbus.toBigInt, BigInt(0xffffff80L))

      dut.io.regY     #= 0x7f
      dut.io.ex.manip #= J2AluManip.SET_BIT_7
      sleep(1)
      assertEquals(dut.io.zbus.toBigInt, BigInt(0xff))
    }
  }

  test("FC aligns PC without shifting its address") {
    SimConfig.withVerilator.compile(new J2Datapath).doSim { dut =>
      defaults(dut)
      dut.io.ex.immediate    #= 0x113
      dut.io.ex.aluX         #= J2AluXSelect.FC
      dut.io.ex.ySelect      #= J2YBusSelect.REG
      dut.io.ex.aluY         #= J2AluYSelect.YBUS
      dut.io.exStall.zSelect #= J2ZBusSelect.ARITH
      sleep(1)
      assertEquals(dut.io.zbus.toBigInt, BigInt(0x110))
    }
  }
}
