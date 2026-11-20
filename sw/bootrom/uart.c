/* UART API */
#include "uart.h"

/* App */
#include "scif.h"

#ifndef J2_CLOCK_HZ
#define J2_CLOCK_HZ 32000000
#endif
#ifndef J2_UART_BAUD
#define J2_UART_BAUD 19200
#endif

/* Choose the smallest prescaler with a representable rounded BRR+1. */
#define SCIF_RATE_N(scale) ((J2_CLOCK_HZ + (scale) * 1ULL * J2_UART_BAUD / 2) / ((scale) * 1ULL * J2_UART_BAUD))
#if SCIF_RATE_N(32) <= 256
#define SCIF_CKS 0
#elif SCIF_RATE_N(128) <= 256
#define SCIF_CKS 1
#elif SCIF_RATE_N(512) <= 256
#define SCIF_CKS 2
#else
#define SCIF_CKS 3
#endif
#define SCIF_SCALE (32 << (2 * SCIF_CKS))
#define SCIF_RATE  SCIF_RATE_N(SCIF_SCALE)
#if SCIF_RATE < 1 || SCIF_RATE > 256
#error Requested SCIF baud is outside the internal-clock range
#endif

static void wait_bit(uint32_t clocks) {
    /* Each volatile loop iteration costs at least one PCLK. Also covers the
     * baud-generator settling time and the final stop bit after TEND. */
    for (volatile uint32_t i = 0; i < clocks; ++i) {
    }
}

void uart_init(void) {
    if (SCIF_REG16(SCIF_SCSCR) & SCIF_SCR_TE) {
        while (!(SCIF_REG16(SCIF_SCFSR) & SCIF_FSR_TEND)) {
        }
        uint32_t clocks = (32u << (2 * (SCIF_REG16(SCIF_SCSMR) & 3))) * (SCIF_REG8(SCIF_SCBRR) + 1u);
        wait_bit(clocks);
    }

    SCIF_REG16(SCIF_SCSCR)  = 0;
    SCIF_REG16(SCIF_SCSMR)  = SCIF_CKS;
    SCIF_REG8(SCIF_SCBRR)   = SCIF_RATE - 1;
    SCIF_REG16(SCIF_SCEMR)  = 0;
    SCIF_REG16(SCIF_SCFCR)  = SCIF_FCR_TFRST | SCIF_FCR_RFRST;
    SCIF_REG16(SCIF_SCFCR)  = SCIF_FCR_TX_ZERO;
    SCIF_REG16(SCIF_SCSPTR) = 0;
    SCIF_REG16(SCIF_SCFSR)  = (uint16_t)~(SCIF_FSR_RDF | SCIF_FSR_DR | SCIF_FSR_ERRORS);
    SCIF_REG16(SCIF_SCLSR)  = 0;
    wait_bit(SCIF_SCALE * SCIF_RATE);
    SCIF_REG16(SCIF_SCSCR) = SCIF_SCR_TE | SCIF_SCR_RE;
}

void uart_tx(uint8_t data) {
    while (!(SCIF_REG16(SCIF_SCFSR) & SCIF_FSR_TDFE)) {
    }
    SCIF_REG8(SCIF_SCFTDR) = data;
    SCIF_REG16(SCIF_SCFSR) = (uint16_t)~(SCIF_FSR_TDFE | SCIF_FSR_TEND);
}

#ifndef J2_UART_RX_IRQ
int uart_rx_failed(void) {
    if (SCIF_REG16(SCIF_SCFSR) & SCIF_FSR_ERRORS) {
        return 1;
    }

    return (SCIF_REG16(SCIF_SCLSR) & SCIF_LSR_ORER) != 0;
}

int uart_try_rx(uint8_t *data) {
    if (uart_rx_failed()) {
        return -1;
    }

    if (!(SCIF_REG16(SCIF_SCFDR) & 255u)) {
        return 0;
    }

    *data                  = SCIF_REG8(SCIF_SCFRDR);
    SCIF_REG16(SCIF_SCFSR) = (uint16_t)~(SCIF_FSR_RDF | SCIF_FSR_DR);
    /* ER/BRK/ORER survive the pop, including errors arriving during it. */
    if (uart_rx_failed()) {
        return -1;
    }

    return 1;
}

void uart_rx_discard(void) {
    uint16_t control       = SCIF_REG16(SCIF_SCFCR);
    SCIF_REG16(SCIF_SCFCR) = control | SCIF_FCR_RFRST;
    SCIF_REG16(SCIF_SCFCR) = control & (uint16_t)~SCIF_FCR_RFRST;
    SCIF_REG16(SCIF_SCFSR) = (uint16_t)~(SCIF_FSR_RDF | SCIF_FSR_DR | SCIF_FSR_ER | SCIF_FSR_BRK);
    SCIF_REG16(SCIF_SCLSR) = (uint16_t)~SCIF_LSR_ORER;
}

int uart_rx_ready(void) {
    uint16_t status = SCIF_REG16(SCIF_SCFSR);
    if (status & SCIF_FSR_ERRORS) {
        /* Resume reception after an invalid/lost character. The loader's
         * checksum and timeout handle the incomplete packet. Preserve queued receive data. */
        SCIF_REG16(SCIF_SCFSR) = (uint16_t)~(status & SCIF_FSR_ERRORS);
    }

    SCIF_REG16(SCIF_SCLSR) = 0;

    while (SCIF_REG16(SCIF_SCFDR) & 255u) {
        if (!(SCIF_REG16(SCIF_SCFSR) & (SCIF_FSR_FER | SCIF_FSR_PER))) {
            return 1;
        }

        (void)SCIF_REG8(SCIF_SCFRDR);
        SCIF_REG16(SCIF_SCFSR) = (uint16_t)~(SCIF_FSR_RDF | SCIF_FSR_DR);
    }

    return 0;
}

uint8_t uart_rx(void) {
    while (!uart_rx_ready()) {
    }
    uint8_t data           = SCIF_REG8(SCIF_SCFRDR);
    SCIF_REG16(SCIF_SCFSR) = (uint16_t)~(SCIF_FSR_RDF | SCIF_FSR_DR);

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
