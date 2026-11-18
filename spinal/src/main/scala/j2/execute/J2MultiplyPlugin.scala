package j2.execute

import j2.core._
import spinal.core._
import spinal.lib.misc.plugin.FiberPlugin

final class J2MultiplyPlugin extends FiberPlugin with J2MultiplyService {
  val allocation = during build new Area {
    val port = new J2MultiplyPort
    val unit = new J2Multiply
    val macS = RegInit(False)
    port.busy := unit.io.busy
    port.mach := unit.io.mach
    port.macl := unit.io.macl
  }
  override def multiply: J2MultiplyPort = allocation.get.port

  val logic = during build new Area {
    val io   = allocation.get.unit.io
    val macS = allocation.get.macS
    val s    = host[J2ScheduleService].schedule
    val m    = host[J2MemoryService].memory
    val e    = host[J2ExecuteService].execute
    val d    = host[J2DecodeService].decode
    val pc   = host[J2ArchitecturalService].architectural
    when(s.advance && d.control.macSLatch)(macS := pc.nextStatus.s)
    val multiplyUseEx1 =
      !m.fault && (s.state.exAction.multiplyStart || s.state.exAction.machWrite)
    val multiplyUseEx2 =
      !m.fault && (s.state.exAction.multiplyCommand =/= J2MultiplyCommand.NOP ||
        s.state.exAction.maclWrite)
    val multiplySelect1 = Mux(
      multiplyUseEx1,
      s.state.exAction.macSelect1,
      s.state.wbAction.macSelect1
    )
    val multiplySelect2 = Mux(
      multiplyUseEx2,
      s.state.exAction.macSelect2,
      s.state.wbAction.macSelect2
    )

    // A command or special-register access must never disappear while busy.
    // This interlock covers memory-fed MAC microsteps as well as EX operations;
    // the arithmetic engine continues ticking while the slot is held.
    val readsResult = s.state.ex.ySelect === J2YBusSelect.MACH ||
      s.state.ex.ySelect === J2YBusSelect.MACL
    allocation.get.port.blocked := io.busy &&
      (io.command =/= J2MultiplyCommand.NOP || io.writeM1 || io.writeMach ||
        io.writeMacl || (!m.fault && readsResult))
    io.slot := s.advance
    io.command := Mux(
      !m.fault && s.state.exAction.multiplyCommand =/= J2MultiplyCommand.NOP,
      s.state.exAction.multiplyCommand,
      Mux(m.readValid, s.state.wbAction.multiplyCommand, J2MultiplyCommand.NOP)
    )
    io.in1 := multiplySelect1.mux(
      J2MacSelect1.XBUS -> e.xbus,
      J2MacSelect1.ZBUS -> e.zbus,
      J2MacSelect1.WBUS -> m.read
    )
    io.in2 := multiplySelect2.mux(
      J2MacSelect2.YBUS -> e.ybus,
      J2MacSelect2.ZBUS -> e.zbus,
      J2MacSelect2.WBUS -> m.read
    )
    io.s := macS
    io.writeM1 := (!m.fault && s.state.exAction.multiplyStart) ||
      (s.state.wbAction.multiplyStart && m.readValid)
    io.writeMach := (!m.fault && s.state.exAction.machWrite) ||
      (s.state.wbAction.machWrite && m.readValid)
    io.writeMacl := (!m.fault && s.state.exAction.maclWrite) ||
      (s.state.wbAction.maclWrite && m.readValid)

  }
}
