package j2.core

import spinal.core._

object J2ShiftOp extends SpinalEnum {
  val SHLL, SHLL2, SHLL8, SHLL16 = newElement()
  val SHLR, SHLR2, SHLR8, SHLR16 = newElement()
  val SHAL, SHAR                 = newElement()
  val ROTL, ROTR, ROTCL, ROTCR   = newElement()
}

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

final class J2Shifter extends Component {
  import J2ShiftOp._

  val io = new Bundle {
    val op     = in(J2ShiftOp())
    val value  = in UInt (32 bits)
    val tIn    = in Bool ()
    val result = out UInt (32 bits)
    val t      = out Bool ()
  }

  io.result := Mux(
    io.op === ROTCR,
    (io.tIn ## io.value(31 downto 1)).asUInt,
    io.value
  )
  io.t := Mux(io.op === ROTCR, io.value(0), io.tIn)
  switch(io.op) {
    is(SHLL) {
      io.result := (io.value(30 downto 0) ## B"0").asUInt
      io.t      := io.value(31)
    }
    is(SHLL2) {
      io.result := (io.value(29 downto 0) ## B"00").asUInt
    }
    is(SHLL8) {
      io.result := (io.value(23 downto 0) ## B"00000000").asUInt
    }
    is(SHLL16) {
      io.result := (io.value(15 downto 0) ## B"0000000000000000").asUInt
    }
    is(SHLR) {
      io.result := (B"0" ## io.value(31 downto 1)).asUInt
      io.t      := io.value(0)
    }
    is(SHLR2) {
      io.result := (B"00" ## io.value(31 downto 2)).asUInt
    }
    is(SHLR8) {
      io.result := (B"00000000" ## io.value(31 downto 8)).asUInt
    }
    is(SHLR16) {
      io.result := (B"0000000000000000" ## io.value(31 downto 16)).asUInt
    }
    is(SHAL) {
      io.result := (io.value(30 downto 0) ## B"0").asUInt
      io.t      := io.value(31)
    }
    is(SHAR) {
      io.result := (io.value(31) ## io.value(31 downto 1)).asUInt
      io.t      := io.value(0)
    }
    is(ROTL) {
      io.result := (io.value(30 downto 0) ## io.value(31)).asUInt
      io.t      := io.value(31)
    }
    is(ROTR) {
      io.result := (io.value(0) ## io.value(31 downto 1)).asUInt
      io.t      := io.value(0)
    }
    is(ROTCL) {
      io.result := (io.value(30 downto 0) ## io.tIn).asUInt
      io.t      := io.value(31)
    }
  }
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
