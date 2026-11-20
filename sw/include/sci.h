#ifndef J2_SCI_H
#define J2_SCI_H

#ifndef J2_SCI_BASE
#define J2_SCI_BASE 0xff001000
#endif

/* SH7265 SCIF layout at every configured FIFO depth, including zero. */
#define SCI_BASE        J2_SCI_BASE
#define SCI_SCSMR       0x00
#define SCI_SCBRR       0x04
#define SCI_SCSCR       0x08
#define SCI_SCFTDR      0x0c
#define SCI_SCFSR       0x10
#define SCI_SCFRDR      0x14
#define SCI_SCFCR       0x18
#define SCI_SCFDR       0x1c
#define SCI_SCSPTR      0x20
#define SCI_SCLSR       0x24
#define SCI_SCEMR       0x28
#define SCI_SCR_TIE     0x80
#define SCI_SCR_RIE     0x40
#define SCI_SCR_TE      0x20
#define SCI_SCR_RE      0x10
#define SCI_SCR_REIE    0x08
#define SCI_FSR_ER      0x80
#define SCI_FSR_TEND    0x40
#define SCI_FSR_TDFE    0x20
#define SCI_FSR_BRK     0x10
#define SCI_FSR_FER     0x08
#define SCI_FSR_PER     0x04
#define SCI_FSR_RDF     0x02
#define SCI_FSR_DR      0x01
#define SCI_FSR_ERRORS  (SCI_FSR_ER | SCI_FSR_BRK | SCI_FSR_FER | SCI_FSR_PER)
#define SCI_LSR_ORER    0x01
#define SCI_FCR_TFRST   0x04
#define SCI_FCR_RFRST   0x02
#define SCI_FCR_TX_ZERO 0x30

#ifndef __ASSEMBLER__
#include <stdint.h>
#define SCI_REG8(offset)  (*(volatile uint8_t *)(SCI_BASE + (offset)))
#define SCI_REG16(offset) (*(volatile uint16_t *)(SCI_BASE + (offset)))
#endif

#endif
