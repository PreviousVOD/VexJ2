#ifndef WUKONG_FLASH_H
#define WUKONG_FLASH_H
#include <stdint.h>
int sf3_quad_init_and_test(void);
extern uint32_t sf3_quad_id;
int sf3_erase(uint32_t offset);
int sf3_program(uint32_t offset, const volatile uint8_t *data, uint32_t length);
void sf3_refresh_cache(void);
#endif
