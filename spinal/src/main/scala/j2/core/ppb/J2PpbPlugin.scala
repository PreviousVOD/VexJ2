package j2.core.ppb

import j2.bus.ahb5.Ahb5DefaultSubordinate
import j2.bus.J2Ahb
import j2.core._
import spinal.core._
import spinal.lib.misc.plugin.FiberPlugin

/** Owns both core-side bus ports; the memory/fetch plugins do not decode PPB addresses. */
final class J2PpbPlugin extends FiberPlugin with J2CoreBusService {
  val allocation = during build new Area {
    val instruction = J2Ahb.manager()
    val data        = J2Ahb.manager()
  }
  override def instructionBus = allocation.get.instruction
  override def dataBus        = allocation.get.data

  val logic = during build new Area {
    val external   = host[J2ExternalService].external
    val data       = new J2PpbRouter
    val fetch      = new J2PpbRouter
    val fabric     = new J2PpbFabric
    val fetchError = new Ahb5DefaultSubordinate(J2Ahb.config)
    data.io.input <> dataBus
    fetch.io.input <> instructionBus
    external.dbus <> data.io.external
    external.ibus <> fetch.io.external
    fabric.io.bus <> data.io.privateBus
    fetchError.io.bus <> fetch.io.privateBus

    val source = fabric.io.intc
    val target = host[J2InterruptService].registers
    // The base is not aligned to 512 bytes; truncate only after subtraction.
    target.PADDR   := (source.PADDR - U(J2Ppb.intc.base, 32 bits)).resized
    target.PSEL    := source.PSEL
    target.PENABLE := source.PENABLE
    target.PWRITE  := source.PWRITE
    target.PWDATA  := source.PWDATA
    target.PSTRB   := source.PSTRB
    target.PPROT   := source.PPROT
    source.PREADY  := target.PREADY
    source.PSLVERR := target.PSLVERR
    source.PRDATA  := target.PRDATA
  }
}
