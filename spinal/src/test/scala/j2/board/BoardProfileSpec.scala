package j2.board

class BoardProfileSpec extends munit.FunSuite {
  test("both boards share the schema and produce generic SoC memory windows") {
    val tang   = BoardProfile.load("tang-primer", Map.empty)
    val wukong = BoardProfile.load("wukong-v1", Map.empty)
    assertEquals(tang.socConfig("rom.hex").memoryBytes, BigInt(0x800000))
    assertEquals(wukong.socConfig("rom.hex").memoryBytes, BigInt(0x10000000))
    assertEquals(tang.clockHz, 32000000)
    assertEquals(wukong.clockHz, 72000000)
  }
  test("Tang diagnostic clock overrides cannot leak into Wukong") {
    val env = Map("J2_CLOCK_HZ" -> "24000000", "J2_USE_PLL" -> "0")
    assertEquals(BoardProfile.load("tang-primer", env).clockHz, 24000000)
    assertEquals(BoardProfile.load("wukong-v1", env).clockHz, 72000000)
    assertEquals(BoardProfile.load("tang-primer", Map("J2_USE_PLL" -> "0")).usePll, false)
  }
  test("reject out-of-range flash partitions") {
    for (board <- Seq("tang-primer", "wukong-v1")) {
      val values = BoardProfile.load(board, Map.empty).values
      intercept[IllegalArgumentException](BoardProfile(values.updated("xipBytes", "0x02000000")))
    }
  }
  test("new boards load without a board-name registry or hardware whitelist") {
    val values = BoardProfile.load("wukong-v1", Map.empty).values ++ Map(
      "name" -> "example-board",
      "part" -> "another-fpga",
      "memoryType" -> "psram",
      "memoryBytes" -> "0x02000000",
      "clockHz" -> "40000000",
      "uartBaud" -> "115200",
      "clockHzEnv" -> "EXAMPLE_CLOCK"
    )
    val file = java.nio.file.Files.createTempFile("board-", ".properties")
    try {
      java.nio.file.Files.writeString(file, values.map { case (k, v) => s"$k=$v" }.mkString("\n"))
      val board = BoardProfile.loadPath(file.toString, Map("EXAMPLE_CLOCK" -> "48000000"))
      assertEquals(board.name, "example-board")
      assertEquals(board.clockHz, 48000000)
      assertEquals(board.socConfig("").uartBaud, 115200)
    } finally java.nio.file.Files.delete(file)
  }
  test("SRAM size reaches SoC configuration and rejects invalid sizes or overlaps") {
    val values = BoardProfile.load("wukong-v1", Map.empty).values
    assertEquals(BoardProfile(values.updated("sramBytes", "65536")).socConfig("").sramBytes, 65536)
    for (size <- Seq("0", "2048", "49152", "0x10000000", "0x100000000"))
      intercept[IllegalArgumentException](BoardProfile(values.updated("sramBytes", size)))
  }
  test("boot peripheral addresses reach each SoC configuration") {
    for (board <- Seq("tang-primer", "wukong-v1")) {
      val values = BoardProfile.load(board, Map.empty).values
      val config = BoardProfile(values ++ Map("sciBase" -> "0xff006000", "cmtBase" -> "0xff007000"))
        .socConfig("")
      assertEquals(config.sciBase, BigInt(0xff006000L))
      assertEquals(config.cmtBase, BigInt(0xff007000L))
      for (
        (key, value) <- Seq(
          "sciBase" -> "-4096",
          "sciBase" -> "0xff006001",
          "cmtBase" -> "0x100000000",
          "cmtBase" -> values("sciBase"),
          "sciBase" -> "0xffffe000"
        )
      )
        intercept[IllegalArgumentException](BoardProfile(values.updated(key, value)))
    }
  }
  test("board interrupt maps preserve order and reject invalid source definitions") {
    val values  = BoardProfile.load("tang-primer", Map.empty).values
    val sources = Seq("SCI_RXI", "CMT0", "EXTRA")
    assertEquals(
      BoardProfile(values.updated("interruptSources", sources.mkString(",")))
        .socConfig("")
        .interruptSources,
      sources
    )
    assertEquals(
      BoardProfile(values.updated("interruptSources", "")).socConfig("").interruptSources.size,
      0
    )
    assertEquals(
      BoardProfile(
        values.updated("interruptSources", (0 until 192).map(i => s"IRQ_$i").mkString(","))
      )
        .socConfig("")
        .interruptSources
        .size,
      192
    )
    for (
      sources <- Seq(
        "CMT0,CMT0",
        "bad-name",
        "CMT0,",
        (0 until 193).map(i => s"IRQ_$i").mkString(",")
      )
    )
      intercept[IllegalArgumentException](BoardProfile(values.updated("interruptSources", sources)))
  }

}
