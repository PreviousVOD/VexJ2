#include <stdarg.h>

/* CoreMark */
#include "coremark.h"

/* App */
#include "cmt.h"
#include "intc.h"
#include "uart.h"

/* API ticks remain microseconds; hardware counts PCLK/512 with an ISR extension. */
#define TIMER_HZ 1000000u
volatile uint32_t cmt_overflows;

static void interrupt_mask(unsigned mask) {
    uint32_t status;
    __asm__ volatile("stc sr, %0" : "=r"(status));
    status = (status & ~0xf0u) | (mask << 4);
    __asm__ volatile("ldc %0, sr" : : "r"(status) : "memory");
}

_Static_assert(sizeof(ee_u32) == 4 && sizeof(ee_u16) == 2 && sizeof(ee_u8) == 1, "CoreMark data widths");
_Static_assert(sizeof(ee_ptr_int) == sizeof(void *), "CoreMark pointer width");

#if VALIDATION_RUN
volatile ee_s32 seed1_volatile = 0x3415;
volatile ee_s32 seed2_volatile = 0x3415;
#else
volatile ee_s32 seed1_volatile = 0;
volatile ee_s32 seed2_volatile = 0;
#endif
volatile ee_s32   seed3_volatile       = 0x66;
volatile ee_s32   seed4_volatile       = ITERATIONS;
volatile ee_s32   seed5_volatile       = 0;
ee_u32            default_num_contexts = 1;
static CORE_TICKS elapsed;

__attribute__((noreturn)) void abort(void) {
    ee_printf("ERROR! CoreMark aborted\n");
    for (;;) {
    }
}

void start_time(void) {
    interrupt_mask(15);
    CMT_CMSTR     = 0;
    CMT_CMCOR(0)  = UINT16_MAX;
    CMT_CMCNT(0)  = 0;
    CMT_CMCSR(0)  = CMT_CMIE | CMT_CKS_DIV512;
    cmt_overflows = 0;
    intc_set_priority(J2_IRQ_CMT0, 14);
    intc_enable(J2_IRQ_CMT0);
    CMT_CMSTR = CMT_STR(0);
    interrupt_mask(0);
}

void stop_time(void) {
    interrupt_mask(15);
    CMT_CMSTR = 0;
    intc_disable(J2_IRQ_CMT0);
    uint32_t wraps = cmt_overflows;
    uint16_t low   = CMT_CMCNT(0);
    /* A stopped equality can still match. Re-read after observing CMF to
     * include a wrap which arrived after the count was first sampled. */
    if (CMT_CMCSR(0) & CMT_CMF) {
        ++wraps;
        low = CMT_CMCNT(0);
    }

    CMT_CMCSR(0)          = CMT_CKS_DIV512;
    uint64_t ticks        = ((uint64_t)wraps << 16) | low;
    uint64_t microseconds = ticks * 512u * TIMER_HZ / J2_CLOCK_HZ;
    elapsed               = microseconds < UINT32_MAX ? (CORE_TICKS)microseconds : UINT32_MAX;
}

CORE_TICKS get_time(void) {
    return elapsed;
}

secs_ret time_in_secs(CORE_TICKS ticks) {
    return ticks / TIMER_HZ;
}

void portable_init(core_portable *p, int *argc, char *argv[]) {
    (void)argc;
    (void)argv;
    uart_init();
    intc_reset();
    CMT_CMSTR      = 0;
    CMT_CMCSR(0)   = 0;
    p->portable_id = 1;
    ee_printf("J2 CoreMark start\nClock Hz: %lu\nTimer Hz: %lu\n", (unsigned long)J2_CLOCK_HZ, (unsigned long)TIMER_HZ);
}

void portable_fini(core_portable *p) {
    p->portable_id = 0;
    if (!elapsed || elapsed == UINT32_MAX) {
        ee_printf("J2 timer error\n");
    }

    ee_printf("J2 CoreMark complete\n");
}

/* CoreMark's integer-only reporting formats, emitted outside the timed region. */
static int put_char(char ch) {
    if (ch == '\n') {
        uart_tx('\r');
    }

    uart_tx(ch);

    return 1;
}

int ee_printf(const char *format, ...) {
    va_list args;
    int     count = 0;
    va_start(args, format);
    while (*format) {
        if (*format != '%') {
            count += put_char(*format++);
            continue;
        }

        ++format;
        char     pad   = ' ';
        unsigned width = 0;
        if (*format == '0') {
            pad = '0';
            ++format;
        }

        while (*format >= '0' && *format <= '9') {
            width = width * 10 + (*format++ - '0');
        }
        int is_long = *format == 'l';
        if (is_long) {
            ++format;
        }

        char kind = *format++;
        if (kind == 's') {
            const char *s = va_arg(args, const char *);
            while (*s) {
                count += put_char(*s++);
            }
        } else if (kind == '%') {
            count += put_char('%');
        } else {
            uint32_t value;
            if (kind == 'd') {
                int32_t number = is_long ? va_arg(args, long) : va_arg(args, int);
                value          = (uint32_t)number;
                if (number < 0) {
                    count += put_char('-');
                    value  = 0u - value;
                }
            } else {
                value = is_long ? va_arg(args, unsigned long) : va_arg(args, unsigned int);
            }

            unsigned base = kind == 'x' ? 16 : 10;
            char     digits[32];
            unsigned length = 0;
            do {
                digits[length++]  = "0123456789abcdef"[value % base];
                value            /= base;
            } while (value);
            while (width > length) {
                count += put_char(pad);
                --width;
            }
            while (length) {
                count += put_char(digits[--length]);
            }
        }
    }
    va_end(args);

    return count;
}
