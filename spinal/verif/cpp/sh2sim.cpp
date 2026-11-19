// AHB5/ISS harness for the SpinalHDL SH-2 core.
//
// The system model is reused from the archived verification infrastructure.
// Addresses are sampled before the edge; write data belongs to the following phase.
// Instruction responses are full aligned big-endian words;
// the core selects and retains their instruction halfwords.
#ifdef USE_MICROCODED_CORE
#include "VJ2MicrocodedCore.h"
using CoreModel = VJ2MicrocodedCore;
#else
#include "VJ2Core.h"
using CoreModel = VJ2Core;
#endif
#include "sysmodel.h"
#include "verilated.h"

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <deque>
#include <string>
#include <vector>

using namespace j2sim;

struct AhbSlave {
  bool pending = false;
  unsigned waits = 0;
  uint32_t address = 0, data = 0;
  unsigned select = 15;
  bool write = false;
  uint64_t txns = 0;
  template <class F>
  bool step(bool wasReady, bool accept, uint32_t a, bool w, unsigned size,
            uint32_t writeData, uint32_t &readData, F access) {
    if (wasReady) pending = false;
    if (accept) {
      pending = true; address = a; write = w; data = writeData; waits = 1;
      select = size == 0 ? (8u >> (a & 3)) : size == 1 ? ((a & 2) ? 3 : 12) : 15;
    }
    readData = 0;
    if (!pending) return true;
    if (waits) { --waits; return false; }
    readData = access(address, write, select, data);
    ++txns;
    return true;
  }
};

