package j2.board

import j2.soc.J2Soc
import spinal.core._
import spinal.core.sim._
import scala.collection.mutable.ArrayBuffer

/** Pin-level Micron model for volatile protocol setup and 4-4-4 cached reads. Deliberately
  * nonuniform array data exposes lane, byte, address and dummy-clock errors.
  */
final class Sf3Model(
    csPin: Bool,
    clockPin: Bool,
    writePins: Bits,
    enablePins: Bits,
    readPins: Bits,
    initiallyQuad: Boolean,
    erased: Boolean = false
) {
  def this(dut: J2Soc, initiallyQuad: Boolean) = this(
    dut.io.spiCs,
    dut.io.spiClk,
    dut.io.spiData.write,
    dut.io.spiData.writeEnable,
    dut.io.spiData.read,
    initiallyQuad
  )
  var quad          = initiallyQuad
  var evcr          = if (quad) 0x5f else 0xdf
  var vcr           = 0xfb
  var wel           = false
  var previousClock = false
  var previousCs    = true
  var width         = 1
  var clocks        = 0
  var opcode        = 0
  var value         = 0
  var address       = 0L
  val data          = ArrayBuffer.empty[Int]
  val quadReads     = ArrayBuffer.empty[Long]
  var quadIds       = 0
  val contents      = scala.collection.mutable.Map.empty[Long, Int]
  val erases        = ArrayBuffer.empty[Long]
  val programs      = ArrayBuffer.empty[(Long, Int)]
  var busy          = 0
  var flags         = 0x80
  var failProgram   = false
  def preload(image: Array[Byte]): Unit =
    image.indices.foreach(i => contents(i.toLong) = image(i) & 255)
  def byte(a: Long): Int =
    contents.getOrElse(a, if (erased) 255 else ((a * 37) ^ (a >> 7) ^ 0xa5).toInt & 255)

  def tick(): Unit = {
    val cs  = csPin.toBoolean
    val clk = clockPin.toBoolean
    if (previousCs && !cs) {
      width  = if (quad) 4 else 1
      clocks = 0; opcode = 0; value = 0; address = 0
      data.clear()
    }
    val commandClocks = 8 / width
    // A short CS pulse during reset or a partial command is ignored by the flash.
    if (!previousCs && cs && clocks >= commandClocks) {
      opcode match {
        case 0x06 => assert(busy == 0); wel = true
        case 0x50 => assert(busy == 0); flags = 0x80
        case 0x05 => if (busy > 0) busy -= 1
        case 0x70 => ()
        case 0xd8 =>
          assert(width == 4 && wel && busy == 0 && (address & 65535) == 0 && address < 0x100000)
          for (i <- 0 until 65536) contents(address + i) = 255
          erases += address; wel                         = false; busy = 3
        case 0x02 =>
          assert(width == 4 && wel && busy == 0 && data.nonEmpty && data.size <= 256)
          assert(address < 0x100000 && (address & 255) + data.size <= 256)
          if (failProgram) { flags = 0x90; failProgram = false }
          else for (i <- data.indices) contents(address + i) = byte(address + i) & data(i)
          programs += ((address, data.size)); wel = false; busy = 2
        case 0x81 | 0x61 | 0xc5 =>
          assert(wel && data.size == 1, s"invalid register write $opcode: $data")
          if (opcode == 0x81) vcr = data.head
          if (opcode == 0x61) { evcr = data.head; quad = (evcr & 0x80) == 0 }
          if (opcode == 0xc5) assert(data.head == 0)
          wel = false
        case 0xe9 => assert(wel); wel = false
        case 0xaf => assert(width == 4); quadIds += 1
        case 0xeb =>
          assert(width == 4 && vcr == 0x8b)
          assert(clocks == 2 + 6 + 8 + 64, s"quad burst clocks: $clocks")
          quadReads += address
        case 0x03 | 0x9f | 0x65 | 0x85 => ()
        // Quad ID probe while the flash is still in single-SPI protocol.
        case 0x7f  => assert(width == 1 && clocks == 8)
        case other => assert(false, f"unexpected flash opcode $other%02x")
      }
    }
    if (cs) readPins #= 15
    else if (!previousClock && clk) {
      val pins   = writePins.toInt
      val enable = enablePins.toInt
      val driven = (pins & enable) | (~enable & 15)
      if (clocks < commandClocks) opcode = (opcode << width) | (driven & ((1 << width) - 1))
      else {
        val index = clocks - commandClocks
        if (Set(0x03, 0xeb, 0xd8, 0x02).contains(opcode) && index < 24 / width)
          address = (address << width) | (driven & ((1 << width) - 1))
        if (Set(0x81, 0x61, 0xc5).contains(opcode) || (opcode == 0x02 && index >= 24 / width)) {
          value = ((value << width) | (driven & ((1 << width) - 1))) & 255
          if ((index + 1) % commandClocks == 0) data += value
        }
        if (opcode == 0xeb && index >= 14) assert(enable == 0, "quad receive contention")
      }
      clocks += 1
    } else if (previousClock && !clk) {
      val payloadStart = commandClocks + (opcode match {
        case 0x03 => 24 / width
        case 0xeb => 24 / width + 8
        case _    => 0
      })
      val index = clocks - payloadStart
      if (index >= 0) {
        val byteIndex = index / commandClocks
        val result = opcode match {
          case 0xaf | 0x9f => if (byteIndex < 3) (0x20ba19 >> (16 - 8 * byteIndex)) & 255 else 255
          case 0x05        => (if (busy > 0) 1 else 0) | (if (wel) 2 else 0)
          case 0x70        => if (busy > 0) flags & 0x7f else flags
          case 0x65        => evcr
          case 0x85        => vcr
          case 0x03 | 0xeb => byte(address + byteIndex)
          case _           => 255
        }
        val shift = 8 - width - (index % commandClocks) * width
        val bits  = (result >> shift) & ((1 << width) - 1)
        readPins #= (if (width == 4) bits else 13 | (bits << 1))
      }
    }
    previousCs    = cs
    previousClock = clk
  }
}
