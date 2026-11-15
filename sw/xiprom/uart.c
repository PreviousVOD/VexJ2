#include "uart.h"

#define UART_BASE 0xff001000
#define UART_REG(index) (*(volatile uint32_t *)(UART_BASE + (index) * 4))

void uart_init(void) {
  UART_REG(3) = 0x83;
  UART_REG(0) = 78;
  UART_REG(1) = 0;
  UART_REG(3) = 0x03;
  UART_REG(2) = 0x07;
}

void uart_tx(uint8_t data) {
  while (!(UART_REG(5) & 0x20));
  UART_REG(0) = data;
}

uint8_t uart_rx(void) {
  while (!(UART_REG(5) & 0x01));
  return UART_REG(0) & 0xff;
}

int uart_rx_ready(void) {
  return (UART_REG(5) & 0x01) != 0;
}

void uart_puts(const char *text) {
  while (*text) {
    if (*text == '\n') uart_tx('\r');
    uart_tx(*text++);
  }
}

void uart_hex(uint32_t value, int digits) {
  int shift;
  for (shift = (digits - 1) * 4; shift >= 0; shift -= 4) {
    uint32_t nibble = (value >> shift) & 0xf;
    uart_tx(nibble < 10 ? '0' + nibble : 'a' + nibble - 10);
  }
}
