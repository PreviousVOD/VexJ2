#ifndef WUKONG_IMAGE_H
#define WUKONG_IMAGE_H
#include <stdint.h>
#define IMAGE_HEADER_BYTES 32u
#define IMAGE_MAGIC 0x4a325831u
uint32_t image_word(const volatile uint8_t *image, unsigned word);
int image_valid(const volatile uint8_t *image, uint32_t available, int exact);
uint32_t image_checksum(const volatile uint8_t *data, uint32_t length);
#endif
