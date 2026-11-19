#include <cassert>
#include <cstdio>

/* App */
#include "common/sysmodel.h"

int main() {
    j2sim::SysBus bus;
    bus.echo_uart  = false;
    auto sci_write = [&](unsigned offset, uint8_t value) {
        unsigned shift = (offset & 2) ? 8 : 24;
        bus.access(0xff001000 + offset, true, 1u << (shift / 8), uint32_t(value) << shift);
    };
    assert(bus.access(0xff001008, false, 0, 0) == 0x84000000);
    sci_write(0, 0xff);
    assert(bus.access(0xff001000, false, 0, 0) == 0x7b00ff00);
    sci_write(4, 0x2b);
    sci_write(6, 'A');
    assert(bus.uart_out.empty());
    sci_write(8, 0xff);
    assert(bus.uart_out.empty());
    sci_write(8, 0x7f);
    assert(bus.uart_out == "A");
    bus.access(0xff001008, true, 0, 0);
    assert(bus.uart_out == "A");

    auto &cmt = bus.cmt;
    cmt.write(6, 1, 3);
    cmt.write(2, 0x40, 1);
    cmt.write(0, 1, 1);
    for (unsigned i = 0; i < 16; ++i) {
        cmt.tick();
    }
    assert(cmt.count[0] == 0 && (cmt.control[0] & 0x80));
    assert(!cmt.irq[0]);
    cmt.tick();
    assert(cmt.irq[0] && bus.ev_en() && bus.ev_vec() == 64);
    cmt.write(2, 0xc0, 1);
    assert(cmt.control[0] & 0x80);
    cmt.write(2, 0x40, 1);
    cmt.tick();
    assert(!cmt.irq[0]);
    cmt.write(0, 0, 1);
    cmt.write(4, 0x1234, 3);
    cmt.write(4, 0xab00, 2);
    assert(cmt.count[0] == 0xab34);
    cmt.write(4, 1, 3);
    for (unsigned i = 0; i < 8; ++i) {
        cmt.tick();
    }
    assert(cmt.count[0] == 0 && (cmt.control[0] & 0x80));

    // Independent channel 1 rolls over at PCLK/512 and asserts one clock later.
    cmt.write(8, 0x43, 1);
    cmt.write(10, 0xffff, 3);
    cmt.write(0, 2, 1);
    while ((cmt.phase & 511) != 0) {
        cmt.tick();
    }
    assert(cmt.count[1] == 0 && (cmt.control[1] & 0x80));
    cmt.tick();
    assert(cmt.irq[1]);
    std::puts("Peripheral functional models passed");

    return 0;
}
