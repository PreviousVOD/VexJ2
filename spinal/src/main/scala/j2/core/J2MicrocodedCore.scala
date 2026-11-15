package j2.core

import j2.bus.J2Wishbone
import j2.isa.J2Predecoder
import j2.microcode._
import spinal.core._
import spinal.lib._

final class J2MicrocodedCore(
    val useEg4Rom: Boolean = false,
    val exposeDebug: Boolean = true
) extends Component {
  val io = new Bundle {
    val ibus = master(J2Wishbone())
    val dbus = master(J2Wishbone())
    val event = slave(Stream(new J2Event))
    val eventAck = out Bool ()
    val pc = if (exposeDebug) out UInt (32 bits) else null
    val sr = if (exposeDebug) out UInt (32 bits) else null
    val sleep = if (exposeDebug) out Bool () else null
    val retired = if (exposeDebug) out Bool () else null
    val illegal = if (exposeDebug) out Bool () else null
    val debugBreak = if (exposeDebug) out Bool () else null
    val debugState = if (exposeDebug) out UInt (3 bits) else null
    val debugOpcode = if (exposeDebug) out UInt (16 bits) else null
    val debugSlotIllegal = if (exposeDebug) out Bool () else null
    val debugEventPending = if (exposeDebug) out Bool () else null
  }

  private val sequencer = new J2Microsequencer
  private val rom: J2MicrocodeRomPort =
    if (useEg4Rom) new Eg4MicrocodeRom else new J2MicrocodeRom
  private val table = new J2MicrocodeTable
  private val pipeline = new J2Pipeline
  private val hazards = new J2Hazards
  private val registers = new J2PipelineRegFile
  private val datapath = new J2Datapath
  private val multiply = new J2Multiply
  private val predecoder = new J2Predecoder

  private val pcReg = RegInit(U(0, 32 bits))
  private val status = Reg(new J2Status)
  private val nextStatus = new J2Status
  nextStatus := status
  private val macS = RegInit(False)
  private val slot = RegInit(False)
  private val sleeping = RegInit(False)
  // Data faults cancel younger EX/WB1 work. Fetch faults stay attached to the
  // prefetched opcode so the preceding instruction (including a branch) drains.
  private val faultPending = RegInit(False)
  private val dataFaultPc = RegInit(U(0, 32 bits))
  private val fetchFaultPc = RegInit(U(0, 32 bits))
  private val instructionPc = RegInit(U(0, 32 bits))
  private val operationResumePc = RegInit(U(0, 32 bits))
  private val executeResumePc = RegInit(U(0, 32 bits))
  private val faultInService = RegInit(False)
  private val faultHalted = RegInit(False)
  private val instructionFault = RegInit(False)
  private val instructionFaultNext = RegInit(False)
  private val dataReadValid = RegInit(True)
  private val dataReadNextValid = RegInit(True)
  private val internalFault = faultPending || instructionFault
  private val wakeEvent = io.event.valid &&
    (io.event.payload.command =/= 0 ||
      (!sequencer.io.maskInterrupt &&
        (io.event.payload.bypassMask || io.event.payload.level > status.interruptMask)))

  private val instruction = RegInit(U(0, 16 bits))
  private val instructionNext = RegInit(U(0, 16 bits))
  private val instructionPending = RegInit(False)
  private val instructionActive = RegInit(False)
  private val instructionAddress = RegInit(U(0, 32 bits))

  private val dataRead = RegInit(U(0, 32 bits))
  private val dataReadNext = RegInit(U(0, 32 bits))
  private val dataPending = RegInit(False)
  private val dataActive = RegInit(False)
  private val dataLock = RegInit(False)
  private val dataAddress = RegInit(U(0, 32 bits))
  private val dataWrite = RegInit(False)
  private val dataWriteData = RegInit(U(0, 32 bits))
  private val dataSize = RegInit(J2MemSize.BYTE)

  rom.io.clk := clockDomain.readClockWire
  rom.io.address := sequencer.io.operation.address
  table.io.line := rom.io.line
  table.io.opcode := sequencer.io.operation.code
  // Branch decode must see the T result produced by the current EX slot.
  table.io.tBcc := nextStatus.t
  table.io.nextIdStall := sequencer.io.nextIdStall

  pipeline.io.slot := slot
  pipeline.io.cancelWb1 := faultPending
  pipeline.io.nextIdStall := sequencer.io.nextIdStall
  pipeline.io.ex := table.io.control.ex
  pipeline.io.exStall := table.io.control.exStall
  pipeline.io.wb := table.io.control.wb
  pipeline.io.wbStall := table.io.control.wbStall

  hazards.io.ex := table.io.control.ex
  hazards.io.exStall := table.io.control.exStall
  hazards.io.state := pipeline.io.state
  hazards.io.macStallSense := table.io.control.macStallSense
  hazards.io.macBusy := multiply.io.busy

  predecoder.io.instruction := instruction

  sequencer.io.slot := slot
  sequencer.io.dispatch := table.io.control.dispatch
  sequencer.io.delayJump := table.io.control.delayJump
  sequencer.io.eventAcknowledge := table.io.control.eventAcknowledge
  sequencer.io.instruction := instruction
  sequencer.io.predecodeAddress := predecoder.io.address
  sequencer.io.illegalInstruction := !predecoder.io.legal && !instructionActive
  sequencer.io.illegalDelaySlot := predecoder.io.delaySlotIllegal && !instructionActive
  sequencer.io.instructionStall := False
  sequencer.io.registerConflict := hazards.io.registerConflict
  sequencer.io.macStall := hazards.io.macStall
  sequencer.io.interruptBits := status.interruptMask
  sequencer.io.interruptLevelCapture := table.io.control.interruptLevelCapture
  sequencer.io.maskInterruptNext := table.io.control.maskInterruptNext
  sequencer.io.enterDebug := False
  sequencer.io.debug := table.io.control.debug
  sequencer.io.eventValid := io.event.valid || internalFault
  sequencer.io.eventCommand := Mux(internalFault, U(1, 2 bits), io.event.payload.command)
  sequencer.io.eventVector := Mux(internalFault, U(9, 8 bits), io.event.payload.vector)
  sequencer.io.eventLevel := io.event.payload.level
  sequencer.io.eventBypassMask := io.event.payload.bypassMask
  sequencer.io.id := table.io.control.id

  io.event.ready := sequencer.io.eventAck && !internalFault && !faultInService
  io.eventAck := io.event.ready

  registers.io.slot := slot
  registers.io.readX := pipeline.io.state.ex1.regX
  registers.io.readY := pipeline.io.state.ex1.regY
  registers.io.writeW.enable := pipeline.io.state.wb3Stall.regWriteW && dataReadValid
  registers.io.writeW.address := pipeline.io.state.wb3.regW
  registers.io.writeW.data := dataRead
  registers.io.writeZ.enable := pipeline.io.state.ex1Stall.regWriteZ && !faultPending &&
    (pipeline.io.state.ex1Stall.zSelect =/= J2ZBusSelect.WBUS || dataReadValid)
  registers.io.writeZ.address := pipeline.io.state.ex1.regZ
  registers.io.writeZ.data := Mux(
    pipeline.io.state.ex1Stall.prWritePc,
    pcReg,
    datapath.io.zbus
  )

  datapath.io.ex := pipeline.io.state.ex1
  datapath.io.exStall := pipeline.io.state.ex1Stall
  datapath.io.regX := registers.io.x
  datapath.io.regY := registers.io.y
  datapath.io.reg0 := registers.io.r0
  datapath.io.pc := pcReg
  datapath.io.sr := status
  datapath.io.mach := multiply.io.mach
  datapath.io.macl := multiply.io.macl
  datapath.io.wbus := dataRead
  datapath.io.yOverrideEnable := False
  datapath.io.yOverride := 0

  private val multiplyUseEx1 =
    !faultPending && (pipeline.io.state.ex1Stall.multiplyStart || pipeline.io.state.ex1Stall.machWrite)
  private val multiplyUseEx2 =
    !faultPending && (pipeline.io.state.ex1Stall.multiplyCommand =/= J2MultiplyCommand.NOP ||
      pipeline.io.state.ex1Stall.maclWrite)
  private val multiplySelect1 = Mux(
    multiplyUseEx1,
    pipeline.io.state.ex1Stall.macSelect1,
    pipeline.io.state.wb3Stall.macSelect1
  )
  private val multiplySelect2 = Mux(
    multiplyUseEx2,
    pipeline.io.state.ex1Stall.macSelect2,
    pipeline.io.state.wb3Stall.macSelect2
  )

  multiply.io.slot := slot
  multiply.io.command := Mux(
    !faultPending && pipeline.io.state.ex1Stall.multiplyCommand =/= J2MultiplyCommand.NOP,
    pipeline.io.state.ex1Stall.multiplyCommand,
    Mux(dataReadValid, pipeline.io.state.wb3Stall.multiplyCommand, J2MultiplyCommand.NOP)
  )
  multiply.io.in1 := multiplySelect1.mux(
    J2MacSelect1.XBUS -> datapath.io.xbus,
    J2MacSelect1.ZBUS -> datapath.io.zbus,
    J2MacSelect1.WBUS -> dataRead
  )
  multiply.io.in2 := multiplySelect2.mux(
    J2MacSelect2.YBUS -> datapath.io.ybus,
    J2MacSelect2.ZBUS -> datapath.io.zbus,
    J2MacSelect2.WBUS -> dataRead
  )
  multiply.io.s := macS
  multiply.io.writeM1 := (!faultPending && pipeline.io.state.ex1Stall.multiplyStart) ||
    (pipeline.io.state.wb3Stall.multiplyStart && dataReadValid)
  multiply.io.writeMach := (!faultPending && pipeline.io.state.ex1Stall.machWrite) ||
    (pipeline.io.state.wb3Stall.machWrite && dataReadValid)
  multiply.io.writeMacl := (!faultPending && pipeline.io.state.ex1Stall.maclWrite) ||
    (pipeline.io.state.wb3Stall.maclWrite && dataReadValid)

  io.ibus.CYC := instructionActive
  io.ibus.STB := instructionActive
  io.ibus.WE := False
  io.ibus.ADR := instructionAddress
  io.ibus.SEL := B"1111"
  io.ibus.DAT_MOSI := 0
  io.ibus.LOCK := False

  io.dbus.CYC := dataActive || dataLock
  io.dbus.STB := dataActive
  io.dbus.WE := dataWrite
  io.dbus.ADR := dataAddress
  io.dbus.DAT_MOSI := dataSize.mux(
    J2MemSize.BYTE -> Cat(
      dataWriteData(7 downto 0),
      dataWriteData(7 downto 0),
      dataWriteData(7 downto 0),
      dataWriteData(7 downto 0)
    ).asBits,
    J2MemSize.WORD -> Cat(dataWriteData(15 downto 0), dataWriteData(15 downto 0)).asBits,
    J2MemSize.LONG -> dataWriteData.asBits
  )
  io.dbus.LOCK := dataLock
  io.dbus.SEL := dataSize.mux(
    J2MemSize.BYTE -> (U(8, 4 bits) >> dataAddress(1 downto 0)).asBits,
    J2MemSize.WORD -> Mux(dataAddress(1), B"0011", B"1100"),
    J2MemSize.LONG -> B"1111"
  )

  private def alignReadData(value: UInt): UInt = {
    val byte = dataAddress(1 downto 0).mux(
      0 -> value(31 downto 24),
      1 -> value(23 downto 16),
      2 -> value(15 downto 8),
      3 -> value(7 downto 0)
    )
    val word = Mux(dataAddress(1), value(15 downto 0), value(31 downto 16))
    dataSize.mux(
      J2MemSize.BYTE -> byte.asSInt.resize(32).asUInt,
      J2MemSize.WORD -> word.asSInt.resize(32).asUInt,
      J2MemSize.LONG -> value
    )
  }

  // ERR terminates a Wishbone request just like ACK, but must not write back data.
  // ERR wins if a slave incorrectly asserts both responses.
  when(dataActive && (io.dbus.ACK || io.dbus.ERR)) {
    dataReadNextValid := !io.dbus.ERR
    when(io.dbus.ERR) {
      faultPending := True
      when(faultInService)(faultHalted := True)
    }
    dataReadNext := alignReadData(io.dbus.DAT_MISO.asUInt)
    dataPending := True
    dataActive := False
  }
  when(instructionActive && (io.ibus.ACK || io.ibus.ERR)) {
    instructionFaultNext := io.ibus.ERR
    when(io.ibus.ERR && faultInService)(faultHalted := True)
    instructionNext := Mux(io.ibus.ERR, U(0x0009, 16 bits), io.ibus.DAT_MISO(15 downto 0).asUInt)
    instructionPending := True
    instructionActive := False
  }

  when(!dataActive && !instructionActive && !sleeping && !faultHalted) {
    slot := True
  } otherwise {
    slot := False
  }

  // The microcode advances PC through the prefetched instruction and delay slot.
  private val sequentialInstructionAddress = pcReg + 2

  private val srSelect = Mux(
    pipeline.io.state.wb3Stall.srWriteW && dataReadValid,
    J2SrSelect.WBUS,
    Mux(faultPending, J2SrSelect.PREV, pipeline.io.state.ex1Stall.srSelect)
  )

  switch(srSelect) {
    is(J2SrSelect.WBUS) {
      nextStatus := J2Status.fromUInt(dataRead)
    }
    is(J2SrSelect.ZBUS) {
      nextStatus := J2Status.fromUInt(datapath.io.zbus)
    }
    is(J2SrSelect.DIV0U) {
      nextStatus.m := False
      nextStatus.q := False
      nextStatus.t := False
    }
    is(J2SrSelect.ARITH) {
      nextStatus := datapath.io.arithmeticSr
    }
    is(J2SrSelect.LOGIC) {
      nextStatus := datapath.io.logicSr
    }
    is(J2SrSelect.INT_MASK) {
      nextStatus.interruptMask := sequencer.io.interruptLevel
    }
    is(J2SrSelect.SET_T) {
      switch(pipeline.io.state.ex1Stall.tSelect) {
        is(J2TSelect.CLEAR)(nextStatus.t := False)
        is(J2TSelect.SET)(nextStatus.t := True)
        is(J2TSelect.SHIFT)(nextStatus.t := datapath.io.shiftT)
        is(J2TSelect.CARRY)(nextStatus.t := datapath.io.arithmeticResult(32))
      }
    }
    default {}
  }

  when(slot) {
    // Architectural instruction addresses travel separately from the microcode's
    // speculative PC. All microsteps of an instruction share its resume address.
    val resumePc = Mux(
      sequencer.io.delaySlot,
      Mux(pipeline.io.state.ex1Stall.pcWriteZ, datapath.io.zbus, pcReg),
      instructionPc + 2
    )
    executeResumePc := Mux(sequencer.io.startInstruction, resumePc, operationResumePc)
    when(sequencer.io.startInstruction) {
      operationResumePc := resumePc
      when(instructionFault && sequencer.io.delaySlot)(fetchFaultPc := resumePc)
    }
    // Present the prefetched opcode only as ID advances, preserving the delay slot.
    when(instructionPending) {
      instruction := instructionNext
      instructionPc := instructionAddress
      when(instructionFaultNext) {
        instructionFault := True
        fetchFaultPc := instructionAddress
      }
      instructionPending := False
    }
    // W belongs to the preceding memory slot. Keep it stable while the
    // next transaction completes, then advance it with the WB controls.
    when(dataPending) {
      dataRead := dataReadNext
      dataReadValid := dataReadNextValid
      dataPending := False
    }
    when(pipeline.io.state.ex1Stall.memoryIssue && !dataActive && !faultPending) {
      // Stop at the issuing edge: active is a register, so waiting for it
      // in the completion logic would advance EX/WB one extra slot.
      slot := False
      val misaligned =
        (pipeline.io.state.ex1.memorySize === J2MemSize.WORD && datapath.io.memoryAddress(0)) ||
          (pipeline.io.state.ex1.memorySize === J2MemSize.LONG && datapath.io.memoryAddress(
            1 downto 0
          ) =/= 0)
      dataActive := !misaligned
      when(misaligned) {
        faultPending := True
        dataReadNextValid := False
        dataPending := True
        dataReadNext := 0
        when(faultInService)(faultHalted := True)
      }
      dataFaultPc := executeResumePc
      dataAddress := datapath.io.memoryAddress
      dataWrite := pipeline.io.state.ex1.memoryWrite
      dataWriteData := datapath.io.memoryWriteData
      dataSize := pipeline.io.state.ex1.memorySize
    }
    when(sequencer.io.instructionIssue && !instructionActive) {
      slot := False
      val fetchAddress = Mux(
        sequencer.io.instructionAddress,
        datapath.io.zbus,
        sequentialInstructionAddress
      )
      instructionAddress := fetchAddress
      instructionActive := !fetchAddress(0)
      when(fetchAddress(0)) {
        instructionNext := 0x0009
        instructionFaultNext := True
        instructionPending := True
        when(faultInService)(faultHalted := True)
      }
    }

    when(pipeline.io.state.ex1Stall.pcWriteZ && !faultPending) {
      pcReg := datapath.io.zbus
    } elsewhen (sequencer.io.incrementPc) {
      pcReg := sequentialInstructionAddress
    }

    status := nextStatus

    when(table.io.control.macSLatch) {
      macS := nextStatus.s
    }
    dataLock := pipeline.io.state.ex1.memoryLock
    when(table.io.control.sleep && !wakeEvent && !internalFault) {
      sleeping := True
      slot := False
    }
    when(internalFault && sequencer.io.eventAck) {
      // ERROR microcode subtracts two in its first EX slot. Undo speculative
      // fetch advancement and supply the actual architectural resume address.
      pcReg := Mux(faultPending, dataFaultPc, fetchFaultPc) + 2
      faultPending := False
      instructionFault := False
      faultInService := True
      dataLock := False
    }
    when(faultInService && table.io.control.dispatch) {
      faultInService := False
    }
  }

  when(sleeping && (wakeEvent || internalFault)) {
    sleeping := False
  }
  // A fault during address-error entry cannot be serviced using the same broken
  // stack/vector memory. Quiesce until reset rather than recursively corrupt it.
  when(faultHalted) {
    slot := False
    instructionActive := False
    dataActive := False
    dataLock := False
  }

  if (exposeDebug) {
    io.pc := pcReg
    io.sr := status.asUInt
    io.sleep := sleeping
    io.retired := slot && table.io.control.dispatch
    io.illegal := slot && !predecoder.io.legal
    io.debugBreak := slot && table.io.control.debug
    io.debugState := 0
    io.debugOpcode := instruction
    io.debugSlotIllegal := predecoder.io.delaySlotIllegal
    io.debugEventPending := internalFault
  }

  when(ClockDomain.current.isResetActive) {
    pcReg := 0
    status.t := False
    status.s := False
    status.q := False
    status.m := False
    status.interruptMask := 0xf
    macS := False
    slot := False
    sleeping := False
    faultPending := False
    faultInService := False
    faultHalted := False
    instructionFault := False
    instructionFaultNext := False
    dataReadValid := True
    dataReadNextValid := True
    instruction := 0
    instructionNext := 0
    instructionPending := False
    instructionActive := False
    instructionAddress := 0
    dataRead := 0
    dataReadNext := 0
    dataPending := False
    dataActive := False
    dataLock := False
    dataAddress := 0
    dataWrite := False
    dataWriteData := 0
    dataSize := J2MemSize.BYTE
  }
}
