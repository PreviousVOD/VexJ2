#include <stdint.h>

/* App */
#include "cmt.h"
#include "intc.h"
#include "sci.h"
#include "uart.h"
#include "uart_irq.h"

#define RESULT (*(volatile uint32_t *)0xff000004)
#define ENABLE (*(volatile uint32_t *)0xff000008)

static volatile unsigned timer_count;

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
extern void xip_sci_tei_isr(void);

static const uintptr_t vectors[64 + J2_INTC_SOURCE_COUNT] __attribute__((aligned(256))) = {
    [J2_VECTOR_CMT0] = (uintptr_t)timer_isr,          [J2_VECTOR_CMT1] = (uintptr_t)xip_cmt1_isr,
    [J2_VECTOR_SCI_ERI] = (uintptr_t)xip_sci_eri_isr, [J2_VECTOR_SCI_RXI] = (uintptr_t)xip_sci_rxi_isr,
    [J2_VECTOR_SCI_TXI] = (uintptr_t)xip_sci_txi_isr, [J2_VECTOR_SCI_TEI] = (uintptr_t)xip_sci_tei_isr};

/* Linked with the production ROM startup and UART driver. */
void boot_main(void) {
    ENABLE = 0xff;
    RESULT = 1;
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
    uart_tx('R');
    while (!(SCI_REG(SCI_SCSSR) & SCI_SSR_TEND)) {
    }
    RESULT = timer_count == 1 && interrupt_result == 0 ? 0x77 : 0x55;
    for (;;) {
    }
}
