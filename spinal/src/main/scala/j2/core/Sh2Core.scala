package j2.core

import j2.bus.J2Wishbone
import j2.isa.{Sh2Decoder, Sh2Isa}
import spinal.core._
import spinal.lib._

object Sh2CoreState extends SpinalEnum {
  val resetData, fetch, execute, data, dataGap = newElement()
}

object Sh2DataAction extends SpinalEnum {
  val resetPcRead, resetSpRead, loadByte, loadWord, loadLong, storeByte, storeWord, storeLong,
      tasRead, tasWrite, gbrRead, gbrWrite, macWordFirst, macWordSecond, macLongFirst,
      macLongSecond, casRead, casWrite, exceptionSrWrite, exceptionPcWrite, exceptionVectorRead,
      rtePcRead, rteSrRead = newElement()
}

final class Sh2Event extends Bundle {
  val command = UInt(2 bits)
  val vector = UInt(8 bits)
  val level = UInt(4 bits)
  val bypassMask = Bool()
}

/** Multicycle SH-2 implementation.
  *
  * The core owns one instruction fetch port and one data port. It does not rely on the J2 pipeline:
  * each instruction is fetched, decoded and either completed in the execute cycle or continued
  * through one or more data transactions. This keeps architectural changes independent from the old
  * SystemVerilog microarchitecture while retaining the Wishbone B4 board interface.
  */
final class Sh2Core extends Component {
  import Sh2CoreState._
  import Sh2DataAction._

  val io = new Bundle {
    val ibus = master(J2Wishbone())
    val dbus = master(J2Wishbone())
    val event = slave(Stream(new Sh2Event))
    val eventAck = out Bool ()
    val pc = out UInt (32 bits)
    val sr = out UInt (32 bits)
    val sleep = out Bool ()
    val retired = out Bool ()
    val illegal = out Bool ()
    val debugBreak = out Bool ()
    val debugState = out UInt (3 bits)
    val debugOpcode = out UInt (16 bits)
    val debugSlotIllegal = out Bool ()
    val debugEventPending = out Bool ()
  }

  private val state = RegInit(resetData)
  private val action = RegInit(resetPcRead)
  private val regs = Vec(Reg(UInt(32 bits)) init 0, 16)
  private val pcReg = Reg(UInt(32 bits)) init 0
  private val gbr = Reg(UInt(32 bits)) init 0
  private val vbr = Reg(UInt(32 bits)) init 0
  private val pr = Reg(UInt(32 bits)) init 0
  private val mach = Reg(UInt(32 bits)) init 0
  private val macl = Reg(UInt(32 bits)) init 0
  private val srReg = Reg(UInt(32 bits)) init 0xf0

  private val opcode = Reg(UInt(16 bits)) init 0
  private val opcodePc = Reg(UInt(32 bits)) init 0
  private val inDelaySlot = Reg(Bool()) init False
  private val currentSlot = Reg(Bool()) init False
  private val delayTarget = Reg(UInt(32 bits)) init 0

  private val memAddress = Reg(UInt(32 bits)) init 0
  private val memWriteData = Reg(UInt(32 bits)) init 0
  private val memStageData = Reg(UInt(32 bits)) init 0
  private val exceptionVector = Reg(UInt(8 bits)) init 0
  private val exceptionReturnPc = Reg(UInt(32 bits)) init 0
  private val exceptionStackBase = Reg(UInt(32 bits)) init 0
  private val exceptionAlignedStack = Reg(Bool()) init False
  private val controlTaken = Bool()
  controlTaken := False
  private val eventPending = Reg(Bool()) init False
  private val eventNeedsInstruction = Reg(Bool()) init False
  private val eventBlockNext = Reg(Bool()) init False
  private val pendingEventCommand = Reg(UInt(2 bits)) init 0
  private val pendingEventVector = Reg(UInt(8 bits)) init 0
  private val pendingEventLevel = Reg(UInt(4 bits)) init 0

  private val decoder = new Sh2Decoder
  decoder.io.instruction := opcode.asBits

  private val n = opcode(11 downto 8)
  private val m = opcode(7 downto 4)
  private val disp4 = opcode(3 downto 0)
  private val imm8 = opcode(7 downto 0)
  private val disp12 = opcode(11 downto 0)

  private val readN = regs(n.resize(4))
  private val readM = regs(m.resize(4))
  private val read0 = regs(0)
  private val read15 = regs(15)

  private def writeReg(index: UInt, value: UInt): Unit =
    regs(index.resize(4)) := value.resize(32)

