package j2.board

import java.nio.file.{Files, Paths}
import java.util.Properties
import j2.soc.J2SocConfig

/** Common board.properties schema; vendor clock/pin implementations stay board-specific. */
final case class BoardProfile(values: Map[String, String]) {
  def text(key: String): String =
    values.getOrElse(key, throw new IllegalArgumentException(s"missing board property $key"))
  def number(key: String): BigInt = {
    val value = text(key)
    if (value.startsWith("0x")) BigInt(value.drop(2), 16) else BigInt(value)
  }
  val name    = text("name")
  val clockHz = number("clockHz").toInt
  val usePll  = number("usePll") == 1
  require(number("usePll") == 0 || number("usePll") == 1)
  require(clockHz > 0 && number("clockHz").isValidInt)
  require(text("uartDevice").nonEmpty && number("uartBaud") == 19200)
  require(
    number("configurationSlotBytes") >= 0 && 2 * number("configurationSlotBytes") <= number(
      "configurationFlashBytes"
    )
  )
  require(number("flashOffset") % 65536 == 0 && number("xipBytes") % 65536 == 0)
  require(number("xipBase") >= 0 && number("xipBase") + number("xipBytes") <= (BigInt(1) << 32))
  require(number("memoryBase") % 16 == 0)
  name match {
    case "tang-primer" =>
      require(text("flashType") == "winbond")
      require(text("memoryType") == "sdram")
      require(text("part") == "EG4S20BG256" && number("inputClockHz") == 24000000)
      require(number("memoryBytes") == 0x00800000, "Tang has 8 MiB of SDRAM")
      require(
        number("memoryBase") % number("memoryBytes") == 0,
        "Tang SDRAM window must align to its size"
      )
      require(number("flashOffset") == 0, "Tang loader uploads start at flash offset zero")
      val vcoHz = if (clockHz == 32000000) 384000000 else 360000000
      require(
        if (usePll) vcoHz % clockHz == 0 else clockHz == 24000000,
        "invalid Tang PLL/bypass clock"
      )
    case "wukong-v1" =>
      require(text("flashType") == "micron")
      require(text("memoryType") == "ddr3")
      require(text("part") == "xc7a100tfgg676-2" && number("inputClockHz") == 50000000)
      require(
        clockHz == 72000000 && usePll,
        "update and validate the Wukong MMCM before changing clocks"
      )
      require(number("memoryBytes") == 0x10000000, "Wukong MIG exposes 256 MiB of DDR3")
      require(number("configurationSlotBytes") > 0)
    case _ => throw new IllegalArgumentException(s"unsupported board $name")
  }
  def socConfig(romHex: String): J2SocConfig = J2SocConfig(
    clockHz     = clockHz,
    romHex      = romHex,
    xipBase     = number("xipBase"),
    xipBytes    = number("xipBytes"),
    flashOffset = number("flashOffset"),
    flashBytes  = number("flashBytes"),
    memoryBase  = number("memoryBase"),
    memoryBytes = number("memoryBytes"),
    uartBaud    = number("uartBaud").toInt,
    sramBytes   = number("sramBytes").toInt
  )
  // Apply the same address/range validation even when only clock settings are used.
  require(number("sramBytes").isValidInt)
  socConfig("")
}

object BoardProfile {
  def load(board: String, environment: Map[String, String] = sys.env): BoardProfile = {
    val properties = new Properties
    val stream     = Files.newInputStream(Paths.get(s"../fpga/$board/board.properties"))
    try properties.load(stream)
    finally stream.close()
    import scala.jdk.CollectionConverters._
    val values =
      properties.stringPropertyNames().asScala.map(key => key -> properties.getProperty(key)).toMap
    // Legacy Tang diagnostic overrides must not leak into Wukong through recursive Make.
    val overrides =
      if (board == "tang-primer")
        Seq("J2_CLOCK_HZ" -> "clockHz", "J2_USE_PLL" -> "usePll").flatMap { case (env, key) =>
          environment.get(env).map(key -> _)
        }.toMap
      else Map.empty[String, String]
    val profile = BoardProfile(values ++ overrides)
    require(profile.name == board, "board profile name does not match its directory")
    profile
  }
}
