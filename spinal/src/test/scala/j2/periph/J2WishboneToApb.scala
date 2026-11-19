package j2.periph

import j2.bus.J2Wishbone
import spinal.core._
import spinal.lib._
import j2.bus.apb._

// Legacy SPI stimulus adapter; production uses the native AHB5-to-APB bridge.
final class J2WishboneToApb(config: Apb4Config) extends Component {
  val io = new Bundle {
    val input  = slave(J2Wishbone())
    val output = master(Apb4(config))
  }
  private val enable = RegInit(False)
  io.output.PADDR   := io.input.ADR(config.addressWidth - 1 downto 0)
  io.output.PSEL    := B(io.input.CYC && io.input.STB)
  io.output.PENABLE := enable
  io.output.PWRITE  := io.input.WE
  io.output.PWDATA  := io.input.DAT_MOSI
  io.output.PSTRB   := Mux(io.input.WE, io.input.SEL, B(0, 4 bits))
  io.output.PPROT   := 1
  when(!enable && io.input.CYC && io.input.STB) {
    enable := True
  }
  when(enable && io.output.PREADY) {
    enable := False
  }
  io.input.ACK      := enable && io.output.PREADY && !io.output.PSLVERR
  io.input.DAT_MISO := io.output.PRDATA
  io.input.ERR      := enable && io.output.PREADY && io.output.PSLVERR
}
