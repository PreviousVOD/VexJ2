#include <stdint.h>

/* App */
#include "cmt.h"
#include "flash.h"
#include "intc.h"
#include "irq_driver.h"
#include "pio.h"
#include "sci.h"
#include "uart.h"

#define RESULT PIO_DATA

static volatile unsigned timer_count;
static volatile unsigned pio_count;
static volatile uint32_t pio_flags;

static void __attribute__((interrupt_handler)) pio_isr(void) {
    uint32_t flags  = PIO_ISR;
    pio_flags      |= flags;
    /* Exercise BE32 byte/halfword W1C lanes for pins 31 and 8. */
    *(volatile uint8_t *)(J2_PIO_BASE + 0x0c)  = (uint8_t)(flags >> 24);
    *(volatile uint16_t *)(J2_PIO_BASE + 0x0e) = (uint16_t)flags;
    (void)PIO_ISR;
    ++pio_count;
}

static int pio_test(void) {
    const uint32_t pins                        = (UINT32_C(1) << 8) | (UINT32_C(1) << 31);
    PIO_CR                                     = 0;
    PIO_ISR                                    = UINT32_MAX;
    *(volatile uint16_t *)(J2_PIO_BASE + 0x10) = 1; /* ICR0 pin 8, upper halfword. */
    PIO_ICR(1)                                 = PIO_ICR_FIELD(31, PIO_IRQ_RISING) | UINT32_C(0x5555);
    intc_set_priority(J2_IRQ_PIO, 9);
    intc_enable(J2_IRQ_PIO);
    __asm__ volatile("ldc %0, sr" : : "r"(0) : "memory");
    RESULT = 5;
    while (PIO_ISR != pins) {
    }
    if (pio_count) {
        return 1;
    }

    if ((PIO_DATA & (pins | UINT32_C(0x00ff0000))) != pins) {
        return 1;
    }

    PIO_CR = PIO_CR_IE;
    while (pio_count == 0) {
    }
    PIO_CR = 0;
    if (pio_flags != pins) {
        return 2;
    }

    if (PIO_ISR) {
        return 2;
    }

    RESULT = 6;
    while (PIO_DATA & pins) {
    }
    PIO_CR = PIO_CR_IE;
    RESULT = 7;
    while (pio_count < 2) {
    }
    PIO_CR = 0;
    intc_disable(J2_IRQ_PIO);
    if (pio_count != 2) {
        return 3;
    }

    if (PIO_ISR) {
        return 3;
    }

    if (pio_flags != pins) {
        return 3;
    }

    return 0;
}

static void __attribute__((interrupt_handler)) timer_isr(void) {
    CMT_CMSTR    = 0;
    CMT_CMCSR(0) = CMT_CKS_DIV8;
    (void)CMT_CMCSR(0);
    ++timer_count;
}

extern int  intc_test(void);
extern void xip_cmt1_isr(void);
extern void xip_sci_eri_isr(void);
extern void xip_sci_rxi_isr(void);
extern void xip_sci_txi_isr(void);
extern void xip_sci_bri_isr(void);

static const uintptr_t vectors[64 + J2_INTC_SOURCE_COUNT]
    __attribute__((aligned(256))) = {[J2_VECTOR_CMT0]    = (uintptr_t)timer_isr,
                                     [J2_VECTOR_CMT1]    = (uintptr_t)xip_cmt1_isr,
                                     [J2_VECTOR_SCI_ERI] = (uintptr_t)xip_sci_eri_isr,
                                     [J2_VECTOR_SCI_RXI] = (uintptr_t)xip_sci_rxi_isr,
                                     [J2_VECTOR_SCI_TXI] = (uintptr_t)xip_sci_txi_isr,
                                     [J2_VECTOR_SCI_BRI] = (uintptr_t)xip_sci_bri_isr,
                                     [J2_VECTOR_PIO]     = (uintptr_t)pio_isr};

/* Linked with the production ROM startup and UART driver. */
void boot_main(void) {
    *(volatile uint8_t *)(J2_PIO_BASE + 0x07) = 0xff; /* DIR low byte. */
    RESULT                                    = 1;
    /* Exercise the real flash driver's cache invalidation at the profile's
     * address, and SPI control readback without requiring a flash model. */
    flash_refresh_cache();
    volatile uint32_t *spi_interrupt = (volatile uint32_t *)(J2_SPI_CONTROL_BASE + 0x0c);
    *spi_interrupt                   = 1;
    if ((*spi_interrupt & 3) != 1) {
        RESULT = 0x55;
        for (;;) {
        }
    }

    *spi_interrupt = 0;
    uart_init();
    uart_rx_irq_start();
    RESULT = 2;
    if (uart_rx() != 0x5a) {
        RESULT = 0x55;
        for (;;) {
        }
    }

    uart_rx_irq_stop();
    intc_reset();
    __asm__ volatile("ldc %0, vbr" : : "r"(vectors) : "memory");
    intc_set_priority(J2_IRQ_CMT0, 14);
    intc_enable(J2_IRQ_CMT0);
    CMT_CMSTR    = 0;
    CMT_CMCNT(0) = 0;
    CMT_CMCOR(0) = 63;
    CMT_CMCSR(0) = CMT_CMIE | CMT_CKS_DIV8;
    CMT_CMSTR    = CMT_STR(0);
    RESULT       = 3;
    __asm__ volatile("ldc %0, sr" : : "r"(0) : "memory");
    while (timer_count == 0) {
    }
    RESULT               = 4;
    int interrupt_result = intc_test();
    int pio_result       = interrupt_result == 0 ? pio_test() : 1;
    uart_tx('R');
    while (!(SCI_REG16(SCI_SCFSR) & SCI_FSR_TEND)) {
    }
    RESULT = timer_count == 1 && interrupt_result == 0 && pio_result == 0 ? 0x77 : 0x55;
    for (;;) {
    }
}
