package j2.soc

import j2.memory.J2MemoryBackend

final case class J2SocConfig(
    memoryBackend: J2MemoryBackend = J2MemoryBackend.Inferred,
    clockHz: Int = 32000000,
    timerTickHz: Int = 1000000,
    romHex: String = sys.env.getOrElse("J2_ROM_HEX", "../build/verilog/xip/j2_validation_rom.hex"),
    xipBase: BigInt = 0x10000000L,
    xipBytes: BigInt = 0x00100000L,
    flashOffset: BigInt = 0,
    flashBytes: BigInt = 0x01000000L,
    memoryBase: BigInt = 0x80000000L,
    memoryBytes: BigInt = 0x00800000L
) {
  require(clockHz > 0 && timerTickHz > 0)
  require(flashOffset >= 0 && flashOffset % 32 == 0)
  require(xipBytes > 0 && flashOffset + xipBytes <= flashBytes)
  require(flashOffset + xipBytes <= 0x01000000L, "SPI backend uses 24-bit flash addresses")
  require(memoryBase >= 0 && memoryBytes > 0 && memoryBase + memoryBytes <= (BigInt(1) << 32))
}
