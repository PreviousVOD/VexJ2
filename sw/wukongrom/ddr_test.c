#include <stdint.h>
#include "board.h"

extern uint32_t ddr_stack_probe(uint32_t value, uint32_t stack);
static uint32_t offset(unsigned i) {
  if (i < 32) return i * 16;
  if (i == 63) return J2_MEMORY_BYTES - 16;
  return (i - 31) * (J2_MEMORY_BYTES / 32);
}

/* Destructive only to DDR scratch locations; no flash array writes. */
int ddr_cpu_test(void) {
  for (unsigned i = 0; i < 64; ++i) {
    volatile uint32_t *p = (volatile uint32_t *)(J2_MEMORY_BASE + offset(i));
    for (unsigned w = 0; w < 4; ++w) p[w] = offset(i) ^ (0x12345678u + w * 0x10203040u);
  }
  for (unsigned i = 0; i < 64; ++i) {
    volatile uint32_t *p = (volatile uint32_t *)(J2_MEMORY_BASE + offset(i));
    for (unsigned w = 0; w < 4; ++w)
      if (p[w] != (offset(i) ^ (0x12345678u + w * 0x10203040u))) return 1;
  }
  volatile uint32_t *words = (volatile uint32_t *)J2_MEMORY_BASE;
  volatile uint16_t *halves = (volatile uint16_t *)J2_MEMORY_BASE;
  volatile uint8_t *bytes = (volatile uint8_t *)J2_MEMORY_BASE;
  for (unsigned b = 0; b < 16; ++b) bytes[b] = 0xa0 + b;
  for (unsigned w = 0; w < 4; ++w)
    if (words[w] != 0xa0a1a2a3u + 0x04040404u*w) return 2;
  for (unsigned h = 0; h < 8; ++h) halves[h] = 0x1357 + 0x1111*h;
  for (unsigned h = 0; h < 8; ++h)
    if (bytes[2*h] != ((0x1357 + 0x1111*h) >> 8) ||
        bytes[2*h+1] != ((0x1357 + 0x1111*h) & 255)) return 3;
  if (ddr_stack_probe(0x89abcdefu,J2_MEMORY_BASE+0x4000) != 0x89abcdefu) return 4;
  if (*(volatile uint32_t *)(J2_MEMORY_BASE+0x3ffc) != 0x89abcdefu) return 5;
  volatile uint32_t *code = (volatile uint32_t *)(J2_MEMORY_BASE+0x1000);
  code[0] = 0xe02a000b; /* mov #42,r0; rts */
  code[1] = 0x00090009; /* nop; nop */
  __asm__ volatile ("" ::: "memory");
  if (((int (*)(void))code)() != 42) return 6;
  code += 0x100 / 4; /* Separate, previously unfetched instruction block. */
  code[0] = 0x441b0029; /* tas.b @r4; movt r0 */
  code[1] = 0x000b0009; /* rts; nop */
  __asm__ volatile ("" ::: "memory");
  volatile uint8_t *lock = (volatile uint8_t *)(J2_MEMORY_BASE+0x2000);
  for (unsigned b = 0; b < 4; ++b) {
    lock[b] = 0;
    if (((int (*)(volatile uint8_t *))code)(lock+b) != 1 || lock[b] != 0x80) return 7;
    if (((int (*)(volatile uint8_t *))code)(lock+b) != 0 || lock[b] != 0x80) return 8;
  }
  return 0;
}
