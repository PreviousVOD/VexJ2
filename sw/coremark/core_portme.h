#ifndef J2_CORE_PORTME_H
#define J2_CORE_PORTME_H

#include <stddef.h>
#include <stdint.h>

#define HAS_FLOAT         0
#define HAS_TIME_H        0
#define USE_CLOCK         0
#define HAS_STDIO         0
#define HAS_PRINTF        0
#define SEED_METHOD       SEED_VOLATILE
#define MEM_METHOD        MEM_STATIC
#define MULTITHREAD       1
#define MAIN_HAS_NOARGC   1
#define MAIN_HAS_NORETURN 0
#define COMPILER_VERSION  "GCC " __VERSION__
#define COMPILER_FLAGS    J2_COMPILER_FLAGS
#define MEM_LOCATION      "Code/rodata in SPI XIP flash; data/stack in SRAM; memory/core 1:1"

typedef int16_t   ee_s16;
typedef uint16_t  ee_u16;
typedef int32_t   ee_s32;
typedef uint32_t  ee_u32;
typedef uint8_t   ee_u8;
typedef uintptr_t ee_ptr_int;
typedef size_t    ee_size_t;
typedef uint32_t  CORE_TICKS;
#define align_mem(x) ((void *)(((uintptr_t)(x) + 3u) & ~(uintptr_t)3u))
typedef struct {
    ee_u8 portable_id;
} core_portable;
extern ee_u32 default_num_contexts;
void          portable_init(core_portable *p, int *argc, char *argv[]);
void          portable_fini(core_portable *p);
int           ee_printf(const char *format, ...);

#endif
