#ifndef J2_SCIF_H
#define J2_SCIF_H

#ifndef J2_SCIF_BASE
#define J2_SCIF_BASE 0xff001000
#endif

/* SH7265 SCIF layout at every configured FIFO depth, including zero. */
#define SCIF_BASE        J2_SCIF_BASE
#define SCIF_SCSMR       0x00
#define SCIF_SCBRR       0x04
#define SCIF_SCSCR       0x08
#define SCIF_SCFTDR      0x0c
#define SCIF_SCFSR       0x10
#define SCIF_SCFRDR      0x14
#define SCIF_SCFCR       0x18
#define SCIF_SCFDR       0x1c
#define SCIF_SCSPTR      0x20
#define SCIF_SCLSR       0x24
#define SCIF_SCEMR       0x28
#define SCIF_SCR_TIE     0x80
#define SCIF_SCR_RIE     0x40
#define SCIF_SCR_TE      0x20
#define SCIF_SCR_RE      0x10
#define SCIF_SCR_REIE    0x08
#define SCIF_FSR_ER      0x80
#define SCIF_FSR_TEND    0x40
#define SCIF_FSR_TDFE    0x20
#define SCIF_FSR_BRK     0x10
#define SCIF_FSR_FER     0x08
#define SCIF_FSR_PER     0x04
#define SCIF_FSR_RDF     0x02
#define SCIF_FSR_DR      0x01
#define SCIF_FSR_ERRORS  (SCIF_FSR_ER | SCIF_FSR_BRK | SCIF_FSR_FER | SCIF_FSR_PER)
#define SCIF_LSR_ORER    0x01
#define SCIF_FCR_TFRST   0x04
#define SCIF_FCR_RFRST   0x02
#define SCIF_FCR_TX_ZERO 0x30

#ifndef __ASSEMBLER__
#include <stdint.h>
#define SCIF_REG8(offset)  (*(volatile uint8_t *)(SCIF_BASE + (offset)))
#define SCIF_REG16(offset) (*(volatile uint16_t *)(SCIF_BASE + (offset)))
#endif

#endif
