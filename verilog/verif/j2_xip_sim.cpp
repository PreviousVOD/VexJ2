#include "Vj2_tang_primer.h"
#include "verilated.h"
#include "flashsim.h"

#include <cstdio>
#include <fstream>
#include <iterator>
#include <string>
#include <vector>

int main(int argc, char **argv) {
  const char *image_path = argc > 1 ? argv[1] : "flash.bin";
  bool loader = argc > 2 && std::string(argv[2]) == "--loader";
  std::ifstream stream(image_path, std::ios::binary);
  std::vector<uint8_t> image((std::istreambuf_iterator<char>(stream)),
                             std::istreambuf_iterator<char>());
  if (image.empty()) {
    std::fprintf(stderr, "cannot read flash image %s\n", image_path);
    return 1;
  }

  Vj2_tang_primer top;
  FLASHSIM flash(22);
  if (!loader) flash.load(image_path);
  top.clk24 = 0;
  top.rst_n = 0;
  top.uart_rx = 1;
  top.spi_miso = 1;
  top.eval();

  auto update_flash = [&]() {
    int mosi = top.spi_mosi;
    top.spi_miso = (flash(top.spi_cs, top.spi_clk, mosi) >> 1) & 1;
  };

  for (int cycle = 0; cycle < 8; ++cycle) {
    top.clk24 = 1;
    top.eval();
    update_flash();
    top.clk24 = 0;
    top.eval();
    update_flash();
  }
  top.rst_n = 1;

  constexpr double bit_cycles = 24000000.0 / 19200.0;
  int state = -1;
  double next_sample = 0;
  unsigned shift = 0;
  bool previous_tx = true;
  std::string output;
  std::vector<uint8_t> upload;
  size_t upload_index = 0;
  int upload_bit = -1;
  double next_upload = 0;
  bool upload_started = false;
  size_t upload_limit = 0;
  size_t upload_pages = 0;
  bool program_started = false;

  uint64_t max_cycles = loader ? 100000000 : 30000000;
  for (uint64_t cycle = 0; cycle < max_cycles &&
       output.find("XIP CPU tests passed") == std::string::npos; ++cycle) {
    top.clk24 = 1;
    top.eval();
    update_flash();
    bool tx = top.uart_tx;
    if (state < 0) {
      if (previous_tx && !tx) {
        state = 0;
        next_sample = cycle + 1.5 * bit_cycles;
        shift = 0;
      }
    } else if (cycle >= next_sample) {
      if (state < 8) {
        shift |= unsigned(tx) << state;
        ++state;
        next_sample += bit_cycles;
      } else {
        if (!tx) {
          std::printf("[xip-soc] UART framing error at cycle %llu\n",
                      (unsigned long long)cycle);
          return 1;
        }
        output.push_back(char(shift));
        state = -1;
      }
    }
    previous_tx = tx;

    if (loader && !upload_started && output.find("J2 loader") != std::string::npos) {
      upload_started = true;
      upload = {'J', '2', 'U', 'P', 0, 0, 0, 0};
      uint32_t length = image.size();
      for (int index = 0; index < 4; ++index)
        upload.push_back((length >> ((3 - index) * 8)) & 0xff);
      upload.insert(upload.end(), image.begin(), image.end());
      upload_limit = 12;
      top.uart_rx = 0;
      upload_bit = 0;
      next_upload = cycle + bit_cycles;
    }
    if (upload_started && !program_started &&
        output.find("Program flash") != std::string::npos) {
      program_started = true;
      upload_limit = 12 + (image.size() < 256 ? image.size() : 256);
      top.uart_rx = 0;
      next_upload = cycle + bit_cycles;
    }
    if (upload_started && upload_pages * 256 < image.size()) {
      char marker[32];
      std::snprintf(marker, sizeof(marker), "Page %06x", upload_pages * 256);
      if (output.find(marker) != std::string::npos) {
        ++upload_pages;
        if (upload_pages * 256 < image.size()) {
          size_t remaining = image.size() - upload_pages * 256;
          upload_limit = 12 + upload_pages * 256 + (remaining < 256 ? remaining : 256);
          top.uart_rx = 0;
          next_upload = cycle + bit_cycles;
        }
      }
    }
    if (upload_started && (upload_index < 12 || program_started) &&
        upload_index < upload_limit && cycle >= next_upload) {
      if (upload_bit < 8) {
        top.uart_rx = (upload[upload_index] >> upload_bit) & 1;
        ++upload_bit;
      } else if (upload_bit == 8) {
        top.uart_rx = 1;
        upload_bit = 9;
      } else {
        ++upload_index;
        upload_bit = 0;
        if (upload_index < upload_limit) top.uart_rx = 0;
      }
      next_upload += bit_cycles;
    }

    top.clk24 = 0;
    top.eval();
    update_flash();
  }

  std::printf("[xip-soc] upload index=%zu limit=%zu pages=%zu total=%zu\n",
              upload_index, upload_limit, upload_pages, upload.size());
  std::printf("[xip-soc] UART output:\n%s\n", output.c_str());
  bool ok = output.find("XIP CPU tests passed") != std::string::npos;
  std::printf("[xip-soc] %s\n", ok ? "PASS" : "FAIL");
  return ok ? 0 : 1;
}
