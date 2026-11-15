#include "flash.h"

#define FLASH_CONTROL (*(volatile uint32_t *)0xff002000)

static void flash_end(void) {
  FLASH_CONTROL = 0x100;
}

static void flash_write_enable(void) {
  flash_end();
  FLASH_CONTROL = 0x06;
  flash_end();
}

static void flash_wait(void) {
  uint8_t status;
  flash_end();
  FLASH_CONTROL = 0x05;
  do {
    FLASH_CONTROL = 0;
    status = FLASH_CONTROL & 0xff;
  } while (status & 1);
  flash_end();
}

void flash_reset(void) {
  int index;
  flash_end();
  for (index = 0; index < 16; ++index)
    FLASH_CONTROL = 0xff;
  flash_end();
}

uint32_t flash_read_id(void) {
  uint32_t id = 0;
  int index;
  flash_end();
  FLASH_CONTROL = 0x9f;
  for (index = 0; index < 3; ++index) {
    FLASH_CONTROL = 0;
    id = (id << 8) | (FLASH_CONTROL & 0xff);
  }
  flash_end();
  return id;
}

void flash_erase_sector(uint32_t address) {
  flash_write_enable();
  FLASH_CONTROL = 0xd8;
  FLASH_CONTROL = (address >> 16) & 0xff;
  FLASH_CONTROL = (address >> 8) & 0xff;
  FLASH_CONTROL = address & 0xff;
  flash_end();
  flash_wait();
}

void flash_program_page(uint32_t address, const uint8_t *data, uint32_t length) {
  uint32_t index;
  flash_write_enable();
  FLASH_CONTROL = 0x02;
  FLASH_CONTROL = (address >> 16) & 0xff;
  FLASH_CONTROL = (address >> 8) & 0xff;
  FLASH_CONTROL = address & 0xff;
  for (index = 0; index < length; ++index)
    FLASH_CONTROL = data[index];
  flash_end();
  flash_wait();
}
