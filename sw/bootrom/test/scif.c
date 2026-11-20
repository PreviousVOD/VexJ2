#include <stdint.h>

/* App */
#include "cmt.h"
#include "intc.h"
#include "sci.h"
#include "uart.h"

#ifndef J2_SCIF_CAPACITY
#error Hardware test requires the expected SCIF capacity
#endif

static void fail(unsigned code) {
    uart_init();
    uart_puts("SCIF FAIL ");
    uart_hex(code, 4);
    uart_puts("\n");
    for (;;) {
    }
}

static void check(int condition, unsigned code) {
    if (!condition) {
        fail(code);
    }
}

static void wait_flag(unsigned reg, uint16_t mask, unsigned code) {
    uint16_t previous = CMT_CMCNT(0);
    uint32_t elapsed  = 0;
    while (!(SCI_REG16(reg) & mask)) {
        uint16_t now  = CMT_CMCNT(0);
        elapsed      += (uint16_t)(now - previous);
        previous      = now;
        if (elapsed > (J2_CLOCK_HZ / 512u) * 10u) {
            fail(code);
        }
    }
}

static void drain_tx(void) {
    wait_flag(SCI_SCFSR, SCI_FSR_TEND, 1);
    /* TEND indicates the final stop bit; let it finish before disabling TE. */
    for (volatile unsigned i = 0; i < J2_CLOCK_HZ / J2_UART_BAUD; ++i) {
    }
}

static unsigned receive_count(void) {
    return SCI_REG16(SCI_SCFDR) & 255u;
}

static void check_irq(unsigned irq, unsigned code) {
    check((INTC_ISPR(irq / 32u) & J2_INTC_IRQ_MASK(irq)) != 0, code);
}

void xip_main(void) {
    uart_init();
    intc_reset();
    CMT_CMSTR    = 0;
    CMT_CMCNT(0) = 0;
    CMT_CMCOR(0) = 65535;
    CMT_CMCSR(0) = CMT_CKS_DIV512;
    CMT_CMSTR    = CMT_STR(0);
    uart_puts("SCIF capacity ");
    uart_hex(J2_SCIF_CAPACITY, 4);
    uart_puts("\nSCIF TX BEGIN\n");
    drain_tx();
    SCI_REG16(SCI_SCSCR) = SCI_SCR_RE;
    for (unsigned i = 0; i < J2_SCIF_CAPACITY; ++i) {
        SCI_REG8(SCI_SCFTDR) = 'A' + i % 26;
    }
    check((SCI_REG16(SCI_SCFDR) >> 8) == J2_SCIF_CAPACITY, 2);
    SCI_REG8(SCI_SCFTDR) = '!';
    check((SCI_REG16(SCI_SCFDR) >> 8) == J2_SCIF_CAPACITY, 3);
    SCI_REG16(SCI_SCFSR) = (uint16_t)~SCI_FSR_TDFE;
    check(!(SCI_REG16(SCI_SCFSR) & SCI_FSR_TDFE), 4);
    SCI_REG16(SCI_SCSCR) = SCI_SCR_TE | SCI_SCR_RE | SCI_SCR_TIE;
    SCI_REG16(SCI_SCFSR) = (uint16_t)~(SCI_FSR_TDFE | SCI_FSR_TEND);
    drain_tx();
    check((SCI_REG16(SCI_SCFDR) >> 8) == 0, 5);
    check_irq(J2_IRQ_SCI_TXI, 6);
    SCI_REG16(SCI_SCSCR) = SCI_SCR_TE | SCI_SCR_RE | SCI_SCR_RIE;
    uart_puts("\nSCIF TX PASS\n");

    SCI_REG16(SCI_SCFCR) = 0xf0; /* RX=ceil(7N/8), TX=empty. */
    uart_puts("SCIF RX FULL\n");
    wait_flag(SCI_SCLSR, SCI_LSR_ORER, 7);
    check(receive_count() == J2_SCIF_CAPACITY, 8);
    check_irq(J2_IRQ_SCI_RXI, 9);
    check_irq(J2_IRQ_SCI_BRI, 10);
    for (unsigned i = 0; i < J2_SCIF_CAPACITY; ++i) {
        check(SCI_REG8(SCI_SCFRDR) == (uint8_t)(0x20 + i), 11);
    }
    check(receive_count() == 0, 12);
    check(SCI_REG16(SCI_SCLSR) & SCI_LSR_ORER, 13);
    SCI_REG16(SCI_SCLSR) = 0xffff;
    check(SCI_REG16(SCI_SCLSR) & SCI_LSR_ORER, 14);
    SCI_REG16(SCI_SCLSR) = 0;
    SCI_REG16(SCI_SCFSR) = (uint16_t)~(SCI_FSR_RDF | SCI_FSR_DR);
    uart_puts("SCIF RX FULL PASS\nSCIF RX SHORT\n");
#if J2_SCIF_CAPACITY > 1
    wait_flag(SCI_SCFSR, SCI_FSR_DR, 15);
    check(!(SCI_REG16(SCI_SCFSR) & SCI_FSR_RDF), 16);
#else
    wait_flag(SCI_SCFSR, SCI_FSR_RDF, 15);
#endif
    check(receive_count() == 1, 17);
    check_irq(J2_IRQ_SCI_RXI, 18);
    check(SCI_REG8(SCI_SCFRDR) == 0x6d, 19);
    SCI_REG16(SCI_SCFSR) = (uint16_t)~(SCI_FSR_RDF | SCI_FSR_DR);
    check(!(SCI_REG16(SCI_SCFSR) & (SCI_FSR_RDF | SCI_FSR_DR)), 20);
    uart_puts("SCIF RX SHORT PASS\nSCIF RX PARITY\n");
    drain_tx();
    SCI_REG16(SCI_SCSCR)  = 0;
    SCI_REG16(SCI_SCSMR) |= 0x20; /* Host sends 8N1: 0x03's stop bit becomes bad even parity. */
    SCI_REG16(SCI_SCSCR)  = SCI_SCR_TE | SCI_SCR_RE | SCI_SCR_REIE;
    wait_flag(SCI_SCFSR, SCI_FSR_ER, 21);
    check(receive_count() == 1, 22);
    check((SCI_REG16(SCI_SCFSR) & 0xf004) == 0x1004, 23);
    check_irq(J2_IRQ_SCI_ERI, 24);
    check(SCI_REG8(SCI_SCFRDR) == 3, 25);
    check(!(SCI_REG16(SCI_SCFSR) & 0xf004), 26);
    SCI_REG16(SCI_SCFSR)  = (uint16_t)~(SCI_FSR_ER | SCI_FSR_RDF | SCI_FSR_DR);
    SCI_REG16(SCI_SCSCR)  = 0;
    SCI_REG16(SCI_SCSMR) &= (uint16_t)~0x20;
    SCI_REG16(SCI_SCSCR)  = SCI_SCR_TE | SCI_SCR_RE;
    uart_puts("SCIF RX PARITY PASS\nSCIF FIFO tests passed\n");
    for (;;) {
    }
}
