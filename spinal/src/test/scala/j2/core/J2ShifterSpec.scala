package j2.core

class J2ShifterSpec extends munit.FunSuite {
  test("fixed shift and rotate behavior") {
    import ShiftKind._
    val x = BigInt("80000001", 16)
    assertEquals(J2ShiftModel.eval(SHLL, x, false), J2ShiftModel.Result(BigInt(2), true))
    assertEquals(
      J2ShiftModel.eval(SHLR, x, false),
      J2ShiftModel.Result(BigInt("40000000", 16), true)
    )
    assertEquals(
      J2ShiftModel.eval(SHAR, x, false),
      J2ShiftModel.Result(BigInt("c0000000", 16), true)
    )
    assertEquals(J2ShiftModel.eval(ROTL, x, false), J2ShiftModel.Result(BigInt(3), true))
    assertEquals(
      J2ShiftModel.eval(ROTR, x, false),
      J2ShiftModel.Result(BigInt("c0000000", 16), true)
    )
  }

  test("rotate through T") {
    import ShiftKind._
    val x = BigInt("80000001", 16)
    assertEquals(J2ShiftModel.eval(ROTCL, x, true), J2ShiftModel.Result(BigInt(3), true))
    assertEquals(
      J2ShiftModel.eval(ROTCR, x, true),
      J2ShiftModel.Result(BigInt("c0000000", 16), true)
    )
  }
}
