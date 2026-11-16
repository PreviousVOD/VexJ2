package j2.execute

import j2.core._
import spinal.core._
import spinal.lib.misc.plugin.FiberPlugin

final class J2ExecutePlugin extends FiberPlugin with J2ExecuteService {
  val allocation = during build new Area {
    val port     = new J2ExecutePort
    val datapath = new J2Datapath
    port.xbus             := datapath.io.xbus
    port.ybus             := datapath.io.ybus
    port.zbus             := datapath.io.zbus
    port.memoryAddress    := datapath.io.memoryAddress
    port.memoryWriteData  := datapath.io.memoryWriteData
    port.arithmeticResult := datapath.io.arithmeticResult
    port.arithmeticSr     := datapath.io.arithmeticSr
    port.logicSr          := datapath.io.logicSr
    port.shiftT           := datapath.io.shiftT
  }
  override def execute: J2ExecutePort = allocation.get.port

  val logic = during build new Area {
    val io  = allocation.get.datapath.io
    val s   = host[J2ScheduleService].schedule
    val r   = host[J2RegisterService].registers
    val pc  = host[J2ArchitecturalService].architectural
    val m   = host[J2MemoryService].memory
    val mul = host[J2MultiplyService].multiply
    io.ex              := s.state.ex1
    io.exStall         := s.state.ex1Stall
    io.regX            := r.x
    io.regY            := r.y
    io.reg0            := r.r0
    io.pc              := pc.pc
    io.sr              := pc.status
    io.mach            := mul.mach
    io.macl            := mul.macl
    io.wbus            := m.read
    io.yOverrideEnable := False
    io.yOverride       := 0
  }
}
