package j2.core

import spinal.core._

final class J2ReadPort extends Bundle {
  val address = in UInt (4 bits)
  val data = out UInt (32 bits)
}

final class J2WritePort extends Bundle {
  val enable = in Bool ()
  val address = in UInt (4 bits)
  val data = in UInt (32 bits)
}

final class J2RegFile extends Component {
  val io = new Bundle {
    val readA = new J2ReadPort
    val readB = new J2ReadPort
    val writeW = new J2WritePort
    val writeZ = new J2WritePort
  }

  val registers = Vec(Reg(UInt(32 bits)) init 0, 16)

  io.readA.data := Mux(
    io.writeW.enable && io.writeW.address === io.readA.address,
    io.writeW.data,
    Mux(
      io.writeZ.enable && io.writeZ.address === io.readA.address,
      io.writeZ.data,
      registers(io.readA.address)
    )
  )
  io.readB.data := Mux(
    io.writeW.enable && io.writeW.address === io.readB.address,
    io.writeW.data,
    Mux(
      io.writeZ.enable && io.writeZ.address === io.readB.address,
      io.writeZ.data,
      registers(io.readB.address)
    )
  )

  when(ClockDomain.current.isResetActive) {
    for (index <- 0 until 16) registers(index) := 0
  } otherwise {
    when(io.writeW.enable) {
      registers(io.writeW.address) := io.writeW.data
    }
    when(io.writeZ.enable) {
      registers(io.writeZ.address) := io.writeZ.data
    }
  }
}
