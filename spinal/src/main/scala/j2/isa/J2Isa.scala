package j2.isa

final case class J2OpcodeDef(
    id: Int,
    name: String,
    pattern: String,
    excluded: Boolean = false
) {
  require(pattern.length == 16, s"$name: opcode pattern must contain 16 bits")
  require(pattern.forall(c => "01nmid".contains(c)), s"$name: invalid pattern character")

  val mask: Int = Integer.parseUnsignedInt(
    pattern.map(c => if (c == '0' || c == '1') '1' else '0').mkString,
    2
  )
  val value: Int = Integer.parseUnsignedInt(
    pattern.map(c => if (c == '1') '1' else '0').mkString,
    2
  )

  def matches(instruction: Int): Boolean = (instruction & mask) == value
}

sealed trait J2DecodeResult
object J2DecodeResult {
  final case class Legal(opcode: J2OpcodeDef) extends J2DecodeResult
  final case class ExcludedJ2(opcode: J2OpcodeDef) extends J2DecodeResult
  final case class Illegal(raw: Int) extends J2DecodeResult
}

object J2Isa {
  import J2DecodeResult._

  /*
   * SH-2 instruction set from REJ09B0171. J2 extensions are illegal opcodes.
   */
  private val basePatterns = Seq(
    "CLRT" -> "0000000000001000",
    "CLRMAC" -> "0000000000101000",
    "DIV0U" -> "0000000000011001",
    "NOP" -> "0000000000001001",
    "RTE" -> "0000000000101011",
    "RTS" -> "0000000000001011",
    "SETT" -> "0000000000011000",
    "SLEEP" -> "0000000000011011",
    "CMP/PL Rn" -> "0100nnnn00010101",
    "CMP/PZ Rn" -> "0100nnnn00010001",
    "DT Rn" -> "0100nnnn00010000",
    "MOVT Rn" -> "0000nnnn00101001",
    "ROTL Rn" -> "0100nnnn00000100",
    "ROTR Rn" -> "0100nnnn00000101",
    "ROTCL Rn" -> "0100nnnn00100100",
    "ROTCR Rn" -> "0100nnnn00100101",
    "SHAL Rn" -> "0100nnnn00100000",
    "SHAR Rn" -> "0100nnnn00100001",
    "SHLL Rn" -> "0100nnnn00000000",
    "SHLR Rn" -> "0100nnnn00000001",
    "SHLL2 Rn" -> "0100nnnn00001000",
    "SHLR2 Rn" -> "0100nnnn00001001",
    "SHLL8 Rn" -> "0100nnnn00011000",
    "SHLR8 Rn" -> "0100nnnn00011001",
    "SHLL16 Rn" -> "0100nnnn00101000",
    "SHLR16 Rn" -> "0100nnnn00101001",
    "STC SR, Rn" -> "0000nnnn00000010",
    "STC GBR, Rn" -> "0000nnnn00010010",
    "STC VBR, Rn" -> "0000nnnn00100010",
    "STS MACH, Rn" -> "0000nnnn00001010",
    "STS MACL, Rn" -> "0000nnnn00011010",
    "STS PR, Rn" -> "0000nnnn00101010",
    "TAS.B @Rn" -> "0100nnnn00011011",
    "STC.L SR, @-Rn" -> "0100nnnn00000011",
    "STC.L GBR, @-Rn" -> "0100nnnn00010011",
    "STC.L VBR, @-Rn" -> "0100nnnn00100011",
    "STS.L MACH, @-Rn" -> "0100nnnn00000010",
    "STS.L MACL, @-Rn" -> "0100nnnn00010010",
    "STS.L PR, @-Rn" -> "0100nnnn00100010",
    "LDC Rm, SR" -> "0100mmmm00001110",
    "LDC Rm, GBR" -> "0100mmmm00011110",
    "LDC Rm, VBR" -> "0100mmmm00101110",
    "LDS Rm, MACH" -> "0100mmmm00001010",
    "LDS Rm, MACL" -> "0100mmmm00011010",
    "LDS Rm, PR" -> "0100mmmm00101010",
    "JMP @Rm" -> "0100mmmm00101011",
    "JSR @Rm" -> "0100mmmm00001011",
    "LDC.L @Rm+, SR" -> "0100mmmm00000111",
    "LDC.L @Rm+, GBR" -> "0100mmmm00010111",
    "LDC.L @Rm+, VBR" -> "0100mmmm00100111",
    "LDS.L @Rm+, MACH" -> "0100mmmm00000110",
    "LDS.L @Rm+, MACL" -> "0100mmmm00010110",
    "LDS.L @Rm+, PR" -> "0100mmmm00100110",
    "BRAF Rm" -> "0000mmmm00100011",
    "BSRF Rm" -> "0000mmmm00000011",
    "ADD Rm, Rn" -> "0011nnnnmmmm1100",
    "ADDC Rm, Rn" -> "0011nnnnmmmm1110",
    "ADDV Rm, Rn" -> "0011nnnnmmmm1111",
    "AND Rm, Rn" -> "0010nnnnmmmm1001",
    "CMP/EQ Rm, Rn" -> "0011nnnnmmmm0000",
    "CMP/HS Rm, Rn" -> "0011nnnnmmmm0010",
    "CMP/GE Rm, Rn" -> "0011nnnnmmmm0011",
    "CMP/HI Rm, Rn" -> "0011nnnnmmmm0110",
    "CMP/GT Rm, Rn" -> "0011nnnnmmmm0111",
    "CMP/STR Rm, Rn" -> "0010nnnnmmmm1100",
    "DIV1 Rm, Rn" -> "0011nnnnmmmm0100",
    "DIV0S Rm, Rn" -> "0010nnnnmmmm0111",
    "DMULS.L Rm, Rn" -> "0011nnnnmmmm1101",
    "DMULU.L Rm, Rn" -> "0011nnnnmmmm0101",
    "EXTS.B Rm, Rn" -> "0110nnnnmmmm1110",
    "EXTS.W Rm, Rn" -> "0110nnnnmmmm1111",
    "EXTU.B Rm, Rn" -> "0110nnnnmmmm1100",
    "EXTU.W Rm, Rn" -> "0110nnnnmmmm1101",
    "MOV Rm, Rn" -> "0110nnnnmmmm0011",
    "MUL.L Rm, Rn" -> "0000nnnnmmmm0111",
    "MULS.W Rm, Rn" -> "0010nnnnmmmm1111",
    "MULU.W Rm, Rn" -> "0010nnnnmmmm1110",
    "NEG Rm, Rn" -> "0110nnnnmmmm1011",
    "NEGC Rm, Rn" -> "0110nnnnmmmm1010",
    "NOT Rm, Rn" -> "0110nnnnmmmm0111",
    "OR Rm, Rn" -> "0010nnnnmmmm1011",
    "SUB Rm, Rn" -> "0011nnnnmmmm1000",
    "SUBC Rm, Rn" -> "0011nnnnmmmm1010",
    "SUBV Rm, Rn" -> "0011nnnnmmmm1011",
    "SWAP.B Rm, Rn" -> "0110nnnnmmmm1000",
    "SWAP.W Rm, Rn" -> "0110nnnnmmmm1001",
    "TST Rm, Rn" -> "0010nnnnmmmm1000",
    "XOR Rm, Rn" -> "0010nnnnmmmm1010",
    "XTRACT Rm, Rn" -> "0010nnnnmmmm1101",
    "MOV.B Rm, @Rn" -> "0010nnnnmmmm0000",
    "MOV.W Rm, @Rn" -> "0010nnnnmmmm0001",
    "MOV.L Rm, @Rn" -> "0010nnnnmmmm0010",
    "MOV.B @Rm, Rn" -> "0110nnnnmmmm0000",
    "MOV.W @Rm, Rn" -> "0110nnnnmmmm0001",
    "MOV.L @Rm, Rn" -> "0110nnnnmmmm0010",
    "MAC.L @Rm+, @Rn+" -> "0000nnnnmmmm1111",
    "MAC.W @Rm+, @Rn+" -> "0100nnnnmmmm1111",
    "MOV.B @Rm+, Rn" -> "0110nnnnmmmm0100",
    "MOV.W @Rm+, Rn" -> "0110nnnnmmmm0101",
    "MOV.L @Rm+, Rn" -> "0110nnnnmmmm0110",
    "MOV.B Rm, @-Rn" -> "0010nnnnmmmm0100",
    "MOV.W Rm, @-Rn" -> "0010nnnnmmmm0101",
    "MOV.L Rm, @-Rn" -> "0010nnnnmmmm0110",
    "MOV.B Rm, @(R0,Rn)" -> "0000nnnnmmmm0100",
    "MOV.W Rm, @(R0,Rn)" -> "0000nnnnmmmm0101",
    "MOV.L Rm, @(R0,Rn)" -> "0000nnnnmmmm0110",
    "MOV.B @(R0,Rm), Rn" -> "0000nnnnmmmm1100",
    "MOV.W @(R0,Rm), Rn" -> "0000nnnnmmmm1101",
    "MOV.L @(R0,Rm), Rn" -> "0000nnnnmmmm1110",
    "MOV.B @(disp,Rm), R0" -> "10000100mmmmdddd",
    "MOV.W @(disp,Rm), R0" -> "10000101mmmmdddd",
    "MOV.B R0, @(disp,Rn)" -> "10000000nnnndddd",
    "MOV.W R0, @(disp,Rn)" -> "10000001nnnndddd",
    "MOV.L Rm, @(disp,Rn)" -> "0001nnnnmmmmdddd",
    "MOV.L @(disp,Rm), Rn" -> "0101nnnnmmmmdddd",
    "MOV.B R0, @(disp,GBR)" -> "11000000dddddddd",
    "MOV.W R0, @(disp,GBR)" -> "11000001dddddddd",
    "MOV.L R0, @(disp,GBR)" -> "11000010dddddddd",
    "MOV.B @(disp,GBR), R0" -> "11000100dddddddd",
    "MOV.W @(disp,GBR), R0" -> "11000101dddddddd",
    "MOV.L @(disp,GBR), R0" -> "11000110dddddddd",
    "MOVA @(disp,PC), R0" -> "11000111dddddddd",
    "BF label" -> "10001011dddddddd",
    "BF/S label" -> "10001111dddddddd",
    "BT label" -> "10001001dddddddd",
    "BT/S label" -> "10001101dddddddd",
    "BRA label" -> "1010dddddddddddd",
    "BSR label" -> "1011dddddddddddd",
    "MOV.W @(disp,PC), Rn" -> "1001nnnndddddddd",
    "MOV.L @(disp,PC), Rn" -> "1101nnnndddddddd",
    "AND.B #imm, @(R0,GBR)" -> "11001101iiiiiiii",
    "OR.B #imm, @(R0,GBR)" -> "11001111iiiiiiii",
    "TST.B #imm, @(R0,GBR)" -> "11001100iiiiiiii",
    "XOR.B #imm, @(R0,GBR)" -> "11001110iiiiiiii",
    "AND #imm, R0" -> "11001001iiiiiiii",
    "CMP/EQ #imm, R0" -> "10001000iiiiiiii",
    "OR #imm, R0" -> "11001011iiiiiiii",
    "TST #imm, R0" -> "11001000iiiiiiii",
    "XOR #imm, R0" -> "11001010iiiiiiii",
    "TRAPA #imm" -> "11000011iiiiiiii",
    "ADD #imm, Rn" -> "0111nnnniiiiiiii",
    "MOV #imm, Rn" -> "1110nnnniiiiiiii"
  )

