#include <stdint.h>

/* App */
#include "intc.h"
#include "irq_driver.h"
#include "sci.h"
#include "uart.h"

/* Optional ISR regression driver; not linked into the production BootROM.
 * One producer (the ISR), one foreground consumer. Leave one slot empty.
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

/* ERI, RXI and BRI share one producer. Drain by count: RDF/DR are sticky,
 * and each FIFO head has its own parity/framing indication. */
void __attribute__((interrupt_handler)) boot_uart_rx_isr(void) {
    uint16_t status      = SCI_REG16(SCI_SCFSR);
    uint16_t line        = SCI_REG16(SCI_SCLSR);
    SCI_REG16(SCI_SCFSR) = (uint16_t)~(status & (SCI_FSR_ER | SCI_FSR_BRK));
    SCI_REG16(SCI_SCLSR) = (uint16_t)~(line & SCI_LSR_ORER);
    if (status & SCI_FSR_ERRORS) {
        rx_failed = 1;
    }

    if (line & SCI_LSR_ORER) {
        rx_failed = 1;
    }

    while (SCI_REG16(SCI_SCFDR) & 255u) {
        status       = SCI_REG16(SCI_SCFSR);
        uint8_t data = SCI_REG8(SCI_SCFRDR);
        if (status & (SCI_FSR_FER | SCI_FSR_PER)) {
            rx_failed = 1;
        }

        if (rx_failed) {
            continue;
        }

        uint16_t head = rx_head;
        uint16_t next = (head + 1u) & RX_MASK;
        if (next == rx_tail) {
            rx_failed = 1;
            continue;
        }

        rx_data[head] = data;
        rx_head       = next;
    }
    SCI_REG16(SCI_SCFSR) = (uint16_t)~(SCI_FSR_RDF | SCI_FSR_DR);
    (void)SCI_REG16(SCI_SCFSR);
}

void uart_rx_irq_discard(void) {
    uint32_t saved       = mask_interrupts();
    rx_head              = 0;
    rx_tail              = 0;
    rx_failed            = 0;
    uint16_t control     = SCI_REG16(SCI_SCFCR);
    SCI_REG16(SCI_SCFCR) = control | SCI_FCR_RFRST;
    SCI_REG16(SCI_SCFCR) = control & (uint16_t)~SCI_FCR_RFRST;
    SCI_REG16(SCI_SCFSR) = (uint16_t)~(SCI_FSR_RDF | SCI_FSR_DR | SCI_FSR_ER | SCI_FSR_BRK);
    SCI_REG16(SCI_SCLSR) = (uint16_t)~SCI_LSR_ORER;
    (void)SCI_REG16(SCI_SCFSR);
    restore_interrupts(saved);
}

void uart_rx_irq_start(void) {
    uint32_t saved = mask_interrupts();
    intc_reset();
    uart_rx_irq_discard();
    /* Equal priorities keep the shared queue producer non-reentrant. */
    intc_set_priority(J2_IRQ_SCI_ERI, 8);
    intc_set_priority(J2_IRQ_SCI_RXI, 8);
    intc_set_priority(J2_IRQ_SCI_BRI, 8);
    intc_enable(J2_IRQ_SCI_ERI);
    intc_enable(J2_IRQ_SCI_RXI);
    intc_enable(J2_IRQ_SCI_BRI);
    SCI_REG16(SCI_SCSCR) |= SCI_SCR_RIE;
    restore_interrupts(saved & ~0xf0u);
}

void uart_rx_irq_stop(void) {
    (void)mask_interrupts();
    SCI_REG16(SCI_SCSCR) &= (uint16_t)~(SCI_SCR_RIE | SCI_SCR_REIE);
    intc_disable(J2_IRQ_SCI_ERI);
    intc_disable(J2_IRQ_SCI_RXI);
    intc_disable(J2_IRQ_SCI_BRI);
    INTC_ICPR(J2_IRQ_SCI_ERI / 32u) = J2_INTC_IRQ_MASK(J2_IRQ_SCI_ERI);
    INTC_ICPR(J2_IRQ_SCI_RXI / 32u) = J2_INTC_IRQ_MASK(J2_IRQ_SCI_RXI);
    INTC_ICPR(J2_IRQ_SCI_BRI / 32u) = J2_INTC_IRQ_MASK(J2_IRQ_SCI_BRI);
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
