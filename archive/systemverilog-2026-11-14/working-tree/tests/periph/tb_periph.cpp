// Bus-level tests for the native Mimas v2 peripheral subsystem.
#include "Vtb_periph.h"
#include "verilated.h"
#include <cstdio>
#include <cstdlib>

static int failures = 0;

static void expect_eq(const char *name, uint32_t got, uint32_t want) {
  if (got != want) {
    std::fprintf(stderr, "[periph] FAIL %-36s got %08x want %08x\n",
                 name, got, want);
    failures++;
  } else {
    std::printf("[periph] PASS %s\n", name);
  }
}

struct Bench {
  Vtb_periph t;
  uint64_t cycles = 0;
  static constexpr double uart_bit = 50e6 / 19073.5;

  void tick() {
    t.clk = 1;
    t.eval();
    t.clk = 0;
    t.eval();
    cycles++;
  }

  void reset() {
    t.clk = 0;
    t.rst = 1;
    t.cyc = 0;
    t.stb = 0;
    t.we = 0;
    t.adr = 0;
    t.sel = 0;
    t.dat_o = 0;
    t.ic_fetch_addr = 0x091a2b3c;
    t.cpu_event_ack = 0;
    t.cpu_event_lvl = 0;
    t.cpu_event_slp = 0;
    t.cpu_event_dbg = 0;
    t.uart_rx = 1;
    t.spi_miso = 0;
    t.pi = 0;
    t.eval();
    for (int i = 0; i < 4; i++) tick();
    t.rst = 0;
    t.eval();
  }

  uint32_t access(uint32_t addr, bool write, uint32_t data,
                  unsigned be = 0xf) {
    t.adr = addr;
    t.dat_o = data;
    t.sel = be;
    t.we = write;
    t.cyc = 1;
    t.stb = 1;
    tick();
    t.stb = 0;

    unsigned guard = 32;
    while (!t.ack && guard--) tick();
    if (!t.ack) {
      std::fprintf(stderr, "[periph] timeout at %08x\n", addr);
      std::exit(1);
    }
    uint32_t result = t.dat_i;
    t.cyc = 0;
    tick();
    return result;
  }

  uint32_t read(uint32_t addr) { return access(addr, false, 0); }
  void write(uint32_t addr, uint32_t data, unsigned be = 0xf) {
    access(addr, true, data, be);
  }

  void delay_bits(double bits) {
    uint64_t end = cycles + (uint64_t)(bits * uart_bit + 0.5);
    while (cycles < end) tick();
  }

  int receive_uart(uint64_t max_cycles = 60000) {
    int state = -1;
    double next_sample = 0;
    unsigned shift = 0;
    bool prev_tx = t.uart_tx;
    uint64_t end = cycles + max_cycles;
    while (cycles < end) {
      tick();
      bool tx = t.uart_tx;
      if (state < 0) {
        if (prev_tx && !tx) {
          state = 0;
          next_sample = cycles + 1.5 * uart_bit;
          shift = 0;
        }
      } else if (cycles >= next_sample) {
        if (state < 8) {
          shift |= (unsigned)tx << state++;
          next_sample += uart_bit;
        } else {
          return tx ? (int)shift : -1;
        }
      }
      prev_tx = tx;
    }
    return -1;
  }

  void send_uart(unsigned char c) {
    t.uart_rx = 0;
    delay_bits(1);
    for (int i = 0; i < 8; i++) {
      t.uart_rx = (c >> i) & 1;
      delay_bits(1);
    }
    t.uart_rx = 1;
    delay_bits(1.5);
  }
};

int main(int argc, char **argv) {
  Verilated::commandArgs(argc, argv);
  Bench b;
  b.reset();

  expect_eq("PIO reset output", b.t.po, 0x80000000);
  b.write(0xabcd0000, 0x12345678);
  expect_eq("PIO full-word write", b.t.po, 0x12345678);
  b.write(0xabcd0000, 0x000000aa, 0x1);
  expect_eq("PIO byte-lane write", b.t.po, 0x123456aa);
  b.t.pi = 0xcafebabe;
  b.tick();
  b.tick();
  expect_eq("PIO input read", b.read(0xabcd0000), 0xcafebabe);

  b.write(0xabcd00c0, 0x10000303);
  expect_eq("cache control read/write", b.read(0xabcd00c0), 0x20000003);
  expect_eq("cache control irq", b.t.event_en ? 1 : 0, 0);
  expect_eq("cache fetch address", b.read(0xabcd00f0), 0x12345678);

  b.write(0xabcd0040, 0xf8000009);
  b.write(0xabcd0044, 0x0000005a);
  b.write(0xabcd0040, 0xf800000b);
  unsigned spi_guard = 3000;
  uint32_t spi_status;
  do {
    spi_status = b.read(0xabcd0040);
  } while ((spi_status & 0x2) && --spi_guard);
  if (!spi_guard) {
    std::fprintf(stderr, "[periph] FAIL SPI transaction timeout\n");
    failures++;
  } else {
    std::printf("[periph] PASS SPI transaction completed\n");
  }
  expect_eq("SPI loopback byte", b.read(0xabcd0044) & 0xff, 0x5a);

  expect_eq("AIC reset control", b.read(0xabcd0200), 0x00000fff);
  b.write(0xabcd0200, 0x40077000);
  unsigned event_guard = 8;
  while (!b.t.event_en && event_guard--) b.tick();
  expect_eq("AIC event enabled", b.t.event_en ? 1 : 0, 1);
  expect_eq("AIC event command", b.t.event_cmd, 0);
  expect_eq("AIC event vector", b.t.event_vec, 0x77);
  expect_eq("AIC event mask", b.t.event_msk, 0);

  b.t.cpu_event_ack = 1;
  b.tick();
  b.t.cpu_event_ack = 0;
  for (int i = 0; i < 4; i++) b.tick();
  expect_eq("AIC event acknowledged", b.t.event_en ? 1 : 0, 0);

  b.write(0xabcd0004, 0x00000001);
  b.write(0xabcd0008, 0x00000001);
  b.write(0xabcd0208, 0x00060000);
  b.t.pi = 0xcafebabe | 1;
  event_guard = 20;
  while (!b.t.event_en && event_guard--) b.tick();
  expect_eq("PIO interrupt event enabled", b.t.event_en ? 1 : 0, 1);
  expect_eq("PIO interrupt vector", b.t.event_vec, 0x15);
  expect_eq("PIO interrupt level", b.t.event_lvl, 6);
  expect_eq("PIO interrupt command", b.t.event_cmd, 0);
  b.t.cpu_event_ack = 1;
  b.tick();
  b.t.cpu_event_ack = 0;
  for (int i = 0; i < 4; i++) b.tick();
  expect_eq("PIO interrupt acknowledged", b.t.event_en ? 1 : 0, 0);

  b.write(0xabcd0100, 0x0000005a);
  expect_eq("UART TX byte", (uint32_t)b.receive_uart(), 0x5a);
  b.send_uart(0xa7);
  uint32_t uart_status = 0;
  for (int i = 0; i < 100 && !(uart_status & 1); i++)
    uart_status = b.read(0xabcd0108);
  expect_eq("UART RX valid", uart_status & 1, 1);
  expect_eq("UART RX byte", b.read(0xabcd0100) & 0xff, 0xa7);

  std::printf("[periph] %llu cycles: %s\n",
              (unsigned long long)b.cycles, failures ? "FAIL" : "PASS");
  return failures ? 1 : 0;
}
