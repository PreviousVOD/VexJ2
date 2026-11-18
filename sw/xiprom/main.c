#include <stdint.h>
#include "flash.h"
#include "uart.h"

#define XIP_BASE 0x10000000
#define XIP_MAGIC 0x4a325831
#define XIP_HEADER_WORDS 8
#define XIP_HEADER_BYTES (XIP_HEADER_WORDS * 4)
#define XIP_LOAD_ADDRESS (XIP_BASE + XIP_HEADER_BYTES)
#define SDRAM_BASE 0x80000000
#define SDRAM_BYTES 0x00800000
#define FLASH_BYTES (1024 * 1024)
#define FLASH_SECTOR_BYTES 65536
#define FLASH_PAGE_BYTES 256

static uint8_t page_buffer[FLASH_PAGE_BYTES];

static uint32_t uart_read_be32(void) {
  uint32_t value = 0;
  int index;
  for (index = 0; index < 4; ++index)
    value = (value << 8) | uart_rx();
  return value;
}

static int image_header_valid(void) {
  volatile const uint32_t *header = (volatile const uint32_t *)XIP_BASE;
  uint32_t entry = header[1];
  uint32_t length = header[2];
  uint32_t load = header[4];
  if (header[0] != XIP_MAGIC || header[5] || header[6] || header[7]) return 0;
  if (length == 0 || length > FLASH_BYTES - XIP_HEADER_BYTES) return 0;
  if ((entry & 1) || entry < load || entry - load >= length) return 0;
  if (load == XIP_LOAD_ADDRESS) return 1;
  if (load < SDRAM_BASE || load >= SDRAM_BASE + SDRAM_BYTES) return 0;
  return length <= SDRAM_BYTES - (load - SDRAM_BASE);
}

static uint32_t application_checksum(uint32_t length) {
  uint32_t checksum = 0;
  uint32_t index;
  for (index = 0; index < length; ++index)
    checksum += *(volatile const uint8_t *)(XIP_LOAD_ADDRESS + index);
  return checksum;
}

static void boot_application(void) {
  volatile const uint32_t *header = (volatile const uint32_t *)XIP_BASE;
  uint32_t length = header[2];
  uint32_t expected = header[3];
  uint32_t load = header[4];
  uint32_t actual;
  uint32_t index;
  void (*entry)(void);

  if (!image_header_valid()) {
    uart_puts("No valid application image: ");
    uart_hex(header[0], 8);
    uart_puts(" ");
    uart_hex(header[1], 8);
    uart_puts(" ");
    uart_hex(length, 8);
    uart_puts("\n");
    return;
  }
  actual = application_checksum(length);
  if (actual != expected) {
    uart_puts("Image checksum error: expected ");
    uart_hex(expected, 8);
    uart_puts(", actual ");
    uart_hex(actual, 8);
    uart_puts("\n");
    return;
  }
  if (load == XIP_LOAD_ADDRESS) {
    uart_puts("Booting XIP image\n");
  } else {
    uart_puts("Loading image to ");
    uart_hex(load, 8);
    uart_puts("\n");
    for (index = 0; index < length; ++index)
      *(volatile uint8_t *)(load + index) = *(volatile const uint8_t *)(XIP_LOAD_ADDRESS + index);
    uart_puts("Booting loaded image\n");
  }
  entry = (void (*)(void))header[1];
  entry();
}

static int wait_for_loader(void) {
  uint32_t timeout;
  for (timeout = 0; timeout < 50000; ++timeout) {
    if (uart_rx_ready()) return uart_rx() == 'U';
  }
  return 0;
}

static int load_application(void) {
  uint32_t address;
  uint32_t length;
  uint32_t offset;
  uint32_t index;
  uint8_t expected;

  uart_puts("J2 loader\n");
  if (uart_rx() != 'J' || uart_rx() != '2' || uart_rx() != 'U' || uart_rx() != 'P') {
    uart_puts("Bad loader magic\n");
    return 0;
  }
  address = uart_read_be32();
  length = uart_read_be32();
  if (address != 0 || length <= XIP_HEADER_BYTES || length > FLASH_BYTES) {
    uart_puts("Bad image range\n");
    return 0;
  }

  uart_puts("Erase flash\n");
  for (offset = 0; offset < length; offset += FLASH_SECTOR_BYTES)
    flash_erase_sector(address + offset);

  uart_puts("Program flash\n");
  for (offset = 0; offset < length;) {
    uint32_t count = length - offset;
    if (count > FLASH_PAGE_BYTES) count = FLASH_PAGE_BYTES;
    for (index = 0; index < count; ++index)
      page_buffer[index] = uart_rx();
    flash_program_page(address + offset, page_buffer, count);
    for (index = 0; index < count; ++index) {
      expected = page_buffer[index];
      if (*(volatile const uint8_t *)(XIP_BASE + offset + index) != expected) {
        uart_puts("Verify error\n");
        return 0;
      }
    }
    uart_puts("Page ");
    uart_hex(offset, 6);
    uart_puts("\n");
    offset += count;
  }
  uart_puts("Flash verified\n");
  return 1;
}

void boot_main(void) {
  uint32_t id;
  uart_init();
  uart_puts("\nJ2 boot\n");
  flash_reset();
  id = flash_read_id();
  uart_puts("Flash ID: ");
  uart_hex(id, 6);
  uart_puts("\n");

  if (image_header_valid()) {
    uart_puts("Send U to load\n");
    if (!wait_for_loader()) boot_application();
  }
  if (load_application()) boot_application();
}
