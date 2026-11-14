package j2.core

import spinal.core._
import spinal.lib._

final class J2Event extends Bundle {
  val command = UInt(2 bits)
  val vector = UInt(8 bits)
  val level = UInt(4 bits)
  val bypassMask = Bool()
}

object J2AluXSelect extends SpinalEnum {
  val XBUS, FC, ROTCL, ZERO = newElement()
}

object J2AluYSelect extends SpinalEnum {
  val YBUS, IMM, R0 = newElement()
}

object J2AluManip extends SpinalEnum {
  val SET_BIT_7, EXTEND_SBYTE, EXTEND_SWORD, EXTEND_UBYTE, EXTEND_UWORD, EXTRACT, SWAP_WORD,
      SWAP_BYTE = newElement()
}

object J2ArithFunc extends SpinalEnum {
  val ADD, SUB = newElement()
}

object J2ArithSrFunc extends SpinalEnum {
  val ZERO, OVERUNDERFLOW, UGRTER, UGRTER_EQ, SGRTER_EQ, SGRTER, DIV1, DIV0S = newElement()
}

object J2LogicFunc extends SpinalEnum {
  val LOGIC_OR, LOGIC_XOR, LOGIC_AND, LOGIC_NOT = newElement()
}

object J2LogicSrFunc extends SpinalEnum {
  val ZERO, BYTE_EQ = newElement()
}

object J2ShiftFunc extends SpinalEnum {
  val LOGIC, ARITH, ROTC, ROTATE = newElement()
}

object J2MemSize extends SpinalEnum {
  val BYTE, WORD, LONG = newElement()
}

object J2XBusSelect extends SpinalEnum {
  val IMM, REG, PC = newElement()
}

object J2YBusSelect extends SpinalEnum {
  val IMM, REG, MACH, MACL, PC, SR = newElement()
}

object J2ZBusSelect extends SpinalEnum {
  val ARITH, LOGIC, SHIFT, MANIP, YBUS, WBUS = newElement()
}

object J2MemAddrSelect extends SpinalEnum {
  val XBUS, YBUS, ZBUS = newElement()
}

object J2MemWdataSelect extends SpinalEnum {
  val ZBUS, YBUS = newElement()
}

object J2MacSelect1 extends SpinalEnum {
  val XBUS, ZBUS, WBUS = newElement()
}

object J2MacSelect2 extends SpinalEnum {
  val YBUS, ZBUS, WBUS = newElement()
}

object J2SrSelect extends SpinalEnum {
  val PREV, WBUS, ZBUS, DIV0U, ARITH, LOGIC, INT_MASK, SET_T = newElement()
}

object J2TSelect extends SpinalEnum {
  val CLEAR, SET, SHIFT, CARRY = newElement()
}

object J2MultiplyCommand extends SpinalEnum {
  val NOP, DMULSL, DMULUL, MACL, MACW, MULL, MULSW, MULUW = newElement()
}

final class J2ExControl extends Bundle {
  val immediate = UInt(32 bits)
  val xSelect = J2XBusSelect()
  val ySelect = J2YBusSelect()
  val regZ = UInt(5 bits)
  val regX = UInt(5 bits)
  val regY = UInt(5 bits)
  val manip = J2AluManip()
  val aluX = J2AluXSelect()
  val aluY = J2AluYSelect()
  val arithFunc = J2ArithFunc()
  val arithCarry = Bool()
  val arithSr = J2ArithSrFunc()
  val logicFunc = J2LogicFunc()
  val logicSr = J2LogicSrFunc()
  val macBusy = Bool()
  val memoryWrite = Bool()
  val memoryLock = Bool()
  val memorySize = J2MemSize()
}

final class J2ExStallControl extends Bundle {
  val pcWriteZ = Bool()
  val srWriteZ = Bool()
  val memoryIssue = Bool()
  val prWritePc = Bool()
  val zSelect = J2ZBusSelect()
  val srSelect = J2SrSelect()
  val tSelect = J2TSelect()
  val memoryAddress = J2MemAddrSelect()
  val memoryWriteData = J2MemWdataSelect()
  val regWriteZ = Bool()
  val machWrite = Bool()
  val maclWrite = Bool()
  val shift = J2ShiftFunc()
  val multiplyStart = Bool()
  val multiplyCommand = J2MultiplyCommand()
  val macSelect1 = J2MacSelect1()
  val macSelect2 = J2MacSelect2()
}

final class J2WbControl extends Bundle {
  val regW = UInt(5 bits)
  val macBusy = Bool()
}

final class J2WbStallControl extends Bundle {
  val multiplyStart = Bool()
  val machWrite = Bool()
  val maclWrite = Bool()
  val regWriteW = Bool()
  val srWriteW = Bool()
  val macSelect1 = J2MacSelect1()
  val macSelect2 = J2MacSelect2()
  val multiplyCommand = J2MultiplyCommand()
}

final class J2IdControl extends Bundle {
  val incrementPc = Bool()
  val instructionIssue = Bool()
  val instructionAddress = Bool()
}

final class J2MicrocodeControl extends Bundle {
  val ex = new J2ExControl
  val exStall = new J2ExStallControl
  val wb = new J2WbControl
  val wbStall = new J2WbStallControl
  val id = new J2IdControl
  val sleep = Bool()
  val maskInterruptNext = Bool()
  val macStallSense = Bool()
  val macSLatch = Bool()
  val interruptLevelCapture = Bool()
  val eventAcknowledge = Bool()
  val dispatch = Bool()
  val delayJump = Bool()
  val debug = Bool()
}
