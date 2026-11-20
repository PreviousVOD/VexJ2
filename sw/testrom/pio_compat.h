#ifndef J2_TESTROM_PIO_COMPAT_H
#define J2_TESTROM_PIO_COMPAT_H

/* Preserve the reference ROM ABI; the native-SoC build uses J2PIO. */
#ifdef J2_NATIVE_PIO
/* App */
#include "pio.h"
#define TESTROM_PIO_DATA     PIO_DATA
#define TESTROM_PIO_DATA_ASM "0xFF000008"
#define TESTROM_PIO_DIR_ASM  "0xFF000004"
#else
#define TESTROM_PIO_DATA     (*(volatile unsigned long *)0xff000004)
#define TESTROM_PIO_DATA_ASM "0xFF000004"
#define TESTROM_PIO_DIR_ASM  "0xFF000008"
#endif

#endif
