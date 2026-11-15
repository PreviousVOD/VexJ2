#include <stdint.h>
#include "uart.h"

#define SDRAM_BASE 0x80000000

static int sdram_test(void) {
  static const uint32_t offsets[] = {0, 4, 8, 12, 0x400, 0x1000, 0x2000, 0x4000};
  volatile uint32_t *memory = (volatile uint32_t *)SDRAM_BASE;
  uint32_t index;

  for (index = 0; index < sizeof(offsets) / sizeof(offsets[0]); ++index)
    *(volatile uint32_t *)(SDRAM_BASE + offsets[index]) = 0x5a5a0000 | index;
  for (index = 0; index < sizeof(offsets) / sizeof(offsets[0]); ++index) {
    if (*(volatile uint32_t *)(SDRAM_BASE + offsets[index]) != (0x5a5a0000 | index))
      return 0;
  }

  memory[16] = 0x11223344;
  *(volatile uint8_t *)(SDRAM_BASE + 65) = 0xaa;
  if (memory[16] != 0x11aa3344) return 0;
  *(volatile uint16_t *)(SDRAM_BASE + 66) = 0xbeef;
  if (memory[16] != 0x11aabeef) return 0;
  memory[16] = 0xc001d00d;
  return memory[16] == 0xc001d00d;
}

void xip_main(void) {
  uart_init();
  if (!sdram_test()) {
    uart_puts("SDRAM tests failed\n");
    for (;;) {
    }
  }
  uart_puts("SDRAM tests passed\n");
  uart_puts("XIP CPU tests passed\n");
  for (;;) {
  }
}
