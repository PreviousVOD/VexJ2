#include <stdint.h>
#include "uart.h"

#define SDRAM_BASE 0x80000000
#define SDRAM_EXEC_BASE 0x80700000

extern void sdram_test_function(void);
extern int isa_test(void);

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

#define TIMER_ENABLE (*(volatile uint32_t *)0xff003000)
#define TIMER_LIMIT (*(volatile uint32_t *)0xff003004)
#define TIMER_VALUE (*(volatile uint32_t *)0xff003008)
#define TIMER_IRQ (*(volatile uint32_t *)0xff00300c)
#define TIMER_IRQ_PENDING 0x100
#define TIMER_COUNT (*(volatile uint32_t *)0x80710000)

static void timer_set_mask(uint32_t mask) {
  uint32_t status;
  __asm__ volatile("stc sr, %0" : "=r"(status));
  status = (status & ~0xf0U) | ((mask & 0xfU) << 4);
  __asm__ volatile("ldc %0, sr" : : "r"(status));
}

static int timer_test(void) {
  volatile uint32_t wait;

  TIMER_ENABLE = 0;
  TIMER_IRQ = 0;
  TIMER_VALUE = 0;
  TIMER_COUNT = 0;
  TIMER_LIMIT = 64;
  timer_set_mask(15);
  TIMER_IRQ = 1;
  TIMER_ENABLE = 1;

  for (wait = 0; wait < 100000 && !(TIMER_IRQ & TIMER_IRQ_PENDING); ++wait) {
  }
  if (!(TIMER_IRQ & TIMER_IRQ_PENDING) || TIMER_COUNT != 0) return 1;

  timer_set_mask(0);
  for (wait = 0; wait < 100000 && TIMER_COUNT == 0; ++wait) {
  }
  if (TIMER_COUNT != 1 || (TIMER_IRQ & TIMER_IRQ_PENDING)) return 2;

  TIMER_LIMIT = 128;
  TIMER_ENABLE = 1;
  for (wait = 0; wait < 100000 && TIMER_COUNT == 1; ++wait) {
  }
  if (TIMER_COUNT != 2 || (TIMER_IRQ & TIMER_IRQ_PENDING)) return 3;

  TIMER_LIMIT = 5000;
  TIMER_ENABLE = 1;
  __asm__ volatile("sleep" ::: "memory");
  if (TIMER_COUNT != 3 || (TIMER_IRQ & TIMER_IRQ_PENDING)) return 4;

  timer_set_mask(15);
  TIMER_ENABLE = 0;
  TIMER_IRQ = 0;
  TIMER_VALUE = 0;
  return 0;
}

void xip_main(void) {
  int timer_result;
  uart_init();
  if (!sdram_test()) {
    uart_puts("SDRAM tests failed\n");
    for (;;) {
    }
  }
  uart_puts("SDRAM tests passed\n");
  timer_result = timer_test();
  if (timer_result) {
    uart_puts("Timer tests failed: ");
    uart_hex(timer_result, 1);
    uart_tx(' ');
    uart_hex(TIMER_IRQ, 8);
    uart_tx(' ');
    uart_hex(TIMER_COUNT, 8);
    uart_tx(' ');
    uart_hex(TIMER_VALUE, 8);
    uart_tx('\n');
    for (;;) {
    }
  }
  uart_puts("Timer tests passed\n");
  if (!isa_test()) for (;;) {}
  uart_puts("XIP CPU tests passed\n");
  for (;;) {
  }
}
