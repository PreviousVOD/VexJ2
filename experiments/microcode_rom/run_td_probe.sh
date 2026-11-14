#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/../.." && pwd)
out_dir="$repo_root/build/fpga/microcode_probe"
log_dir="$repo_root/build/logs/td"

mkdir -p "$out_dir" "$log_dir"

# Bind the same CPU datapath to the 256x72-bit microcode ROM.
sed \
  -e 's/decode_type => REVERSE, reset_vector => DEC_CORE_RESET/decode_type => MICROCODE, reset_vector => DEC_CORE_ROM_RESET/' \
  -e 's/entity work.decode_table(reverse_logic)/entity work.decode_table(rom)/' \
  "$repo_root/build/td_vhdl/decode_bound.vhd" > "$out_dir/decode_microcode.vhd"

# Adjust the ROM initialisation path for the extra experiment directory depth.
sed \
  -e 's#\.\./\.\./build/td_vhdl#../../../build/td_vhdl#' \
  "$repo_root/archive/systemverilog-2026-11-14/working-tree/rtl/fpga/j2_tang_primer_original.vhd" \
  > "$out_dir/j2_tang_primer_original.vhd"

cp "$repo_root/experiments/microcode_rom/project.al" "$out_dir/j2_microcode_probe.al"
cp "$repo_root/archive/systemverilog-2026-11-14/working-tree/rtl/fpga/j2_eg4_bram32.v" \
  "$out_dir/j2_eg4_bram32.v"
cp "$repo_root/experiments/microcode_rom/microcode_rom.vhd" "$out_dir/microcode_rom.vhd"
python3 "$repo_root/experiments/microcode_rom/make_bram_variant.py" \
  "$repo_root/reference/soc_top/components/cpu/decode/decode_table_rom.vhd" \
  "$out_dir/decode_table_rom_bram.vhd" \
  "$out_dir/microcode.mif"

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

cd "$log_dir"
exec env QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-offscreen}" \
  "$td_exe" "$repo_root/experiments/microcode_rom/run.tcl"
