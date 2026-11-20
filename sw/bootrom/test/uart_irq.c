#include <stdint.h>

/* App */
#include "intc.h"
#include "irq_driver.h"
#include "scif.h"
#include "uart.h"

/* Simulation-only rendezvous registers on the external data bus. No test hooks
 * are compiled into the receive driver or production loader. */
#define PHASE   (*(volatile uint32_t *)0x40000000)
#define RELEASE (*(volatile uint32_t *)0x40000004)
#define RESULT  (*(volatile uint32_t *)0x40000008)

static void mask(unsigned value) {
    __asm__ volatile("ldc %0, sr" : : "r"(value << 4) : "memory");
}

static void check(int condition, unsigned code) {
    if (!condition) {
        RESULT = code;
        for (;;) {
        }
    }
}

static void rendezvous(unsigned phase) {
    PHASE = phase;
    while (RELEASE != phase) {
    }
}

void boot_main(void) {
    uart_init();
    uart_rx_irq_start();
    /* Keep foreground busy while 512 bytes arrive into the 511-byte queue. */
    rendezvous(1);
    check(uart_rx_irq_failed(), 1);
    check(!(SCIF_REG16(SCIF_SCFSR) & SCIF_FSR_ERRORS), 2);
    unsigned count = 0;
    while (uart_rx_ready()) {
        check(uart_rx() == (uint8_t)count, 3);
        ++count;
    }
    check(count == 511, 4);
    uart_rx_irq_discard();
    check(!uart_rx_irq_failed(), 5);

    /* Suppress service long enough to produce an actual hardware overrun. */
    mask(15);
    rendezvous(2);
    check((SCIF_REG16(SCIF_SCLSR) & SCIF_LSR_ORER) != 0, 6);
    mask(0);
    while (!uart_rx_irq_failed()) {
    }
    check(!uart_rx_ready(), 7);
    check(!(SCIF_REG16(SCIF_SCFSR) & (SCIF_FSR_ERRORS | SCIF_FSR_RDF)), 8);
    check(!(SCIF_REG16(SCIF_SCLSR) & SCIF_LSR_ORER), 19);
    uart_rx_irq_discard();

    /* Receive even parity, inject an incorrect parity bit while masked, then
     * verify that the normal ERI handler clears PER and rejects that byte. */
    mask(15);
    SCIF_REG16(SCIF_SCSCR) = 0;
    SCIF_REG16(SCIF_SCSMR) = 0x20;
    SCIF_REG16(SCIF_SCSCR) = SCIF_SCR_TE | SCIF_SCR_RE | SCIF_SCR_RIE;
    rendezvous(3);
    check((SCIF_REG16(SCIF_SCFSR) & SCIF_FSR_PER) != 0, 9);
    mask(0);
    while (!uart_rx_irq_failed()) {
    }
    check(!uart_rx_ready(), 10);
    check(!(SCIF_REG16(SCIF_SCFSR) & (SCIF_FSR_ERRORS | SCIF_FSR_RDF)), 11);
    uart_rx_irq_discard();

    SCIF_REG16(SCIF_SCSCR) = 0;
    SCIF_REG16(SCIF_SCSMR) = 0;
    SCIF_REG16(SCIF_SCSCR) = SCIF_SCR_TE | SCIF_SCR_RE | SCIF_SCR_RIE;
    rendezvous(4);
    check(!uart_rx_irq_failed(), 12);
    for (unsigned i = 0; i < 8; ++i) {
        check(uart_rx_ready(), 13);
        check(uart_rx() == 0xa0u + i, 14);
    }
    check(!uart_rx_ready(), 15);
    uart_rx_irq_stop();
    uint32_t sr;
    __asm__ volatile("stc sr, %0" : "=r"(sr));
    check((sr & 0xf0) == 0xf0, 16);
    check(!(SCIF_REG16(SCIF_SCSCR) & SCIF_SCR_RIE), 17);
    check(INTC_ISER(0) == 0, 18);
    RESULT = 0x600d;
    for (;;) {
    }
}
