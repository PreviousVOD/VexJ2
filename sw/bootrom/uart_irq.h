#ifndef BOOT_UART_IRQ_H
#define BOOT_UART_IRQ_H

void uart_rx_irq_start(void);
void uart_rx_irq_stop(void);
void uart_rx_irq_discard(void);
int  uart_rx_irq_failed(void);

#endif
