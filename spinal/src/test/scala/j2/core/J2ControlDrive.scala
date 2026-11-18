package j2.core

import spinal.core._
import spinal.core.sim._

object J2ControlDrive {
  def ex(value: J2ExControl): Unit = {
    value.immediate   #= 0
    value.xSelect     #= J2XBusSelect.IMM
    value.ySelect     #= J2YBusSelect.IMM
    value.regZ        #= 0
    value.regX        #= 0
    value.regY        #= 0
    value.manip       #= J2AluManip.SWAP_BYTE
    value.aluX        #= J2AluXSelect.XBUS
    value.aluY        #= J2AluYSelect.YBUS
    value.arithFunc   #= J2ArithFunc.ADD
    value.arithCarry  #= false
    value.arithSr     #= J2ArithSrFunc.ZERO
    value.logicFunc   #= J2LogicFunc.LOGIC_NOT
    value.logicSr     #= J2LogicSrFunc.ZERO
    value.macBusy     #= false
    value.memoryWrite #= false
    value.memoryLock  #= false
    value.memorySize  #= J2MemSize.BYTE
  }

  def exStall(value: J2ExStallControl): Unit = {
    value.pcWriteZ        #= false
    value.srWriteZ        #= false
    value.memoryIssue     #= false
    value.prWritePc       #= false
    value.zSelect         #= J2ZBusSelect.ARITH
    value.srSelect        #= J2SrSelect.PREV
    value.tSelect         #= J2TSelect.CLEAR
    value.memoryAddress   #= J2MemAddrSelect.XBUS
    value.memoryWriteData #= J2MemWdataSelect.ZBUS
    value.regWriteZ       #= false
    value.machWrite       #= false
    value.maclWrite       #= false
    value.shift           #= J2ShiftFunc.LOGIC
    value.multiplyStart   #= false
    value.multiplyCommand #= J2MultiplyCommand.NOP
    value.macSelect1      #= J2MacSelect1.XBUS
    value.macSelect2      #= J2MacSelect2.YBUS
  }

  def wb(value: J2WbControl): Unit = {
    value.regW    #= 0
    value.macBusy #= false
  }

  def wbStall(value: J2WbStallControl): Unit = {
    value.multiplyStart   #= false
    value.machWrite       #= false
    value.maclWrite       #= false
    value.regWriteW       #= false
    value.srWriteW        #= false
    value.macSelect1      #= J2MacSelect1.XBUS
    value.macSelect2      #= J2MacSelect2.YBUS
    value.multiplyCommand #= J2MultiplyCommand.NOP
  }

  def memoryRequest(value: J2MemoryRequest): Unit = {
    value.address #= 0
    value.data    #= 0
    value.write   #= false
    value.size    #= J2MemSize.BYTE
  }

  def state(value: J2PipelineState): Unit = {
    memoryRequest(value.maRequest)
    for (metadata <- Seq(value.exMetadata, value.maMetadata, value.wbMetadata)) {
      metadata.pc       #= 0
      metadata.resumePc #= 0
    }
    ex(value.ex)
    exStall(value.exAction)
    wb(value.exWriteback)
    wb(value.ma)
    wb(value.wb)
    wbStall(value.exWritebackAction)
    wbStall(value.maAction)
    wbStall(value.wbAction)
  }
}
