#include "flash.h"

#define FLASH_REG(index) (*(volatile uint32_t *)(0xff002000 + (index) * 4))
#define FLASH_DATA FLASH_REG(0)
#define FLASH_STATUS FLASH_REG(1)

static void spi_init(void) {
  FLASH_REG(2) = 0;
  FLASH_REG(3) = 0;
  FLASH_REG(4) = 0;
  FLASH_REG(8) = 1;
  FLASH_REG(9) = 1;
  FLASH_REG(10) = 1;
  FLASH_REG(11) = 1;
  FLASH_REG(12) = 0;
  FLASH_REG(17) = 0x02ff01eb;
  FLASH_REG(18) = 0x01010100;
}

static void flash_end(void) {
  FLASH_DATA = 0x800;
}

static void flash_begin(void) {
  spi_init();
  FLASH_DATA = 0x881;
}

static uint8_t flash_transfer(uint8_t data) {
  while ((FLASH_STATUS & 0xffff) == 0);
  FLASH_DATA = 0x300 | data;
  while (FLASH_DATA & 0x80000000);
  return FLASH_DATA & 0xff;
}

static void flash_write_enable(void) {
  flash_begin();
  flash_transfer(0x06);
  flash_end();
}

static void flash_wait(void) {
  uint8_t status;
  flash_begin();
  flash_transfer(0x05);
  do {
    status = flash_transfer(0);
  } while (status & 1);
  flash_end();
}

void flash_reset(void) {
  int index;
  flash_end();
  flash_begin();
  for (index = 0; index < 16; ++index)
    flash_transfer(0xff);
  flash_end();

  flash_write_enable();
  flash_begin();
  flash_transfer(0x01);
  flash_transfer(0x00);
  flash_transfer(0x02);
  flash_end();
  flash_wait();
}

uint32_t flash_read_id(void) {
  uint32_t id = 0;
  int index;
  flash_begin();
  flash_transfer(0x9f);
  for (index = 0; index < 3; ++index)
    id = (id << 8) | flash_transfer(0);
  flash_end();
  return id;
}

void flash_read(uint32_t address, uint8_t *data, uint32_t length) {
  uint32_t index;
  flash_begin();
  flash_transfer(0x03);
  flash_transfer((address >> 16) & 0xff);
  flash_transfer((address >> 8) & 0xff);
  flash_transfer(address & 0xff);
  for (index = 0; index < length; ++index)
    data[index] = flash_transfer(0);
  flash_end();
}

void flash_erase_sector(uint32_t address) {
  flash_write_enable();
  flash_begin();
  flash_transfer(0xd8);
  flash_transfer((address >> 16) & 0xff);
  flash_transfer((address >> 8) & 0xff);
  flash_transfer(address & 0xff);
  flash_end();
  flash_wait();
}

void flash_program_page(uint32_t address, const uint8_t *data, uint32_t length) {
  uint32_t index;
  flash_write_enable();
  flash_begin();
  flash_transfer(0x02);
  flash_transfer((address >> 16) & 0xff);
  flash_transfer((address >> 8) & 0xff);
  flash_transfer(address & 0xff);
  for (index = 0; index < length; ++index)
    flash_transfer(data[index]);
  flash_end();
  flash_wait();
}
