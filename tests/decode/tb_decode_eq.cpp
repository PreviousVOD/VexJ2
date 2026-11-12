// Exhaustive decode-table equivalence test.
//   new == simple_logic         for every input (bit exact)
//   new == reverse_logic        on cared-about bits, for valid (op, step)
#include "Vtb_decode_eq.h"
#include <cstdio>
#include <cstdint>

static bool eq_masked(const uint32_t *a, const uint32_t *b, const uint32_t *m, int words) {
  for (int i = 0; i < words; i++) {
    uint32_t d = a[i] ^ b[i];
    if (m) d &= m[i];
    if (d) return false;
  }
  return true;
}

static void dump(const char *n, const uint32_t *v, int words) {
  printf("    %-8s", n);
  for (int i = words - 1; i >= 0; i--) printf(" %08x", v[i]);
  printf("\n");
}

int main(int argc, char **argv) {
  Vtb_decode_eq t;
  const int words = (134 + 31) / 32;  // $bits(decode_table_o_t)
  uint64_t n = 0, valid = 0, bad_simple = 0, bad_reverse = 0;
  for (uint32_t plane = 0; plane < 2; plane++)
    for (uint32_t code = 0; code < 0x10000; code++)
      for (uint32_t addr = 0; addr < 16; addr++)
        for (uint32_t tb = 0; tb < 2; tb++)
          for (uint32_t st = 0; st < 2; st++) {
            t.plane = plane; t.code = code; t.addr = addr; t.t_bcc = tb; t.next_id_stall = st;
            t.eval();
            n++;
            if (!eq_masked(&t.o_new[0], &t.o_simple[0], nullptr, words)) {
              if (bad_simple++ < 5) {
                printf("SIMPLE MISMATCH plane=%u code=%04x addr=%u t=%u stall=%u\n",
                       plane, code, addr, tb, st);
                dump("new", &t.o_new[0], words); dump("simple", &t.o_simple[0], words);
              }
            }
            if (t.valid) {
              valid++;
              if (!eq_masked(&t.o_new[0], &t.o_reverse[0], &t.care[0], words)) {
                if (bad_reverse++ < 5) {
                  printf("REVERSE MISMATCH plane=%u code=%04x addr=%u t=%u stall=%u\n",
                         plane, code, addr, tb, st);
                  dump("new", &t.o_new[0], words); dump("reverse", &t.o_reverse[0], words);
                  dump("care", &t.care[0], words);
                }
              }
            }
          }
  printf("%llu vectors (%llu valid op steps): %llu simple mismatches, %llu reverse mismatches\n",
         (unsigned long long)n, (unsigned long long)valid,
         (unsigned long long)bad_simple, (unsigned long long)bad_reverse);
  return (bad_simple || bad_reverse) ? 1 : 0;
}
