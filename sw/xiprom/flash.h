#ifndef XIP_FLASH_H
#define XIP_FLASH_H

#include <stdint.h>

void flash_reset(void);
uint32_t flash_read_id(void);
void flash_read(uint32_t address, uint8_t *data, uint32_t length);
void flash_erase_sector(uint32_t address);
void flash_program_page(uint32_t address, const uint8_t *data, uint32_t length);

#endif
