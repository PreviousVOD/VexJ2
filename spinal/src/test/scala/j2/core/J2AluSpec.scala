package j2.core

import scala.util.Random

class J2AluSpec extends munit.FunSuite {
  test("ALU reference model covers all operations") {
    val rng = new Random(1)
    val edges = Seq(
      BigInt("00000000", 16),
      BigInt("00000001", 16),
      BigInt("7fffffff", 16),
      BigInt("80000000", 16),
      BigInt("fffffffe", 16),
      BigInt("ffffffff", 16)
    )
    val values = edges ++ Seq.fill(2000)(BigInt(rng.nextLong() & 0xffffffffL))
    for (op <- AluKind.all; a <- values.take(300); b <- values.take(300); t <- Seq(false, true)) {
      val r = J2AluModel.eval(op, a, b, t)
      assertEquals(r.value & 0xffffffffL, r.value, s"$op: result must be 32-bit")
    }
  }

  test("signed versus unsigned comparisons differ") {
    import AluKind._
    val minusOne = BigInt("ffffffff", 16)
    assertEquals(J2AluModel.eval(CMP_HS, minusOne, BigInt(1), false).t, true)
    assertEquals(J2AluModel.eval(CMP_GE, minusOne, BigInt(1), false).t, false)
    assertEquals(J2AluModel.eval(CMP_HI, minusOne, BigInt(1), false).t, true)
    assertEquals(J2AluModel.eval(CMP_GT, minusOne, BigInt(1), false).t, false)
  }

  test("carry and overflow flags") {
    import AluKind._
    val max       = BigInt("ffffffff", 16)
    val signedMax = BigInt("7fffffff", 16)
    assertEquals(J2AluModel.eval(ADDC, max, BigInt(0), true).t, true)
    assertEquals(J2AluModel.eval(ADDV, signedMax, BigInt(1), false).t, true)
    assertEquals(J2AluModel.eval(SUBC, BigInt(0), BigInt(0), true).t, true)
    assertEquals(J2AluModel.eval(SUBV, BigInt("80000000", 16), BigInt(1), false).t, true)
  }
}
