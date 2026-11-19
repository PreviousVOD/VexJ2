package j2.core

import spinal.core._
import spinal.lib._
import j2.bus.J2Ahb
import j2.core.microcode.J2Operation

final case class J2CoreConfig(
    exposeDebug: Boolean = true
)

final class J2CoreIo(config: J2CoreConfig) extends Bundle {
  val ibus              = master(J2Ahb.manager())
  val dbus              = master(J2Ahb.manager())
  val event             = slave(Stream(new J2Event))
  val eventAck          = out Bool ()
  val pc                = if (config.exposeDebug) out UInt (32 bits) else null
  val sr                = if (config.exposeDebug) out UInt (32 bits) else null
  val sleep             = if (config.exposeDebug) out Bool () else null
  val retired           = if (config.exposeDebug) out Bool () else null
  val illegal           = if (config.exposeDebug) out Bool () else null
  val debugBreak        = if (config.exposeDebug) out Bool () else null
  val debugState        = if (config.exposeDebug) out UInt (3 bits) else null
  val debugOpcode       = if (config.exposeDebug) out UInt (16 bits) else null
  val debugSlotIllegal  = if (config.exposeDebug) out Bool () else null
  val debugEventPending = if (config.exposeDebug) out Bool () else null
}

// Services publish wires, never the owning plugin's registers or child components.
trait J2ExternalService { def external: J2CoreIo }
trait J2FetchService { def fetch: J2FetchPort }
trait J2MemoryService { def memory: J2MemoryPort }
trait J2DecodeService { def decode: J2DecodePort }
trait J2ScheduleService { def schedule: J2SchedulePort }
trait J2ExecuteService { def execute: J2ExecutePort }
trait J2RegisterService { def registers: J2RegisterPort }
trait J2MultiplyService { def multiply: J2MultiplyPort }
trait J2ArchitecturalService { def architectural: J2ArchitecturalPort }
trait J2TrapService { def trap: J2TrapPort }

final class J2FetchPort extends Bundle {
  val opcode                            = UInt(16 bits)
  val predecodeAddress                  = UInt(8 bits)
  val firstLine                         = UInt(72 bits)
  val legal, delaySlotIllegal           = Bool()
  val pc                                = UInt(32 bits)
  val active, fault, entryFault, issued = Bool()
  val faultPc                           = UInt(32 bits)
}
final class J2MemoryPort extends Bundle {
  val read                                         = UInt(32 bits)
  val readValid, active, fault, entryFault, issued = Bool()
  val locked                                       = Bool()
  val faultPc                                      = UInt(32 bits)
}
final class J2DecodePort extends Bundle {
  val ready                                                          = Bool()
  val control                                                        = new J2MicrocodeControl
  val operation                                                      = new J2Operation
  val nextIdStall, instructionIssue, instructionAddress, incrementPc = Bool()
  val eventAck, maskInterrupt, delaySlot, startInstruction           = Bool()
  val interruptLevel                                                 = UInt(4 bits)
  val legal, delaySlotIllegal                                        = Bool()
}
final class J2InstructionMetadata extends Bundle {
  val pc, resumePc = UInt(32 bits)
}
final class J2SchedulePort extends Bundle {
  val advance = Bool()
  val state   = new J2PipelineState
}
final class J2RegisterPort extends Bundle {
  val x, y, r0 = UInt(32 bits)
}
final class J2ExecutePort extends Bundle {
  val xbus, ybus, zbus, memoryAddress, memoryWriteData = UInt(32 bits)
  val arithmeticResult                                 = UInt(33 bits)
  val arithmeticSr, logicSr                            = new J2Status
  val shiftT                                           = Bool()
}
final class J2MultiplyPort extends Bundle {
  val busy, blocked = Bool()
  val mach, macl    = UInt(32 bits)
}
final class J2ArchitecturalPort extends Bundle {
  val pc, sequentialPc   = UInt(32 bits)
  val status, nextStatus = new J2Status
  val metadata           = new J2InstructionMetadata
}
final class J2TrapPort extends Bundle {
  val sleeping, halted, inService, internalFault, acceptInternal, enterSleep = Bool()
}
