package j2.core

import j2.Generate

/** Event-injection interface used by the standalone C++ ISA harness. */
object GenerateCoreVerification extends App {
  require(args.isEmpty, "GenerateCoreVerification takes no arguments")
  Generate
    .config(sys.env.getOrElse("J2_SPINAL_OUT", "../build/spinal/verif/microcoded/rtl"))
    .generateVerilog(new J2Core(J2CoreConfig(exposeDebug = true, eventInjection = true)))
}
