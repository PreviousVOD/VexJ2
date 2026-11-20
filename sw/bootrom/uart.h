#ifndef XIP_UART_H
#define XIP_UART_H

#include <stdint.h>

void    uart_init(void);
void    uart_tx(uint8_t data);
uint8_t uart_rx(void);
int     uart_rx_ready(void);
/* Polling transport: try_rx returns 1 for data, 0 if empty, -1 on error.
 * Errors remain latched until discard; no interrupt controller is needed. */
int  uart_try_rx(uint8_t *data);
int  uart_rx_failed(void);
void uart_rx_discard(void);
void uart_puts(const char *text);
void uart_hex(uint32_t value, int digits);

#endif
