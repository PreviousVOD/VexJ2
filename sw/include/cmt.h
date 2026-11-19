#ifndef J2_CMT_H
#define J2_CMT_H

#ifndef __ASSEMBLER__
#include <stdint.h>
#endif

/* SH7124/SH7125 CMT offsets, at the project's shared peripheral address. */
#define J2_CMT_BASE                0xff003000
#define CMT_CMSTR_ADDRESS          (J2_CMT_BASE + 0x00)
#define CMT_CMCSR_ADDRESS(channel) (J2_CMT_BASE + 0x02 + 6 * (channel))
#define CMT_CMCNT_ADDRESS(channel) (J2_CMT_BASE + 0x04 + 6 * (channel))
#define CMT_CMCOR_ADDRESS(channel) (J2_CMT_BASE + 0x06 + 6 * (channel))

#ifndef __ASSEMBLER__
#define CMT_CMSTR          (*(volatile uint16_t *)CMT_CMSTR_ADDRESS)
#define CMT_CMCSR(channel) (*(volatile uint16_t *)CMT_CMCSR_ADDRESS(channel))
#define CMT_CMCNT(channel) (*(volatile uint16_t *)CMT_CMCNT_ADDRESS(channel))
#define CMT_CMCOR(channel) (*(volatile uint16_t *)CMT_CMCOR_ADDRESS(channel))
#define CMT_CMF            0x0080u
#define CMT_CMIE           0x0040u
#define CMT_CKS_DIV8       0u
#define CMT_CKS_DIV32      1u
#define CMT_CKS_DIV128     2u
#define CMT_CKS_DIV512     3u
#define CMT_STR(channel)   (1u << (channel))
#endif

#endif
