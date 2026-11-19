/* Generated from IntcConfig and IntcRegisters. Do not edit. */
#ifndef J2_GENERATED_INTC_H
#define J2_GENERATED_INTC_H

#include <stdint.h>

#define J2_INTC_SOURCE_COUNT   UINT32_C(0x6)
#define J2_INTC_VECTOR_BASE    UINT32_C(0x40)
#define J2_INTC_NMI_VECTOR     UINT32_C(0xb)
#define J2_INTC_NMI_OFFSET     UINT32_C(0x0)
#define J2_INTC_ISER_OFFSET    UINT32_C(0x10)
#define J2_INTC_ICER_OFFSET    UINT32_C(0x30)
#define J2_INTC_ISPR_OFFSET    UINT32_C(0x50)
#define J2_INTC_ICPR_OFFSET    UINT32_C(0x70)
#define J2_INTC_IPR_OFFSET     UINT32_C(0x100)
#define J2_INTC_CONTROL_WORDS  UINT32_C(0x8)
#define J2_INTC_PRIORITY_WORDS UINT32_C(0x20)
#define J2_IRQ_CMT0            UINT32_C(0x0)
#define J2_VECTOR_CMT0         UINT32_C(0x40)
#define J2_IRQ_CMT1            UINT32_C(0x1)
#define J2_VECTOR_CMT1         UINT32_C(0x41)
#define J2_IRQ_SCI_ERI         UINT32_C(0x2)
#define J2_VECTOR_SCI_ERI      UINT32_C(0x42)
#define J2_IRQ_SCI_RXI         UINT32_C(0x3)
#define J2_VECTOR_SCI_RXI      UINT32_C(0x43)
#define J2_IRQ_SCI_TXI         UINT32_C(0x4)
#define J2_VECTOR_SCI_TXI      UINT32_C(0x44)
#define J2_IRQ_SCI_TEI         UINT32_C(0x5)
#define J2_VECTOR_SCI_TEI      UINT32_C(0x45)

#define J2_INTC_WORD_OFFSET(irq)     (((uint32_t)(irq) / 32U) * 4U)
#define J2_INTC_IRQ_MASK(irq)        (UINT32_C(1) << ((uint32_t)(irq) % 32U))
#define J2_INTC_IPR_WORD_OFFSET(irq) (J2_INTC_IPR_OFFSET + ((uint32_t)(irq) / 8U) * 4U)
#define J2_INTC_IPR_SHIFT(irq)       (((uint32_t)(irq) % 8U) * 4U)

#endif
