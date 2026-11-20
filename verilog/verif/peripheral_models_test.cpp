#include <cassert>
#include <cstdio>

/* App */
#include "common/sysmodel.h"

int main() {
    j2sim::SysBus bus;
    bus.echo_uart  = false;
    auto sci_write = [&](unsigned offset, uint8_t value) {
        bool byte = offset == 4 || offset == 12;
        bus.access(0xff001000 + offset, true, byte ? 8 : 12, uint32_t(value) << (byte ? 24 : 16));
    };
    assert(bus.access(0xff001010, false, 0, 0) == 0x00600000);
    sci_write(0, 0xff);
    assert(bus.access(0xff001000, false, 0, 0) == 0x007b0000);
    assert(bus.access(0xff001004, false, 0, 0) == 0xff000000);
    sci_write(8, 0x2b);
    assert(bus.access(0xff001008, false, 0, 0) == 0x00280000);
    sci_write(12, 'A');
    assert(bus.uart_out == "A");
    sci_write(16, 0x9f);
    assert(bus.uart_out == "A");
    bus.access(0xff00100c, true, 0, 0);
    assert(bus.uart_out == "A");
    sci_write(24, 4);
    sci_write(12, 'B');
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
