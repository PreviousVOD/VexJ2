# qspiflash simulation sources

Source: https://github.com/ZipCPU/qspiflash

Upstream commit: `f0a3d2ac4c0e2d4bd2a7847bc0df24bb3a7c11ad`

Only `bench/cpp/flashsim.cpp` and `flashsim.h` are retained for Verilator. The
hardware SPI/XIP implementation uses native SpinalHDL `Apb3SpiXdrMasterCtrl`;
upstream `llqspi` RTL has been removed. The testbench inverts the model clock to
match the native PHY's launch/sample timing. Original LGPL notices are retained;
the license is in `doc/lgpl-3.0.pdf`.
