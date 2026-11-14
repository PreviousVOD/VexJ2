package j2.core

class Sh2ShifterSpec extends munit.FunSuite {
  test("fixed shift and rotate behavior") {
    import ShiftKind._
    val x = BigInt("80000001", 16)
    assertEquals(Sh2ShiftModel.eval(SHLL, x, false), Sh2ShiftModel.Result(BigInt(2), true))
    assertEquals(
      Sh2ShiftModel.eval(SHLR, x, false),
      Sh2ShiftModel.Result(BigInt("40000000", 16), true)
    )
    assertEquals(
      Sh2ShiftModel.eval(SHAR, x, false),
      Sh2ShiftModel.Result(BigInt("c0000000", 16), true)
    )
    assertEquals(Sh2ShiftModel.eval(ROTL, x, false), Sh2ShiftModel.Result(BigInt(3), true))
    assertEquals(
      Sh2ShiftModel.eval(ROTR, x, false),
      Sh2ShiftModel.Result(BigInt("c0000000", 16), true)
    )
  }

  test("rotate through T") {
    import ShiftKind._
    val x = BigInt("80000001", 16)
    assertEquals(Sh2ShiftModel.eval(ROTCL, x, true), Sh2ShiftModel.Result(BigInt(3), true))
    assertEquals(
      Sh2ShiftModel.eval(ROTCR, x, true),
      Sh2ShiftModel.Result(BigInt("c0000000", 16), true)
    )
  }
}
