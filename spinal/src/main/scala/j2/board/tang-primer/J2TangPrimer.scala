package j2.board.tang_primer

import j2.soc.{J2ResetController, J2SocConfig}
import spinal.core._

final class J2TangPrimer(
    socConfig: J2SocConfig,
    forFpga: Boolean = false,
    usePll: Boolean = true
) extends Component {
  require(
    socConfig.memoryBytes == 0x800000 && socConfig.memoryBase % 0x800000 == 0,
    "Tang SDRAM controller uses an aligned 8 MiB window"
  )
  private val clockHz = socConfig.clockHz
  require(clockHz > 0)
  require(
    !forFpga || usePll || clockHz == 24000000,
    "PLL bypass runs at 24 MHz; set J2_CLOCK_HZ=24000000"
  )
  setDefinitionName("j2_tang_primer")
  val io = new Bundle {
    val clk24         = in Bool ()
    val rstN          = in Bool ()
    val uartRx        = in Bool ()
    val uartTx        = out Bool ()
    val gpio          = inout(Analog(Bits(32 bits)))
    val spiClk        = out Bool ()
    val spiCs         = out Bool ()
    val spiData       = inout(Analog(Bits(4 bits)))
    val spiDataEnable = if (!forFpga) out Bits (4 bits) else null
  }
  io.clk24.setName("clk24")
  io.rstN.setName("rst_n")
  io.uartRx.setName("uart_rx")
  io.uartTx.setName("uart_tx")
  io.gpio.setName("gpio")
  io.spiClk.setName("spi_clk")
  io.spiCs.setName("spi_cs")
  io.spiData.setName("spi_data")
  if (!forFpga) io.spiDataEnable.setName("spi_data_enable")
  private val clockLocked = Bool()
  private val socClock = if (forFpga && usePll) {
    val vcoHz = if (clockHz == 32000000) 384000000 else 360000000
    require(vcoHz % clockHz == 0, "J2_CLOCK_HZ must divide the PLL VCO exactly")
    val pll = new Eg4Pll(
      feedbackDivider = vcoHz / 24000000,
      outputDivider   = vcoHz / clockHz
    )
    val buffer = new Eg4Bufg
    pll.refclk   := io.clk24
    pll.reset    := False
    pll.load_reg := False
    pll.stdby    := False
    pll.fbclk    := False // Internal VCO feedback; external feedback is unused.
    pll.psclk    := False
    pll.psdown   := False
    pll.psstep   := False
    pll.psclksel := 0
    pll.dclk     := False
    pll.dcs      := False
    pll.dwe      := False
    pll.di       := 0
    pll.daddr    := 0
    buffer.i     := pll.clkc(0)
    clockLocked  := pll.extlock
    buffer.o
  } else {
    clockLocked := True
    io.clk24
  }
  private val resetController = new J2ResetController
  resetController.io.referenceClock := io.clk24
  resetController.io.systemClock    := socClock
  resetController.io.resetN         := io.rstN
  resetController.io.clockLocked    := clockLocked
  private val socDomain = ClockDomain(
    clock     = socClock,
    reset     = resetController.io.reset,
    frequency = FixedFrequency(clockHz Hz)
  )
  private val soc   = socDomain(new J2TangPrimerSoc(socConfig))
  private val sdram = socDomain(new J2Sdram)
  sdram.io.bus <> soc.io.memory
  soc.io.uartRx := io.uartRx
  io.uartTx     := soc.io.uartTx
  private val gpioPads = Seq.fill(32)(new Eg4GpioPad)
  for (bit <- 0 until 32) {
    val pad = gpioPads(bit)
    pad.ipad   := False
    pad.rst    := False
    pad.ce     := True
    pad.isclk  := False
    pad.ipclk  := False
    pad.osclk  := False
    pad.opclk  := False
    pad.ts     := !soc.io.gpio.writeEnable(bit)
    pad.doData := soc.io.gpio.write(bit).asBits.resize(4)
    pad.bpad <> io.gpio(bit)
    soc.io.gpio.read(bit) := pad.di
  }
  io.spiClk                      := soc.io.spiClk
  io.spiCs                       := soc.io.spiCs
  if (!forFpga) io.spiDataEnable := soc.io.spiData.writeEnable
  private val spiPads = Seq.fill(4)(new Eg4GpioPad)
  for (bit <- 0 until 4) {
    val pad = spiPads(bit)
    pad.ipad   := False
    pad.rst    := False
    pad.ce     := True
    pad.isclk  := False
    pad.ipclk  := False
    pad.osclk  := False
    pad.opclk  := False
    pad.ts     := !soc.io.spiData.writeEnable(bit)
    pad.doData := soc.io.spiData.write(bit).asBits.resize(4)
    pad.bpad <> io.spiData(bit)
    soc.io.spiData.read(bit) := pad.di
  }

  private val sdramPhy = new Eg4SdramPhy
  sdramPhy.clk   := socClock
  sdramPhy.ras_n := sdram.io.sdram.RASn
  sdramPhy.cas_n := sdram.io.sdram.CASn
  sdramPhy.we_n  := sdram.io.sdram.WEn
  sdramPhy.addr  := sdram.io.sdram.ADDR
  sdramPhy.ba    := sdram.io.sdram.BA
  sdramPhy.cs_n  := sdram.io.sdram.CSn
  sdramPhy.dm0   := sdram.io.sdram.DQM(0)
  sdramPhy.dm1   := sdram.io.sdram.DQM(1)
  sdramPhy.dm2   := sdram.io.sdram.DQM(2)
  sdramPhy.dm3   := sdram.io.sdram.DQM(3)
  sdramPhy.cke   := sdram.io.sdram.CKE
  private val sdramDq = Analog(Bits(32 bits))
  sdramPhy.dq <> sdramDq
  when(sdram.io.sdram.DQ.writeEnable(0)) {
    sdramDq := sdram.io.sdram.DQ.write
  }
  sdram.io.sdram.DQ.read := sdramDq
}
