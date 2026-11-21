package j2.vendor.anlogic

import spinal.core._
import spinal.lib.io.TriStateArray

final class Eg4IoBuf extends BlackBox {
  val ipad   = in Bool ()
  val opad   = out Bool ()
  val bpad   = inout(Analog(Bool()))
  val rst    = in Bool ()
  val ce     = in Bool ()
  val isclk  = in Bool ()
  val ipclk  = in Bool ()
  val osclk  = in Bool ()
  val opclk  = in Bool ()
  val ts     = in Bool ()
  val doData = in Bits (4 bits)
  doData.setName("do")
  val di  = out Bool ()
  val diq = out Bits (4 bits)
  setDefinitionName("EG_PHY_PAD")
  addGeneric("MODE", "BI")
  addGeneric("TSMUX", "TS")
  addGeneric("IOTYPE", "LVCMOS33")
  addGeneric("DRIVE", "12")
}

object Eg4IoBuf {

  /** Connect a combinational bidirectional pad without adding RTL hierarchy. */
  def connect(pad: Eg4IoBuf, bus: TriStateArray, bit: Int, pin: Bool): Unit = {
    pad.ipad   := False
    pad.rst    := False
    pad.ce     := True
    pad.isclk  := False
    pad.ipclk  := False
    pad.osclk  := False
    pad.opclk  := False
    pad.ts     := !bus.writeEnable(bit)
    pad.doData := bus.write(bit).asBits.resize(4)
    pad.bpad <> pin
    bus.read(bit) := pad.di
  }
}
