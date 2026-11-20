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
  require(text("uartDevice").nonEmpty && number("uartBaud").isValidInt && number("uartBaud") > 0)
  require(
    number("configurationSlotBytes") >= 0 && 2 * number("configurationSlotBytes") <= number(
      "configurationFlashBytes"
    )
  )
  require(number("flashOffset") % 65536 == 0 && number("xipBytes") % 65536 == 0)
  require(number("xipBase") >= 0 && number("xipBase") + number("xipBytes") <= (BigInt(1) << 32))
  require(number("memoryBase") % 16 == 0)
  def socConfig(romHex: String): J2SocConfig = J2SocConfig(
    clockHz             = clockHz,
    romHex              = romHex,
    xipBase             = number("xipBase"),
    xipBytes            = number("xipBytes"),
    flashOffset         = number("flashOffset"),
    flashBytes          = number("flashBytes"),
    memoryBase          = number("memoryBase"),
    memoryBytes         = number("memoryBytes"),
    uartBaud            = number("uartBaud").toInt,
    sramBytes           = number("sramBytes").toInt,
    scifBase            = number("scifBase"),
    cmtBase             = number("cmtBase"),
    scifFifoDepth       = number("scifFifoDepth").toInt,
    spiControlBase      = number("spiControlBase"),
    xipCacheControlBase = number("xipCacheControlBase"),
    interruptSources =
      if (text("interruptSources").trim.isEmpty) Seq.empty
      else text("interruptSources").split(",", -1).toSeq.map(_.trim)
  )
  // Apply the same address/range validation even when only clock settings are used.
  require(number("scifFifoDepth").isValidInt)
  require(number("sramBytes").isValidInt)
  socConfig("")
}

object BoardProfile {
  def load(board: String, environment: Map[String, String] = sys.env): BoardProfile =
    loadPath(
      environment.getOrElse("J2_BOARD_PROPERTIES", s"../fpga/$board/board.properties"),
      environment
    )

  def loadPath(path: String, environment: Map[String, String] = sys.env): BoardProfile = {
    val properties = new Properties
    val stream     = Files.newInputStream(Paths.get(path))
    try properties.load(stream)
    finally stream.close()
    import scala.jdk.CollectionConverters._
    val values =
      properties.stringPropertyNames().asScala.map(key => key -> properties.getProperty(key)).toMap
    val overrides = values.iterator
      .collect {
        case (key, env) if key.endsWith("Env") =>
          environment.get(env).map(key.stripSuffix("Env") -> _)
      }
      .flatten
      .toMap
    BoardProfile(values ++ overrides)
  }
}
