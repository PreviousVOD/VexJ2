#ifndef J2_FLASH_H
#define J2_FLASH_H
#include <stdint.h>

int             flash_init_and_test(void);
extern uint32_t flash_jedec_id;
int             flash_erase(uint32_t offset);
int             flash_program(uint32_t offset, const volatile uint8_t *data, uint32_t length);
void            flash_refresh_cache(void);
#endif
