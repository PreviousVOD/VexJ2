package j2.core

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

object J2AluModel {
  import AluKind._

  final case class Result(value: BigInt, t: Boolean)

  private def u32(v: BigInt): BigInt = v & 0xffffffffL
  private def s32(v: BigInt): Int    = u32(v).toInt

  def eval(op: AluKind, a: BigInt, b: BigInt, tIn: Boolean): Result = {
    val au    = u32(a)
    val bu    = u32(b)
    val carry = if (tIn) BigInt(1) else BigInt(0)
    op match {
      case ADD  => Result(u32(au + bu), tIn)
      case ADDC => val s = au + bu + carry; Result(u32(s), s > 0xffffffffL)
      case ADDV =>
        val r  = u32(au + bu)
        val ov = au.testBit(31) == bu.testBit(31) && r.testBit(31) != au.testBit(31)
        Result(r, ov)
      case SUB  => Result(u32(au - bu), tIn)
      case SUBC => val d = au - bu - carry; Result(u32(d), d < 0)
      case SUBV =>
        val r  = u32(au - bu)
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
