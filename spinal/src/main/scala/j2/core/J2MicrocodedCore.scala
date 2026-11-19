package j2.core

import spinal.core._
import spinal.lib.misc.plugin._

/** Stable external CPU interface; all hardware ownership lives in plugins. */
final class J2MicrocodedCore(
    val config: J2CoreConfig,
    pluginFactory: J2CoreConfig => Seq[FiberPlugin]
) extends Component {
  def this(config: J2CoreConfig) = this(config, J2CorePlugins.apply _)
  def this(exposeDebug: Boolean = true) =
    this(J2CoreConfig(exposeDebug = exposeDebug))

  val exposeDebug = config.exposeDebug
  val io          = new J2CoreIo(config)
  val host        = new PluginHost
  val plugins     = pluginFactory(config) :+ new J2ExternalPlugin(io)
  J2CorePlugins.validate(plugins)
  host.asHostOf(plugins)
}
