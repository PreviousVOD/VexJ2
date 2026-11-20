#include <stdint.h>

/* App */
#include "intc.h"
#include "sci.h"
#include "uart.h"

/* Simulation-only rendezvous registers; production polling has no hooks. */
#define PHASE   (*(volatile uint32_t *)0x40000000)
#define RELEASE (*(volatile uint32_t *)0x40000004)
#define RESULT  (*(volatile uint32_t *)0x40000008)

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
    uint8_t data;
    uart_init();
    uint32_t sr;
    __asm__ volatile("stc sr, %0" : "=r"(sr));
    check((sr & 0xf0) == 0xf0, 1);
    check(INTC_ISER(0) == 0, 2);
    check(!(SCI_REG16(SCI_SCSCR) & (SCI_SCR_RIE | SCI_SCR_REIE | SCI_SCR_TIE)), 3);
    check(uart_try_rx(&data) == 0, 4);
    /* Leave RX unserviced until the host overflows the four-byte FIFO. */
    rendezvous(1);
    check(uart_try_rx(&data) == -1, 5);
    check(uart_rx_failed(), 6);
    uart_rx_discard();
    check(!uart_rx_failed(), 7);
    check(uart_try_rx(&data) == 0, 8);

    SCI_REG16(SCI_SCSCR) = 0;
    SCI_REG16(SCI_SCSMR) = 0x20;
    SCI_REG16(SCI_SCSCR) = SCI_SCR_TE | SCI_SCR_RE;
    rendezvous(2);
    check(uart_try_rx(&data) == -1, 9);
    check(uart_rx_failed(), 10);
    uart_rx_discard();
    check(!uart_rx_failed(), 11);
    SCI_REG16(SCI_SCSCR) = 0;
    SCI_REG16(SCI_SCSMR) = 0;
    SCI_REG16(SCI_SCSCR) = SCI_SCR_TE | SCI_SCR_RE;

    /* A full loader page arrives continuously while foreground code polls. */
    PHASE = 3;
    for (unsigned i = 0; i < 256; ++i) {
        int received;
        do {
            received = uart_try_rx(&data);
        } while (received == 0);
        check(received == 1, 12);
        check(data == (uint8_t)i, 13);
    }
    check(!uart_rx_failed(), 14);
    check(uart_try_rx(&data) == 0, 15);
    check(INTC_ISER(0) == 0, 16);
    check(!(SCI_REG16(SCI_SCSCR) & (SCI_SCR_RIE | SCI_SCR_REIE | SCI_SCR_TIE)), 17);
    RESULT = 0x600d;
    for (;;) {
    }
}