  val instructions: Seq[J2OpcodeDef] =
    basePatterns.zipWithIndex.map { case ((name, pattern), id) =>
      J2OpcodeDef(id, name, pattern)
    }

  val excludedInstructions: Seq[J2OpcodeDef] = Seq.empty

  val allDefinitions: Seq[J2OpcodeDef] = instructions ++ excludedInstructions

  final case class Fields(
      n: Int,
      m: Int,
      disp4: Int,
      disp8: Int,
      disp12: Int,
      immediate8: Int
  )

  def decode(instruction: Int): J2DecodeResult = {
    val raw = instruction & 0xffff
    allDefinitions.find(_.matches(raw)) match {
      case Some(op) if op.excluded => ExcludedJ2(op)
      case Some(op)                => Legal(op)
      case None                    => Illegal(raw)
    }
  }

  def legal(instruction: Int): Boolean = decode(instruction).isInstanceOf[Legal]

  def excludedJ2(instruction: Int): Boolean =
    decode(instruction).isInstanceOf[ExcludedJ2]

  val opcodeWidth: Int =
    Math.max(1, Integer.SIZE - Integer.numberOfLeadingZeros(allDefinitions.length))

  def fields(instruction: Int): Option[Fields] = {
    val decoded = decode(instruction)
    val opcode = decoded match {
      case Legal(op)      => Some(op)
      case ExcludedJ2(op) => Some(op)
      case Illegal(_)     => None
    }

    def value(marker: Char): Int = {
      val positions =
        opcode.get.pattern.zipWithIndex.collect { case (c, index) if c == marker => 15 - index }
      positions.foldLeft(0) { case (acc, bit) =>
        (acc << 1) | ((instruction >>> bit) & 1)
      }
    }

    opcode.map { _ =>
      Fields(
        n          = value('n'),
        m          = value('m'),
        disp4      = value('d') & 0xf,
        disp8      = value('d') & 0xff,
        disp12     = value('d') & 0xfff,
        immediate8 = value('i')
      )
    }
  }
}
