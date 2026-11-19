#include <stdint.h>
#include "board.h"
#include "uart.h"
#include "flash.h"
#include "image.h"
#define TIMER(i) (*(volatile uint32_t *)(0xff003000u + 4u * (i)))
#define STAGING (J2_MEMORY_BASE + J2_MEMORY_BYTES - J2_XIP_BYTES)
#ifndef BOOT_WAIT_US
#define BOOT_WAIT_US 1000000u
#endif
#ifndef RECEIVE_WAIT_US
#define RECEIVE_WAIT_US 5000000u
#endif

static int receive(uint8_t *value, uint32_t timeout) {
  TIMER(2) = 0;
  while (!uart_rx_ready()) if (TIMER(2) >= timeout) return 0;
  *value = uart_rx();
  return 1;
}
static int receive_word(uint32_t *value) {
  *value = 0;
  for (unsigned i = 0; i < 4; ++i) {
    uint8_t b;
    if (!receive(&b, RECEIVE_WAIT_US)) return 0;
    *value = (*value << 8) | b;
  }
  return 1;
}
static int boot(void) {
  volatile const uint8_t *image = (volatile const uint8_t *)J2_XIP_BASE;
  sf3_refresh_cache();
  if (!image_valid(image, J2_XIP_BYTES, 0)) { uart_puts("No valid application image\n"); return 0; }
  uint32_t length = image_word(image, 2), load = image_word(image, 4);
  if (image_checksum(image + IMAGE_HEADER_BYTES, length) != image_word(image, 3)) {
    uart_puts("Image checksum error\n"); return 0;
  }
  if (load != J2_XIP_BASE + IMAGE_HEADER_BYTES) {
    uart_puts("Loading image to "); uart_hex(load, 8); uart_puts("\n");
    for (uint32_t i = 0; i < length; ++i)
      *(volatile uint8_t *)(load + i) = image[IMAGE_HEADER_BYTES + i];
    if (image_checksum((volatile const uint8_t *)load, length) != image_word(image, 3)) {
      uart_puts("DDR copy error\n"); return 0;
    }
  }
  TIMER(0) = 0; TIMER(3) = 0; TIMER(2) = 0;
  uart_puts(load == J2_XIP_BASE + IMAGE_HEADER_BYTES ? "Booting XIP image\n" : "Booting loaded image\n");
  ((void (*)(void))image_word(image, 1))();
  uart_puts("Application returned\n");
  /* Application startup owns VBR, stack and writable data initialization. */
  return 0;
}
static int upload(void) {
  uint32_t magic, offset, total;
  if (!receive_word(&magic) || !receive_word(&offset) || !receive_word(&total)) {
    uart_puts("Receive timeout\n"); return 0;
  }
  if (magic == 0x4a325244) { /* J2RD: read-only backup of application bytes */
    if (!total || offset >= J2_XIP_BYTES || total > J2_XIP_BYTES - offset) {
      uart_puts("Bad image range\n"); return 0;
    }
    uart_puts("Read flash\n");
    for (uint32_t i = 0; i < total; ++i)
      uart_tx(*(volatile const uint8_t *)(J2_XIP_BASE + offset + i));
    uart_puts("Read complete\n"); return 0;
  }
  if (magic != 0x4a325550 || offset != 0 || total < IMAGE_HEADER_BYTES + 2 || total > J2_XIP_BYTES) {
    uart_puts("Bad image range\n"); return 0;
  }
  volatile uint8_t *staged = (volatile uint8_t *)STAGING;
  uart_puts("Send image\n");
  for (uint32_t i = 0; i < total;) {
    uint32_t count = total - i;
    if (count > 256) count = 256;
    for (uint32_t j = 0; j < count; ++j) {
      uint8_t b;
      if (!receive(&b, RECEIVE_WAIT_US)) { uart_puts("Receive timeout\n"); return 0; }
      staged[i + j] = b;
    }
    uart_puts("Received "); uart_hex(i, 6); uart_puts("\n");
    i += count;
  }
  if (!image_valid(staged, total, 1) ||
      image_checksum(staged + IMAGE_HEADER_BYTES, total - IMAGE_HEADER_BYTES) != image_word(staged, 3)) {
    uart_puts("Invalid staged image\n"); return 0;
  }
  uart_puts("Erase flash\n");
  for (uint32_t i = 0; i < total; i += 65536)
    if (!sf3_erase(i)) { uart_puts("Erase error\n"); return 0; }
  uart_puts("Program flash\n");
  /* Leave the header erased until every payload byte is programmed and verified. */
  for (uint32_t i = IMAGE_HEADER_BYTES; i < total;) {
    uint32_t count = 256 - (i & 255);
    if (count > total - i) count = total - i;
    if (!sf3_program(i, staged + i, count)) { uart_puts("Program error\n"); return 0; }
    for (uint32_t j = 0; j < count; ++j)
      if (*(volatile const uint8_t *)(J2_XIP_BASE + i + j) != staged[i + j]) {
        uart_puts("Verify error\n"); return 0;
      }
    i += count;
  }
  if (!sf3_program(0, staged, IMAGE_HEADER_BYTES)) { uart_puts("Header error\n"); return 0; }
  for (uint32_t i = 0; i < IMAGE_HEADER_BYTES; ++i)
    if (*(volatile const uint8_t *)(J2_XIP_BASE + i) != staged[i]) {
      uart_puts("Verify error\n"); return 0;
    }
  uart_puts("Flash verified\n");
  return 1;
}
void application_loader(void) {
  TIMER(0) = 0; TIMER(3) = 0; TIMER(1) = 0xffffffffu; TIMER(0) = 1;
  uart_puts("Send U to load\n");
  uint8_t command;
  if (!receive(&command, BOOT_WAIT_US) || command != 'U') boot();
  for (;;) {
    TIMER(0) = 1;
    uart_puts("Wukong loader\n");
    if (upload()) boot();
  }
}
