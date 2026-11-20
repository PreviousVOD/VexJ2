#include <stdint.h>

/* App */
#include "board.h"

#define SPI_REG(index) (*(volatile uint32_t *)(J2_SPI_CONTROL_BASE + (index) * 4u))
#define SF3_ID         0x20ba19u

static int array_ready(void);

/* Initialization uses volatile protocol settings; array writes are bounded below. */
static int enqueue(uint32_t command) {
    uint32_t timeout = 100000;
    while ((SPI_REG(1) & 0xffff) == 0) {
        if (--timeout == 0) {
            return 0;
        }
    }
    SPI_REG(0) = command;

    return 1;
}

static int idle(void) {
    uint32_t timeout = 100000;
    while ((SPI_REG(1) & 0xffff) != 32 || (SPI_REG(3) & 0x10000)) {
        if (--timeout == 0) {
            return 0;
        }
    }

    return 1;
}

static int end(void) {
    return enqueue(0x800) && idle();
}

static int receive(uint8_t *result) {
    uint32_t timeout = 100000;
    if (!enqueue(0x200)) {
        return 0;
    }

    do {
        uint32_t response = SPI_REG(0);
        if (!(response & 0x80000000u)) {
            *result = (uint8_t)response;

            return 1;
        }
    } while (--timeout);

    return 0;
}

static int begin(uint8_t opcode) {
    return enqueue(0x881) && enqueue(0x100u | opcode);
}

static int read_reg(uint8_t opcode, uint8_t *value) {
    int ok = begin(opcode) && receive(value);

    return end() && ok;
}

static int write_enable(void) {
    return begin(0x06) && end();
}

#if J2_FLASH_MICRON
static int write_reg(uint8_t opcode, uint8_t value) {
    int ok = write_enable() && begin(opcode) && enqueue(0x100u | value);

    return end() && ok;
}

#endif

static uint32_t read_id(uint8_t opcode) {
    uint32_t id = 0;
    uint8_t  byte;
    if (!begin(opcode)) {
        return 0xffffffffu;
    }

    for (int i = 0; i < 3; ++i) {
        if (!receive(&byte)) {
            end();

            return 0xffffffffu;
        }

        id = (id << 8) | byte;
    }

    return end() ? id : 0xffffffffu;
}

static int single_read(uint32_t address, uint8_t *bytes) {
    int ok = begin(0x03) && enqueue(0x100u | (address >> 16)) && enqueue(0x100u | ((address >> 8) & 255)) &&
             enqueue(0x100u | (address & 255));
    for (int i = 0; ok && i < 32; ++i) {
        ok = receive(bytes + i);
    }

    return end() && ok;
}

uint32_t flash_jedec_id;

/* Obtain an independent single-SPI reference before qualifying quad XIP.
 * Micron recovers persistent 4-4-4 mode; Winbond uses 1-4-4 with its QE bit. */
int flash_init_and_test(void) {
    static const uint32_t offsets[] = {0, 32, 0x100, 0x800, J2_XIP_BYTES - 32};
    uint8_t               reference[sizeof(offsets) / sizeof(offsets[0])][32];
    uint8_t               evcr, verify;
#if J2_FLASH_MICRON
    SPI_REG(2) = 0x10; /* mode 0, quad half duplex */
    SPI_REG(3) = 0;
    SPI_REG(4) = 0;
    /* Keep SCK at 4 MHz and CS setup/hold/disable at 125 ns. */
    SPI_REG(8) = J2_CLOCK_HZ / 8000000u - 1u;
    SPI_REG(9) = SPI_REG(10) = SPI_REG(11) = J2_CLOCK_HZ / 8000000u - 1u;
    SPI_REG(12)                            = 0;
    if (read_id(0xaf) == SF3_ID) {
        if (!read_reg(0x65, &evcr)) {
            return 0;
        }

        if (!write_reg(0x61, evcr | 0xc0)) {
            return 0;
        }
    }

    SPI_REG(2) = 0; /* single SPI */
    if (read_id(0x9f) != SF3_ID) {
        return 0;
    }

    /* Explicitly select 3-byte addressing and the lower 16 MiB bank. */
    if (!write_enable()) {
        return 0;
    }

    if (!begin(0xe9)) {
        return 0;
    }

    if (!end()) {
        return 0;
    }

    if (!write_reg(0xc5, 0)) {
        return 0;
    }

    for (unsigned i = 0; i < sizeof(offsets) / sizeof(offsets[0]); ++i) {
        if (!single_read(J2_FLASH_OFFSET + offsets[i], reference[i])) {
            return 0;
        }
    }
    if (!write_reg(0x81, 0x8b)) {
        return 0;
    }

    if (!read_reg(0x85, &verify)) {
        return 0;
    }

    if ((verify & 0xfb) != 0x8b) {
        return 0;
    }

    if (!read_reg(0x65, &evcr)) {
        return 0;
    }

    if (!write_reg(0x61, (evcr & 0x7f) | 0x40)) {
        return 0;
    }

    SPI_REG(2)     = 0x10;
    flash_jedec_id = read_id(0xaf);
    if (flash_jedec_id != SF3_ID) {
        return 0;
    }

    /* dummyCount is byte-count minus one: four quad bytes = eight clocks. */
    SPI_REG(17) = 0x03ff01eb;
    SPI_REG(18) = 0x01010101;
#else
    (void)evcr;
    (void)verify;
    SPI_REG(2) = 0; /* Winbond 1-4-4: single-bit commands, quad XIP address/data. */
    SPI_REG(3) = 0;
    SPI_REG(4) = 0;
    SPI_REG(8) = (J2_CLOCK_HZ + 15999999u) / 16000000u - 1u;
    SPI_REG(9) = SPI_REG(10) = SPI_REG(11) = 1;
    SPI_REG(12)                            = 0;
    if (!end()) {
        return 0;
    }

    if (!begin(0xff)) {
        return 0;
    }

    for (unsigned i = 0; i < 15; ++i) {
        if (!enqueue(0x1ff)) {
            return 0;
        }
    }
    if (!end()) {
        return 0;
    }

    flash_jedec_id = read_id(0x9f);
    if (!flash_jedec_id) {
        return 0;
    }

    if (flash_jedec_id == 0xffffffu) {
        return 0;
    }

    if (flash_jedec_id == 0xffffffffu) {
        return 0;
    }

    for (unsigned i = 0; i < sizeof(offsets) / sizeof(offsets[0]); ++i) {
        if (!single_read(J2_FLASH_OFFSET + offsets[i], reference[i])) {
            return 0;
        }
    }
    /* Match the supported board's W25Q status-register/QE sequence. */
    if (!write_enable()) {
        return 0;
    }

    if (!begin(0x01)) {
        return 0;
    }

    if (!enqueue(0x100)) {
        return 0;
    }

    if (!enqueue(0x102)) {
        return 0;
    }

    if (!end()) {
        return 0;
    }

    if (!array_ready()) {
        return 0;
    }

    SPI_REG(17) = 0x02ff01eb;
    SPI_REG(18) = 0x01010100;
#endif
    SPI_REG(16) = 1;
    for (unsigned i = 0; i < sizeof(offsets) / sizeof(offsets[0]); ++i) {
        volatile const uint32_t *mapped = (volatile const uint32_t *)(J2_XIP_BASE + offsets[i]);
        for (unsigned word = 0; word < 8; ++word) {
            const uint8_t *b        = &reference[i][word * 4];
            uint32_t       expected = ((uint32_t)b[0] << 24) | ((uint32_t)b[1] << 16) | ((uint32_t)b[2] << 8) | b[3];
            if (mapped[word] != expected) {
                return 0;
            }
        }
    }

    return 1;
}

