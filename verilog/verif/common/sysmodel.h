// System models shared by the J2 Verilator testbenches.
//
//   Memory      big-endian RAM image at address 0 (16 MB, mirrors original
//               cpu_ctb: ram.img at 0 with RAM above it)
//   SysBus      address decode to RAM, DDR stub, PIO (LEDs), uartlite console,
//               sim magic block. Register behaviour follows the original
//               peripherals / reference/.../cpu/sim/cpu_ctb.c.
//   NativeSlave cycle model of a native J-Core bus slave (en/ack handshake)
//               with configurable ack latency, including same-cycle ack.
#pragma once
#include <array>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <functional>
#include <random>
#include <string>
#include <vector>

/* Peripheral models */
#include "cmt.h"

namespace j2sim {

// ------------------------------------------------------------------ memory
struct Memory {
    static constexpr uint32_t SIZE = 16u << 20;
    std::vector<uint8_t>      m    = std::vector<uint8_t>(SIZE, 0);

    bool load_bin(const std::string &path, uint32_t base = 0) {
        FILE *f = fopen(path.c_str(), "rb");
        if (!f) {
            perror(path.c_str());

            return false;
        }

        size_t n = fread(&m[base], 1, SIZE - base, f);
        fclose(f);

        return n > 0;
    }

    uint32_t read32(uint32_t a) const {
        a &= (SIZE - 1) & ~3u;

        return (uint32_t)m[a] << 24 | (uint32_t)m[a + 1] << 16 | (uint32_t)m[a + 2] << 8 | m[a + 3];
    }

    uint16_t read16(uint32_t a) const {
        a &= (SIZE - 1) & ~1u;

        return (uint16_t)(m[a] << 8 | m[a + 1]);
    }
    // we[3] = byte at offset 0 = d[31:24] (big-endian lanes)
    void write(uint32_t a, unsigned we, uint32_t d) {
        a &= (SIZE - 1) & ~3u;
        for (int i = 0; i < 4; i++)
            if (we & (8 >> i)) {
                m[a + i] = (uint8_t)(d >> (24 - 8 * i));
            }
    }
};

// ---------------------------------------------------------- system bus map
struct SysBus {
    Memory mem;
    // observable results
    std::vector<uint32_t> leds;      // every PIO write
    std::string           uart_out;  // everything written to the uartlite TX
    bool                  echo_uart    = true;
    bool                  verbose      = false;
    int                   test_result  = -1;          // written to TEST_RESULT (0 = pass)
    uint32_t              pio          = 0x80000000;  // pio.vhd reset value
    uint64_t              ddr_accesses = 0;
    // Sim event trigger (cpu_ctb.c trigger_event): req 7 = none.
    //   000/001 INTERRUPT (000 maskable, else msk=1), 01x ERROR, 100 BREAK,
    //   other RESET_CPU.  info[11:8] = level, info[7:0] = vector.
    unsigned event_req = 7, event_info = 0;
    Cmt      cmt;
    // Functional SCIF console: transmit completion is immediate, no RX source.
    std::array<uint16_t, 11> scif{0, 0xff, 0, 0, 0x60, 0, 0, 0, 0x51, 0, 0};

    void timer_tick() {
        cmt.tick();
    }

    static constexpr uint32_t PIO_BASE = 0xabcd0000, UART_BASE = 0xabcd0100;
    static constexpr uint32_t MAGIC_BASE  = 0xbcde0000;
    static constexpr uint32_t TEST_RESULT = 0xbcde0010;