  private def signExtend(value: UInt, width: Int): UInt =
    value.asSInt.resize(32).asUInt

  private val pcRelative = Mux(
    currentSlot,
    delayTarget + 2,
    opcodePc + 4
  ).resize(32)

  private def isPcModifying(code: UInt): Bool =
    ((code(15 downto 12) === 0) && (code(3 downto 2) === 0) && code(0)) ||
      ((code(15 downto 14) === 2) && (code(12 downto 11) === 1) && code(8)) ||
      (code(15 downto 13) === 5) ||
      (code(15) && (code(13 downto 8) === 3)) ||
      (!code(15) && (code(13 downto 12) === 0) && (code(4 downto 0) === 0x0b))

  private def isSrSensitive(code: UInt): Bool =
    (code(15 downto 12) === 0 && (code(7 downto 0) === 0x02) &&
      (code(7 downto 4) === 0)) ||
      (code(15 downto 12) === 4 &&
        (code(7 downto 0) === 0x0e || code(7 downto 0) === 0x07))

  private def finishDefault(): Unit = {
    pcReg := Mux(currentSlot, delayTarget, opcodePc + 2).resize(32)
    inDelaySlot := False
    state := fetch
    io.retired := True
  }

  private def finishDelayed(target: UInt): Unit = {
    pcReg := (opcodePc + 2).resize(32)
    delayTarget := target.resize(32)
    inDelaySlot := True
    state := fetch
    io.retired := True
    controlTaken := True
  }

  private def finishBranch(target: UInt): Unit = {
    pcReg := target.resize(32)
    inDelaySlot := False
    state := fetch
    io.retired := True
    controlTaken := True
  }

  private def startData(nextAction: Sh2DataAction.C, address: UInt): Unit = {
    action := nextAction
    memAddress := address.resize(32)
    state := data
    controlTaken := True
  }

  private def restartData(nextAction: Sh2DataAction.C, address: UInt): Unit = {
    action := nextAction
    memAddress := address.resize(32)
    state := dataGap
  }

  private def startTrap(vector: UInt, returnPc: UInt): Unit = {
    exceptionVector := vector.resize(8)
    exceptionReturnPc := returnPc.resize(32)
    exceptionAlignedStack := False
    memWriteData := srReg
    regs(15) := read15 - 4
    startData(exceptionSrWrite, read15 - 4)
    io.illegal := !decoder.io.legal
  }

  private def startEvent(command: UInt, vector: UInt, level: UInt): Unit =
    when(command === 3) {
      memAddress := 0
      action := resetPcRead
      vbr := 0
      state := data
    } otherwise {
      val stackBase = read15 & 0xfffffffcL
      exceptionVector := vector
      exceptionReturnPc := pcReg
      exceptionStackBase := stackBase
      exceptionAlignedStack := True
      memWriteData := srReg
      regs(15) := stackBase - 4
      when(command === 0) {
        srReg(7 downto 4) := level
      }
      startData(exceptionSrWrite, stackBase - 4)
    }

  private def setT(value: Bool): Unit = srReg(0) := value

  private def setSr(value: UInt): Unit =
    srReg := (value.resize(32) & U(0x3f3, 32 bits))

  private val alignedAddress = memAddress & 0xfffffffcL
  private val byteSelect = (U(8, 4 bits) >> memAddress(1 downto 0)).asBits
  private val wordSelect =
    Mux(memAddress(1), U(3, 4 bits), U(12, 4 bits)).asBits

  private def replicateByte(value: UInt): UInt = {
    val byte = value(7 downto 0)
    Cat(byte, byte, byte, byte).asUInt
  }

  private def replicateWord(value: UInt): UInt = {
    val word = value(15 downto 0)
    Cat(word, word).asUInt
  }

  private def extractedByte(value: UInt, address: UInt): UInt =
    Mux(
      address(1 downto 0) === 3,
      value(7 downto 0),
      Mux(
        address(1 downto 0) === 2,
        value(15 downto 8),
        Mux(address(1 downto 0) === 1, value(23 downto 16), value(31 downto 24))
      )
    )

  private def extractedWord(value: UInt, address: UInt): UInt =
    Mux(address(1), value(15 downto 0), value(31 downto 16))

  val dataWrite =
    action === storeByte || action === storeWord || action === storeLong ||
      action === tasWrite || action === gbrWrite || action === exceptionSrWrite ||
      action === exceptionPcWrite || action === casWrite

