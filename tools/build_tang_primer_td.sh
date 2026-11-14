#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
td_log_dir="$repo_root/build/logs/td"
fpga_out_dir="$repo_root/build/fpga/j2_tang_primer"
rom=${J2_ROM:-"$repo_root/build/sw/testrom/main.bin"}

mkdir -p "$td_log_dir" "$fpga_out_dir"

(
  cd "$repo_root"
  J2_ROM="$rom" make spinal-generate
)

cp "$repo_root"/build/spinal/verilog/J2TangPrimer.v \
   "$repo_root"/build/spinal/verilog/J2TangPrimer.v_*.bin \
   "$repo_root"/fpga/j2_tang_primer.al \
   "$repo_root"/fpga/j2_tang_primer.adc \
   "$repo_root"/fpga/j2_tang_primer.sdc \
   "$repo_root"/fpga/j2_tang_primer_spinal.v \
   "$fpga_out_dir/"
mv "$fpga_out_dir/j2_tang_primer_spinal.v" "$fpga_out_dir/j2_tang_primer.v"

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
  "$td_exe" ../../../tools/build_tang_primer.tcl
