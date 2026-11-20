package j2.soc

final case class J2SocConfig(
    clockHz: Int = 32000000,
    romHex: String = sys.env.getOrElse("J2_ROM_HEX", "../build/verilog/xip/j2_validation_rom.hex"),
    xipBase: BigInt = 0x10000000L,
    xipBytes: BigInt = 0x00100000L,
    flashOffset: BigInt = 0,
    flashBytes: BigInt = 0x01000000L,
    memoryBase: BigInt = 0x80000000L,
    memoryBytes: BigInt = 0x00800000L,
    uartBaud: Int = 19200,
    sramBytes: Int = 32768,
    scifBase: BigInt = 0xff001000L,
    cmtBase: BigInt = 0xff003000L,
    interruptSources: Seq[String] = Seq.empty,
    scifFifoDepth: Int = 0,
    spiControlBase: BigInt = 0xff002000L,
    xipCacheControlBase: BigInt = 0xff004000L
) {
  require(interruptSources.size <= 192, "SH-2 INTC supports at most 192 sources")
  require(interruptSources.distinct.size == interruptSources.size, "duplicate interrupt source")
  require(interruptSources.forall(_.matches("[A-Z][A-Z0-9_]*")), "invalid interrupt source name")
  require(scifFifoDepth >= 0 && scifFifoDepth <= 255, "SCIF FIFO depth must be 0–255")
  require(clockHz > 0)
  private val controlBases = Seq(scifBase, cmtBase, spiControlBase, xipCacheControlBase)
  for (base <- controlBases) {
    require(
      base >= 0 && base % 4096 == 0 && base + 4096 <= (BigInt(1) << 32),
      "Peripheral control windows must be 4 KiB aligned in the 32-bit address space"
    )
    require(
      base + 4096 <= 0xffffe000L || base >= 0xfffff000L,
      "Peripheral controls must not overlap private PPB"
    )
  }
  require(controlBases.distinct.size == controlBases.size, "peripheral control windows overlap")
  require(
    sramBytes >= 4096 && (sramBytes & (sramBytes - 1)) == 0,
    "SRAM size must be a power of two, at least 4 KiB"
  )
  private val sramEnd = BigInt(0x8000) + sramBytes
  require(sramEnd <= 0xff000000L)
  require(sramEnd <= xipBase || xipBase + xipBytes <= 0x8000, "SRAM overlaps XIP")
  require(
    sramEnd <= memoryBase || memoryBase + memoryBytes <= 0x8000,
    "SRAM overlaps external memory"
  )
  require(uartBaud > 0 && clockHz / uartBaud >= 32)
  require(flashOffset >= 0 && flashOffset % 32 == 0)
  require(xipBytes > 0 && flashOffset + xipBytes <= flashBytes)
  require(flashOffset + xipBytes <= 0x01000000L, "SPI backend uses 24-bit flash addresses")
  require(memoryBase >= 0 && memoryBytes > 0 && memoryBase + memoryBytes <= (BigInt(1) << 32))
}
