package j2.board

import j2.soc.{J2Soc, J2SocConfig}
import j2.board.wukong_v1.{J2AhbDdrBridge, J2MigPort}
import spinal.lib._
import spinal.lib.io.TriStateArray
import spinal.core._

final class WukongSocFixture(config: J2SocConfig) extends Component {
  val io = new Bundle {
    val clock, memoryClock, reset, uartRx = in Bool ()
    val uartTx, spiCs, spiClk             = out Bool ()
    val spiData                           = master(TriStateArray(4))
    val native                            = master(J2MigPort())
  }
  val busDomain    = ClockDomain(io.clock, io.reset, frequency = FixedFrequency(config.clockHz Hz))
  val memoryDomain = ClockDomain(io.memoryClock, io.reset, frequency = FixedFrequency(83333333 Hz))
  val soc          = busDomain(new J2Soc(config))
  soc.io.uartRx    := io.uartRx; io.uartTx    := soc.io.uartTx
  soc.io.gpio.read := 0
  io.spiCs         := soc.io.spiCs; io.spiClk := soc.io.spiClk; io.spiData <> soc.io.spiData
  val bridge =
    new J2AhbDdrBridge(busDomain, memoryDomain, config.memoryBase, config.memoryBytes)
  bridge.io.bus <> soc.io.memory; bridge.io.native <> io.native
  bridge.io.calibrated := !io.reset
}

/** Compatibility entry point; make wukong-sim builds the isolated boot fixtures. */
object WukongSmokeSim extends App {
  WukongBootSim.main(args)
}
