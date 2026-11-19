package j2.board.wukong

import java.nio.file.{Files, Paths}
import java.util.Properties
import j2.soc.J2SocConfig

object WukongV1 {
  def load(path: String, romHex: String): J2SocConfig = {
    val properties = new Properties
    val stream     = Files.newInputStream(Paths.get(path))
    try properties.load(stream)
    finally stream.close()
    def number(key: String): BigInt = {
      val value = Option(properties.getProperty(key)).getOrElse(
        throw new IllegalArgumentException(s"missing Wukong property $key")
      )
      if (value.startsWith("0x")) BigInt(value.drop(2), 16) else BigInt(value)
    }
    require(properties.getProperty("name") == "wukong-v1")
    require(properties.getProperty("part") == "xc7a100tfgg676-2")
    require(
      number("inputClockHz") == 50000000 && number("clockHz") == 72000000,
      "update and validate the MMCM before changing Wukong clock frequencies"
    )
    require(number("uartBaud") == 19200)
    require(2 * number("configurationSlotBytes") <= number("configurationFlashBytes"))
    J2SocConfig(
      clockHz     = number("clockHz").toInt,
      romHex      = romHex,
      xipBase     = number("xipBase"),
      xipBytes    = number("xipBytes"),
      flashOffset = number("flashOffset"),
      flashBytes  = number("flashBytes"),
      memoryBase  = number("memoryBase"),
      memoryBytes = number("memoryBytes")
    )
  }
}