  val eventAtBoundary = state === fetch && !inDelaySlot
  val incomingEventAcceptable =
    io.event.valid &&
      (io.event.payload.command =/= 0 || io.event.payload.bypassMask ||
        srReg(7 downto 4) < io.event.payload.level)
  val captureEvent =
    eventAtBoundary && !eventPending && incomingEventAcceptable
  val dispatchEvent =
    eventAtBoundary && eventPending && !eventNeedsInstruction && !eventBlockNext

  io.event.ready := captureEvent
  io.eventAck := captureEvent

  io.ibus.CYC := state === fetch && !dispatchEvent
  io.ibus.STB := state === fetch && !dispatchEvent
  io.ibus.WE := False
  io.ibus.ADR := pcReg
  io.ibus.SEL := B"1111"
  io.ibus.DAT_MOSI := B(0, 32 bits)
  io.ibus.LOCK := False

  io.dbus.CYC := state === data
  io.dbus.STB := state === data
  io.dbus.WE := dataWrite
  io.dbus.ADR := alignedAddress
  io.dbus.DAT_MOSI := memWriteData.asBits
  io.dbus.LOCK :=
    action === tasRead || action === tasWrite || action === casRead || action === casWrite
  io.dbus.SEL := B"1111"

  io.pc := pcReg
  io.sr := srReg
  io.sleep := False
  io.retired := False
  io.illegal := False
  io.debugBreak := False
  io.debugState := state.asBits.asUInt
  io.debugOpcode := opcode
  io.debugSlotIllegal := currentSlot && (!decoder.io.legal || isPcModifying(opcode))
  io.debugEventPending := eventPending

  when(state === resetData || state === dataGap) {
    state := data
  }

  when(captureEvent) {
    eventPending := True
    eventNeedsInstruction := True
    pendingEventCommand := io.event.payload.command
    pendingEventVector := io.event.payload.vector
    pendingEventLevel := io.event.payload.level
  }

  when(dispatchEvent) {
    eventPending := False
    eventNeedsInstruction := False
    startEvent(pendingEventCommand, pendingEventVector, pendingEventLevel)
  }

  switch(action) {
    is(loadByte, storeByte, tasRead, tasWrite, gbrRead, gbrWrite) {
      io.dbus.SEL := byteSelect
      when(action === storeByte) {
        io.dbus.DAT_MOSI := replicateByte(memWriteData).asBits
      } elsewhen (action === tasWrite) {
        io.dbus.DAT_MOSI := replicateByte(memWriteData).asBits
      } elsewhen (action === gbrWrite) {
        io.dbus.DAT_MOSI := replicateByte(memWriteData).asBits
      }
    }
    is(loadWord, storeWord, macWordFirst, macWordSecond) {
      io.dbus.SEL := wordSelect
      when(action === storeWord) {
        io.dbus.DAT_MOSI := replicateWord(memWriteData).asBits
      }
    }
    default {
      io.dbus.SEL := B"1111"
    }
  }

  when(state === fetch && io.ibus.ACK && !dispatchEvent) {
    opcode := io.ibus.DAT_MISO(15 downto 0).asUInt
    opcodePc := pcReg
    currentSlot := inDelaySlot
    inDelaySlot := False
    eventNeedsInstruction := False
    eventBlockNext := False
    state := execute
  }

