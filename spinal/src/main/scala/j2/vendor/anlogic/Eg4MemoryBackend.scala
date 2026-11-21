package j2.vendor.anlogic

import j2.memory.MemoryBackend
import java.nio.charset.StandardCharsets
import java.nio.file.{Files, Paths}
import spinal.core._
import spinal.core.internals._

/** Initialized block ROMs use EG4's separate 32K pool; writable RAM retains TD inference. */
case object Eg4MemoryBackend extends MemoryBackend {
  override def configure(config: SpinalConfig): SpinalConfig = {
    config.memBlackBoxers += new Eg4RomPhase
    config
  }
}

/** EG4 ROMs use the separate 32K pool; writable memories retain TD inference. */
final private[anlogic] class Eg4RomPhase extends PhaseMemBlackboxing {
  override def doBlackboxing(pc: PhaseContext, topo: MemTopology): Unit = {
    val mem = topo.mem
    if (mem.technology != ramBlock || topo.writes.nonEmpty || topo.readWriteSync.nonEmpty) return
    require(mem.initialContent != null, "EG4 block ROM requires initialization")
    require(
      topo.portCount == 1 && topo.readsSync.size == 1,
      "EG4 block ROM requires one synchronous read port"
    )
    val rd = topo.readsSync.head
    require(rd.clockDomain.config.clockEdge == RISING, "EG4 block ROM requires a rising-edge clock")
    require(
      rd.getWidth == mem.width && rd.address.getWidth == mem.addressWidth,
      "EG4 block ROM requires a full-width read"
    )

    // Include dimensions and contents in the name: multiple top-level outputs
    // can share a directory without overwriting a different ROM's image.
    val words = mem.initialContent.toVector
    val contents = words.zipWithIndex
      .map { case (word, address) =>
        s"${address.toHexString} : ${word.toString(16)};"
      }
      .mkString("\n")
    val mif =
      s"DEPTH = ${mem.wordCount};\nWIDTH = ${mem.width};\nADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT BEGIN\n$contents\nEND;\n"
    val bytes = mif.getBytes(StandardCharsets.US_ASCII)
    val digest = java.security.MessageDigest
      .getInstance("SHA-256")
      .digest(bytes)
      .map(b => f"${b & 0xff}%02x")
      .mkString
    val fileName  = s"rom_${mem.wordCount}x${mem.width}_$digest.mif"
    val directory = Paths.get(pc.config.targetDirectory)
    Files.createDirectories(directory)
    Files.write(directory.resolve(fileName), bytes)

    mem.component.rework {
      val rom = new Eg4BlockRom(mem.width, mem.wordCount, fileName)
      rom.setName(mem.getName())
      rom.addra.assignFrom(rd.address)
      val enable = Bool()
      enable.assignFrom(rd.readEnable)
      rom.cea  := enable && rd.clockDomain.isClockEnableActive
      rom.clka := rd.clockDomain.readClockWire
      wrapConsumers(topo, rd, rom.doa)
      removeMem(mem)
    }
  }
}

/** Same single-port, unregistered-output macro configuration as the proven ROMs. */
final private[anlogic] class Eg4BlockRom(width: Int, depth: Int, initFile: String)
    extends BlackBox {
  val dia   = in Bits (width bits)
  val dib   = in Bits (width bits)
  val addra = in UInt (log2Up(depth) bits)
  val addrb = in UInt (log2Up(depth) bits)
  val cea, ceb, ocea, oceb, clka, clkb, wea, web, rsta, rstb, bea, beb = in Bool ()
  val doa, dob                                                         = out Bits (width bits)
  setDefinitionName("EG_LOGIC_BRAM")
  for (port <- Seq("A", "B")) {
    addGeneric(s"DATA_WIDTH_$port", width)
    addGeneric(s"ADDR_WIDTH_$port", log2Up(depth))
    addGeneric(s"DATA_DEPTH_$port", depth)
    addGeneric(s"BYTE_$port", 1)
    addGeneric(s"REGMODE_$port", "NOREG")
    addGeneric(s"WRITEMODE_$port", "NORMAL")
  }
  addGeneric("BYTE_ENABLE", 0)
  addGeneric("MODE", "SP")
  addGeneric("RESETMODE", "SYNC")
  addGeneric("IMPLEMENT", "32K")
  addGeneric("INIT_FILE", initFile)
  addGeneric("FILL_ALL", "NONE")
  // Tie unused inputs from the parent, leaving clock/address/enable as the ROM interface.
  parent.rework {
    dia  := 0; dib      := 0; addrb    := 0
    ceb  := False; ocea := False; oceb := False
    clkb := clka
    wea  := False; web  := False; bea  := False; beb := False
    rsta := False; rstb := False
  }
}