/* ROM runs outside XIP throughout updates. Offsets are relative to the
 * application partition; neither bulk erase nor config-flash access exists. */
void flash_refresh_cache(void) {
    volatile uint32_t *cache = (volatile uint32_t *)J2_XIP_CACHE_CONTROL_BASE;
    *cache                   = 1;
    while (*cache & 2) {
    }
}

static int array_address(uint8_t opcode, uint32_t offset) {
    uint32_t address = J2_FLASH_OFFSET + offset;

    return begin(opcode) && enqueue(0x100u | (address >> 16)) && enqueue(0x100u | ((address >> 8) & 255)) &&
           enqueue(0x100u | (address & 255));
}

static int array_ready(void) {
    uint8_t status;
#if J2_FLASH_MICRON
    uint8_t flags;
#endif
    /* Bounded, deliberately conservative for a 64 KiB sector erase at 4 MHz. */
    uint32_t polls = 1000000;
    do {
        if (!read_reg(0x05, &status)) {
            return 0;
        }

        if (!(status & 1)) {
#if J2_FLASH_MICRON
            if (!read_reg(0x70, &flags)) {
                return 0;
            }

            return (flags & 0xfe) == 0x80; /* ready, no suspend/program/erase/VPP/protection error */
#else
            return 1;
#endif
        }
    } while (--polls);

    return 0;
}

static int array_write_enable(void) {
    uint8_t status;
#if J2_FLASH_MICRON
    if (!begin(0x50)) {
        return 0;
    }

    if (!end()) {
        return 0;
    }

#endif
    if (!write_enable()) {
        return 0;
    }

    if (!read_reg(0x05, &status)) {
        return 0;
    }

    return (status & 3) == 2; /* WEL set, no operation in progress */
}

int flash_erase(uint32_t offset) {
    if (offset & 65535) {
        return 0;
    }

    if (offset >= J2_XIP_BYTES) {
        return 0;
    }

    if (J2_XIP_BYTES - offset < 65536) {
        return 0;
    }

    if (!array_write_enable()) {
        return 0;
    }

    int ok = array_address(0xd8, offset);
    if (!end()) {
        return 0;
    }

    if (!ok) {
        return 0;
    }

    if (!array_ready()) {
        return 0;
    }

    flash_refresh_cache();

    return 1;
}

int flash_program(uint32_t offset, const volatile uint8_t *data, uint32_t length) {
    if (!length) {
        return 0;
    }

    if (length > 256) {
        return 0;
    }

    if (offset >= J2_XIP_BYTES) {
        return 0;
    }

    if (length > J2_XIP_BYTES - offset) {
        return 0;
    }

    if (length > 256 - (offset & 255)) {
        return 0;
    }

    if (!array_write_enable()) {
        return 0;
    }

    int ok = array_address(0x02, offset);
    for (uint32_t i = 0; ok && i < length; ++i) {
        ok = enqueue(0x100u | data[i]);
    }
    if (!end()) {
        return 0;
    }

    if (!ok) {
        return 0;
    }

    if (!array_ready()) {
        return 0;
    }

    flash_refresh_cache();

    return 1;
}
