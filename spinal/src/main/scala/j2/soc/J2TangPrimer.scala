package j2.soc

import j2.periph.Eg4GpioPad
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
    val clk24 = in Bool ()
    val rstN = in Bool ()
    val uartRx = in Bool ()
    val uartTx = out Bool ()
    val gpio = inout(Analog(Bits(32 bits)))
    val spiClk = out Bool ()
    val spiCs = out Bool ()
    val spiMosi = out Bool ()
    val spiMiso = in Bool ()
    val spiWpN = out Bool ()
    val spiHoldN = out Bool ()
  }
  io.clk24.setName("clk24")
  io.rstN.setName("rst_n")
  io.uartRx.setName("uart_rx")
  io.uartTx.setName("uart_tx")
  io.gpio.setName("gpio")
  io.spiClk.setName("spi_clk")
  io.spiCs.setName("spi_cs")
  io.spiMosi.setName("spi_mosi")
  io.spiMiso.setName("spi_miso")
  io.spiWpN.setName("spi_wp_n")
  io.spiHoldN.setName("spi_hold_n")
  private val clockLocked = Bool()
  private val socClock = if (useEg4Rom && usePll) {
    val vcoHz = if (clockHz == 32000000) 384000000 else 360000000
    require(vcoHz % clockHz == 0, "J2_CLOCK_HZ must divide the PLL VCO exactly")
    val pll = new Eg4Pll(
      feedbackDivider = vcoHz / 24000000,
      outputDivider = vcoHz / clockHz
    )
    val buffer = new Eg4Bufg
    pll.refclk := io.clk24
    pll.reset := False
    pll.load_reg := False
    pll.stdby := False
    pll.fbclk := False // Internal VCO feedback; external feedback is unused.
    pll.psclk := False
    pll.psdown := False
    pll.psstep := False
    pll.psclksel := 0
    pll.dclk := False
    pll.dcs := False
    pll.dwe := False
    pll.di := 0
    pll.daddr := 0
    buffer.i := pll.clkc(0)
    clockLocked := pll.extlock
    buffer.o
  } else {
    clockLocked := True
    io.clk24
  }
  private val resetController = new J2ResetController
  resetController.io.referenceClock := io.clk24
  resetController.io.systemClock := socClock
  resetController.io.resetN := io.rstN
  resetController.io.clockLocked := clockLocked
  private val soc = ClockDomain(
    clock = socClock,
    reset = resetController.io.reset,
    frequency = FixedFrequency(clockHz Hz)
  )(new J2Soc(useEg4Rom, clockHz))
  soc.io.uartRx := io.uartRx
  io.uartTx := soc.io.uartTx
  private val gpioPads = Seq.fill(32)(new Eg4GpioPad)
  for (bit <- 0 until 32) {
    val pad = gpioPads(bit)
    pad.ipad := False
    pad.rst := False
    pad.ce := True
    pad.isclk := False
    pad.ipclk := False
    pad.osclk := False
    pad.opclk := False
    pad.ts := !soc.io.gpio.writeEnable(bit)
    pad.doData := soc.io.gpio.write(bit).asBits.resize(4)
    pad.bpad <> io.gpio(bit)
    soc.io.gpio.read(bit) := pad.di
  }
  io.spiClk := soc.io.spiClk
  io.spiCs := soc.io.spiCs
  io.spiMosi := soc.io.spiMosi
  soc.io.spiMiso := io.spiMiso
  io.spiWpN := soc.io.spiWpN
  io.spiHoldN := soc.io.spiHoldN
}
