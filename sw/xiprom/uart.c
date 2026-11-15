#include "uart.h"

#define UART_BASE 0xff001000
#define UART_REG(index) (*(volatile uint32_t *)(UART_BASE + (index) * 4))
#ifndef J2_CLOCK_HZ
#define J2_CLOCK_HZ 32000000
#endif
#define UART_CLOCK_DIVIDER (J2_CLOCK_HZ / (19200 * 5) - 1)

void uart_init(void) {
  UART_REG(2) = UART_CLOCK_DIVIDER;
  UART_REG(3) = 7;
}

void uart_tx(uint8_t data) {
  while ((UART_REG(1) & 0xff0000) == 0);
  UART_REG(0) = data;
}

uint8_t uart_rx(void) {
  uint32_t value;
  do {
    value = UART_REG(0);
  } while (!(value & 0x10000));
  return value & 0xff;
}

int uart_rx_ready(void) {
  return (UART_REG(1) & 0x3f000000) != 0;
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
