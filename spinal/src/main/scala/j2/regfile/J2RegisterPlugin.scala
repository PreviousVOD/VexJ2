package j2.regfile

import j2.core._
import spinal.core._
import spinal.lib.misc.plugin.FiberPlugin

final class J2RegisterPlugin extends FiberPlugin with J2RegisterService {
  val allocation = during build new Area {
    val port = new J2RegisterPort
    val file = new J2PipelineRegFile
    port.x  := file.io.x
    port.y  := file.io.y
    port.r0 := file.io.r0
  }
  override def registers: J2RegisterPort = allocation.get.port

  val logic = during build new Area {
    val io = allocation.get.file.io
    val s  = host[J2ScheduleService].schedule
    val m  = host[J2MemoryService].memory
    val e  = host[J2ExecuteService].execute
    val pc = host[J2ArchitecturalService].architectural
    io.slot           := s.advance
    io.readX          := s.state.ex.regX
    io.readY          := s.state.ex.regY
    io.writeW.enable  := s.state.wbAction.regWriteW && m.readValid
    io.writeW.address := s.state.wb.regW
    io.writeW.data    := m.read
    io.writeZ.enable := s.state.exAction.regWriteZ && !m.fault &&
      (s.state.exAction.zSelect =/= J2ZBusSelect.WBUS || m.readValid)
    io.writeZ.address := s.state.ex.regZ
    io.writeZ.data    := Mux(s.state.exAction.prWritePc, pc.pc, e.zbus)
  }
}
