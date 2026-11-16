#include "uart.h"
#include <stdint.h>

extern const uint32_t isa_atomic_begin[], isa_atomic_end[];
extern uint32_t isa_pc_relative(void);
extern int isa_bad_mach(volatile uint32_t *), isa_bad_macl(volatile uint32_t *),
    isa_bad_sr(volatile uint32_t *);
extern int isa_forward(volatile uint32_t *);
extern void isa_macl(volatile uint32_t *), isa_macw(volatile uint32_t *);
extern int isa_bad_long(volatile uint32_t *), isa_bad_word(volatile uint32_t *);
extern int isa_bad_store_long(volatile uint32_t *),
    isa_bad_store_word(volatile uint32_t *);
extern int isa_bad_postinc(volatile uint32_t *),
    isa_bus_error(volatile uint32_t *);
extern int isa_delay_fault(volatile uint32_t *),
    isa_fetch_error(volatile uint32_t *);
#define CONTEXT ((volatile uint32_t *)0x9000)

static int failure(const char *name, uint32_t actual, uint32_t expected) {
  uart_puts("ISA FAIL ");
  uart_puts(name);
  uart_tx(' ');
  uart_hex(actual, 8);
  uart_puts(" expected ");
  uart_hex(expected, 8);
  uart_tx('\n');
  return 0;
}

static int atomics(uint32_t code, uint32_t data) {
  volatile uint32_t *destination = (volatile uint32_t *)code;
  const uint32_t *source = isa_atomic_begin;
  while (source < isa_atomic_end)
    *destination++ = *source++;
  int result = ((int (*)(volatile uint32_t *))code)((volatile uint32_t *)data);
  return result ? failure("atomic", result, 0) : 1;
}

static int multiply(void) {
  /* high, low, a, b, S, expected high, expected low */
  static const uint32_t cases[][7] = {
      {0x00010000, 0, 0, 0, 1, 0, 0},
      {0x0007ffff, 0xffffffff, 1, 1, 1, 0, 0},
      {0xfff80000, 0, 0xffffffff, 1, 1, 0xffffffff, 0xffffffff},
      {0xdeadffff, 0xffffffff, 0, 0, 1, 0xffffffff, 0xffffffff},
      {0x12340000, 5, 2, 3, 1, 0, 11},
      {0x00007fff, 0xffffffff, 1, 1, 1, 0x7fff, 0xffffffff},
      {0x00008000, 0, 0xffffffff, 1, 1, 0xffff8000, 0},
      {0, 0, 0x80000000, 0x80000000, 1, 0x7fff, 0xffffffff},
      {0, 0, 0x80000000, 0x7fffffff, 1, 0xffff8000, 0},
      {0x00010000, 0, 0, 0, 0, 0x10000, 0},
      {0xffffffff, 0xffffffff, 1, 1, 0, 0, 0}};
  volatile uint32_t *p = CONTEXT;
  unsigned i, j;
  for (i = 0; i < sizeof(cases) / sizeof(cases[0]); ++i) {
    for (j = 0; j < 4; ++j)
      p[j] = cases[i][j];
    p[4] = 0xf0 | (cases[i][4] << 1);
    isa_macl(p);
    if (p[5] != cases[i][5])
      return failure("MAC.L MACH", p[5], cases[i][5]);
    if (p[6] != cases[i][6])
      return failure("MAC.L MACL", p[6], cases[i][6]);
    if (p[7] != (uint32_t)&p[3] || p[8] != (uint32_t)&p[4])
      return failure("MAC.L postincrement", p[7], (uint32_t)&p[3]);
  }
  static const uint32_t words[][5] = {
      {0, 0x80000000, 0x7fff0000, 0x12345678, 0xc0008000},
      {0x7fffffff, 0x00010000, 0x00010000, 0x12345679, 0x7fffffff},
      {0x80000000, 0xffff0000, 0x00010000, 0x12345679, 0x80000000}};
  for (i = 0; i < 3; ++i) {
    p[0] = 0x12345678;
    p[1] = words[i][0];
    p[2] = words[i][1];
    p[3] = words[i][2];
    p[4] = 0xf2;
    isa_macw(p);
    if (p[5] != words[i][3] || p[6] != words[i][4])
      return failure("MAC.W", p[6], words[i][4]);
    if (p[7] != (uint32_t)&p[2] + 2 || p[8] != (uint32_t)&p[3] + 2)
      return failure("MAC.W postincrement", p[7], (uint32_t)&p[2] + 2);
  }
  return 1;
}

static int faults(void) {
  typedef int (*test_fn)(volatile uint32_t *);
  static const test_fn tests[] = {
      isa_bad_long,    isa_bad_word,  isa_bad_store_long, isa_bad_store_word,
      isa_bad_postinc, isa_bus_error, isa_delay_fault,    isa_fetch_error,
      isa_bad_mach,    isa_bad_macl,  isa_bad_sr,         isa_fetch_error};
  volatile uint32_t *p = CONTEXT;
  unsigned i, j;
  for (i = 0; i < sizeof(tests) / sizeof(tests[0]); ++i) {
    for (j = 0; j < 8; ++j)
      p[j] = 0;
    p[5] = (uint32_t)&p[6];
    p[6] = (i == 5 || i == 7) ? 0x20000000 : 0x9001;
    int result = tests[i](p);
    uint32_t expected = (i == 7 || i == 11) ? p[6] : p[0];
    if (p[1] != expected)
      return failure("exception PC", p[1], expected);
    if (p[3] != 9 || p[4] != 1)
      return failure("exception vector/count", p[3], 9);
    if ((p[2] & 0xf0) != 0xf0)
      return failure("saved SR", p[2], 0xf0);
    if (result != 77)
      return failure("fault writeback", result, 77);
  }
  return 1;
}

int isa_test(void) {
  if (!atomics(0xa000, 0xb000) || !atomics(0x80720000, 0x80721000))
    return 0;
  uart_puts("ISA atomics passed (SRAM/SDRAM)\n");
  if (isa_forward(CONTEXT))
    return failure("forwarding/branch/shift", 1, 0);
  if (isa_pc_relative() != 0x13579bdf)
    return failure("PC-relative delay slot", isa_pc_relative(), 0x13579bdf);
  uart_puts("ISA forwarding passed\n");
  if (!multiply())
    return 0;
  uart_puts("ISA MAC saturation passed\n");
  if (!faults())
    return 0;
  uart_puts("ISA exceptions passed\n");
  uart_puts("ISA regression tests passed\n");
  return 1;
}
