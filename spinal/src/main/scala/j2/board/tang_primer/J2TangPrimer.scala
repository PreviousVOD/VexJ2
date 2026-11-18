package j2.board.tang_primer

import j2.soc.{J2ResetController, J2Soc}
import spinal.core._

final class J2TangPrimer(
    clockHz: Int = 32000000,
    useEg4Rom: Boolean = false,
    usePll: Boolean = true
) extends Component {
  require(clockHz > 0)
  require(
    !useEg4Rom || usePll || clockHz == 24000000,
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
    val spiDataEnable = if (!useEg4Rom) out Bits (4 bits) else null
  }
  io.clk24.setName("clk24")
  io.rstN.setName("rst_n")
  io.uartRx.setName("uart_rx")
  io.uartTx.setName("uart_tx")
  io.gpio.setName("gpio")
  io.spiClk.setName("spi_clk")
  io.spiCs.setName("spi_cs")
  io.spiData.setName("spi_data")
  if (!useEg4Rom) io.spiDataEnable.setName("spi_data_enable")
  private val clockLocked = Bool()
  private val socClock = if (useEg4Rom && usePll) {
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
  private val soc = ClockDomain(
    clock     = socClock,
    reset     = resetController.io.reset,
    frequency = FixedFrequency(clockHz Hz)
  )(new J2Soc(useEg4Rom, clockHz))
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
  io.spiClk                        := soc.io.spiClk
  io.spiCs                         := soc.io.spiCs
  if (!useEg4Rom) io.spiDataEnable := soc.io.spiData.writeEnable
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
  sdramPhy.ras_n := soc.sdramInterface.RASn
  sdramPhy.cas_n := soc.sdramInterface.CASn
  sdramPhy.we_n  := soc.sdramInterface.WEn
  sdramPhy.addr  := soc.sdramInterface.ADDR
  sdramPhy.ba    := soc.sdramInterface.BA
  sdramPhy.cs_n  := soc.sdramInterface.CSn
  sdramPhy.dm0   := soc.sdramInterface.DQM(0)
  sdramPhy.dm1   := soc.sdramInterface.DQM(1)
  sdramPhy.dm2   := soc.sdramInterface.DQM(2)
  sdramPhy.dm3   := soc.sdramInterface.DQM(3)
  sdramPhy.cke   := soc.sdramInterface.CKE
  private val sdramDq = Analog(Bits(32 bits))
  sdramPhy.dq <> sdramDq
  when(soc.sdramInterface.DQ.writeEnable(0)) {
    sdramDq := soc.sdramInterface.DQ.write
  }
  soc.sdramInterface.DQ.read := sdramDq
}
