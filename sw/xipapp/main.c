#include <stdint.h>

/* App */
#include "uart.h"

#define SDRAM_BASE        0x80000000
#define SDRAM_EXEC_BASE   0x80700000
#define XIP_CACHE_CONTROL (*(volatile uint32_t *)0xff004000)

extern void sdram_test_function(void);
extern int  isa_test(void);

static int cache_test(void) {
    static const uint32_t words[16] __attribute__((aligned(32))) = {
        0x10203040, 0x11213141, 0x12223242, 0x13233343, 0x14243444, 0x15253545, 0x16263646, 0x17273747,
        0x18283848, 0x19293949, 0x1a2a3a4a, 0x1b2b3b4b, 0x1c2c3c4c, 0x1d2d3d4d, 0x1e2e3e4e, 0x1f2f3f4f};
    unsigned pass, index;
    for (pass = 0; pass < 4; ++pass) {
        for (index = 0; index < 16; ++index) {
            uint32_t                 expected = 0x10203040U + index * 0x01010101U;
            const volatile uint32_t *word     = words + index;
            /* Execute this store from XIP, exercising a concurrent instruction read.
             * The invalidate command self-clears; only the busy bit may read as one.
             */
            XIP_CACHE_CONTROL = 1;
            if (XIP_CACHE_CONTROL & ~2U) {
                return 0;
            }

            if (*word != expected) {
                return 0;
            }

            if (*(const volatile uint8_t *)word != (expected >> 24)) {
                return 0;
            }

            if (*((const volatile uint16_t *)word + 1) != (expected & 0xffff)) {
                return 0;
            }

            XIP_CACHE_CONTROL = 0; /* Writing zero does not invalidate. */
            if (*word != expected) {
                return 0;
            }
        }
    }

    return 1;
}

static int sdram_test(void) {
    static const uint32_t offsets[] = {0, 4, 8, 12, 0x400, 0x1000, 0x2000, 0x4000};
    volatile uint32_t    *memory    = (volatile uint32_t *)SDRAM_BASE;
    uint32_t              index;

    for (index = 0; index < sizeof(offsets) / sizeof(offsets[0]); ++index) {
        *(volatile uint32_t *)(SDRAM_BASE + offsets[index]) = 0x5a5a0000 | index;
    }
    for (index = 0; index < sizeof(offsets) / sizeof(offsets[0]); ++index) {
        if (*(volatile uint32_t *)(SDRAM_BASE + offsets[index]) != (0x5a5a0000 | index)) {
            return 0;
        }
    }

    memory[16]                             = 0x11223344;
    *(volatile uint8_t *)(SDRAM_BASE + 65) = 0xaa;
    if (memory[16] != 0x11aa3344) {
        return 0;
    }

    *(volatile uint16_t *)(SDRAM_BASE + 66) = 0xbeef;
    if (memory[16] != 0x11aabeef) {
        return 0;
    }

    memory[16] = 0xc001d00d;
    if (memory[16] != 0xc001d00d) {
        return 0;
    }

    {
        volatile uint32_t *destination = (volatile uint32_t *)SDRAM_EXEC_BASE;
        const uint32_t    *source      = (const uint32_t *)sdram_test_function;
        int (*function)(int, int)      = (int (*)(int, int))SDRAM_EXEC_BASE;
        destination[0]                 = source[0];
        destination[1]                 = source[1];

        return function(77, 42) == 119;
    }
}

#define TIMER_ENABLE      (*(volatile uint32_t *)0xff003000)
#define TIMER_LIMIT       (*(volatile uint32_t *)0xff003004)
#define TIMER_VALUE       (*(volatile uint32_t *)0xff003008)
#define TIMER_IRQ         (*(volatile uint32_t *)0xff00300c)
#define TIMER_IRQ_PENDING 0x100
#define TIMER_COUNT       (*(volatile uint32_t *)0x80710000)

static void timer_set_mask(uint32_t mask) {
    uint32_t status;
    __asm__ volatile("stc sr, %0" : "=r"(status));
    status = (status & ~0xf0U) | ((mask & 0xfU) << 4);
    __asm__ volatile("ldc %0, sr" : : "r"(status));
}

static int timer_test(void) {
    volatile uint32_t wait;

    TIMER_ENABLE = 0;
    TIMER_IRQ    = 0;
    TIMER_VALUE  = 0;
    TIMER_COUNT  = 0;
    TIMER_LIMIT  = 64;
    timer_set_mask(15);
    TIMER_IRQ    = 1;
    TIMER_ENABLE = 1;

    for (wait = 0; wait < 100000 && !(TIMER_IRQ & TIMER_IRQ_PENDING); ++wait) {
    }
    if (!(TIMER_IRQ & TIMER_IRQ_PENDING)) {
        return 1;
    }

    if (TIMER_COUNT != 0) {
        return 1;
    }

    timer_set_mask(0);
    for (wait = 0; wait < 100000 && TIMER_COUNT == 0; ++wait) {
    }
    if (TIMER_COUNT != 1) {
        return 2;
    }

    if ((TIMER_IRQ & TIMER_IRQ_PENDING)) {
        return 2;
    }

    TIMER_LIMIT  = 128;
    TIMER_ENABLE = 1;
    for (wait = 0; wait < 100000 && TIMER_COUNT == 1; ++wait) {
    }
    if (TIMER_COUNT != 2) {
        return 3;
    }

    if ((TIMER_IRQ & TIMER_IRQ_PENDING)) {
        return 3;
    }

    TIMER_LIMIT  = 5000;
    TIMER_ENABLE = 1;
    __asm__ volatile("sleep" ::: "memory");
    if (TIMER_COUNT != 3) {
        return 4;
    }

    if ((TIMER_IRQ & TIMER_IRQ_PENDING)) {
        return 4;
    }

    timer_set_mask(15);
    TIMER_ENABLE = 0;
    TIMER_IRQ    = 0;
    TIMER_VALUE  = 0;

    return 0;
}

static volatile uint32_t startup_data = 0x13579bdf;
static volatile uint32_t startup_bss[2];

void xip_main(void) {
    int timer_result;
    uart_init();
    if (startup_data != 0x13579bdf || startup_bss[0] || startup_bss[1]) {
        uart_puts("Startup initialization failed\n");
        for (;;) {
        }
    }

    startup_data   ^= 0xffffffffu;
    startup_bss[0]  = 0x12345678;
    if (startup_data != 0xeca86420 || startup_bss[0] != 0x12345678) {
        uart_puts("Startup writable data failed\n");
        for (;;) {
        }
    }

    uart_puts("Startup initialization passed\n");
    if (!cache_test()) {
        uart_puts("XIP cache tests failed\n");
        for (;;) {
        }
    }

    uart_puts("XIP cache tests passed\n");
    if (!sdram_test()) {
        uart_puts("SDRAM tests failed\n");
        for (;;) {
        }
    }

    uart_puts("SDRAM tests passed\n");
    timer_result = timer_test();
    if (timer_result) {
        uart_puts("Timer tests failed: ");
        uart_hex(timer_result, 1);
        uart_tx(' ');
        uart_hex(TIMER_IRQ, 8);
        uart_tx(' ');
        uart_hex(TIMER_COUNT, 8);
        uart_tx(' ');
        uart_hex(TIMER_VALUE, 8);
        uart_tx('\n');
        for (;;) {
        }
    }

    uart_puts("Timer tests passed\n");
    if (!isa_test()) {
        for (;;) {
        }
    }

    uart_puts("XIP CPU tests passed\n");
    for (;;) {
    }
}
