/* UART API */
#include "uart.h"

/* App */
#include "sci.h"

#ifndef J2_CLOCK_HZ
#define J2_CLOCK_HZ 32000000
#endif
#ifndef J2_UART_BAUD
#define J2_UART_BAUD 19200
#endif

/* Choose the smallest prescaler with a representable rounded BRR+1. */
#define SCI_RATE_N(scale) ((J2_CLOCK_HZ + (scale) * 1ULL * J2_UART_BAUD / 2) / ((scale) * 1ULL * J2_UART_BAUD))
#if SCI_RATE_N(32) <= 256
#define SCI_CKS 0
#elif SCI_RATE_N(128) <= 256
#define SCI_CKS 1
#elif SCI_RATE_N(512) <= 256
#define SCI_CKS 2
#else
#define SCI_CKS 3
#endif
#define SCI_SCALE (32 << (2 * SCI_CKS))
#define SCI_RATE  SCI_RATE_N(SCI_SCALE)
#if SCI_RATE < 1 || SCI_RATE > 256
#error Requested SCI baud is outside the internal-clock range
#endif

static void wait_bit(uint32_t clocks) {
    /* Each volatile loop iteration costs at least one PCLK. Also covers the
     * baud-generator settling time and the final stop bit after TEND. */
    for (volatile uint32_t i = 0; i < clocks; ++i) {
    }
}

void uart_init(void) {
    if (SCI_REG(SCI_SCSCR) & SCI_SCR_TE) {
        while (!(SCI_REG(SCI_SCSSR) & SCI_SSR_TEND)) {
        }
        uint32_t clocks = (32u << (2 * (SCI_REG(SCI_SCSMR) & 3))) * (SCI_REG(SCI_SCBRR) + 1u);
        wait_bit(clocks);
    }

    SCI_REG(SCI_SCSCR)  = 0;
    SCI_REG(SCI_SCSMR)  = SCI_CKS;
    SCI_REG(SCI_SCBRR)  = SCI_RATE - 1;
    SCI_REG(SCI_SCSDCR) = 0xf2;
    SCI_REG(SCI_SCSPTR) = 1;
    SCI_REG(SCI_SCSSR)  = (uint8_t)~(SCI_SSR_RDRF | SCI_SSR_ERRORS);
    wait_bit(SCI_SCALE * SCI_RATE);
    SCI_REG(SCI_SCSCR) = SCI_SCR_TE | SCI_SCR_RE;
}

void uart_tx(uint8_t data) {
    while (!(SCI_REG(SCI_SCSSR) & SCI_SSR_TDRE)) {
    }
    SCI_REG(SCI_SCTDR) = data;
    SCI_REG(SCI_SCSSR) = (uint8_t)~SCI_SSR_TDRE;
}

#ifndef J2_UART_RX_IRQ
int uart_rx_ready(void) {
    uint8_t status = SCI_REG(SCI_SCSSR);
    if (status & SCI_SSR_ERRORS) {
        /* Resume reception after an invalid/lost character. The loader's
         * checksum and timeout handle the incomplete packet. Preserve RDRF. */
        SCI_REG(SCI_SCSSR) = (uint8_t)~(status & SCI_SSR_ERRORS);
    }

    return (status & SCI_SSR_RDRF) != 0;
}

uint8_t uart_rx(void) {
    while (!uart_rx_ready()) {
    }
    uint8_t data       = SCI_REG(SCI_SCRDR);
    SCI_REG(SCI_SCSSR) = (uint8_t)~SCI_SSR_RDRF;

    return data;
}

#endif

void uart_puts(const char *text) {
    while (*text) {
        if (*text == '\n') {
            uart_tx('\r');
        }

        uart_tx(*text++);
    }
}

void uart_hex(uint32_t value, int digits) {
    int shift;
    for (shift = (digits - 1) * 4; shift >= 0; shift -= 4) {
        uint32_t nibble = (value >> shift) & 0xf;
        uart_tx(nibble < 10 ? '0' + nibble : 'a' + nibble - 10);
    }
}
