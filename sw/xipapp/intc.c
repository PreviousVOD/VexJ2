#include <stdint.h>

/* App */
#include "cmt.h"
#include "intc.h"
#include "scif.h"

static volatile uint32_t counts[J2_INTC_SOURCE_COUNT];
static volatile uint32_t levels[J2_INTC_SOURCE_COUNT];
static volatile uint32_t order[16];
static volatile uint32_t entries;

static void set_mask(unsigned mask) {
    uint32_t sr;
    __asm__ volatile("stc sr, %0" : "=r"(sr));
    sr = (sr & ~0xf0U) | ((mask & 15U) << 4);
    __asm__ volatile("ldc %0, sr" : : "r"(sr) : "memory");
}

static void record(unsigned irq) {
    uint32_t sr;
    __asm__ volatile("stc sr, %0" : "=r"(sr));
    levels[irq] = (sr >> 4) & 15U;
    counts[irq]++;
    if (entries < 16) {
        order[entries++] = irq;
    }

    intc_disable(irq);
}

void __attribute__((interrupt_handler)) xip_cmt1_isr(void) {
    record(J2_IRQ_CMT1);
    CMT_CMSTR    &= (uint16_t)~CMT_STR(1);
    CMT_CMCSR(1)  = CMT_CKS_DIV32;
    (void)CMT_CMCSR(1);
}

void __attribute__((interrupt_handler)) xip_scif_eri_isr(void) {
    record(J2_IRQ_SCIF_ERI);
    SCIF_REG16(SCIF_SCFSR) = (uint16_t)~SCIF_FSR_ER;
    (void)SCIF_REG16(SCIF_SCFSR);
}

void __attribute__((interrupt_handler)) xip_scif_rxi_isr(void) {
    record(J2_IRQ_SCIF_RXI);
    (void)SCIF_REG8(SCIF_SCFRDR);
    SCIF_REG16(SCIF_SCFSR) = (uint16_t)~(SCIF_FSR_RDF | SCIF_FSR_DR);
    (void)SCIF_REG16(SCIF_SCFSR);
}

void __attribute__((interrupt_handler)) xip_scif_txi_isr(void) {
    record(J2_IRQ_SCIF_TXI);
    SCIF_REG16(SCIF_SCSCR) &= (uint16_t)~SCIF_SCR_TIE;
    (void)SCIF_REG16(SCIF_SCSCR);
}

void __attribute__((interrupt_handler)) xip_scif_bri_isr(void) {
    record(J2_IRQ_SCIF_BRI);
    SCIF_REG16(SCIF_SCFSR) = (uint16_t)~SCIF_FSR_BRK;
    SCIF_REG16(SCIF_SCLSR) = (uint16_t)~SCIF_LSR_ORER;
    (void)SCIF_REG16(SCIF_SCLSR);
}

static int wait_entries(unsigned wanted) {
    for (volatile unsigned spin = 0; spin < 100000 && entries < wanted; ++spin) {
    }

    return entries == wanted;
}

static int pending(void) {
    for (unsigned word = 0; word < (J2_INTC_SOURCE_COUNT + 31U) / 32U; ++word) {
        if (INTC_ISPR(word)) {
            return 1;
        }
    }

    return 0;
}

static void clear_log(void) {
    entries = 0;
    for (unsigned n = 0; n < J2_INTC_SOURCE_COUNT; ++n) {
        counts[n] = 0;
        levels[n] = 0;
    }
}