  when(state === data && io.dbus.ACK) {
    memStageData := io.dbus.DAT_MISO.asUInt

    switch(action) {
      is(resetPcRead) {
        memStageData := io.dbus.DAT_MISO.asUInt
        action := resetSpRead
        memAddress := 4
      }
      is(resetSpRead) {
        pcReg := memStageData
        regs(15) := io.dbus.DAT_MISO.asUInt
        vbr := 0
        inDelaySlot := False
        currentSlot := False
        state := fetch
      }
      is(loadByte) {
        val value = signExtend(extractedByte(io.dbus.DAT_MISO.asUInt, memAddress), 8)
        val implicitR0 =
          (opcode(15 downto 12) === 8 && (n === 4 || n === 5)) ||
            (opcode(15 downto 12) === 0xc && n >= 4 && n <= 6)
        when(implicitR0) {
          writeReg(0, value)
        } otherwise {
          writeReg(n, value)
        }
        finishDefault()
      }
      is(loadWord) {
        val value = signExtend(extractedWord(io.dbus.DAT_MISO.asUInt, memAddress), 16)
        val implicitR0 =
          (opcode(15 downto 12) === 8 && (n === 4 || n === 5)) ||
            (opcode(15 downto 12) === 0xc && n >= 4 && n <= 6)
        when(implicitR0) {
          writeReg(0, value)
        } otherwise {
          writeReg(n, value)
        }
        finishDefault()
      }
      is(loadLong) {
        val loaded = io.dbus.DAT_MISO.asUInt
        when(opcode(15 downto 12) === 4) {
          switch(opcode(7 downto 0)) {
            is(0x06)(mach := loaded)
            is(0x07)(setSr(loaded))
            is(0x16)(macl := loaded)
            is(0x17)(gbr := loaded)
            is(0x26)(pr := loaded)
            is(0x27)(vbr := loaded)
            default(writeReg(n, loaded))
          }
        } otherwise {
          when(opcode(15 downto 12) === 0xc && n === 6) {
            writeReg(0, loaded)
          } otherwise
            writeReg(n, loaded)
        }
        finishDefault()
      }
      is(storeByte, storeWord, storeLong) {
        finishDefault()
      }
      is(tasRead) {
        val byte = extractedByte(io.dbus.DAT_MISO.asUInt, memAddress)
        setT(byte === 0)
        memWriteData := (byte | U(0x80, 8 bits)).resize(32)
        action := tasWrite
        state := dataGap
      }
      is(tasWrite) {
        finishDefault()
      }
      is(casRead) {
        val loaded = io.dbus.DAT_MISO.asUInt
        val compareValue = Mux(n === m, loaded, readM)
        writeReg(n, loaded)
        setT(loaded === compareValue)
        when(loaded === compareValue) {
          action := casWrite
          state := dataGap
        } otherwise
          finishDefault()
      }
      is(casWrite) {
        finishDefault()
      }
      is(gbrRead) {
        val byte = extractedByte(io.dbus.DAT_MISO.asUInt, memAddress)
        switch(n) {
          is(0xc) {
            setT((byte & imm8) === 0)
            finishDefault()
          }
          is(0xd, 0xe, 0xf) {
            val result = UInt(8 bits)
            switch(n) {
              is(0xd)(result := byte & imm8)
              is(0xe)(result := byte ^ imm8)
              default(result := byte | imm8)
            }
            memWriteData := result.resize(32)
            action := gbrWrite
            state := dataGap
          }
          default {
            finishDefault()
          }
        }
      }
      is(gbrWrite) {
        finishDefault()
      }
      is(macWordFirst) {
        memStageData := signExtend(extractedWord(io.dbus.DAT_MISO.asUInt, memAddress), 16)
        writeReg(n, readN + 2)
        restartData(macWordSecond, Mux(n === m, readM + 2, readM))
      }
      is(macWordSecond) {
        writeReg(m, readM + 2)
        val left = memStageData.asSInt
        val right = signExtend(extractedWord(io.dbus.DAT_MISO.asUInt, memAddress), 16).asSInt
        val product = left * right
        when(srReg(1)) {
          val sum = macl.asSInt.resize(33) + product.resize(33)
          when(sum > S(BigInt("7fffffff", 16), 33 bits)) {
            macl := 0x7fffffffL
            mach(0) := True
          } elsewhen (sum < S(BigInt("-80000000", 16), 33 bits)) {
            macl := 0x80000000L
            mach(0) := True
          } otherwise {
            macl := sum(31 downto 0).asUInt
          }
        } otherwise {
          val accumulator = Cat(mach, macl).asSInt + product.resize(64)
          mach := accumulator(63 downto 32).asUInt
          macl := accumulator(31 downto 0).asUInt
        }
        finishDefault()
      }
      is(macLongFirst) {
        memStageData := io.dbus.DAT_MISO.asUInt
        writeReg(n, readN + 4)
        restartData(macLongSecond, Mux(n === m, readM + 4, readM))
      }
      is(macLongSecond) {
        writeReg(m, readM + 4)
        val product =
          memStageData.asSInt * io.dbus.DAT_MISO.asUInt.asSInt
        val accumulator = Cat(mach, macl).asSInt + product
        when(srReg(1)) {
          val wide = accumulator.resize(65)
          when(wide > S(BigInt("7fffffffffff", 16), 65 bits)) {
            mach := U(BigInt("00007fff", 16), 32 bits)
            macl := U(BigInt("ffffffff", 16), 32 bits)
          } elsewhen (wide < S(BigInt("-800000000000", 16), 65 bits)) {
            mach := U(BigInt("ffff8000", 16), 32 bits)
            macl := 0
          } otherwise {
            mach := wide(63 downto 32).asUInt
            macl := wide(31 downto 0).asUInt
          }
        } otherwise {
          mach := accumulator(63 downto 32).asUInt
          macl := accumulator(31 downto 0).asUInt
        }
        finishDefault()
      }
      is(exceptionSrWrite) {
        when(exceptionAlignedStack) {
          regs(15) := exceptionStackBase - 8
          restartData(exceptionPcWrite, exceptionStackBase - 8)
        } otherwise {
          regs(15) := read15 - 4
          restartData(exceptionPcWrite, read15 - 4)
        }
        memWriteData := exceptionReturnPc
      }
      is(exceptionPcWrite) {
        restartData(exceptionVectorRead, vbr + (exceptionVector << 2).resize(32))
      }
      is(exceptionVectorRead) {
        pcReg := io.dbus.DAT_MISO.asUInt
        inDelaySlot := False
        currentSlot := False
        state := fetch
      }
      is(rtePcRead) {
        memStageData := io.dbus.DAT_MISO.asUInt
        regs(15) := read15 + 4
        restartData(rteSrRead, read15 + 4)
      }
      is(rteSrRead) {
        regs(15) := read15 + 4
        setSr(io.dbus.DAT_MISO.asUInt)
        delayTarget := memStageData
        inDelaySlot := True
        pcReg := opcodePc + 2
        state := fetch
        io.retired := True
      }
      default {}
    }
  }

