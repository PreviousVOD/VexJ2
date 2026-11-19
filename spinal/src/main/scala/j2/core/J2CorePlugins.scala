package j2.core

import j2.core.fetch._
import j2.core.intc.J2IntcPlugin
import j2.core.ppb.J2PpbPlugin
import j2.core.decode._
import j2.core.execute._
import j2.core.regfile._
import j2.core.schedule._
import j2.core.misc._
import spinal.lib.misc.plugin._
import scala.reflect.ClassTag

object J2CorePlugins {
  def apply(config: J2CoreConfig): Seq[FiberPlugin] = Seq(
    new J2PpbPlugin,
    new J2IntcPlugin(config),
    new J2FetchPlugin,
    new J2MemoryPlugin,
    new J2DecodePlugin,
    new J2SchedulePlugin,
    new J2RegisterPlugin,
    new J2ExecutePlugin,
    new J2MultiplyPlugin,
    new J2ArchitecturalPlugin,
    new J2TrapPlugin,
    new J2ObservationPlugin(config.exposeDebug),
    new J2PipelineBuilderPlugin
  )

  def validate(plugins: Seq[FiberPlugin]): Unit = {
    def exactlyOne[T: ClassTag](): Unit = {
      val tag   = implicitly[ClassTag[T]]
      val count = plugins.count(p => p.pluginEnabled && tag.runtimeClass.isInstance(p))
      require(count == 1, s"expected exactly one ${tag.runtimeClass.getSimpleName}, found $count")
    }
    exactlyOne[J2ExternalService]()
    exactlyOne[J2CoreBusService]()
    exactlyOne[J2InterruptService]()
    exactlyOne[J2FetchService]()
    exactlyOne[J2MemoryService]()
    exactlyOne[J2DecodeService]()
    exactlyOne[J2ScheduleService]()
    exactlyOne[J2RegisterService]()
    exactlyOne[J2ExecuteService]()
    exactlyOne[J2MultiplyService]()
    exactlyOne[J2ArchitecturalService]()
    exactlyOne[J2TrapService]()
    exactlyOne[J2PipelineService]()
    exactlyOne[J2PipelineBuilderPlugin]()
  }
}

final class J2ExternalPlugin(val external: J2CoreIo) extends FiberPlugin with J2ExternalService
