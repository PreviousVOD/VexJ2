#include <stdint.h>

/* App */
#include "intc.h"
#include "sci.h"
#include "uart.h"
#include "uart_irq.h"

/* One producer (the ISR), one consumer (the loader). Leave one slot empty.
 * A complete 256-byte loader page fits while foreground code is busy. */

#define RX_BYTES 512u
#define RX_MASK  (RX_BYTES - 1u)
static volatile uint8_t  rx_data[RX_BYTES];
static volatile uint16_t rx_head;
static volatile uint16_t rx_tail;
static volatile uint8_t  rx_failed;

static uint32_t mask_interrupts(void) {
    uint32_t saved;
    __asm__ volatile("stc sr, %0" : "=r"(saved));
    uint32_t masked = saved | 0xf0u;
    __asm__ volatile("ldc %0, sr" : : "r"(masked) : "memory");

    return saved;
}

static void restore_interrupts(uint32_t sr) {
    __asm__ volatile("ldc %0, sr" : : "r"(sr) : "memory");
}

/* ERI and RXI share this handler. Acknowledge only observed receive flags;
 * TX status is owned by the polling transmitter. Never print from the ISR. */
void __attribute__((interrupt_handler)) boot_uart_rx_isr(void) {
    uint8_t status     = SCI_REG(SCI_SCSSR);
    uint8_t flags      = status & (SCI_SSR_RDRF | SCI_SSR_ERRORS);
    uint8_t data       = SCI_REG(SCI_SCRDR);
    SCI_REG(SCI_SCSSR) = (uint8_t)~flags;
    (void)SCI_REG(SCI_SCSSR);
    if (status & SCI_SSR_ERRORS) {
        rx_failed = 1;

        return;
    }

    if (!(status & SCI_SSR_RDRF)) {
        return;
    }

    uint16_t head = rx_head;
    uint16_t next = (head + 1u) & RX_MASK;
    if (next == rx_tail) {
        rx_failed = 1;

        return;
    }

    rx_data[head] = data;
    rx_head       = next;
}

void uart_rx_irq_discard(void) {
    uint32_t saved = mask_interrupts();
    rx_head        = 0;
    rx_tail        = 0;
    rx_failed      = 0;
    (void)SCI_REG(SCI_SCRDR);
    SCI_REG(SCI_SCSSR) = (uint8_t)~(SCI_SSR_RDRF | SCI_SSR_ERRORS);
    (void)SCI_REG(SCI_SCSSR);
    restore_interrupts(saved);
}

void uart_rx_irq_start(void) {
    uint32_t saved = mask_interrupts();
    intc_reset();
    uart_rx_irq_discard();
    /* Equal priorities keep the shared queue producer non-reentrant. */
    intc_set_priority(J2_IRQ_SCI_ERI, 8);
    intc_set_priority(J2_IRQ_SCI_RXI, 8);
    intc_enable(J2_IRQ_SCI_ERI);
    intc_enable(J2_IRQ_SCI_RXI);
    SCI_REG(SCI_SCSCR) |= SCI_SCR_RIE;
    restore_interrupts(saved & ~0xf0u);
}

void uart_rx_irq_stop(void) {
    (void)mask_interrupts();
    SCI_REG(SCI_SCSCR) &= (uint8_t)~SCI_SCR_RIE;
    intc_disable(J2_IRQ_SCI_ERI);
    intc_disable(J2_IRQ_SCI_RXI);
    INTC_ICPR(J2_IRQ_SCI_ERI / 32u) = J2_INTC_IRQ_MASK(J2_IRQ_SCI_ERI);
    INTC_ICPR(J2_IRQ_SCI_RXI / 32u) = J2_INTC_IRQ_MASK(J2_IRQ_SCI_RXI);
    uart_rx_irq_discard();
    /* Leave SR.I=15 while the application installs VBR, stack and .bss. */
}

int uart_rx_irq_failed(void) {
    return rx_failed != 0;
}

int uart_rx_ready(void) {
    return rx_head != rx_tail;
}

uint8_t uart_rx(void) {
    while (!uart_rx_ready()) {
    }
    uint16_t tail = rx_tail;
    uint8_t  data = rx_data[tail];
    rx_tail       = (tail + 1u) & RX_MASK;

    return data;
}
