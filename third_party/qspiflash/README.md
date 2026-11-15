# qspiflash vendor sources

Source: https://github.com/ZipCPU/qspiflash

Upstream commit: `f0a3d2ac4c0e2d4bd2a7847bc0df24bb3a7c11ad`

The J2 integration uses `llqspi.v` for registered-clock single-SPI transfers.
`verilog/j2_spiflash.v` adds XIP read sequencing, byte-oriented flash control,
and classic-Wishbone arbitration. `flashsim.cpp` and `flashsim.h` support the
Verilator integration. Original LGPL notices are retained; the license is in
`doc/lgpl-3.0.pdf`.
