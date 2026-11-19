package j2.core

import j2.bus._
import spinal.core._
import spinal.lib._
import spinal.lib.misc.plugin.FiberPlugin

// Preserve legacy architectural test drivers while exercising the native AHB CPU through
// protocol adapters. Production tops instantiate J2MicrocodedCore directly.
final class J2WishboneCoreIo(config: J2CoreConfig, exposeInterrupts: Boolean = false)
    extends Bundle {
  val ibus              = master(J2Wishbone())
  val dbus              = master(J2Wishbone())
  val interrupts        = if (exposeInterrupts) in Bits (config.interruptCount bits) else null
  val nmi               = if (exposeInterrupts) in Bool () else null
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

final class J2WishboneCoreFixture(
    config: J2CoreConfig,
    factory: J2CoreConfig => Seq[FiberPlugin],
    exposeInterrupts: Boolean
) extends Component {
  def this(config: J2CoreConfig, factory: J2CoreConfig => Seq[FiberPlugin]) =
    this(config, factory, false)
  def this(config: J2CoreConfig) = this(config, J2CorePlugins.apply _, false)
  def this(exposeDebug: Boolean = true) = this(J2CoreConfig(exposeDebug = exposeDebug))
  val io                = new J2WishboneCoreIo(config, exposeInterrupts)
  val cpu               = new J2MicrocodedCore(config.copy(eventInjection = true), factory)
  val instruction, data = new J2AhbToWishbone
  J2Ahb.connect(cpu.io.ibus, instruction.io.ahb)
  J2Ahb.connect(cpu.io.dbus, data.io.ahb)
  io.ibus <> instruction.io.wb
  io.dbus <> data.io.wb
  cpu.io.interrupts := (if (exposeInterrupts) io.interrupts else B(0, config.interruptCount bits))
  cpu.io.nmi        := (if (exposeInterrupts) io.nmi else True)
  cpu.io.event <> io.event
  for ((name, port) <- io.elements if !Set("ibus", "dbus", "event", "interrupts", "nmi")(name))
    port.assignFromBits(cpu.io.elements.find(_._1 == name).get._2.asBits)
}