    // data bus access; returns read data (whole aligned word, CPU extracts)
    uint32_t access(uint32_t a, bool wr, unsigned we, uint32_t d) {
        if (a < Memory::SIZE) {
            if (wr) {
                mem.write(a, we, d);
            }

            return mem.read32(a);
        }

        if ((a >> 28) == 1) {
            ddr_accesses++;

            return 0;
        }  // DDR stub
        if ((a & ~0xfu) == PIO_BASE) {
            if (((a >> 2) & 3) == 0) {
                if (wr) {
                    for (int i = 0; i < 4; i++)
                        if (we & (8 >> i)) {
                            pio = (pio & ~(0xffu << (24 - 8 * i))) | (d & (0xffu << (24 - 8 * i)));
                        }

                    leds.push_back(pio);
                    if (verbose) {
                        printf("[pio] %08x\n", pio);
                    }
                }

                return pio;
            }

            return 0;
        }

        if ((a & ~0xfu) == UART_BASE) {  // uartlite: only a(3) is decoded
            bool reg_hi = (a >> 3) & 1;
            if (!reg_hi) {  // RX FIFO / TX FIFO
                if (wr) {
                    char c = (char)(d & 0xff);
                    uart_out.push_back(c);
                    if (echo_uart) {
                        fputc(c, stdout);
                        fflush(stdout);
                    }
                }

                return 0;
            }

            return 0x04;  // STATUS: TX FIFO empty, RX empty
        }

        if ((a & 0xfffff000u) == 0xff001000u) {
            unsigned offset = a & 0xffc;
            if (offset > 0x28) {
                return 0;
            }

            unsigned index = offset / 4;
            bool     byte  = index == 1 || index == 3 || index == 5;
            unsigned shift = byte ? 24 : 16;
            unsigned lane  = byte ? 8 : 4;
            if (wr && (we & lane)) {
                uint8_t value = d >> shift;
                switch (index) {
                    case 0:
                        scif[index] = value & 0x7b;
                        break;

                    case 1:
                        scif[index] = value;
                        break;

                    case 2:
                        scif[index] = value & 0xf8;
                        break;

                    case 3:
                        if ((scif[2] & 0x20) && !(scif[6] & 4)) {
                            char c = value;
                            uart_out.push_back(c);
                            if (echo_uart) {
                                fputc(c, stdout);
                                fflush(stdout);
                            }
                        }

                        break;

                    case 6:
                        scif[index] = value & 0xf6;
                        break;

                    case 8:
                        scif[index] = 0x51 | (value & 2);
                        break;

                    default:
                        break;
                }
            }

            return uint32_t(scif[index]) << shift;
        }

        if ((a & 0xfffff000u) == 0xff003000u) {
            return cmt.access(a, wr, we, d);
        }

        if ((a & 0xffff0000u) == MAGIC_BASE) {
            if (wr && a == TEST_RESULT) {
                test_result = (int)d;
                if (d) {
                    printf("[sys] Test failed. Result=%u\n", d);
                }
            }

            if (wr && a == MAGIC_BASE && we == 0xf) {
                event_req  = (d >> 12) & 7;
                event_info = d & 0xfff;
                if (verbose) {
                    printf("[sys] trigger event req=%u info=%03x\n", event_req, event_info);
                }
            }

            return 0;
        }

        return 0;  // unmapped: loopback, ack with 0
    }
    // CPU event_i fields for the current trigger request
    bool ev_en() const {
        return event_req != 7 || cmt.irq[0];
    }

    unsigned ev_cmd() const {  // cpu_event_cmd_t position

        return event_req == 7 ? 0 : event_req <= 1 ? 0 : event_req <= 3 ? 1 : event_req == 4 ? 2 : 3;
    }

    bool ev_msk() const {
        return event_req != 7 && event_req != 0;
    }

    unsigned ev_lvl() const {
        return event_req == 7 ? 14 : event_info >> 8;
    }

    unsigned ev_vec() const {
        return event_req == 7 ? 0x40 : event_info & 0xff;
    }
    // call every cycle with the CPU's event_o.ack; clears on the falling edge
    void ev_ack(bool ack) {
        if (ev_ack_prev && !ack) {
            event_req  = 7;
            event_info = 0;
        }

        ev_ack_prev = ack;
    }

    bool ev_ack_prev = false;

    uint16_t fetch(uint32_t a) {
        if (a < Memory::SIZE) {
            return mem.read16(a);
        }

        return 0;
    }
    // 32-bit instruction fetch (Wishbone instruction bus): same map as fetch()
    uint32_t fetch32(uint32_t a) {
        if (a < Memory::SIZE) {
            return mem.read32(a);
        }

        return 0;
    }
};

// ------------------------------------------------- native bus slave model
// Ack latency: k = cycles from the first cycle 'en' is seen to the ack cycle
// (k = 0: combinational ack in the same cycle). Either fixed or random.
struct Latency {
    unsigned     fixed    = 0;
    unsigned     rand_max = 0;  // >0: uniform random in [fixed, fixed + rand_max]
    std::mt19937 rng{1};
    unsigned     next() {
        return rand_max ? fixed + rng() % (rand_max + 1) : fixed;
    }
};

struct NativeSlave {
    Latency  lat;
    unsigned wait = 0, target = 0;
    bool     in_txn = false, acked = false;
    uint64_t transactions = 0;

    // Called once per cycle after the posedge eval (CPU outputs are registered
    // and stable). Returns ack; 'fn' performs the access and gives read data.
    bool step(bool en, const std::function<uint32_t()> &fn, uint32_t &data) {
        if (acked) {
            in_txn = false;
            acked  = false;
        }  // previous ack consumed at this edge
        data = 0;
        if (!en) {
            in_txn = false;

            return false;
        }

        if (!in_txn) {
            in_txn = true;
            wait   = 0;
            target = lat.next();
        }

        if (wait >= target) {
            data  = fn();
            acked = true;
            transactions++;

            return true;
        }

        wait++;

        return false;
    }
};

}  // namespace j2sim