int intc_test(void) {
    static const unsigned priorities[J2_INTC_SOURCE_COUNT] = {
        [J2_IRQ_CMT1] = 3, [J2_IRQ_SCIF_ERI] = 5, [J2_IRQ_SCIF_RXI] = 5, [J2_IRQ_SCIF_TXI] = 2, [J2_IRQ_SCIF_BRI] = 6};
    static const unsigned expected[5] = {
        J2_IRQ_SCIF_BRI, J2_IRQ_SCIF_ERI < J2_IRQ_SCIF_RXI ? J2_IRQ_SCIF_ERI : J2_IRQ_SCIF_RXI,
        J2_IRQ_SCIF_ERI < J2_IRQ_SCIF_RXI ? J2_IRQ_SCIF_RXI : J2_IRQ_SCIF_ERI, J2_IRQ_CMT1, J2_IRQ_SCIF_TXI};
    set_mask(15);
    intc_reset();
    clear_log();
    INTC_ISER(6) = UINT32_MAX;
    INTC_IPR(24) = UINT32_MAX;
    if (INTC_ISER(6) || INTC_IPR(24)) {
        return 1;
    }

    /* Pending survives disable and priority zero; SR.I equality also masks. */
    INTC_ISPR(J2_IRQ_CMT1 / 32U) = J2_INTC_IRQ_MASK(J2_IRQ_CMT1);
    if (INTC_ICPR(J2_IRQ_CMT1 / 32U) != J2_INTC_IRQ_MASK(J2_IRQ_CMT1)) {
        return 2;
    }

    intc_enable(J2_IRQ_CMT1);
    set_mask(0);
    for (volatile unsigned spin = 0; spin < 100; ++spin) {
    }
    if (entries) {
        return 3;
    }

    set_mask(4);
    intc_set_priority(J2_IRQ_CMT1, 4);
    for (volatile unsigned spin = 0; spin < 100; ++spin) {
    }
    if (entries) {
        return 4;
    }

    set_mask(3);
    if (!wait_entries(1)) {
        return 5;
    }

    if (levels[J2_IRQ_CMT1] != 4 || pending()) {
        return 6;
    }

    set_mask(15);
    INTC_ISPR(J2_IRQ_CMT1 / 32U) = J2_INTC_IRQ_MASK(J2_IRQ_CMT1);
    INTC_ICPR(J2_IRQ_CMT1 / 32U) = J2_INTC_IRQ_MASK(J2_IRQ_CMT1);
    intc_enable(J2_IRQ_CMT1);
    set_mask(0);
    for (volatile unsigned spin = 0; spin < 100; ++spin) {
    }
    if (entries != 1) {
        return 7;
    }

    set_mask(15);
    intc_reset();
    clear_log();
    for (unsigned i = 0; i < 5; ++i) {
        unsigned irq = expected[i];
        intc_set_priority(irq, priorities[irq]);
        INTC_ISPR(irq / 32U) = J2_INTC_IRQ_MASK(irq);
        intc_enable(irq);
    }
    set_mask(0);
    if (!wait_entries(5)) {
        return 8;
    }

    set_mask(15);
    for (unsigned i = 0; i < 5; ++i) {
        unsigned irq = expected[i];
        if (order[i] != irq) {
            return 9;
        }

        if (counts[irq] != 1 || levels[irq] != priorities[irq]) {
            return 10;
        }
    }
    if (pending()) {
        return 11;
    }

    /* Exercise the physical CMT1 request; its handler clears the source flag. */
    clear_log();
    CMT_CMSTR    = 0;
    CMT_CMCNT(1) = 0;
    CMT_CMCOR(1) = 31;
    CMT_CMCSR(1) = CMT_CMIE | CMT_CKS_DIV32;
    intc_set_priority(J2_IRQ_CMT1, 9);
    intc_enable(J2_IRQ_CMT1);
    CMT_CMSTR = CMT_STR(1);
    set_mask(0);
    if (!wait_entries(1)) {
        return 12;
    }

    set_mask(15);
    if (counts[J2_IRQ_CMT1] != 1 || levels[J2_IRQ_CMT1] != 9) {
        return 13;
    }

    if ((CMT_CMCSR(1) & CMT_CMF) || pending()) {
        return 14;
    }

    /* SCIF TXI requests service while its transmit FIFO is empty. */
    clear_log();
    for (volatile unsigned spin = 0; spin < 100000 && !(SCIF_REG16(SCIF_SCFSR) & SCIF_FSR_TEND); ++spin) {
    }
    if (!(SCIF_REG16(SCIF_SCFSR) & SCIF_FSR_TEND)) {
        return 15;
    }

    intc_set_priority(J2_IRQ_SCIF_TXI, 7);
    intc_enable(J2_IRQ_SCIF_TXI);
    SCIF_REG16(SCIF_SCSCR) |= SCIF_SCR_TIE;
    set_mask(0);
    if (!wait_entries(1)) {
        return 16;
    }

    set_mask(15);
    if (order[0] != J2_IRQ_SCIF_TXI) {
        return 17;
    }

    if (levels[J2_IRQ_SCIF_TXI] != 7 || pending()) {
        return 18;
    }

    intc_reset();

    return 0;
}
