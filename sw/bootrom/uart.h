#ifndef XIP_UART_H
#define XIP_UART_H

#include <stdint.h>

void    uart_init(void);
void    uart_tx(uint8_t data);
uint8_t uart_rx(void);
int     uart_rx_ready(void);
void    uart_puts(const char *text);
void    uart_hex(uint32_t value, int digits);

#endif
