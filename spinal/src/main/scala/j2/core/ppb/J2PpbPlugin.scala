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

    // Step 1: all valid words in the future INTC window are reserved, read-only zero.
    fabric.io.intc.PREADY  := True
    fabric.io.intc.PRDATA  := 0
    fabric.io.intc.PSLVERR := False
  }
}
