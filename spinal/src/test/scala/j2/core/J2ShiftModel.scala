package j2.core

sealed trait ShiftKind
object ShiftKind {
  case object SHLL extends ShiftKind
  case object SHLL2 extends ShiftKind
  case object SHLL8 extends ShiftKind
  case object SHLL16 extends ShiftKind
  case object SHLR extends ShiftKind
  case object SHLR2 extends ShiftKind
  case object SHLR8 extends ShiftKind
  case object SHLR16 extends ShiftKind
  case object SHAL extends ShiftKind
  case object SHAR extends ShiftKind
  case object ROTL extends ShiftKind
  case object ROTR extends ShiftKind
  case object ROTCL extends ShiftKind
  case object ROTCR extends ShiftKind

  val all: Seq[ShiftKind] = Seq(
    SHLL,
    SHLL2,
    SHLL8,
    SHLL16,
    SHLR,
    SHLR2,
    SHLR8,
    SHLR16,
    SHAL,
    SHAR,
    ROTL,
    ROTR,
    ROTCL,
    ROTCR
  )
}

object J2ShiftModel {
  import ShiftKind._
  final case class Result(value: BigInt, t: Boolean)
  private def u32(v: BigInt): BigInt = v & 0xffffffffL

  def eval(op: ShiftKind, value: BigInt, tIn: Boolean): Result = {
    val v                                 = u32(value)
    def left(amount: Int): Result         = Result(u32(v << amount), tIn)
    def logicalRight(amount: Int): Result = Result(u32(v >> amount), tIn)
    op match {
      case SHLL | SHAL => Result(u32(v << 1), v.testBit(31))
      case SHLL2       => left(2)
      case SHLL8       => left(8)
      case SHLL16      => left(16)
      case SHLR        => Result(u32(v >> 1), v.testBit(0))
      case SHLR2       => logicalRight(2)
      case SHLR8       => logicalRight(8)
      case SHLR16      => logicalRight(16)
      case SHAR        => Result(u32(BigInt(v.toInt >> 1)), v.testBit(0))
      case ROTL        => Result(u32((v << 1) | (v >> 31)), v.testBit(31))
      case ROTR  => Result(u32((v >> 1) | (if (v.testBit(0)) BigInt(1) << 31 else 0)), v.testBit(0))
      case ROTCL => Result(u32((v << 1) | (if (tIn) BigInt(1) else 0)), v.testBit(31))
      case ROTCR => Result(u32((v >> 1) | (if (tIn) BigInt(1) << 31 else 0)), v.testBit(0))
    }
  }
}
