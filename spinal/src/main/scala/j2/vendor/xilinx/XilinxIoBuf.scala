package j2.vendor.xilinx

import spinal.core._
import spinal.lib.io.TriStateArray

final class XilinxIoBuf extends BlackBox {
  val I, T = in Bool ()
  val O    = out Bool ()
  val IO   = inout(Analog(Bool()))
  setDefinitionName("IOBUF")
}

object XilinxIoBuf {

  /** Connect a combinational bidirectional pad without adding RTL hierarchy. */
  def connect(pad: XilinxIoBuf, bus: TriStateArray, bit: Int, pin: Bool): Unit = {
    pad.I         := bus.write(bit)
    pad.T         := !bus.writeEnable(bit)
    bus.read(bit) := pad.O
    pad.IO <> pin
  }
}
