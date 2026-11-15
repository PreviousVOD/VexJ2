package j2.soc

import j2.periph.{Eg4GpioPad, Eg4SdramPhy}
import spinal.core._
import spinal.lib.memory.sdram.sdr.EG4S20

final class J2TangPrimer(
    clockHz: Int = 30000000,
    useEg4Rom: Boolean = false,
    usePll: Boolean = true
) extends Component {
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
  private val socClock = if (useEg4Rom && usePll) {
    val pll = new Eg4Pll(feedbackDivider = 15, outputDivider = 360000000 / clockHz)
    val buffer = new Eg4Bufg
    pll.refclk := io.clk24
    pll.reset := False
    pll.stdby := False
    pll.fbclk := buffer.o
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
    buffer.o
  } else {
    io.clk24
  }
  private val reset = Bool()
  ClockDomain(socClock, !io.rstN) {
    val count = RegInit(U(3, 2 bits))
    when(!io.rstN) {
      count := 3
    }.elsewhen(count =/= 0) {
      count := count - 1
    }
    reset := !io.rstN || count =/= 0
  }
  private val soc = ClockDomain(
    clock = socClock,
    reset = reset,
    frequency = FixedFrequency(clockHz Hz)
  )(new J2Soc(useEg4Rom))
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
