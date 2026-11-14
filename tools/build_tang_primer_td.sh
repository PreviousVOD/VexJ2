#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
td_log_dir="$repo_root/build/logs/td"
fpga_out_dir="$repo_root/build/fpga/j2_tang_primer"
rom=${J2_ROM:-"$repo_root/build/sw/testrom/main.bin"}
implementation=${J2_CPU:-microcode}

mkdir -p "$td_log_dir" "$fpga_out_dir"

case "$implementation" in
  microcode)
    python3 "$repo_root/tools/gen_td_vhdl.py" --decode microcode --program "$rom"
    cp "$repo_root/fpga/j2_tang_primer_microcode.al" \
       "$fpga_out_dir/j2_tang_primer.al"
    cp "$repo_root"/fpga/j2_tang_primer.adc \
       "$repo_root"/fpga/j2_tang_primer.sdc \
       "$repo_root"/fpga/j2_tang_primer.vhd \
       "$repo_root"/fpga/j2_cpu_flat.vhd \
       "$repo_root"/fpga/j2_eg4_bram32.v \
       "$fpga_out_dir/"
    ;;
  spinal)
    (
      cd "$repo_root"
      make microcode-mif
      J2_FPGA=1 J2_ROM="$rom" make spinal-generate
    )
    cp "$repo_root"/build/spinal/verilog/J2TangPrimer.v \
       "$repo_root"/build/spinal/verilog/J2TangPrimer.v_*.bin \
       "$repo_root"/fpga/j2_tang_primer.adc \
       "$repo_root"/fpga/j2_tang_primer.sdc \
       "$repo_root"/fpga/j2_microcode_rom.v \
       "$repo_root"/fpga/j2_tang_primer_spinal.v \
       "$fpga_out_dir/"
    cp "$repo_root/fpga/j2_tang_primer_spinal.al" \
       "$fpga_out_dir/j2_tang_primer.al"
    mv "$fpga_out_dir/j2_tang_primer_spinal.v" "$fpga_out_dir/j2_tang_primer.v"
    ;;
  *)
    printf 'Unknown J2_CPU implementation: %s\n' "$implementation" >&2
    exit 2
    ;;
esac

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
