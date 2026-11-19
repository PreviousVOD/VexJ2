#ifndef J2_SCI_H
#define J2_SCI_H

#define SCI_BASE       0xff001000
#define SCI_SCSMR      0x00
#define SCI_SCBRR      0x02
#define SCI_SCSCR      0x04
#define SCI_SCTDR      0x06
#define SCI_SCSSR      0x08
#define SCI_SCRDR      0x0a
#define SCI_SCSDCR     0x0c
#define SCI_SCSPTR     0x0e
#define SCI_SCR_TIE    0x80
#define SCI_SCR_RIE    0x40
#define SCI_SCR_TE     0x20
#define SCI_SCR_RE     0x10
#define SCI_SCR_TEIE   0x04
#define SCI_SSR_TDRE   0x80
#define SCI_SSR_RDRF   0x40
#define SCI_SSR_ORER   0x20
#define SCI_SSR_FER    0x10
#define SCI_SSR_PER    0x08
#define SCI_SSR_TEND   0x04
#define SCI_SSR_ERRORS (SCI_SSR_ORER | SCI_SSR_FER | SCI_SSR_PER)

#ifndef __ASSEMBLER__
#include <stdint.h>
#define SCI_REG(offset) (*(volatile uint8_t *)(SCI_BASE + (offset)))
#endif

#endif
