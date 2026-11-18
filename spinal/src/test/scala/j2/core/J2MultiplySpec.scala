package j2.core

import spinal.core._
import spinal.core.sim._

class J2MultiplySpec extends munit.FunSuite {
  test("multiply and MAC commands produce signed, unsigned, and accumulated results") {
    SimConfig.withVerilator.compile(new J2Multiply).doSim { dut =>
      dut.io.slot      #= true
      dut.io.command   #= J2MultiplyCommand.NOP
      dut.io.in1       #= 0
      dut.io.in2       #= 0
      dut.io.s         #= false
      dut.io.writeM1   #= false
      dut.io.writeMach #= false
      dut.io.writeMacl #= false
      dut.clockDomain.forkStimulus(10)
      dut.clockDomain.assertReset()
      dut.clockDomain.waitSampling(2)
      dut.clockDomain.deassertReset()
      dut.clockDomain.waitSampling()

      def run(
          command: SpinalEnumElement[J2MultiplyCommand.type],
          a: BigInt,
          b: BigInt,
          expectedMach: BigInt,
          expectedMacl: BigInt
      ): Unit = {
        dut.io.in1     #= (a & 0xffffffffL)
        dut.io.in2     #= (b & 0xffffffffL)
        dut.io.writeM1 #= true
        dut.io.command #= J2MultiplyCommand.NOP
        dut.clockDomain.waitSampling()
        sleep(1)
        dut.io.writeM1 #= false
        dut.io.in1     #= 0xdeadbeefL // The first operand must survive until command.
        dut.io.command #= command
        dut.clockDomain.waitSampling()
        sleep(1)
        dut.io.command #= J2MultiplyCommand.NOP
        dut.io.slot    #= false // Arithmetic must progress during bus stalls.
        var cycles = 0
        while (dut.io.busy.toBoolean && cycles < 8) {
          dut.clockDomain.waitSampling()
          sleep(1)
          cycles += 1
        }
        sleep(1)
        dut.io.slot #= true
        assert(!dut.io.busy.toBoolean)
        val longCommand = Set(
          J2MultiplyCommand.DMULSL,
          J2MultiplyCommand.DMULUL,
          J2MultiplyCommand.MULL,
          J2MultiplyCommand.MACL
        ).contains(command)
        assertEquals(cycles, if (longCommand) 4 else 2, s"arithmetic clocks: $command")
        assertEquals(dut.io.mach.toBigInt, expectedMach & 0xffffffffL, s"MACH $command")
        assertEquals(dut.io.macl.toBigInt, expectedMacl & 0xffffffffL, s"MACL $command")
      }

      run(J2MultiplyCommand.DMULSL, -2, 3, 0xffffffffL, 0xfffffffaL)
      run(J2MultiplyCommand.DMULUL, 0xffffffffL, 2, 1, 0xfffffffeL)
      run(J2MultiplyCommand.MULL, -7, 3, 1, 0xffffffebL)
      run(J2MultiplyCommand.MULSW, 0x8000, 2, 1, 0xffff0000L)
      run(J2MultiplyCommand.MULUW, 0xffff, 2, 1, 0x0001fffeL)

      dut.io.writeMach #= true
      dut.io.writeMacl #= true
      dut.io.in1       #= 0
      dut.io.in2       #= 5
      dut.clockDomain.waitSampling()
      dut.io.writeMach #= false
      dut.io.writeMacl #= false
      run(J2MultiplyCommand.MACL, 2, 3, 0, 11)
      run(J2MultiplyCommand.MACW, -2, 3, 0, 5)

      def accumulator(high: Long, low: Long): Unit = {
        dut.io.writeMach #= true
        dut.io.writeMacl #= true
        dut.io.in1       #= high
        dut.io.in2       #= low
        dut.clockDomain.waitSampling()
        sleep(1)
        dut.io.writeMach #= false
        dut.io.writeMacl #= false
      }
      dut.io.s #= true
      accumulator(0x12345678L, 0)
      run(J2MultiplyCommand.MACW, -32768, 32767, 0x12345678L, 0xc0008000L)
      accumulator(0x12345678L, 0x7fffffffL)
      run(J2MultiplyCommand.MACW, 1, 1, 0x12345679L, 0x7fffffffL)
      accumulator(0x12345678L, 0x80000000L)
      run(J2MultiplyCommand.MACW, -1, 1, 0x12345679L, 0x80000000L)

      // Only the signed low 48 bits participate in saturating MAC.L.
      accumulator(0x00010000L, 0)
      run(J2MultiplyCommand.MACL, 0, 0, 0, 0)
      accumulator(0x0007ffffL, 0xffffffffL)
      run(J2MultiplyCommand.MACL, 1, 1, 0, 0)
      accumulator(0xfff80000L, 0)
      run(J2MultiplyCommand.MACL, -1, 1, 0xffffffffL, 0xffffffffL)
      accumulator(0xdeadffffL, 0xffffffffL)
      run(J2MultiplyCommand.MACL, 0, 0, 0xffffffffL, 0xffffffffL)
      accumulator(0x12340000L, 5)
      run(J2MultiplyCommand.MACL, 2, 3, 0, 11)
      accumulator(0x7fffL, 0xffffffffL)
      run(J2MultiplyCommand.MACL, 1, 1, 0x7fffL, 0xffffffffL)
      accumulator(0x8000L, 0)
      run(J2MultiplyCommand.MACL, -1, 1, 0xffff8000L, 0)
      accumulator(0, 0)
      run(J2MultiplyCommand.MACL, -2147483648L, -2147483648L, 0x7fffL, 0xffffffffL)
      accumulator(0, 0)
      run(J2MultiplyCommand.MACL, -2147483648L, 2147483647L, 0xffff8000L, 0)
      dut.io.s #= false
      val random = new scala.util.Random(0x532)
      val mask   = (BigInt(1) << 64) - 1
      for (_ <- 0 until 100) {
        val a        = random.nextInt()
        val b        = random.nextInt()
        val signed   = BigInt(a) * BigInt(b) & mask
        val unsigned = BigInt(a.toLong & 0xffffffffL) * BigInt(b.toLong & 0xffffffffL)
        run(J2MultiplyCommand.DMULSL, a, b, signed >> 32, signed)
        run(J2MultiplyCommand.DMULUL, a, b, unsigned >> 32, unsigned)
        val acc = (BigInt(random.nextLong()) & mask)
        accumulator((acc >> 32).toLong, (acc & 0xffffffffL).toLong)
        val sum = (acc + signed) & mask
        run(J2MultiplyCommand.MACL, a, b, sum >> 32, sum)
      }
      accumulator(0x00010000L, 0)
      run(J2MultiplyCommand.MACL, 0, 0, 0x00010000L, 0)
      accumulator(0xffffffffL, 0xffffffffL)
      run(J2MultiplyCommand.MACL, 1, 1, 0, 0)

    }
  }
}
