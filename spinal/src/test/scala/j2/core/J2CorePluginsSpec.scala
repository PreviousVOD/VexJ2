package j2.core

import j2.core.regfile.J2RegisterPlugin
import j2.core.ppb.J2PpbPlugin
import spinal.core._
import spinal.core.sim._

class J2CorePluginsSpec extends munit.FunSuite {
  test("observation configurations elaborate through the same composition") {
    for (debug <- Seq(false, true)) {
      val config = J2CoreConfig(exposeDebug = debug)
      SpinalConfig(targetDirectory = s"simWorkspace/plugin-config-$debug")
        .generateVerilog(new J2MicrocodedCore(config))
    }
  }

  test("missing and duplicate required services fail before plugin elaboration") {
    for (duplicate <- Seq(false, true)) {
      val error = intercept[Exception] {
        SpinalConfig(targetDirectory = "simWorkspace/plugin-invalid").generateVerilog(
          new J2MicrocodedCore(
            J2CoreConfig(),
            config => {
              val plugins = J2CorePlugins(config)
              if (duplicate) plugins :+ new J2RegisterPlugin
              else plugins.filterNot(_.isInstanceOf[J2RegisterService])
            }
          )
        )
      }
      assert(error.toString.contains("J2RegisterService"), error.toString)
    }
  }

  test("private bus service is mandatory and unique") {
    for (duplicate <- Seq(false, true)) {
      val error = intercept[Exception] {
        SpinalConfig(targetDirectory = "simWorkspace/plugin-invalid-ppb").generateVerilog(
          new J2MicrocodedCore(
            J2CoreConfig(),
            config => {
              val plugins = J2CorePlugins(config)
              if (duplicate) plugins :+ new J2PpbPlugin
              else plugins.filterNot(_.isInstanceOf[J2CoreBusService])
            }
          )
        )
      }
      assert(error.toString.contains("J2CoreBusService"), error.toString)
    }
  }

  test("microstep addresses remain aligned across freeze and selective cancellation") {
    class Probe extends Component {
      val io = new Bundle {
        val advance, bubble, cancel = in Bool ()
        val pc                      = in UInt (32 bits)
        val state                   = out(new J2PipelineState)
      }
      val metadata = new J2InstructionMetadata
      metadata.pc       := io.pc
      metadata.resumePc := io.pc + 2
      val exActions = J2ControlDefaults.exStall()
      val wbActions = J2ControlDefaults.wbStall()
      exActions.regWriteZ.allowOverride
      wbActions.regWriteW.allowOverride
      exActions.regWriteZ := True
      wbActions.regWriteW := True
      val request = new J2MemoryRequest
      request.assignFromBits(B(0, request.getBitsWidth bits))
      val graph = new J2PipelineLogic(
        io.advance,
        io.bubble,
        io.cancel,
        J2ControlDefaults.ex(),
        exActions,
        J2ControlDefaults.wb(),
        wbActions,
        metadata,
        request
      )
      io.state := graph.state
      graph.build()
    }
    SimConfig.withVerilator.compile(new Probe).doSim { dut =>
      dut.io.advance #= false
      dut.io.bubble  #= false
      dut.io.cancel  #= false
      dut.io.pc      #= 0x100
      dut.clockDomain.forkStimulus(10)
      dut.clockDomain.assertReset()
      dut.clockDomain.waitSampling(2)
      dut.clockDomain.deassertReset()
      dut.io.advance #= true
      dut.clockDomain.waitSampling()
      sleep(1)
      assertEquals(dut.io.state.exMetadata.resumePc.toLong, 0x102L)
      dut.io.advance #= false
      dut.io.pc      #= 0x200
      dut.clockDomain.waitSampling(3)
      sleep(1)
      assertEquals(dut.io.state.exMetadata.pc.toLong, 0x100L)
      dut.io.advance #= true
      dut.clockDomain.waitSampling()
      sleep(1)
      assertEquals(dut.io.state.maMetadata.pc.toLong, 0x100L)
      assertEquals(dut.io.state.exMetadata.pc.toLong, 0x200L)
      dut.io.pc     #= 0x300
      dut.io.cancel #= true
      dut.io.bubble #= true
      dut.clockDomain.waitSampling()
      sleep(1)
      assertEquals(dut.io.state.wbMetadata.pc.toLong, 0x100L)
      assertEquals(dut.io.state.maMetadata.pc.toLong, 0x200L)
      assert(dut.io.state.wbAction.regWriteW.toBoolean, "older writeback drains")
      assert(!dut.io.state.maAction.regWriteW.toBoolean, "younger writeback is cancelled")
      assert(!dut.io.state.exAction.regWriteZ.toBoolean, "decode hazards insert a bubble")
      assertEquals(dut.io.state.exMetadata.resumePc.toLong, 0x302L)
    }
  }
}
