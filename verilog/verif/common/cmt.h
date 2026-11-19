#pragma once

#include <array>
#include <cstdint>

namespace j2sim {

// Functional CMT model for the original VHDL core's native-bus testbench.
struct Cmt {
    uint16_t                start = 0;
    unsigned                phase = 0;
    std::array<uint16_t, 2> count{}, previous{}, control{};
    std::array<uint16_t, 2> compare{0xffff, 0xffff};
    std::array<bool, 2>     matched{}, incremented{}, irq{};

    void tick() {
        ++phase;
        for (unsigned i = 0; i < 2; ++i) {
            irq[i]           = (control[i] & 0xc0) == 0xc0;
            previous[i]      = count[i];
            unsigned divisor = 8u << (2u * (control[i] & 3));
            bool     clock   = (phase & (divisor - 1)) == 0;
            matched[i]       = clock && count[i] == compare[i];
            incremented[i]   = clock && (start & (1u << i)) && !matched[i];
            if (matched[i]) {
                count[i]    = 0;
                control[i] |= 0x80;
            } else if (incremented[i]) {
                ++count[i];
            }
        }
    }

    uint16_t read(unsigned offset) const {
        switch (offset) {
            case 0:
                return start;

            case 2:
                return control[0];

            case 4:
                return count[0];

            case 6:
                return compare[0];

            case 8:
                return control[1];

            case 10:
                return count[1];

            case 12:
                return compare[1];

            default:
                return 0;
        }
    }

    void write(unsigned offset, uint16_t data, unsigned lanes) {
        if (!lanes) {
            return;
        }

        uint16_t mask = ((lanes & 2) ? 0xff00 : 0) | ((lanes & 1) ? 0xff : 0);
        if (offset == 0) {
            if (lanes & 1) {
                start = data & 3;
            }

            return;
        }

        unsigned channel = offset >= 8;
        unsigned csr     = 2 + 6 * channel;
        if (offset == csr) {
            if (lanes & 1) {
                control[channel] = (data & 0x43) | (control[channel] & data & 0x80) | (matched[channel] ? 0x80 : 0);
            }
        } else if (offset == csr + 2) {
            if (!matched[channel]) {
                uint16_t before      = incremented[channel] ? previous[channel] : count[channel];
                count[channel]       = (before & ~mask) | (data & mask);
                incremented[channel] = false;
            }
        } else if (offset == csr + 4) {
            compare[channel] = (compare[channel] & ~mask) | (data & mask);
        }
    }

    uint32_t access(uint32_t address, bool wr, unsigned lanes, uint32_t data) {
        unsigned offset = address & 0xffc;
        if (wr) {
            write(offset, data >> 16, (lanes >> 2) & 3);
            write(offset + 2, data, lanes & 3);
        }

        return (uint32_t(read(offset)) << 16) | read(offset + 2);
    }
};

}  // namespace j2sim
