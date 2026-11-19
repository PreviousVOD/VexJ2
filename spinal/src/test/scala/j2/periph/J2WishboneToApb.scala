package j2.periph

import j2.bus.J2Wishbone
import spinal.core._
import spinal.lib._
import spinal.lib.bus.amba3.apb._

// Legacy SPI stimulus adapter; production uses the native AHB5-to-APB bridge.
final class J2WishboneToApb(config: Apb3Config) extends Component {
  val io = new Bundle {
    val input  = slave(J2Wishbone())
    val output = master(Apb3(config))
  }
  private val enable = RegInit(False)
  io.output.PADDR   := io.input.ADR(config.addressWidth - 1 downto 0)
  io.output.PSEL    := B(io.input.CYC && io.input.STB)
  io.output.PENABLE := enable
  io.output.PWRITE  := io.input.WE
  io.output.PWDATA  := io.input.DAT_MOSI
  when(!enable && io.input.CYC && io.input.STB) {
    enable := True
  }
  when(enable && io.output.PREADY) {
    enable := False
  }
  io.input.ACK      := enable && io.output.PREADY
  io.input.DAT_MISO := io.output.PRDATA
  io.input.ERR      := False
}
