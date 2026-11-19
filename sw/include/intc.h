#ifndef J2_INTC_H
#define J2_INTC_H

#include <stdint.h>

/* App */
#include "j2_intc_regs.h"

#define J2_INTC_BASE     UINT32_C(0xffffe900)
#define INTC_REG(offset) (*(volatile uint32_t *)(J2_INTC_BASE + (offset)))
#define INTC_ISER(word)  INTC_REG(J2_INTC_ISER_OFFSET + 4U * (word))
#define INTC_ICER(word)  INTC_REG(J2_INTC_ICER_OFFSET + 4U * (word))
#define INTC_ISPR(word)  INTC_REG(J2_INTC_ISPR_OFFSET + 4U * (word))
#define INTC_ICPR(word)  INTC_REG(J2_INTC_ICPR_OFFSET + 4U * (word))
#define INTC_IPR(word)   INTC_REG(J2_INTC_IPR_OFFSET + 4U * (word))

static inline void intc_enable(unsigned irq) {
    INTC_ISER(irq / 32U) = J2_INTC_IRQ_MASK(irq);
}

static inline void intc_disable(unsigned irq) {
    INTC_ICER(irq / 32U) = J2_INTC_IRQ_MASK(irq);
}

static inline void intc_set_priority(unsigned irq, unsigned priority) {
    uint32_t shift     = J2_INTC_IPR_SHIFT(irq);
    uint32_t value     = INTC_IPR(irq / 8U);
    INTC_IPR(irq / 8U) = (value & ~(UINT32_C(15) << shift)) | ((priority & 15U) << shift);
}

/* Call with SR.I=15 before enabling peripheral sources. NMI remains independent. */
static inline void intc_reset(void) {
    for (unsigned word = 0; word < J2_INTC_CONTROL_WORDS; ++word) {
        INTC_ICER(word) = UINT32_MAX;
        INTC_ICPR(word) = UINT32_MAX;
    }
    for (unsigned word = 0; word < J2_INTC_PRIORITY_WORDS; ++word) {
        INTC_IPR(word) = 0;
    }
}

#endif
