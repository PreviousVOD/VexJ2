/*                                                                           *\
**        _____ ____  _____   _____    __                                    **
**       / ___// __ \/  _/ | / /   |  / /   HDL Lib                          **
**       \__ \/ /_/ // //  |/ / /| | / /    (c) Dolu, All rights reserved    **
**      ___/ / ____// // /|  / ___ |/ /___                                   **
**     /____/_/   /___/_/ |_/_/  |_/_____/  MIT Licence                      **
**                                                                           **
** Permission is hereby granted, free of charge, to any person obtaining a   **
** copy of this software and associated documentation files (the "Software"),**
** to deal in the Software without restriction, including without limitation **
** the rights to use, copy, modify, merge, publish, distribute, sublicense,  **
** and/or sell copies of the Software, and to permit persons to whom the     **
** Software is furnished to do so, subject to the following conditions:      **
**                                                                           **
** The above copyright notice and this permission notice shall be included   **
** in all copies or substantial portions of the Software.                    **
**                                                                           **
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS   **
** OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF                **
** MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.    **
** IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY      **
** CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT **
** OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR  **
** THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                **
\*                                                                           */
package j2.bus.apb

import spinal.core._
import spinal.lib.bus.misc._
import scala.collection.Seq

object Apb4SlaveFactory {
  def apply(bus: Apb4): Apb4SlaveFactory = new Apb4SlaveFactory(bus)
}

/** Byte-enabled register mapping. Empty writes have no effects. Command registers can require
  * payload lanes explicitly, avoiding partial FIFO commands or RMW. As in BusSlaveFactory,
  * callbacks must use byte enables for lane-specific effects.
  */
class Apb4SlaveFactory(bus: Apb4) extends BusSlaveFactoryDelayed {
  bus.PREADY := True
  bus.PRDATA := 0
  private val aligned =
    if (bus.config.bytes == 1) True
    else bus.PADDR(log2Up(bus.config.bytes) - 1 downto 0) === 0
  private val rejected = Bool()
  rejected := !aligned
  private val askWrite = bus.access && bus.PWRITE && bus.PSTRB.orR && !rejected
  private val askRead  = bus.access && !bus.PWRITE && !rejected
  private val doWrite  = askWrite && bus.PREADY
  private val doRead   = askRead && bus.PREADY
  bus.PSLVERR := bus.fire && (rejected || Mux(bus.PWRITE, writeErrorFlag, readErrorFlag))

  def requireWriteStrobes(address: BigInt, mask: BigInt): Unit = {
    require(mask > 0 && mask < (BigInt(1) << bus.config.bytes))
    when(
      bus.PWRITE && bus.PADDR === address && bus.PSTRB.orR &&
        (bus.PSTRB & B(mask, bus.config.bytes bits)) =/= B(mask, bus.config.bytes bits)
    ) {
      rejected := True
    }
  }
  override def readAddress()     = bus.PADDR
  override def writeAddress()    = bus.PADDR
  override def writeByteEnable() = bus.PSTRB
  override def readHalt(): Unit  = bus.PREADY := False
  override def writeHalt(): Unit = bus.PREADY := False
  override def busDataWidth      = bus.config.dataWidth
  override def wordAddressInc    = bus.config.bytes

  // Spinal's generic address wrapper does not forward byte enables, and its
  // W0C/W0S helpers ignore them. Keep these semantics through nested offsets.
  override def withOffset(offset: BigInt): BusSlaveFactoryAddressWrapper =
    new BusSlaveFactoryAddressWrapper(this, offset) {
      override def writeByteEnable() = Apb4SlaveFactory.this.writeByteEnable()
      override def withOffset(next: BigInt): BusSlaveFactoryAddressWrapper =
        Apb4SlaveFactory.this.withOffset(offset + next)
      override def clearOnClear[T <: Data](that: T, address: BigInt, bitOffset: Int = 0): T =
        Apb4SlaveFactory.this.clearOnClear(that, address + offset, bitOffset)
      override def setOnClear[T <: Data](that: T, address: BigInt, bitOffset: Int = 0): T =
        Apb4SlaveFactory.this.setOnClear(that, address + offset, bitOffset)
      override def readError(): Unit  = Apb4SlaveFactory.this.readError()
      override def writeError(): Unit = Apb4SlaveFactory.this.writeError()
    }

  override def clearOnClear[T <: Data](that: T, address: BigInt, bitOffset: Int = 0): T = {
    when(isWriting(address)) {
      for (i <- 0 until widthOf(that))
        when(bus.PSTRB((bitOffset + i) / 8) && !bus.PWDATA(bitOffset + i)) {
          that.assignFromBits(B"0", i, 1 bits)
        }
    }
    that
  }
  override def setOnClear[T <: Data](that: T, address: BigInt, bitOffset: Int = 0): T = {
    when(isWriting(address)) {
      for (i <- 0 until widthOf(that))
        when(bus.PSTRB((bitOffset + i) / 8) && !bus.PWDATA(bitOffset + i)) {
          that.assignFromBits(B"1", i, 1 bits)
        }
    }
    that
  }
  override def build(): Unit = {
    // Non-stop data feeds W1C/W1S and FIFO helpers, which bypass mapped writes.
    val masked = Bits(busDataWidth bits)
    for (i <- 0 until bus.config.bytes)
      masked(i * 8, 8 bits) := Mux(bus.PSTRB(i), bus.PWDATA(i * 8, 8 bits), B(0, 8 bits))
    super.doNonStopWrite(masked)
    def map(jobs: Seq[BusSlaveFactoryElement]): Unit =
      super.doMappedElements(jobs, askWrite, askRead, doWrite, doRead, bus.PWDATA, bus.PRDATA)
    switch(bus.PADDR) {
      for ((address, jobs) <- elementsPerAddress if address.isInstanceOf[SingleMapping])
        is(address.asInstanceOf[SingleMapping].address)(map(jobs))
    }
    for ((address, jobs) <- elementsPerAddress if !address.isInstanceOf[SingleMapping])
      when(address.hit(bus.PADDR))(map(jobs))
  }
}
