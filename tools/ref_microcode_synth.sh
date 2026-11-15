#!/usr/bin/env bash
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
src="$root/reference/soc_top"
out="$root/build/ref_microcode"
work="$out/work"
td="$root/build/td_vhdl"
ghdl=${GHDL:-"$root/tools/local/bin/ghdl"}
gflags=(--std=93c --ieee=synopsys -fexplicit --workdir="$work")

make -C "$root" td-vhdl
mkdir -p "$work"

"$ghdl" -a "${gflags[@]}" \
  "$src/components/cpu/cpu2j0_pkg.vhd" \
  "$td/components_pkg_bound.vhd" \
  "$src/components/cpu/core/mult_pkg.vhd" \
  "$src/components/cpu/decode/decode_pkg.vhd" \
  "$src/components/cpu/decode/decode_body.vhd" \
  "$src/components/cpu/core/datapath_pkg.vhd" \
  "$src/components/cpu/core/register_file.vhd" \
  "$td/pre/mult.vhd" \
  "$src/components/cpu/decode/decode_table.vhd" \
  "$src/components/cpu/decode/decode_table_rom.vhd" \
  "$td/pre/decode_core.vhd" \
  "$td/decode_bound.vhd" \
  "$td/datapath_bound.vhd" \
  "$td/cpu_bound.vhd" \
  "$root/reference/j2_cpu_flat.vhd"

"$ghdl" --synth "${gflags[@]}" --out=verilog j2_cpu_flat > "$out/j2_cpu_flat.v.tmp"
perl -pi -e 's/\$fatal\(1, "assertion failure (\w+)"\);/; \/\/ assert $1 stripped/g' "$out/j2_cpu_flat.v.tmp"
perl -pi -e 's/\b(table|config|cell|design|library|use|int|bit|byte|shortint|longint|string|class|do|final|type|const|var|logic)\b/$1_i/g' "$out/j2_cpu_flat.v.tmp"
python3 "$root/tools/fix_ghdl_verilog.py" \
  "$out/j2_cpu_flat.v.tmp"
mv "$out/j2_cpu_flat.v.tmp" "$out/j2_cpu_flat.v"
