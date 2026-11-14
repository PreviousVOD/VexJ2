package j2.isa

class Sh2IsaSpec extends munit.FunSuite {
  test("known SH-2 instructions decode") {
    assertEquals(Sh2Isa.decode(0x0009).asInstanceOf[Sh2DecodeResult.Legal].opcode.name, "NOP")
    assertEquals(
      Sh2Isa.decode(0xe105).asInstanceOf[Sh2DecodeResult.Legal].opcode.name,
      "MOV #imm, Rn"
    )
    assertEquals(Sh2Isa.decode(0x000b).asInstanceOf[Sh2DecodeResult.Legal].opcode.name, "RTS")
    assertEquals(
      Sh2Isa.decode(0x4f22).asInstanceOf[Sh2DecodeResult.Legal].opcode.name,
      "STS.L PR, @-Rn"
    )
  }

  test("J2 extension instructions decode as legal") {
    val extensions = Seq(
      0x4f2c, // SHAD
      0x4f2d, // SHLD
      0x2333, // CAS.L
      0x003b // BGND
    )
    extensions.foreach { instruction =>
      assert(!Sh2Isa.excludedJ2(instruction), f"0x$instruction%04x must not be excluded")
      assert(Sh2Isa.legal(instruction))
    }
  }

  test("operand fields follow the instruction format") {
    assertEquals(
      Sh2Isa.fields(0xe105),
      Some(Sh2Isa.Fields(n = 1, m = 0, disp4 = 0, disp8 = 0, disp12 = 0, immediate8 = 5))
    )
    assertEquals(
      Sh2Isa.fields(0xa123),
      Some(Sh2Isa.Fields(n = 0, m = 0, disp4 = 3, disp8 = 0x23, disp12 = 0x123, immediate8 = 0))
    )
    assert(Sh2Isa.fields(0xffff).isEmpty)
  }

  test("opcode patterns do not overlap") {
    Sh2Isa.allDefinitions.combinations(2).foreach {
      case Seq(a, b) =>
        assert((a.mask & b.mask & (a.value ^ b.value)) != 0, s"${a.name} overlaps ${b.name}")
      case _ =>
    }
  }

  test("all 16-bit encodings are classified") {
    var legal = 0
    var excludedJ2 = 0
    var illegal = 0
    for (instruction <- 0 to 0xffff)
      Sh2Isa.decode(instruction) match {
        case _: Sh2DecodeResult.Legal      => legal += 1
        case _: Sh2DecodeResult.ExcludedJ2 => excludedJ2 += 1
        case _: Sh2DecodeResult.Illegal    => illegal += 1
      }
    println(s"SH-2 decoder: legal=$legal excludedJ2=$excludedJ2 illegal=$illegal")
    assertEquals(legal + excludedJ2 + illegal, 65536)
  }
}
