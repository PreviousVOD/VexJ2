package j2.periph

import j2.bus.{J2Ahb, J2Apb, J2ReadCache, J2ReadCacheConfig}
import spinal.core._
import spinal.lib._
import spinal.lib.io.TriStateArray

/** Reusable cached SPI endpoint. The board owns its address map and physical pads. */
final class J2CachedSpiFlash(config: J2ReadCacheConfig, flashOffset: BigInt = 0) extends Component {
  require(flashOffset >= 0 && flashOffset % config.lineBytes == 0)
  require(flashOffset + config.rangeBytes <= 0x01000000L, "SPI uses 24-bit flash addresses")
  val io = new Bundle {
    val bus                   = slave(J2Ahb.subordinate())
    val control, cacheControl = slave(J2Apb())
    val spi = new Bundle {
      val cs, clk = out Bool ()
      val data    = master(TriStateArray(4))
    }
  }
  private val cache = new J2ReadCache(config)
  private val flash = new J2SpiFlash(config.lineBytes)
  cache.io.bus <> io.bus
  cache.io.control <> io.cacheControl
  flash.io.control <> io.control
  // Cache tags retain absolute addresses; only this SPI adapter translates them.
  flash.io.xip.cmd.valid := cache.io.refill.cmd.valid
  flash.io.xip.cmd.address := cache.io.refill.cmd.address - U(config.baseAddress, 32 bits) + U(
    flashOffset,
    32 bits
  )
  flash.io.xip.cmd.length   := cache.io.refill.cmd.length
  cache.io.refill.cmd.ready := flash.io.xip.cmd.ready
  cache.io.refill.rsp <> flash.io.xip.rsp
  cache.io.hold       := flash.io.readHold
  cache.io.invalidate := flash.io.invalidate
  flash.io.readBusy   := cache.io.busy
  io.spi.cs           := flash.io.spi.cs
  io.spi.clk          := flash.io.spi.clk
  io.spi.data <> flash.io.spi.data
}
