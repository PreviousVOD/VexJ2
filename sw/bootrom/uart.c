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
    if (SCI_REG16(SCI_SCSCR) & SCI_SCR_TE) {
        while (!(SCI_REG16(SCI_SCFSR) & SCI_FSR_TEND)) {
        }
        uint32_t clocks = (32u << (2 * (SCI_REG16(SCI_SCSMR) & 3))) * (SCI_REG8(SCI_SCBRR) + 1u);
        wait_bit(clocks);
    }

    SCI_REG16(SCI_SCSCR)  = 0;
    SCI_REG16(SCI_SCSMR)  = SCI_CKS;
    SCI_REG8(SCI_SCBRR)   = SCI_RATE - 1;
    SCI_REG16(SCI_SCEMR)  = 0;
    SCI_REG16(SCI_SCFCR)  = SCI_FCR_TFRST | SCI_FCR_RFRST;
    SCI_REG16(SCI_SCFCR)  = SCI_FCR_TX_ZERO;
    SCI_REG16(SCI_SCSPTR) = 0;
    SCI_REG16(SCI_SCFSR)  = (uint16_t)~(SCI_FSR_RDF | SCI_FSR_DR | SCI_FSR_ERRORS);
    SCI_REG16(SCI_SCLSR)  = 0;
    wait_bit(SCI_SCALE * SCI_RATE);
    SCI_REG16(SCI_SCSCR) = SCI_SCR_TE | SCI_SCR_RE;
}

void uart_tx(uint8_t data) {
    while (!(SCI_REG16(SCI_SCFSR) & SCI_FSR_TDFE)) {
    }
    SCI_REG8(SCI_SCFTDR) = data;
    SCI_REG16(SCI_SCFSR) = (uint16_t)~(SCI_FSR_TDFE | SCI_FSR_TEND);
}

#ifndef J2_UART_RX_IRQ
int uart_rx_failed(void) {
    if (SCI_REG16(SCI_SCFSR) & SCI_FSR_ERRORS) {
        return 1;
    }

    return (SCI_REG16(SCI_SCLSR) & SCI_LSR_ORER) != 0;
}

int uart_try_rx(uint8_t *data) {
    if (uart_rx_failed()) {
        return -1;
    }

    if (!(SCI_REG16(SCI_SCFDR) & 255u)) {
        return 0;
    }

    *data                = SCI_REG8(SCI_SCFRDR);
    SCI_REG16(SCI_SCFSR) = (uint16_t)~(SCI_FSR_RDF | SCI_FSR_DR);
    /* ER/BRK/ORER survive the pop, including errors arriving during it. */
    if (uart_rx_failed()) {
        return -1;
    }

    return 1;
}

void uart_rx_discard(void) {
    uint16_t control     = SCI_REG16(SCI_SCFCR);
    SCI_REG16(SCI_SCFCR) = control | SCI_FCR_RFRST;
    SCI_REG16(SCI_SCFCR) = control & (uint16_t)~SCI_FCR_RFRST;
    SCI_REG16(SCI_SCFSR) = (uint16_t)~(SCI_FSR_RDF | SCI_FSR_DR | SCI_FSR_ER | SCI_FSR_BRK);
    SCI_REG16(SCI_SCLSR) = (uint16_t)~SCI_LSR_ORER;
}

int uart_rx_ready(void) {
    uint16_t status = SCI_REG16(SCI_SCFSR);
    if (status & SCI_FSR_ERRORS) {
        /* Resume reception after an invalid/lost character. The loader's
         * checksum and timeout handle the incomplete packet. Preserve queued receive data. */
        SCI_REG16(SCI_SCFSR) = (uint16_t)~(status & SCI_FSR_ERRORS);
    }

    SCI_REG16(SCI_SCLSR) = 0;

    while (SCI_REG16(SCI_SCFDR) & 255u) {
        if (!(SCI_REG16(SCI_SCFSR) & (SCI_FSR_FER | SCI_FSR_PER))) {
            return 1;
        }

        (void)SCI_REG8(SCI_SCFRDR);
        SCI_REG16(SCI_SCFSR) = (uint16_t)~(SCI_FSR_RDF | SCI_FSR_DR);
    }

    return 0;
}

uint8_t uart_rx(void) {
    while (!uart_rx_ready()) {
    }
    uint8_t data         = SCI_REG8(SCI_SCFRDR);
    SCI_REG16(SCI_SCFSR) = (uint16_t)~(SCI_FSR_RDF | SCI_FSR_DR);

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
