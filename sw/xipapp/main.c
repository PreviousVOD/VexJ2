#include <stdint.h>
#include "uart.h"

#define SDRAM_BASE 0x80000000
#define SDRAM_EXEC_BASE 0x80700000

extern void sdram_test_function(void);

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
  if (memory[16] != 0xc001d00d) return 0;

  {
    volatile uint32_t *destination = (volatile uint32_t *)SDRAM_EXEC_BASE;
    const uint32_t *source = (const uint32_t *)sdram_test_function;
    int (*function)(int, int) = (int (*)(int, int))SDRAM_EXEC_BASE;
    destination[0] = source[0];
    destination[1] = source[1];
    return function(77, 42) == 119;
  }
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
