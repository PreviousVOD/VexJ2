package j2.board

import j2.bus.J2MigPort
import spinal.core.ClockDomain
import spinal.core.sim._
import scala.collection.mutable

/** Native MIG model with independent command/data stalls and address-ordered writes. */
final class MigModel(port: J2MigPort, clock: ClockDomain, seed: Int = 923) {
  val bytes           = mutable.Map.empty[Long, Int]
  val writes          = mutable.Queue.empty[(BigInt, Int)]
  val reads           = mutable.Queue.empty[(Long, BigInt)]
  var cycle           = 0L
  var commands        = 0
  var writeCommands   = 0
  var readCommands    = 0
  var enabled         = true
  var commandsEnabled = true
  var writesEnabled   = true
  var deliverReads    = true
  var corruptEnd      = false
  val random          = new scala.util.Random(seed)
  def reset(): Unit   = { writes.clear(); reads.clear() }
  def word(address: Long): Long =
    (0 until 4).foldLeft(0L)((v, b) => (v << 8) | bytes.getOrElse(address + b, 0))
  def start(): Unit = {
    port.ready     #= false; port.writeReady #= false
    port.readValid #= false; port.readEnd    #= true; port.readData #= 0
    fork {
      while (true) {
        clock.waitFallingEdge()
        port.ready      #= enabled && commandsEnabled && random.nextBoolean()
        port.writeReady #= enabled && writesEnabled && random.nextInt(4) != 0
        port.readValid  #= false
        if (deliverReads && reads.nonEmpty && reads.front._1 <= cycle) {
          port.readData  #= reads.dequeue()._2
          port.readValid #= true; port.readEnd #= !corruptEnd
        }
        sleep(1)
        if (port.writeEnable.toBoolean && port.writeReady.toBoolean) {
          assert(port.writeEnd.toBoolean)
          writes.enqueue((port.writeData.toBigInt, port.writeMask.toInt))
        }
        if (port.enable.toBoolean && port.ready.toBoolean) {
          val address = port.address.toLong * 2
          assert((address & 15) == 0)
          commands += 1
          if (port.command.toInt == 0) {
            assert(writes.nonEmpty, "MIG write command has no buffered data")
            val (data, mask) = writes.dequeue()
            for (b <- 0 until 16 if (mask & (1 << b)) == 0)
              bytes(address + b) = ((data >> (8 * b)) & 255).toInt
            writeCommands += 1
          } else {
            assert(port.command.toInt == 1)
            val value = (0 until 16).foldLeft(BigInt(0))((v, b) =>
              v | (BigInt(bytes.getOrElse(address + b, 0)) << (8 * b))
            )
            reads.enqueue((cycle + 2 + random.nextInt(10), value))
            readCommands += 1
          }
        }
        clock.waitSampling()
        cycle += 1
      }
    }
  }
}
