package j2.core

import spinal.core._

final class J2Multiply extends Component {
  val io = new Bundle {
    val slot      = in Bool ()
    val command   = in(J2MultiplyCommand())
    val in1       = in UInt (32 bits)
    val in2       = in UInt (32 bits)
    val s         = in Bool ()
    val writeM1   = in Bool ()
    val writeMach = in Bool ()
    val writeMacl = in Bool ()
    val busy      = out Bool ()
    val mach      = out UInt (32 bits)
    val macl      = out UInt (32 bits)
  }

  private val busyReg      = RegInit(False)
  private val remaining    = RegInit(U(0, 2 bits))
  private val commandReg   = RegInit(J2MultiplyCommand.NOP)
  private val firstOperand = RegInit(U(0, 32 bits))
  private val operand1     = RegInit(U(0, 32 bits))
  private val operand2     = RegInit(U(0, 32 bits))
  private val saturate     = RegInit(False)
  private val machReg      = RegInit(U(0, 32 bits))
  private val maclReg      = RegInit(U(0, 32 bits))

  // Independent multiplier pipeline, clocked even while CPU slots wait for memory.
  // Word operations: product -> accumulate/commit (2 clocks).
  // Long operations: partial products -> cross terms -> product -> commit (4 clocks).
  private val product        = RegInit(U(0, 64 bits))
  private val p00            = RegInit(U(0, 32 bits))
  private val p01, p10, p11  = RegInit(S(0, 34 bits))
  private val cross          = RegInit(S(0, 35 bits))
  private val base           = RegInit(U(0, 64 bits))
  private val longCommandReg = RegInit(False)
  private val signedLong     = commandReg =/= J2MultiplyCommand.DMULUL
  private val aLow           = operand1(15 downto 0).resize(17).asSInt
  private val bLow           = operand2(15 downto 0).resize(17).asSInt
  private val aHigh          = Cat(signedLong && operand1(31), operand1(31 downto 16)).asSInt
  private val bHigh          = Cat(signedLong && operand2(31), operand2(31 downto 16)).asSInt
  private val signedWord     = commandReg =/= J2MultiplyCommand.MULUW
  private val aWord          = Cat(signedWord && operand1(15), operand1(15 downto 0)).asSInt
  private val bWord          = Cat(signedWord && operand2(15), operand2(15 downto 0)).asSInt
  private val accumulator = Mux(
    saturate && commandReg === J2MultiplyCommand.MACL,
    Cat(machReg(15 downto 0), maclReg).asSInt.resize(64).asUInt,
    Cat(machReg, maclReg).asUInt
  )
  private val sum = accumulator + product

  private val macwPositiveOverflow   = !maclReg(31) && !product(31) && sum(31)
  private val macwNegativeOverflow   = maclReg(31) && product(31) && !sum(31)
  private val macwSaturationRequired = macwPositiveOverflow || macwNegativeOverflow

  private val maclPositiveSaturation =
    !sum(63) && (sum(62 downto 47) =/= 0)
  private val maclNegativeSaturation =
    sum(63) && (sum(62 downto 47) =/= 0xffffL)
  private val maclSaturationRequired = maclPositiveSaturation || maclNegativeSaturation

  io.busy := busyReg
  io.mach := machReg
  io.macl := maclReg

  // Slot gates CPU operand/control acceptance, not the arithmetic clock.
  when(io.slot || busyReg) {
    when(io.slot && io.writeM1) {
      firstOperand := io.in1
    }
    when(io.slot && io.writeMach) {
      machReg := io.in1
    }
    when(io.slot && io.writeMacl) {
      maclReg := io.in2
    }

    when(io.slot && !busyReg && io.command =/= J2MultiplyCommand.NOP) {
      busyReg    := True
      commandReg := io.command
      // MAC supplies operand 1 in an earlier WB slot via writeM1.
      operand1 := Mux(io.writeM1, io.in1, firstOperand)
      operand2 := io.in2
      saturate := io.s
      val longCommand = io.command === J2MultiplyCommand.DMULSL ||
        io.command === J2MultiplyCommand.DMULUL ||
        io.command === J2MultiplyCommand.MULL ||
        io.command === J2MultiplyCommand.MACL
      longCommandReg := longCommand
      remaining      := Mux(longCommand, U(3, 2 bits), U(1, 2 bits))
      when(
        io.command === J2MultiplyCommand.DMULSL ||
          io.command === J2MultiplyCommand.DMULUL
      ) {
        machReg := 0
        maclReg := 0
      } elsewhen (io.command =/= J2MultiplyCommand.MACL && io.command =/= J2MultiplyCommand.MACW) {
        maclReg := 0
      }
    } elsewhen (busyReg) {
      when(longCommandReg) {
        switch(remaining) {
          is(3) {
            p00 := operand1(15 downto 0) * operand2(15 downto 0)
            p01 := aLow * bHigh
            p10 := aHigh * bLow
            p11 := aHigh * bHigh
          }
          is(2) {
            cross := p01.resize(35) + p10.resize(35)
            base  := Cat(p11(31 downto 0), p00).asUInt
          }
          is(1) {
            product := base + (cross.resize(64).asUInt << 16).resize(64)
          }
        }
      } elsewhen (remaining === 1) {
        product := (aWord * bWord).resize(64).asUInt
      }
      when(remaining === 0) {
        busyReg    := False
        commandReg := J2MultiplyCommand.NOP
        switch(commandReg) {
          is(J2MultiplyCommand.DMULSL, J2MultiplyCommand.DMULUL) {
            machReg := product(63 downto 32)
            maclReg := product(31 downto 0)
          }
          is(J2MultiplyCommand.MULL, J2MultiplyCommand.MULSW, J2MultiplyCommand.MULUW) {
            maclReg := product(31 downto 0)
          }
          is(J2MultiplyCommand.MACL) {
            when(saturate && maclSaturationRequired) {
              when(maclPositiveSaturation) {
                machReg := 0x00007fffL
                maclReg := 0xffffffffL
              } otherwise {
                machReg := 0xffff8000L
                maclReg := 0
              }
            } otherwise {
              machReg := sum(63 downto 32)
              maclReg := sum(31 downto 0)
            }
          }
          is(J2MultiplyCommand.MACW) {
            when(saturate && macwSaturationRequired) {
              machReg := machReg | U(1, 32 bits)
              maclReg := Mux(macwNegativeOverflow, U(0x80000000L, 32 bits), U(0x7fffffffL, 32 bits))
            } otherwise {
              when(!saturate)(machReg := sum(63 downto 32))
              maclReg := sum(31 downto 0)
            }
          }
          default {}
        }
      } otherwise {
        remaining := remaining - 1
      }
    }
  }

  when(ClockDomain.current.isResetActive) {
    busyReg      := False
    remaining    := 0
    commandReg   := J2MultiplyCommand.NOP
    firstOperand := 0
    operand1     := 0
    operand2     := 0
    saturate     := False
    machReg      := 0
    maclReg      := 0
  }
}
