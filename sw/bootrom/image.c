/* App */
#include "image.h"

#include "board.h"

uint32_t image_word(const volatile uint8_t *image, unsigned word) {
    const volatile uint8_t *p = image + word * 4;

    return ((uint32_t)p[0] << 24) | ((uint32_t)p[1] << 16) | ((uint32_t)p[2] << 8) | p[3];
}

int image_valid(const volatile uint8_t *image, uint32_t available, int exact) {
    if (available < IMAGE_HEADER_BYTES) {
        return 0;
    }

    if (available > J2_XIP_BYTES) {
        return 0;
    }

    uint32_t entry  = image_word(image, 1);
    uint32_t length = image_word(image, 2);
    uint32_t load   = image_word(image, 4);
    if (image_word(image, 0) != IMAGE_MAGIC) {
        return 0;
    }

    if (image_word(image, 5)) {
        return 0;
    }

    if (image_word(image, 6)) {
        return 0;
    }

    if (image_word(image, 7)) {
        return 0;
    }

    if (length < 2) {
        return 0;
    }

    if (length > available - IMAGE_HEADER_BYTES) {
        return 0;
    }

    if (exact && length != available - IMAGE_HEADER_BYTES) {
        return 0;
    }

    if ((entry | load) & 1) {
        return 0;
    }

    if (entry < load) {
        return 0;
    }

    if (entry - load > length - 2) {
        return 0;
    }

    return load == J2_XIP_BASE + IMAGE_HEADER_BYTES;
}

uint32_t image_checksum(const volatile uint8_t *data, uint32_t length) {
    uint32_t sum = 0;
    while (length--) {
        sum += *data++;
    }

    return sum;
}