int main(int argc, char **argv) {
  if (argc < 2) {
    fprintf(stderr, "usage: %s image.bin [--expect STR] [--max-cycles N] [--quiet] [--log-retired]\n",
            argv[0]);
    return 2;
  }

  SysBus sys;
  AhbSlave ibus, dbus;
  uint64_t max_cycles = 8000000;
  uint64_t stop_pc = ~0ull;
  uint64_t bus_log_from = ~0ull;
  std::vector<std::string> expect;
  bool log_retired = false;
  std::deque<std::string> retired_trace;

  for (int i = 2; i < argc; ++i) {
    std::string option = argv[i];
    if (option == "--expect") {
      expect.emplace_back(argv[++i]);
    } else if (option == "--max-cycles") {
      max_cycles = strtoull(argv[++i], nullptr, 0);
    } else if (option == "--quiet") {
      sys.echo_uart = false;
    } else if (option == "--log-retired") {
      log_retired = true;
    } else if (option == "--stop-pc") {
      stop_pc = strtoull(argv[++i], nullptr, 0);
    } else if (option == "--log-bus-from") {
      bus_log_from = strtoull(argv[++i], nullptr, 0);
    } else {
      fprintf(stderr, "unknown option %s\n", option.c_str());
      return 2;
    }
  }

  if (!sys.mem.load_bin(argv[1])) {
    return 2;
  }

  CoreModel top;
  top.io_ibus_HREADY = 1;
  top.io_ibus_HRDATA = 0;
  top.io_ibus_HRESP = 0;
  top.io_dbus_HREADY = 1;
  top.io_dbus_HRDATA = 0;
  top.io_dbus_HRESP = 0;
  top.io_event_valid = 0;
  top.io_event_payload_command = 0;
  top.io_event_payload_vector = 0;
  top.io_event_payload_level = 0;
  top.io_event_payload_bypassMask = 0;
  top.reset = 1;
  top.clk = 0;
  top.eval();

  for (int i = 0; i < 4; ++i) {
    top.clk = 1;
    top.eval();
    top.clk = 0;
    top.eval();
  }
  top.reset = 0;
  top.eval();

  uint64_t cycles = 0;
  uint64_t instructions = 0;
  bool done = false;
  bool saw_expected = false;
  bool saw_stop_pc = false;

  while (cycles < max_cycles && !done) {
    sys.timer_tick();
    const bool ir = top.io_ibus_HREADY, dr = top.io_dbus_HREADY;
    const bool ia = ir && (top.io_ibus_address_HTRANS & 2);
    const bool da = dr && (top.io_dbus_address_HTRANS & 2);
    const uint32_t iaddr = top.io_ibus_address_HADDR, daddr = top.io_dbus_address_HADDR;
    const unsigned dsize = top.io_dbus_address_HSIZE;
    const bool dwrite = top.io_dbus_address_HWRITE;
    top.clk = 1;
    top.eval();

    uint32_t data = 0;
    top.io_ibus_HREADY =
        ibus.step(ir, ia, iaddr, false, 2, 0, data,
                  [&](uint32_t address, bool, unsigned, uint32_t) {
                    uint32_t value = sys.fetch32(address);
                    if (cycles >= bus_log_from) {
                      printf("%9llu IF adr=%08x data=%04x\n",
                             (unsigned long long)cycles, address, value);
                    }
                    return value;
                  });
    top.io_ibus_HRDATA = data;

    top.io_dbus_HREADY =
        dbus.step(dr, da, daddr, dwrite, dsize, top.io_dbus_HWDATA, data,
                  [&](uint32_t address, bool write, unsigned select, uint32_t value) {
                    uint32_t result = sys.access(address, write, select, value);
                    if (cycles >= bus_log_from) {
                      printf("%9llu dbus %s adr=%08x sel=%x data=%08x\n",
                             (unsigned long long)cycles, write ? "WR" : "RD",
                             address, select, write ? value : result);
                    }
                    return result;
                  });
    top.io_dbus_HRDATA = data;

    top.io_event_valid = sys.ev_en();
    top.io_event_payload_command = sys.ev_cmd();
    top.io_event_payload_vector = sys.ev_vec();
    top.io_event_payload_level = sys.ev_lvl();
    top.io_event_payload_bypassMask = sys.ev_msk();
    top.eval();
    if (cycles >= bus_log_from) {
      printf("%9llu state=%u pc=%08x pending=%u retired=%u eventAck=%u\n",
             (unsigned long long)cycles, top.io_debugState, top.io_pc,
             top.io_debugEventPending, top.io_retired, top.io_eventAck);
    }
    if (cycles >= bus_log_from && top.io_event_valid) {
      printf("%9llu event valid cmd=%u vec=%u lvl=%u bypass=%u ready=%u ack=%u pending=%u state=%u\n",
             (unsigned long long)cycles, top.io_event_payload_command,
             top.io_event_payload_vector, top.io_event_payload_level,
             top.io_event_payload_bypassMask, top.io_event_ready, top.io_eventAck,
             top.io_debugEventPending, top.io_debugState);
    }

    if (top.io_retired) {
      ++instructions;
      char trace[96];
      snprintf(trace, sizeof(trace), "%9llu pc=%08x op=%04x slot_illegal=%d",
               (unsigned long long)cycles, top.io_pc, top.io_debugOpcode,
               top.io_debugSlotIllegal);
      retired_trace.emplace_back(trace);
      if (retired_trace.size() > 64) {
        retired_trace.pop_front();
      }
      if (log_retired) {
        printf("%s\n", trace);
      }
      if (top.io_pc == stop_pc) {
        printf("[sh2sim] retired trace ending at requested PC %08llx:\n",
               (unsigned long long)stop_pc);
        for (const auto &line : retired_trace) {
          printf("  %s\n", line.c_str());
        }
        saw_stop_pc = true;
        done = true;
      }
    }
    sys.ev_ack(top.io_eventAck);

    top.clk = 0;
    top.eval();
    ++cycles;

    if (sys.test_result >= 0) {
      done = true;
    }
    if (!expect.empty()) {
      bool all = true;
      for (const auto &text : expect) {
        all = all && sys.uart_out.find(text) != std::string::npos;
      }
      if (all) {
        saw_expected = true;
        done = true;
      }
    }
  }

  printf("\n[sh2sim] %llu cycles, %llu retired instructions, %llu ibus txns, %llu dbus txns\n",
         (unsigned long long)cycles, (unsigned long long)instructions,
         (unsigned long long)ibus.txns, (unsigned long long)dbus.txns);
  printf("[sh2sim] final pc=%08x op=%04x state=%u\n", top.io_pc, top.io_debugOpcode,
         top.io_debugState);
  if (!done && !retired_trace.empty()) {
    printf("[sh2sim] final retired trace:\n");
    for (const auto &line : retired_trace) {
      printf("  %s\n", line.c_str());
    }
  }
  printf("[sh2sim] LEDs:");
  for (size_t i = 0; i < sys.leds.size() && i < 32; ++i) {
    printf(" %02x", sys.leds[i] & 0xff);
  }
  printf("\n");

  if (saw_stop_pc && sys.test_result < 0 && expect.empty()) {
    printf("[sh2sim] STOPPED at requested PC (diagnostic stop, not a regression result)\n");
    return 0;
  }

  bool ok = false;
  if (sys.test_result >= 0) {
    printf("[sh2sim] TEST_RESULT=%d\n", sys.test_result);
    ok = sys.test_result == 0;
  } else if (!expect.empty()) {
    printf("[sh2sim] expected output %s\n", saw_expected ? "seen" : "not seen");
    ok = saw_expected;
  } else {
    printf("[sh2sim] no TEST_RESULT or expected output\n");
  }
  printf("[sh2sim] %s\n", ok ? "PASS" : "FAIL");
  return ok ? 0 : 1;
}
