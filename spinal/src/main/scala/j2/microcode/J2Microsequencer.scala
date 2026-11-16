package j2.microcode

import j2.core.J2IdControl
import spinal.core._

final class J2Operation extends Bundle {
  val system  = Bool()
  val code    = UInt(16 bits)
  val address = UInt(8 bits)
}

final class J2Microsequencer extends Component {
  val io = new Bundle {
    val slot                  = in Bool ()
    val dispatch              = in Bool ()
    val delayJump             = in Bool ()
    val eventAcknowledge      = in Bool ()
    val instruction           = in UInt (16 bits)
    val predecodeAddress      = in UInt (8 bits)
    val illegalInstruction    = in Bool ()
    val illegalDelaySlot      = in Bool ()
    val instructionStall      = in Bool ()
    val registerConflict      = in Bool ()
    val macStall              = in Bool ()
    val interruptBits         = in UInt (4 bits)
    val interruptLevelCapture = in Bool ()
    val maskInterruptNext     = in Bool ()
    val enterDebug            = in Bool ()
    val debug                 = in Bool ()
    val eventValid            = in Bool ()
    val eventCommand          = in UInt (2 bits)
    val eventVector           = in UInt (8 bits)
    val eventLevel            = in UInt (4 bits)
    val eventBypassMask       = in Bool ()
    val id                    = in(new J2IdControl)

    val operation          = out(new J2Operation)
    val eventAck           = out Bool ()
    val instructionIssue   = out Bool ()
    val instructionAddress = out Bool ()
    val interruptLevel     = out UInt (4 bits)
    val incrementPc        = out Bool ()
    val nextIdStall        = out Bool ()
    val maskInterrupt      = out Bool ()
    val delaySlot          = out Bool ()
    val startInstruction   = out Bool ()
  }

  private val maskInterruptReg        = RegInit(False)
  private val delaySlotReg            = RegInit(False)
  private val idStall                 = RegInit(False)
  private val instructionSequenceZero = RegInit(False)
  private val interruptLevelReg       = RegInit(U(0, 4 bits))
  private val operationReg            = Reg(new J2Operation)
  operationReg.system init True
  operationReg.code init 0x0300
  operationReg.address init 0xda

  private val normalOperation = new J2Operation
  normalOperation.system  := False
  normalOperation.code    := io.instruction
  normalOperation.address := io.predecodeAddress

  private val nextOperation = new J2Operation
  nextOperation := normalOperation

  private def setSystemOperation(code: UInt, address: UInt): Unit = {
    nextOperation.system  := True
    nextOperation.code    := code.resize(16)
    nextOperation.address := address
  }

  private val interruptAccepted =
    !maskInterruptReg && ((io.interruptBits < io.eventLevel) || io.eventBypassMask)
  private val eventAccepted =
    !delaySlotReg && io.eventValid &&
      ((io.eventCommand === 0 && interruptAccepted) || io.eventCommand =/= 0)

  when(eventAccepted) {
    val systemCode = io.eventCommand.mux(
      0 -> U(0, 4 bits),
      1 -> U(1, 4 bits),
      2 -> U(2, 4 bits),
      3 -> U(3, 4 bits)
    )
    val address = io.eventCommand.mux(
      0 -> U(0xe0, 8 bits),
      1 -> U(0xe9, 8 bits),
      2 -> U(0xf2, 8 bits),
      3 -> U(0xd9, 8 bits)
    )
    setSystemOperation(Cat(U(0, 4 bits), systemCode, io.eventVector).asUInt, address)
  } elsewhen (delaySlotReg && (io.illegalDelaySlot || io.illegalInstruction)) {
    // The vector-fetch microstep uses code[7:0] as the vector number.
    setSystemOperation(0x0606, 0xd1)
  } elsewhen (io.illegalInstruction) {
    setSystemOperation(0x0704, 0xc9)
  } elsewhen (!delaySlotReg && io.enterDebug) {
    setSystemOperation(0x0200, 0xf2)
  }

  io.nextIdStall        := io.registerConflict || io.instructionStall || io.macStall
  io.incrementPc        := io.id.incrementPc && !io.nextIdStall
  io.instructionIssue   := io.id.instructionIssue && !io.registerConflict && !io.macStall
  io.instructionAddress := io.id.instructionAddress
  io.maskInterrupt      := maskInterruptReg
  io.delaySlot          := delaySlotReg
  // Capture metadata when selecting the instruction, even if its first
  // microstep stalls. On retry idStall selects operationReg, not nextOperation.
  io.startInstruction := !idStall && instructionSequenceZero && !nextOperation.system
  io.interruptLevel   := interruptLevelReg
  io.eventAck := io.slot &&
    (io.eventAcknowledge || (io.eventValid && io.eventCommand === 2 && io.debug))

  private val selectedOperation = new J2Operation
  selectedOperation := operationReg
  when(!idStall && instructionSequenceZero) {
    selectedOperation := nextOperation
  }

  private val advancedOperation = new J2Operation
  advancedOperation := selectedOperation
  when(!io.nextIdStall) {
    advancedOperation.address := selectedOperation.address + 1
  }

  when(io.slot) {
    maskInterruptReg := io.maskInterruptNext
    when(io.interruptLevelCapture) {
      interruptLevelReg := io.eventLevel
    }
    operationReg := advancedOperation
    idStall      := io.nextIdStall
    when(!io.nextIdStall) {
      delaySlotReg            := io.delayJump
      instructionSequenceZero := io.dispatch
    }
  }

  when(idStall || !instructionSequenceZero) {
    io.operation := operationReg
  } otherwise {
    io.operation := nextOperation
  }

  when(ClockDomain.current.isResetActive) {
    maskInterruptReg        := False
    delaySlotReg            := False
    idStall                 := False
    instructionSequenceZero := False
    interruptLevelReg       := 0
    operationReg.system     := True
    operationReg.code       := 0x0300
    operationReg.address    := 0xda
  }
}
