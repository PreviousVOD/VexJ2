#include "uart.h"
#include <stdint.h>

extern const uint32_t isa_atomic_begin[], isa_atomic_end[];
extern uint32_t isa_pc_relative(void);
extern int isa_bad_mach(volatile uint32_t *), isa_bad_macl(volatile uint32_t *),
    isa_bad_sr(volatile uint32_t *);
extern int isa_forward(volatile uint32_t *), isa_mul_pipeline(volatile uint32_t *);
extern int isa_fetch_call(uint32_t, volatile uint32_t *);
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

/* Execute writable code through both halves of a fetched word. Re-entry after
 * patching must refetch; an unused halfword containing illegal code must not run. */
static int instruction_fetch(uint32_t address) {
  volatile uint32_t *code = (volatile uint32_t *)address;
  int (*entry)(void) = (int (*)(void))address;
  code[0] = 0xe0017002; /* mov #1,r0; add #2,r0 */
  code[1] = 0x000b7004; /* rts; add #4,r0 */
  int result = entry();
  if (result != 7)
    return failure("word fetch", result, 7);
  code[0] = 0xe0097002;
  result = entry();
  if (result != 15)
    return failure("fetch after code patch", result, 15);
  code[0] = 0xffffe003;
  result = ((int (*)(void))(address + 2))();
  if (result != 7)
    return failure("lower-half entry", result, 7);
  code[0] = 0xa002e001; /* bra address+8; mov #1,r0 */
  code[1] = 0xffffffff; /* wrong path: both halfwords illegal */
  code[2] = 0x000b7004;
  result = entry();
  if (result != 5)
    return failure("fetch redirect/delay slot", result, 5);
  return 1;
}

/* Put BT/BF in the last halfword of SDRAM. The overrun word at 0x80800000
 * faults, but the taken branch must discard it and execute its valid target. */
static int discarded_fetch_fault(void) {
  volatile uint32_t *entry = (volatile uint32_t *)0x807ffffc;
  volatile uint32_t *target = (volatile uint32_t *)0x807fff04;
  target[0] = 0xe04d000b; /* mov #77,r0; rts */
  target[1] = 0x00090009; /* delay slot; nop */
  for (unsigned i = 0; i < 2; ++i) {
    *entry = i ? 0x00188981 : 0x00088b81; /* sett; bt / clrt; bf */
    CONTEXT[4] = 0;
    int result = isa_fetch_call((uint32_t)entry, CONTEXT);
    if (result != 77 || CONTEXT[4] != 0)
      return failure("discarded fallthrough fetch fault", result, 77);
  }
  return 1;
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

extern int isa_removed_bgnd(volatile uint32_t *), isa_removed_cas(volatile uint32_t *),
    isa_removed_shad(volatile uint32_t *), isa_removed_shld(volatile uint32_t *),
    isa_slot_bgnd(volatile uint32_t *), isa_slot_cas(volatile uint32_t *),
    isa_slot_shad(volatile uint32_t *), isa_slot_shld(volatile uint32_t *);

static int removed_extensions(void) {
  typedef int (*test_fn)(volatile uint32_t *);
  static const test_fn tests[] = {
      isa_removed_bgnd, isa_removed_cas, isa_removed_shad, isa_removed_shld,
      isa_slot_bgnd, isa_slot_cas, isa_slot_shad, isa_slot_shld};
  volatile uint32_t *p = CONTEXT;
  for (unsigned i = 0; i < sizeof(tests) / sizeof(tests[0]); ++i) {
    for (unsigned j = 0; j < 6; ++j)
      p[j] = 0;
    int result = tests[i](p);
    uint32_t vector = i < 4 ? 4 : 6;
    if (p[3] != vector || p[4] != 1)
      return failure("removed extension vector/count", p[3], vector);
    if (p[1] != p[5])
      return failure("removed extension saved PC", p[1], p[5]);
    if (result != 77 || (p[2] & 0xf0) != 0xf0)
      return failure("removed extension state", result, 77);
  }
  return 1;
}

int isa_test(void) {
  if (!atomics(0xa000, 0xb000) || !atomics(0x80720000, 0x80721000))
    return 0;
  uart_puts("ISA atomics passed (SRAM/SDRAM)\n");
  if (!instruction_fetch(0xa800) || !instruction_fetch(0x80722000))
    return 0;
  if (!discarded_fetch_fault())
    return 0;
  uart_puts("ISA word fetch passed (SRAM/SDRAM)\n");
  if (isa_forward(CONTEXT))
    return failure("forwarding/branch/shift", 1, 0);
  if (isa_pc_relative() != 0x13579bdf)
    return failure("PC-relative delay slot", isa_pc_relative(), 0x13579bdf);
  uart_puts("ISA forwarding passed\n");
  if (isa_mul_pipeline(CONTEXT))
    return failure("MUL/MAC interlock", 1, 0);
  uart_puts("ISA multiply pipeline passed\n");
  if (!multiply())
    return 0;
  uart_puts("ISA MAC saturation passed\n");
  if (!faults())
    return 0;
  uart_puts("ISA exceptions passed\n");
  if (!removed_extensions())
    return 0;
  uart_puts("ISA SH-2 illegal extensions passed\n");
  uart_puts("ISA regression tests passed\n");
  return 1;
}
