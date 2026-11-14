package j2.core

import spinal.core._

final class J2Multiply extends Component {
  val io = new Bundle {
    val slot = in Bool ()
    val command = in(J2MultiplyCommand())
    val in1 = in UInt (32 bits)
    val in2 = in UInt (32 bits)
    val s = in Bool ()
    val writeM1 = in Bool ()
    val writeMach = in Bool ()
    val writeMacl = in Bool ()
    val busy = out Bool ()
    val mach = out UInt (32 bits)
    val macl = out UInt (32 bits)
  }

  private val busyReg = RegInit(False)
  private val remaining = RegInit(U(0, 2 bits))
  private val commandReg = RegInit(J2MultiplyCommand.NOP)
  private val firstOperand = RegInit(U(0, 32 bits))
  private val operand1 = RegInit(U(0, 32 bits))
  private val operand2 = RegInit(U(0, 32 bits))
  private val saturate = RegInit(False)
  private val machReg = RegInit(U(0, 32 bits))
  private val maclReg = RegInit(U(0, 32 bits))

  private val signedProduct = (operand1.asSInt * operand2.asSInt).resize(64).asUInt
  private val unsignedProduct = (operand1 * operand2).resize(64)
  private val signedProduct16 =
    (operand1(15 downto 0).asSInt * operand2(15 downto 0).asSInt).resize(64).asUInt
  private val unsignedProduct16 = (operand1(15 downto 0) * operand2(15 downto 0)).resize(64)
  private val product = commandReg.mux(
    J2MultiplyCommand.DMULSL -> signedProduct,
    J2MultiplyCommand.MULL -> signedProduct,
    J2MultiplyCommand.MACL -> signedProduct,
    J2MultiplyCommand.MULSW -> signedProduct16,
    J2MultiplyCommand.MACW -> signedProduct16,
    J2MultiplyCommand.MULUW -> unsignedProduct16,
    default -> unsignedProduct
  )
  private val accumulator = Cat(machReg, maclReg).asUInt
  private val sum = accumulator + product

  private val macwPositiveOverflow = !maclReg(31) && !product(31) && sum(31)
  private val macwNegativeOverflow = maclReg(31) && product(31) && !sum(31)
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
      busyReg := True
      commandReg := io.command
      // MAC supplies operand 1 in an earlier WB slot via writeM1.
      operand1 := Mux(io.writeM1, io.in1, firstOperand)
      operand2 := io.in2
      saturate := io.s
      val longCommand = io.command === J2MultiplyCommand.DMULSL ||
        io.command === J2MultiplyCommand.DMULUL ||
        io.command === J2MultiplyCommand.MULL ||
        io.command === J2MultiplyCommand.MACL
      remaining := Mux(longCommand, U(2, 2 bits), U(0, 2 bits))
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
      when(remaining === 0) {
        busyReg := False
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
              when(!saturate) { machReg := sum(63 downto 32) }
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
    busyReg := False
    remaining := 0
    commandReg := J2MultiplyCommand.NOP
    firstOperand := 0
    operand1 := 0
    operand2 := 0
    saturate := False
    machReg := 0
    maclReg := 0
  }
}
