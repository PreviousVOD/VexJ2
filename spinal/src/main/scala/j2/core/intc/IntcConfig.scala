package j2.core.intc

final case class IntcConfig(peripheralCount: Int = 6) {
  require(peripheralCount >= 0 && peripheralCount <= 192, "SH-2 INTC supports 0–192 sources")
}

/** Offsets within the private 512-byte window; bank sizes reserve 256 source slots. */
object IntcRegisters {
  val nmiControl    = 0x000
  val setEnable     = 0x010
  val clearEnable   = 0x030
  val setPending    = 0x050
  val clearPending  = 0x070
  val priority      = 0x100
  val controlWords  = 8
  val priorityWords = 32
  val vectorBase    = 64

  def registerHeader: String = header(IntcConfig(0), includeSources = false)

  def header(
      config: IntcConfig,
      names: Seq[String] = Seq.empty,
      includeSources: Boolean = true
  ): String = {
    require(names.isEmpty || names.size == config.peripheralCount)
    require(names.distinct.size == names.size)
    require(
      names.forall(_.matches("[A-Z][A-Z0-9_]*")),
      "source names must be uppercase C identifiers"
    )
    val definitions = Seq(
      "J2_INTC_SOURCE_COUNT" -> config.peripheralCount,
      "J2_INTC_VECTOR_BASE" -> vectorBase,
      "J2_INTC_NMI_VECTOR" -> 11,
      "J2_INTC_NMI_OFFSET" -> nmiControl,
      "J2_INTC_ISER_OFFSET" -> setEnable,
      "J2_INTC_ICER_OFFSET" -> clearEnable,
      "J2_INTC_ISPR_OFFSET" -> setPending,
      "J2_INTC_ICPR_OFFSET" -> clearPending,
      "J2_INTC_IPR_OFFSET" -> priority,
      "J2_INTC_CONTROL_WORDS" -> controlWords,
      "J2_INTC_PRIORITY_WORDS" -> priorityWords
    ) ++ names.zipWithIndex.flatMap { case (name, index) =>
      Seq(s"J2_IRQ_$name" -> index, s"J2_VECTOR_$name" -> (vectorBase + index))
    }
    val selected =
      if (includeSources) definitions else definitions.filterNot(_._1 == "J2_INTC_SOURCE_COUNT")
    val width = selected.map(_._1.length).max
    val constants = selected
      .map { case (name, value) =>
        s"#define ${name.padTo(width, ' ')} UINT32_C(0x${value.toHexString})"
      }
      .mkString("\n")
    s"""/* Generated from IntcConfig and IntcRegisters. Do not edit. */
#ifndef J2_GENERATED_INTC_H
#define J2_GENERATED_INTC_H

#include <stdint.h>

$constants

#define J2_INTC_WORD_OFFSET(irq)     (((uint32_t)(irq) / 32U) * 4U)
#define J2_INTC_IRQ_MASK(irq)        (UINT32_C(1) << ((uint32_t)(irq) % 32U))
#define J2_INTC_IPR_WORD_OFFSET(irq) (J2_INTC_IPR_OFFSET + ((uint32_t)(irq) / 8U) * 4U)
#define J2_INTC_IPR_SHIFT(irq)       (((uint32_t)(irq) % 8U) * 4U)

#endif
"""
  }
}
