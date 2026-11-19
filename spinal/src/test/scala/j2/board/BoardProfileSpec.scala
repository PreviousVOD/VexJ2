package j2.board

class BoardProfileSpec extends munit.FunSuite {
  test("both boards share the schema and produce generic SoC memory windows") {
    val tang   = BoardProfile.load("tang-primer", Map.empty)
    val wukong = BoardProfile.load("wukong-v1", Map.empty)
    assertEquals(tang.values.keySet, wukong.values.keySet)
    assertEquals(tang.socConfig("rom.hex").memoryBytes, BigInt(0x800000))
    assertEquals(wukong.socConfig("rom.hex").memoryBytes, BigInt(0x10000000))
    assertEquals(tang.clockHz, 32000000)
    assertEquals(wukong.clockHz, 72000000)
  }
  test("Tang diagnostic clock overrides cannot leak into Wukong") {
    val env = Map("J2_CLOCK_HZ" -> "24000000", "J2_USE_PLL" -> "0")
    assertEquals(BoardProfile.load("tang-primer", env).clockHz, 24000000)
    assertEquals(BoardProfile.load("wukong-v1", env).clockHz, 72000000)
    intercept[IllegalArgumentException](BoardProfile.load("tang-primer", Map("J2_USE_PLL" -> "0")))
  }
  test("reject incompatible physical memory and out-of-range flash partitions") {
    for (board <- Seq("tang-primer", "wukong-v1")) {
      val values = BoardProfile.load(board, Map.empty).values
      intercept[IllegalArgumentException](BoardProfile(values.updated("memoryType", "unknown")))
      intercept[IllegalArgumentException](BoardProfile(values.updated("memoryBytes", "0x20000000")))
      intercept[IllegalArgumentException](BoardProfile(values.updated("xipBytes", "0x02000000")))
    }
  }
  test("SRAM size reaches SoC configuration and rejects invalid sizes or overlaps") {
    val values = BoardProfile.load("wukong-v1", Map.empty).values
    assertEquals(BoardProfile(values.updated("sramBytes", "65536")).socConfig("").sramBytes, 65536)
    for (size <- Seq("0", "2048", "49152", "0x10000000", "0x100000000"))
      intercept[IllegalArgumentException](BoardProfile(values.updated("sramBytes", size)))
  }
}
