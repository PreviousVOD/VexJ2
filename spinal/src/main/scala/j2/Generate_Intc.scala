package j2

import j2.core.intc._
import java.nio.charset.StandardCharsets
import java.nio.file.{Files, Paths}

/** Standalone generator: count, output directory, then optional ordered source names. */
object Generate_Intc extends App {
  require(args.length >= 2, "expected: source-count output-directory [SOURCE_NAME ...]")
  private val intcConfig = IntcConfig(args(0).toInt)
  private val header     = IntcRegisters.header(intcConfig, args.drop(2).toSeq)
  private val output     = Paths.get(args(1))
  Files.createDirectories(output)
  Generate.config(output.toString).generateVerilog(new J2Intc(intcConfig))
  Files.write(output.resolve("j2_intc.h"), header.getBytes(StandardCharsets.UTF_8))
}
