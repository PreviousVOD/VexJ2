#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
td_log_dir="$repo_root/build/logs/td_verilog"
fpga_out_dir="$repo_root/build/fpga/j2_tang_primer_verilog"
rom=${J2_ROM:-"$repo_root/build/sw/xiprom/main.bin"}
export J2_CLOCK_HZ=${J2_CLOCK_HZ:-32000000}
export J2_USE_PLL=${J2_USE_PLL:-1}

mkdir -p "$td_log_dir" "$fpga_out_dir"

cd "$repo_root"
make "$rom"
python3 tools/gen_verilog_rom.py "$rom" build/verilog/xip/j2_validation_rom.hex
J2_FPGA=1 J2_ROM="$rom" make spinal-generate

cp build/spinal/verilog-fpga/J2MicrocodedCore.v build/spinal/verilog-fpga/j2_tang_primer.v "$fpga_out_dir/"
cp build/spinal/verilog-fpga/j2_tang_primer.v_*.bin build/spinal/verilog-fpga/rom_*.mif "$fpga_out_dir/"
cp fpga/j2_tang_primer_verilog/j2_tang_primer.al \
   fpga/j2_tang_primer_verilog/j2_tang_primer.adc \
   fpga/j2_tang_primer_verilog/j2_tang_primer.sdc "$fpga_out_dir/"
soc_period=$(python3 -c "print(f'{1e9 / $J2_CLOCK_HZ:.6f}')")
sed -i "s/create_clock -name soc_clk -period [0-9.]*/create_clock -name soc_clk -period ${soc_period}/" \
  "$fpga_out_dir/j2_tang_primer.sdc"
if [[ $J2_USE_PLL == 0 ]]; then
  sed -i '/create_clock -name soc_clk/d' "$fpga_out_dir/j2_tang_primer.sdc"
fi

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
