package j2.core

import spinal.core._

final class J2RegisterWrite extends Bundle {
  val enable = Bool()
  val address = UInt(5 bits)
  val data = UInt(32 bits)
}

object J2RegisterWrite {
  def empty(): J2RegisterWrite = {
    val value = new J2RegisterWrite
    value.enable := False
    value.address := 0
    value.data := 0
    value
  }
}

final class J2PipelineRegFile extends Component {
  val io = new Bundle {
    val slot = in Bool ()
    val readX = in UInt (5 bits)
    val readY = in UInt (5 bits)
    val writeW = in(new J2RegisterWrite)
    val writeZ = in(new J2RegisterWrite)
    val x = out UInt (32 bits)
    val y = out UInt (32 bits)
    val r0 = out UInt (32 bits)
    val writeData = out UInt (32 bits)
  }

  private val registers = Vec(Reg(UInt(32 bits)) init 0, 21)
  private val z1 = Reg(J2RegisterWrite.empty())
  private val z2 = Reg(J2RegisterWrite.empty())

  private def read(address: UInt): UInt =
    Mux(
      io.writeW.enable && io.writeW.address === address,
      io.writeW.data,
      Mux(
        z1.enable && z1.address === address,
        z1.data,
        Mux(z2.enable && z2.address === address, z2.data, registers(address))
      )
    )

  io.x := read(io.readX)
  io.y := read(io.readY)
  io.r0 := read(U(0, 5 bits))
  io.writeData := Mux(z2.enable, z2.data, io.writeW.data)

  when(io.slot) {
    when(io.writeW.enable || z2.enable) {
      when(z2.enable) {
        registers(z2.address) := z2.data
      } otherwise {
        registers(io.writeW.address) := io.writeW.data
      }
    }
    z2 := z1
    z1 := io.writeZ
  }

  when(ClockDomain.current.isResetActive) {
    for (index <- 0 until 21) registers(index) := 0
    z1 := J2RegisterWrite.empty()
    z2 := J2RegisterWrite.empty()
  }
}
