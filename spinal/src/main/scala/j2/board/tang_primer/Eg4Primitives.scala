package j2.board.tang_primer

import j2.microcode.J2MicrocodeRomIo
import spinal.core._

final class Eg4GpioPad extends BlackBox {
  val ipad   = in Bool ()
  val opad   = out Bool ()
  val bpad   = inout(Analog(Bool()))
  val rst    = in Bool ()
  val ce     = in Bool ()
  val isclk  = in Bool ()
  val ipclk  = in Bool ()
  val osclk  = in Bool ()
  val opclk  = in Bool ()
  val ts     = in Bool ()
  val doData = in Bits (4 bits)
  doData.setName("do")
  val di  = out Bool ()
  val diq = out Bits (4 bits)
  setDefinitionName("EG_PHY_PAD")
  addGeneric("MODE", "BI")
  addGeneric("TSMUX", "TS")
  addGeneric("IOTYPE", "LVCMOS33")
  addGeneric("DRIVE", "12")
}

final class Eg4SdramPhy extends BlackBox {
  val clk   = in Bool ()
  val ras_n = in Bool ()
  val cas_n = in Bool ()
  val we_n  = in Bool ()
  val addr  = in Bits (11 bits)
  val ba    = in Bits (2 bits)
  val dq    = inout(Analog(Bits(32 bits)))
  val cs_n  = in Bool ()
  val dm0   = in Bool ()
  val dm1   = in Bool ()
  val dm2   = in Bool ()
  val dm3   = in Bool ()
  val cke   = in Bool ()
  setDefinitionName("EG_PHY_SDRAM_2M_32")
}

final class Eg4Bram32 extends BlackBox {
  val dia   = in Bits (32 bits)
  val dib   = in Bits (32 bits)
  val addra = in UInt (13 bits)
  val addrb = in UInt (13 bits)
  val cea   = in Bool ()
  val ceb   = in Bool ()
  val ocea  = in Bool ()
  val oceb  = in Bool ()
  val clka  = in Bool ()
  val clkb  = in Bool ()
  val wea   = in Bool ()
  val web   = in Bool ()
  val rsta  = in Bool ()
  val rstb  = in Bool ()
  val bea   = in Bool ()
  val beb   = in Bool ()
  val doa   = out Bits (32 bits)
  val dob   = out Bits (32 bits)
  setDefinitionName("EG_LOGIC_BRAM")
  addGeneric("DATA_WIDTH_A", 32)
  addGeneric("DATA_WIDTH_B", 32)
  addGeneric("ADDR_WIDTH_A", 13)
  addGeneric("ADDR_WIDTH_B", 13)
  addGeneric("DATA_DEPTH_A", 8192)
  addGeneric("DATA_DEPTH_B", 8192)
  addGeneric("BYTE_ENABLE", 0)
  addGeneric("BYTE_A", 1)
  addGeneric("BYTE_B", 1)
  addGeneric("MODE", "SP")
  addGeneric("REGMODE_A", "NOREG")
  addGeneric("REGMODE_B", "NOREG")
  addGeneric("WRITEMODE_A", "NORMAL")
  addGeneric("WRITEMODE_B", "NORMAL")
  addGeneric("RESETMODE", "SYNC")
  addGeneric("IMPLEMENT", "32K")
  addGeneric("INIT_FILE", "j2_validation_rom.mif")
  addGeneric("FILL_ALL", "NONE")
}

final class Eg4MicrocodeRom(
    initFile: String = "../../microcode/j2_microcode.mif"
) extends BlackBox
    with j2.microcode.J2MicrocodeRomPort {
  val io = new J2MicrocodeRomIo
  setDefinitionName("j2_microcode_rom")
  noIoPrefix()
  addGeneric("INIT_FILE", initFile)
}
