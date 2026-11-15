#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
td_log_dir="$repo_root/build/logs/td_verilog"
fpga_out_dir="$repo_root/build/fpga/j2_tang_primer_verilog"
rom=${J2_ROM:-"$repo_root/build/sw/xiprom/main.bin"}

mkdir -p "$td_log_dir" "$fpga_out_dir"

cd "$repo_root"
make microcode-mif
make "$rom"
python3 tools/gen_verilog_rom.py "$rom" build/verilog/xip/j2_validation_rom.hex \
  --mif build/verilog/xip/j2_validation_rom.mif
J2_FPGA=1 J2_ROM="$rom" make spinal-generate

cp build/spinal/verilog-fpga/J2MicrocodedCore.v "$fpga_out_dir/"
cp build/verilog/xip/j2_validation_rom.hex build/verilog/xip/j2_validation_rom.mif "$fpga_out_dir/"
cp fpga/j2_microcode_rom.v fpga/j2_eg4_bram32.v "$fpga_out_dir/"
cp verilog/j2_validation_rom.v verilog/j2_pio.v verilog/j2_uart16550.v \
   verilog/j2_spiflash.v verilog/j2_sdram.v verilog/j2_sdram_phy.v \
   verilog/j2_soc.v verilog/j2_tang_primer.v "$fpga_out_dir/"
cp third_party/uart16550/rtl/verilog/*.v "$fpga_out_dir/"
cp third_party/qspiflash/rtl/llqspi.v "$fpga_out_dir/"
cp fpga/j2_tang_primer_verilog/j2_tang_primer.al \
   fpga/j2_tang_primer_verilog/j2_tang_primer.adc \
   fpga/j2_tang_primer_verilog/j2_tang_primer.sdc "$fpga_out_dir/"

if [[ -n ${TD_BIN:-} ]]; then
  td_exe=$TD_BIN
elif [[ -n ${TD_HOME:-} && -x $TD_HOME/bin/td ]]; then
  td_exe=$TD_HOME/bin/td
elif command -v td >/dev/null 2>&1; then
  td_exe=$(command -v td)
else
  printf 'Set TD_HOME or TD_BIN to the Tang Dynasty installation.\n' >&2
  exit 2
fi

cd "$td_log_dir"
exec env QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-offscreen}" \
  "$td_exe" ../../../tools/build_tang_primer_verilog.tcl
