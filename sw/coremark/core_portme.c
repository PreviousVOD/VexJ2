#include "coremark.h"
#include "uart.h"
#include <stdarg.h>

#define TIMER_ENABLE (*(volatile uint32_t *)0xff003000)
#define TIMER_LIMIT (*(volatile uint32_t *)0xff003004)
#define TIMER_VALUE (*(volatile uint32_t *)0xff003008)
#define TIMER_IRQ (*(volatile uint32_t *)0xff00300c)
#define TIMER_HZ 1000000u

_Static_assert(sizeof(ee_u32) == 4 && sizeof(ee_u16) == 2 && sizeof(ee_u8) == 1,
               "CoreMark data widths");
_Static_assert(sizeof(ee_ptr_int) == sizeof(void *), "CoreMark pointer width");

#if VALIDATION_RUN
volatile ee_s32 seed1_volatile = 0x3415;
volatile ee_s32 seed2_volatile = 0x3415;
#else
volatile ee_s32 seed1_volatile = 0;
volatile ee_s32 seed2_volatile = 0;
#endif
volatile ee_s32 seed3_volatile = 0x66;
volatile ee_s32 seed4_volatile = ITERATIONS;
volatile ee_s32 seed5_volatile = 0;
ee_u32 default_num_contexts = 1;
static CORE_TICKS elapsed;

__attribute__((noreturn)) void abort(void) {
  ee_printf("ERROR! CoreMark aborted\n");
  for (;;) {}
}

void start_time(void) {
  TIMER_ENABLE = 0;
  TIMER_IRQ = 0;
  TIMER_LIMIT = UINT32_MAX; /* Writing the limit also clears the counter. */
  TIMER_ENABLE = 1;
}

void stop_time(void) {
  TIMER_ENABLE = 0;
  elapsed = TIMER_VALUE;
}

CORE_TICKS get_time(void) { return elapsed; }
secs_ret time_in_secs(CORE_TICKS ticks) { return ticks / TIMER_HZ; }

void portable_init(core_portable *p, int *argc, char *argv[]) {
  (void)argc;
  (void)argv;
  uart_init();
  TIMER_ENABLE = 0;
  TIMER_IRQ = 0;
  p->portable_id = 1;
  ee_printf("J2 CoreMark start\nClock Hz: %lu\nTimer Hz: %lu\n",
            (unsigned long)J2_CLOCK_HZ, (unsigned long)TIMER_HZ);
}

void portable_fini(core_portable *p) {
  p->portable_id = 0;
  if (!elapsed || elapsed == UINT32_MAX)
    ee_printf("J2 timer error\n");
  ee_printf("J2 CoreMark complete\n");
}

/* CoreMark's integer-only reporting formats, emitted outside the timed region. */
static int put_char(char ch) {
  if (ch == '\n') uart_tx('\r');
  uart_tx(ch);
  return 1;
}

int ee_printf(const char *format, ...) {
  va_list args;
  int count = 0;
  va_start(args, format);
  while (*format) {
    if (*format != '%') { count += put_char(*format++); continue; }
    ++format;
    char pad = ' ';
    unsigned width = 0;
    if (*format == '0') { pad = '0'; ++format; }
    while (*format >= '0' && *format <= '9') width = width * 10 + (*format++ - '0');
    int is_long = *format == 'l';
    if (is_long) ++format;
    char kind = *format++;
    if (kind == 's') {
      const char *s = va_arg(args, const char *);
      while (*s) count += put_char(*s++);
    } else if (kind == '%') {
      count += put_char('%');
    } else {
      uint32_t value;
      if (kind == 'd') {
        int32_t number = is_long ? va_arg(args, long) : va_arg(args, int);
        value = (uint32_t)number;
        if (number < 0) { count += put_char('-'); value = 0u - value; }
      } else {
        value = is_long ? va_arg(args, unsigned long) : va_arg(args, unsigned int);
      }
      unsigned base = kind == 'x' ? 16 : 10;
      char digits[32];
      unsigned length = 0;
      do { digits[length++] = "0123456789abcdef"[value % base]; value /= base; } while (value);
      while (width > length) { count += put_char(pad); --width; }
      while (length) count += put_char(digits[--length]);
    }
  }
  va_end(args);
  return count;
}
