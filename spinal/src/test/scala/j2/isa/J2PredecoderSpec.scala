package j2.isa

import j2.isa.J2Isa
import spinal.core._
import spinal.core.sim._

class J2PredecoderSpec extends munit.FunSuite {
  test("generated patterns match the ISA definitions") {
    assertEquals(
      J2PredecodeEntry.entries.map(_.pattern).toSet,
      J2Isa.instructions.map(_.pattern).toSet
    )
  }

  test("delay-slot PC modifications match the reference rule") {
    for (instruction <- 0 to 0xffff) {
      val code = instruction
      val expected =
        ((code >>> 12) == 0 && ((code >>> 2) & 3) == 0 && (code & 1) != 0) ||
          ((code >>> 14) == 2 && ((code >>> 11) & 3) == 1 && (code & 0x100) != 0) ||
          ((code >>> 13) == 5) ||
          ((code & 0x8000) != 0 && ((code >>> 8) & 0x3f) == 3) ||
          ((code & 0x8000) == 0 && ((code >>> 12) & 3) == 0 && (code & 0x1f) == 0x0b)
      assertEquals(
        J2PredecodeEntry.isDelaySlotIllegal(instruction),
        expected,
        f"0x$instruction%04x"
      )
    }
  }

  test("all 16-bit encodings produce the reference ROM address") {
    SimConfig.withVerilator.compile(new J2Predecoder).doSim { dut =>
      for (instruction <- 0 to 0xffff) {
        val expected = J2PredecodeEntry.find(instruction)
        dut.io.instruction #= instruction
        sleep(1)
        assertEquals(
          expected.isDefined,
          J2Isa.legal(instruction),
          f"ISA legality 0x$instruction%04x"
        )
        assertEquals(dut.io.legal.toBoolean, expected.isDefined, f"legality 0x$instruction%04x")
        assertEquals(
          dut.io.delaySlotIllegal.toBoolean,
          J2PredecodeEntry.isDelaySlotIllegal(instruction),
          f"delay-slot rule 0x$instruction%04x"
        )
        assertEquals(
          dut.io.address.toInt,
          expected.map(_.address).getOrElse(0),
          f"address 0x$instruction%04x"
        )
      }
    }
  }
}
