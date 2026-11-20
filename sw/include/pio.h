#ifndef J2_PIO_H
#define J2_PIO_H

#include <stdint.h>

#define J2_PIO_BASE              UINT32_C(0xff000000)
#define PIO_REG(offset)          (*(volatile uint32_t *)(J2_PIO_BASE + (offset)))
#define PIO_CR                   PIO_REG(0x00)
#define PIO_DIR                  PIO_REG(0x04)
#define PIO_DATA                 PIO_REG(0x08)
#define PIO_ISR                  PIO_REG(0x0c)
#define PIO_ICR(word)            PIO_REG(0x10 + 4U * (word))
#define PIO_CR_IE                UINT32_C(1)
#define PIO_IRQ_DISABLED         UINT32_C(0)
#define PIO_IRQ_RISING           UINT32_C(1)
#define PIO_IRQ_FALLING          UINT32_C(2)
#define PIO_IRQ_RESERVED         UINT32_C(3)
#define PIO_ICR_SHIFT(pin)       (2U * ((pin) % 16U))
#define PIO_ICR_FIELD(pin, mode) ((uint32_t)(mode) << PIO_ICR_SHIFT(pin))

#endif
