package j2.core

import spinal.core._

object J2AluOp extends SpinalEnum {
  val ADD, ADDC, ADDV = newElement()
  val SUB, SUBC, SUBV = newElement()
  val NEG, NEGC = newElement()
  val CMP_EQ, CMP_HS, CMP_GE, CMP_HI, CMP_GT = newElement()
  val TST, AND, OR, XOR = newElement()
  val NOT, MOV = newElement()
}

sealed trait AluKind
object AluKind {
  case object ADD extends AluKind
  case object ADDC extends AluKind
  case object ADDV extends AluKind
  case object SUB extends AluKind
  case object SUBC extends AluKind
  case object SUBV extends AluKind
  case object NEG extends AluKind
  case object NEGC extends AluKind
  case object CMP_EQ extends AluKind
  case object CMP_HS extends AluKind
  case object CMP_GE extends AluKind
  case object CMP_HI extends AluKind
  case object CMP_GT extends AluKind
  case object TST extends AluKind
  case object AND extends AluKind
  case object OR extends AluKind
  case object XOR extends AluKind
  case object NOT extends AluKind
  case object MOV extends AluKind

  val all: Seq[AluKind] = Seq(
    ADD,
    ADDC,
    ADDV,
    SUB,
    SUBC,
    SUBV,
    NEG,
    NEGC,
    CMP_EQ,
    CMP_HS,
    CMP_GE,
    CMP_HI,
    CMP_GT,
    TST,
    AND,
    OR,
    XOR,
    NOT,
    MOV
  )
}

final class J2Alu extends Component {
  import J2AluOp._

  val io = new Bundle {
    val op = in(J2AluOp())
    val a = in UInt (32 bits)
    val b = in UInt (32 bits)
    val tIn = in Bool ()
    val qIn = in Bool ()
    val mIn = in Bool ()
    val result = out UInt (32 bits)
    val t = out Bool ()
    val q = out Bool ()
    val m = out Bool ()
  }

  val sum33 = io.a.resize(33 bits) + io.b.resize(33 bits)
  val sumCarry33 = sum33 + io.tIn.asUInt.resize(33 bits)
  val diff33 = io.a.resize(33 bits) - io.b.resize(33 bits)
  val diffBorrow33 = diff33 - io.tIn.asUInt.resize(33 bits)
  val neg33 = U(0, 33 bits) - io.a.resize(33 bits)
  val negBorrow33 = neg33 - io.tIn.asUInt.resize(33 bits)

  val addOverflow =
    io.a.msb === io.b.msb && sum33(31) =/= io.a.msb
  val subOverflow =
    io.a.msb =/= io.b.msb && diff33(31) =/= io.a.msb

  io.result := Mux(io.op === MOV, io.b, io.a)
  io.t := io.tIn
  io.q := io.qIn
  io.m := io.mIn

  switch(io.op) {
    is(ADD) {
      io.result := sum33.resize(32)
    }
    is(ADDC) {
      io.result := sumCarry33.resize(32)
      io.t := sumCarry33(32)
    }
    is(ADDV) {
      io.result := sum33.resize(32)
      io.t := addOverflow
    }
    is(SUB) {
      io.result := diff33.resize(32)
    }
    is(SUBC) {
      io.result := diffBorrow33.resize(32)
      io.t := diffBorrow33(32)
    }
    is(SUBV) {
      io.result := diff33.resize(32)
      io.t := subOverflow
    }
    is(NEG) {
      io.result := neg33.resize(32)
    }
    is(NEGC) {
      io.result := negBorrow33.resize(32)
      io.t := negBorrow33(32)
    }
    is(CMP_EQ) {
      io.t := io.a === io.b
    }
    is(CMP_HS) {
      io.t := io.a >= io.b
    }
    is(CMP_GE) {
      io.t := io.a.asSInt >= io.b.asSInt
    }
    is(CMP_HI) {
      io.t := io.a > io.b
    }
    is(CMP_GT) {
      io.t := io.a.asSInt > io.b.asSInt
    }
    is(TST) {
      io.result := io.a & io.b
      io.t := (io.a & io.b) === 0
    }
    is(AND) {
      io.result := io.a & io.b
    }
    is(OR) {
      io.result := io.a | io.b
    }
    is(XOR) {
      io.result := io.a ^ io.b
    }
    is(NOT) {
      io.result := ~io.b
    }
  }
}

object J2AluModel {
  import AluKind._

  final case class Result(value: BigInt, t: Boolean)

  private def u32(v: BigInt): BigInt = v & 0xffffffffL
  private def s32(v: BigInt): Int = u32(v).toInt

  def eval(op: AluKind, a: BigInt, b: BigInt, tIn: Boolean): Result = {
    val au = u32(a)
    val bu = u32(b)
    val carry = if (tIn) BigInt(1) else BigInt(0)
    op match {
      case ADD  => Result(u32(au + bu), tIn)
      case ADDC => val s = au + bu + carry; Result(u32(s), s > 0xffffffffL)
      case ADDV =>
        val r = u32(au + bu)
        val ov = au.testBit(31) == bu.testBit(31) && r.testBit(31) != au.testBit(31)
        Result(r, ov)
      case SUB  => Result(u32(au - bu), tIn)
      case SUBC => val d = au - bu - carry; Result(u32(d), d < 0)
      case SUBV =>
        val r = u32(au - bu)
        val ov = au.testBit(31) != bu.testBit(31) && r.testBit(31) != au.testBit(31)
        Result(r, ov)
      case NEG    => Result(u32(-au), tIn)
      case NEGC   => val d = -au - carry; Result(u32(d), d < 0)
      case CMP_EQ => Result(au, au == bu)
      case CMP_HS => Result(au, au >= bu)
      case CMP_GE => Result(au, s32(au) >= s32(bu))
      case CMP_HI => Result(au, au > bu)
      case CMP_GT => Result(au, s32(au) > s32(bu))
      case TST    => Result(au & bu, (au & bu) == 0)
      case AND    => Result(au & bu, tIn)
      case OR     => Result(au | bu, tIn)
      case XOR    => Result(au ^ bu, tIn)
      case NOT    => Result(u32(~bu), tIn)
      case MOV    => Result(bu, tIn)
    }
  }
}