  when(state === execute) {
    val slotIllegal =
      currentSlot && (!decoder.io.legal || isPcModifying(opcode))

    when(slotIllegal) {
      startTrap(6, delayTarget)
    } elsewhen (!decoder.io.legal) {
      startTrap(4, opcodePc)
    } otherwise {
      switch(opcode(15 downto 12)) {
        is(0x0) {
          switch(opcode(7 downto 0)) {
            is(0x08)(setT(False))
            is(0x09) {}
            is(0x0b)(finishDelayed(pr))
            is(0x18)(setT(True))
            is(0x19) {
              srReg(8) := False
              srReg(9) := False
              srReg(0) := False
            }
            is(0x1b)(io.sleep := True)
            is(0x28) {
              mach := 0
              macl := 0
            }
            is(0x2b) {
              startData(rtePcRead, read15)
            }
            is(0x3b)(io.debugBreak := True)
            default {
              switch(opcode(3 downto 0)) {
                is(0x2) {
                  when(m === 0)(writeReg(n, srReg))
                    .elsewhen(m === 1)(writeReg(n, gbr))
                    .elsewhen(m === 2)(writeReg(n, vbr))
                }
                is(0x3) {
                  when(m === 0) {
                    pr := pcRelative
                    finishDelayed(pcRelative + readN)
                  } elsewhen (m === 2) {
                    finishDelayed(pcRelative + readN)
                  }
                }
                is(0x4) {
                  memWriteData := readM
                  startData(storeByte, readN + read0)
                }
                is(0x5) {
                  memWriteData := readM
                  startData(storeWord, readN + read0)
                }
                is(0x6) {
                  memWriteData := readM
                  startData(storeLong, readN + read0)
                }
                is(0x7) {
                  macl := (readN * readM)(31 downto 0)
                }
                is(0x9) {
                  when(m === 2)(writeReg(n, Mux(srReg(0), 1, 0)))
                }
                is(0xa) {
                  when(m === 0)(writeReg(n, mach))
                    .elsewhen(m === 1)(writeReg(n, macl))
                    .elsewhen(m === 2)(writeReg(n, pr))
                }
                is(0xc) { startData(loadByte, readM + read0); when(n === m) {} }
                is(0xd)(startData(loadWord, readM + read0))
                is(0xe)(startData(loadLong, readM + read0))
                is(0xf)(startData(macLongFirst, readN))
                default {}
              }
            }
          }
        }
        is(0x1) {
          memWriteData := readM
          startData(storeLong, readN + (disp4 << 2).resize(32))
        }
        is(0x2) {
          switch(opcode(3 downto 0)) {
            is(0x0) { memWriteData := readM; startData(storeByte, readN) }
            is(0x1) { memWriteData := readM; startData(storeWord, readN) }
            is(0x2) { memWriteData := readM; startData(storeLong, readN) }
            is(0x3) {
              memWriteData := readN
              startData(casRead, read0)
            }
            is(0x4) {
              memWriteData := readM
              writeReg(n, readN - 1)
              startData(storeByte, readN - 1)
            }
            is(0x5) {
              memWriteData := readM
              writeReg(n, readN - 2)
              startData(storeWord, readN - 2)
            }
            is(0x6) {
              memWriteData := readM
              writeReg(n, readN - 4)
              startData(storeLong, readN - 4)
            }
            is(0x7) {
              val newQ = readN(31)
              val newM = readM(31)
              srReg(8) := newQ
              srReg(9) := newM
              setT(newQ =/= newM)
            }
            is(0x8)(setT((readN & readM) === 0))
            is(0x9)(writeReg(n, readN & readM))
            is(0xa)(writeReg(n, readN ^ readM))
            is(0xb)(writeReg(n, readN | readM))
            is(0xc) {
              val diff = readN ^ readM
              setT(
                diff(31 downto 24) === 0 || diff(23 downto 16) === 0 ||
                  diff(15 downto 8) === 0 || diff(7 downto 0) === 0
              )
            }
            is(0xd) {
              writeReg(n, Cat(readM(15 downto 0), readN(31 downto 16)).asUInt)
            }
            is(0xe) {
              macl := (readN(15 downto 0) * readM(15 downto 0))(31 downto 0)
            }
            is(0xf) {
              macl := (readN(15 downto 0).asSInt * readM(15 downto 0).asSInt)
                .resize(32)
                .asUInt
            }
            default {}
          }
        }
        is(0x3) {
          switch(opcode(3 downto 0)) {
            is(0x0)(setT(readN === readM))
            is(0x2)(setT(readN >= readM))
            is(0x3)(setT(readN.asSInt >= readM.asSInt))
            is(0x4) {
              val oldQ = srReg(8)
              val newQ = readN(31)
              val shifted =
                Cat(readN(30 downto 0), srReg(0)).asUInt
              val adjusted = UInt(32 bits)
              val borrow = Bool()
              when(oldQ === srReg(9)) {
                adjusted := shifted - readM
                borrow := adjusted > shifted
              } otherwise {
                adjusted := shifted + readM
                borrow := adjusted < shifted
              }
              val resultQ = newQ ^ srReg(9) ^ borrow
              srReg(8) := resultQ
              setT(resultQ === srReg(9))
              writeReg(n, adjusted)
            }
            is(0x5) {
              val product = readN * readM
              mach := product(63 downto 32)
              macl := product(31 downto 0)
            }
            is(0x6)(setT(readN > readM))
            is(0x7)(setT(readN.asSInt > readM.asSInt))
            is(0x8)(writeReg(n, readN - readM))
            is(0xa) {
              val first = readN - readM
              val result = first - srReg(0).asUInt
              setT(readN < first || first < result)
              writeReg(n, result)
            }
            is(0xb) {
              val result = readN - readM
              setT(((readN ^ readM) & (readN ^ result))(31))
              writeReg(n, result)
            }
            is(0xc)(writeReg(n, readN + readM))
            is(0xd) {
              val product = readN.asSInt * readM.asSInt
              mach := product(63 downto 32).asUInt
              macl := product(31 downto 0).asUInt
            }
            is(0xe) {
              val first = readN + readM
              val result = first + srReg(0).asUInt
              setT(readN > first || first > result)
              writeReg(n, result)
            }
            is(0xf) {
              val result = readN + readM
              setT(((~(readN ^ readM)) & (readN ^ result))(31))
              writeReg(n, result)
            }
            default {}
          }
        }
        is(0x4) {
          switch(opcode(7 downto 0)) {
            is(0x00) { setT(readN(31)); writeReg(n, readN << 1) }
            is(0x01) { setT(readN(0)); writeReg(n, readN >> 1) }
            is(0x02) {
              memWriteData := mach
              writeReg(n, readN - 4)
              startData(storeLong, readN - 4)
            }
            is(0x03) {
              memWriteData := srReg
              writeReg(n, readN - 4)
              startData(storeLong, readN - 4)
            }
            is(0x04) {
              setT(readN(31))
              writeReg(n, Cat(readN(30 downto 0), readN(31)).asUInt)
            }
            is(0x05) {
              setT(readN(0))
              writeReg(n, Cat(readN(0), readN(31 downto 1)).asUInt)
            }
            is(0x06) {
              writeReg(n, readN + 4)
              startData(loadLong, readN)
            }
            is(0x07) {
              writeReg(n, readN + 4)
              startData(loadLong, readN)
            }
            is(0x08)(writeReg(n, readN << 2))
            is(0x09)(writeReg(n, readN >> 2))
            is(0x0a)(mach := readN)
            is(0x0b) {
              pr := pcRelative
              finishDelayed(readN)
            }
            is(0x0e)(setSr(readN))
            is(0x10) {
              val result = readN - 1
              writeReg(n, result)
              setT(result === 0)
            }
            is(0x11)(setT(readN.asSInt >= 0))
            is(0x12) {
              memWriteData := macl
              writeReg(n, readN - 4)
              startData(storeLong, readN - 4)
            }
            is(0x13) {
              memWriteData := gbr
              writeReg(n, readN - 4)
              startData(storeLong, readN - 4)
            }
            is(0x15)(setT(readN.asSInt > 0))
            is(0x16) {
              writeReg(n, readN + 4)
              startData(loadLong, readN)
            }
            is(0x17) {
              writeReg(n, readN + 4)
              startData(loadLong, readN)
            }
            is(0x18)(writeReg(n, readN << 8))
            is(0x19)(writeReg(n, readN >> 8))
            is(0x1a)(macl := readN)
            is(0x1b)(startData(tasRead, readN))
            is(0x1e)(gbr := readN)
            is(0x20) { setT(readN(31)); writeReg(n, readN << 1) }
            is(0x21) {
              setT(readN(0))
              writeReg(n, Cat(readN(31), readN(31 downto 1)).asUInt)
            }
            is(0x22) {
              memWriteData := pr
              writeReg(n, readN - 4)
              startData(storeLong, readN - 4)
            }
            is(0x23) {
              memWriteData := vbr
              writeReg(n, readN - 4)
              startData(storeLong, readN - 4)
            }
            is(0x24) {
              val oldT = srReg(0)
              setT(readN(31))
              writeReg(n, Cat(readN(30 downto 0), oldT).asUInt)
            }
            is(0x25) {
              val oldT = srReg(0)
              setT(readN(0))
              writeReg(n, Cat(oldT, readN(31 downto 1)).asUInt)
            }
            is(0x26) {
              writeReg(n, readN + 4)
              startData(loadLong, readN)
            }
            is(0x27) {
              writeReg(n, readN + 4)
              startData(loadLong, readN)
            }
            is(0x28)(writeReg(n, readN << 16))
            is(0x29)(writeReg(n, readN >> 16))
            is(0x2a)(pr := readN)
            is(0x2b)(finishDelayed(readN))
            is(0x2e)(vbr := readN)
            default {
              switch(opcode(3 downto 0)) {
                is(0xc) {
                  val leftShift = readM(4 downto 0)
                  val rightShift = (U(0, 32 bits) - readM)(4 downto 0)
                  val signedRight =
                    Mux(
                      rightShift === 0,
                      Mux(readN(31), U(0xffffffffL, 32 bits), U(0, 32 bits)),
                      (readN.asSInt >> rightShift).asUInt
                    )
                  writeReg(n, Mux(readM(31), signedRight, readN << leftShift))
                }
                is(0xd) {
                  val leftShift = readM(4 downto 0)
                  val rightShift = (U(0, 32 bits) - readM)(4 downto 0)
                  val logicalRight =
                    Mux(rightShift === 0, U(0, 32 bits), readN >> rightShift)
                  writeReg(n, Mux(readM(31), logicalRight, readN << leftShift))
                }
                is(0xf) {
                  startData(macWordFirst, readN)
                }
                default {}
              }
            }
          }
        }
        is(0x5) {
          startData(loadLong, readM + (disp4 << 2).resize(32))
        }
        is(0x6) {
          switch(opcode(3 downto 0)) {
            is(0x0)(startData(loadByte, readM))
            is(0x1)(startData(loadWord, readM))
            is(0x2)(startData(loadLong, readM))
            is(0x3)(writeReg(n, readM))
            is(0x4) {
              startData(loadByte, readM)
              writeReg(m, readM + 1)
            }
            is(0x5) {
              startData(loadWord, readM)
              writeReg(m, readM + 2)
            }
            is(0x6) {
              startData(loadLong, readM)
              writeReg(m, readM + 4)
            }
            is(0x7)(writeReg(n, ~readM))
            is(0x8) {
              val value = readM
              writeReg(n, Cat(value(31 downto 16), value(7 downto 0), value(15 downto 8)).asUInt)
            }
            is(0x9)(writeReg(n, Cat(readM(15 downto 0), readM(31 downto 16)).asUInt))
            is(0xa) {
              val first = U(0, 32 bits) - readM
              val result = first - srReg(0).asUInt
              setT(U(0, 32 bits) < first || first < result)
              writeReg(n, result)
            }
            is(0xb)(writeReg(n, U(0, 32 bits) - readM))
            is(0xc)(writeReg(n, readM(7 downto 0).resize(32)))
            is(0xd)(writeReg(n, readM(15 downto 0).resize(32)))
            is(0xe)(writeReg(n, signExtend(readM(7 downto 0), 8)))
            is(0xf)(writeReg(n, signExtend(readM(15 downto 0), 16)))
            default {}
          }
        }
        is(0x7) {
          writeReg(n, readN + signExtend(imm8, 8))
        }
        is(0x8) {
          switch(n) {
            is(0x0) {
              memWriteData := read0
              startData(storeByte, readM + disp4)
            }
            is(0x1) {
              memWriteData := read0
              startData(storeWord, readM + (disp4 << 1).resize(32))
            }
            is(0x4)(startData(loadByte, readM + disp4))
            is(0x5)(startData(loadWord, readM + (disp4 << 1).resize(32)))
            is(0x8) {
              setT(read0 === signExtend(imm8, 8))
            }
            is(0x9) {
              when(srReg(0))(finishBranch(pcRelative + signExtend(imm8, 8) * 2))
            }
            is(0xb) {
              when(!srReg(0))(finishBranch(pcRelative + signExtend(imm8, 8) * 2))
            }
            is(0xd) {
              when(srReg(0))(finishDelayed(pcRelative + signExtend(imm8, 8) * 2))
            }
            is(0xf) {
              when(!srReg(0))(finishDelayed(pcRelative + signExtend(imm8, 8) * 2))
            }
            default {}
          }
        }
        is(0x9) {
          startData(loadWord, pcRelative + (imm8 << 1).resize(32))
        }
        is(0xa) {
          finishDelayed(pcRelative + signExtend(disp12, 12) * 2)
        }
        is(0xb) {
          pr := pcRelative
          finishDelayed(pcRelative + signExtend(disp12, 12) * 2)
        }
        is(0xc) {
          switch(n) {
            is(0x0) {
              memWriteData := read0
              startData(storeByte, gbr + imm8)
            }
            is(0x1) {
              memWriteData := read0
              startData(storeWord, gbr + (imm8 << 1).resize(32))
            }
            is(0x2) {
              memWriteData := read0
              startData(storeLong, gbr + (imm8 << 2).resize(32))
            }
            is(0x3) {
              startTrap(imm8, opcodePc + 2)
            }
            is(0x4)(startData(loadByte, gbr + imm8))
            is(0x5)(startData(loadWord, gbr + (imm8 << 1).resize(32)))
            is(0x6)(startData(loadLong, gbr + (imm8 << 2).resize(32)))
            is(0x7)(writeReg(0, (pcRelative & 0xfffffffcL) + (imm8 << 2).resize(32)))
            is(0x8)(setT((read0 & imm8.resize(32)) === 0))
            is(0x9)(writeReg(0, read0 & imm8.resize(32)))
            is(0xa)(writeReg(0, read0 ^ imm8.resize(32)))
            is(0xb)(writeReg(0, read0 | imm8.resize(32)))
            is(0xc) {
              startData(gbrRead, gbr + read0)
            }
            is(0xd) {
              startData(gbrRead, gbr + read0)
            }
            is(0xe) {
              startData(gbrRead, gbr + read0)
            }
            is(0xf) {
              startData(gbrRead, gbr + read0)
            }
            default {}
          }
        }
        is(0xd) {
          startData(loadLong, (pcRelative & 0xfffffffcL) + (imm8 << 2).resize(32))
        }
        is(0xe) {
          writeReg(n, signExtend(imm8, 8))
        }
        default {}
      }

      when(!controlTaken) {
        finishDefault()
      }

      when(isSrSensitive(opcode)) {
        eventBlockNext := True
      }
    }
  }

  when(ClockDomain.current.isResetActive) {
    state := resetData
    action := resetPcRead
    memAddress := 0
    memWriteData := 0
    memStageData := 0
    for (index <- 0 until 16)
      regs(index) := 0
    pcReg := 0
    gbr := 0
    vbr := 0
    pr := 0
    mach := 0
    macl := 0
    srReg := 0xf0
    opcode := 0
    opcodePc := 0
    inDelaySlot := False
    currentSlot := False
    delayTarget := 0
    exceptionVector := 0
    exceptionReturnPc := 0
    exceptionStackBase := 0
    exceptionAlignedStack := False
    eventPending := False
    eventNeedsInstruction := False
    eventBlockNext := False
    pendingEventCommand := 0
    pendingEventVector := 0
    pendingEventLevel := 0
  }
}
