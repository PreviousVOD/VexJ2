#!/usr/bin/env bash
# Convert parts of the ORIGINAL J-Core VHDL (reference/soc_top, untouched)
# into Verilog with ghdl --synth, so they can be co-simulated in Verilator
# next to the new SystemVerilog RTL.
#
#   .vhm files are first run through the original v2p preprocessor.
#   Output: ref/gen/<top>.v      Work library: build/ref/work
#
# Usage: tools/ref_synth.sh [target...]   (default: all)
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
SRC=$ROOT/reference/soc_top
WORK=$ROOT/build/ref/work
PRE=$ROOT/build/ref/pre      # preprocessed .vhm -> .vhd
OUT=$ROOT/ref/gen
# system tools first, repository-local toolchain as fallback
export PATH="$PATH:$ROOT/tools/local/bin"
GHDL=${GHDL:-ghdl}
GFLAGS=(--std=93c --ieee=synopsys -fexplicit --workdir="$WORK")

mkdir -p "$WORK" "$PRE" "$OUT"

v2p() {  # v2p <file.vhm> -> prints path of converted .vhd
  local in=$SRC/$1 out=$PRE/$(basename "${1%.vhm}").vhd
  if [[ ! -f $out || $in -nt $out ]]; then
    LD_LIBRARY_PATH='' perl -X "$SRC/tools/v2p" < "$in" > "$out"
  fi
  echo "$out"
}

analyze() { "$GHDL" -a "${GFLAGS[@]}" "$@"; }

synth() {  # synth <top>
  echo "ghdl --synth $1 -> ref/gen/$1.v"
  "$GHDL" --synth "${GFLAGS[@]}" --out=verilog "$1" > "$OUT/$1.v.tmp"
  # Prefix internal module names with the top name so several converted
  # tops (e.g. two architectures of one entity) can be compiled together.
  local m
  for m in $(sed -n 's/^module \([A-Za-z0-9_]*\).*/\1/p' "$OUT/$1.v.tmp"); do
    [[ $m == "$1" ]] && continue
    perl -pi -e "s/\\b\Q$m\E\\b/${1}__$m/g" "$OUT/$1.v.tmp"
  done
  # GHDL turns VHDL asserts into '$fatal' on a sampled flop that is not
  # initialised, so they fire spuriously at time 0. They are debug checks
  # only; drop them (the SV side has its own checks).
  perl -pi -e 's/\$fatal\(1, "assertion failure (\w+)"\);/; \/\/ assert $1 stripped/g' "$OUT/$1.v.tmp"
  # VHDL identifiers that are (System)Verilog keywords, e.g. instance 'table'
  # or uartlite's port 'int'. GHDL's Verilog output never uses these words
  # itself, so rename them everywhere.
  perl -pi -e 's/\b(table|config|cell|design|library|use|int|bit|byte|shortint|longint|string|class|do|final|type|const|var|logic)\b/$1_i/g' "$OUT/$1.v.tmp"
  python3 "$ROOT/tools/fix_ghdl_verilog.py" "$OUT/$1.v.tmp"
  mv "$OUT/$1.v.tmp" "$OUT/$1.v"
}

CPU_PKGS=(
  "$SRC/components/cpu/cpu2j0_pkg.vhd"
  "$SRC/components/cpu/core/components_pkg.vhd"
  "$SRC/components/cpu/core/mult_pkg.vhd"
  "$SRC/components/cpu/decode/decode_pkg.vhd"
  "$SRC/components/cpu/decode/decode_body.vhd"
)

t_decode_table() {
  analyze "${CPU_PKGS[@]}" \
    "$SRC/components/cpu/decode/decode_table.vhd" \
    "$SRC/components/cpu/decode/decode_table_simple.vhd" \
    "$SRC/components/cpu/decode/decode_table_reverse.vhd" \
    "$ROOT/ref/ref_flatten_pkg.vhd" \
    "$ROOT/ref/ref_decode_table.vhd"
  synth ref_decode_table_simple
  synth ref_decode_table_reverse
}

t_core_units() {
  analyze "${CPU_PKGS[@]}" \
    "$SRC/components/cpu/core/register_file.vhd" \
    "$(v2p components/cpu/core/mult.vhm)" \
    "$ROOT/ref/ref_core_units.vhd"
  synth ref_alu
  synth ref_regfile
  synth ref_mult
}

# Derived copies that bind exactly what configuration cpu_sim binds, using
# direct entity instantiation (GHDL 5 synth crashes on the configuration).
bind_cpu_sim() {
  local C=$SRC/components/cpu
  sed -e 's/^\( *core : \)decode_core$/\1entity work.decode_core(arch) generic map (decode_type => REVERSE, reset_vector => DEC_CORE_RESET)/' \
      -e 's/^\( *table : \)decode_table$/\1entity work.decode_table(reverse_logic)/' \
      "$C/decode/decode.vhd" > "$PRE/decode_bound.vhd"
  grep -q 'entity work.decode_core(arch)' "$PRE/decode_bound.vhd"
  grep -q 'entity work.decode_table(reverse_logic)' "$PRE/decode_bound.vhd"
  sed -e 's/\(u_regfile : \)register_file/\1entity work.register_file(two_bank)/' \
      "$(v2p components/cpu/core/datapath.vhm)" > "$PRE/datapath_bound.vhd"
  grep -q 'entity work.register_file(two_bank)' "$PRE/datapath_bound.vhd"
}

# cpu variant: "" = as released; "_ill" = illegal-instruction vector fix
# (general illegal -> vector 4, slot illegal -> vector 6; the release uses 0).
cpu_variant() {
  local var=$1 C=components/cpu core
  bind_cpu_sim
  core=$(v2p $C/decode/decode_core.vhm)
  if [[ $var == _ill ]]; then
    sed -e 's/^\( *\)cd := x"0" & system_instr_codes(instr) & x"00";/\1if instr = GENERAL_ILLEGAL then cd := x"0" \& system_instr_codes(instr) \& x"04"; elsif instr = SLOT_ILLEGAL then cd := x"0" \& system_instr_codes(instr) \& x"06"; else cd := x"0" \& system_instr_codes(instr) \& x"00"; end if;/' \
      "$core" > "$PRE/decode_core_ill.vhd"
    grep -q 'x"04"' "$PRE/decode_core_ill.vhd"
    core=$PRE/decode_core_ill.vhd
  fi
  sed -e "s/\bref_cpu\b/ref_cpu$var/g" "$ROOT/ref/ref_cpu.vhd" > "$PRE/ref_cpu$var.vhd"
  local saved=$WORK
  WORK=$ROOT/build/ref/work$var; mkdir -p "$WORK"
  GFLAGS=(--std=93c --ieee=synopsys -fexplicit --workdir="$WORK")
  analyze "${CPU_PKGS[@]}" \
    "$SRC/$C/core/datapath_pkg.vhd" \
    "$SRC/$C/core/register_file.vhd" \
    "$(v2p $C/core/mult.vhm)" \
    "$SRC/$C/decode/decode_table.vhd" \
    "$SRC/$C/decode/decode_table_reverse.vhd" \
    "$core" \
    "$PRE/decode_bound.vhd" \
    "$PRE/datapath_bound.vhd" \
    "$SRC/$C/core/cpu.vhd" \
    "$PRE/ref_cpu$var.vhd"
  synth ref_cpu$var
  WORK=$saved; GFLAGS=(--std=93c --ieee=synopsys -fexplicit --workdir="$WORK")
}

t_cpu() { cpu_variant ""; cpu_variant _ill; }

# Original Mimas v2 peripheral subsystem (devices.vhd) for the reference SoC.
# pio.vhd uses a group template 'bus_signals' that the released attr_pkg
# lacks (attributes for the soc_gen tool only); a derived copy adds it.
t_devices() {
  sed -e 's/^\( *\)group peripheral_bus is (signal <>);/&\n\1group bus_signals is (signal <>);/' \
      "$SRC/lib/hwutils/attr_pkg.vhd" > "$PRE/attr_pkg.vhd"
  grep -q 'group bus_signals' "$PRE/attr_pkg.vhd"
  local saved=$WORK
  WORK=$ROOT/build/ref/work_dev; mkdir -p "$WORK"
  GFLAGS=(--std=93c --ieee=synopsys -fexplicit --workdir="$WORK")
  analyze \
    "$SRC/components/cpu/cpu2j0_pkg.vhd" \
    "$ROOT/ref/ref_config.vhd" \
    "$SRC/targets/clk_config.vhd" \
    "$SRC/targets/data_bus_pkg.vhd" \
    "$PRE/attr_pkg.vhd" \
    "$SRC/components/misc/misc_pkg.vhd" \
    "$SRC/components/misc/aic2_pkg.vhd" \
    "$SRC/components/uartlite/uart_pkg.vhd" \
    "$SRC/components/icache/cache_pkg.vhd" \
    "$(v2p components/uartlite/uart.vhm)" \
    "$SRC/components/uartlite/uartlitedb.vhd" \
    "$SRC/components/misc/pio.vhd" \
    "$(v2p components/misc/spi2.vhm)" \
    "$SRC/components/misc/aic_edgedet.vhd" \
    "$SRC/components/misc/aic.vhd" \
    "$(v2p components/icache/icache_modereg.vhm)" \
    "$SRC/targets/boards/mimas_v2/devices.vhd" \
    "$ROOT/ref/ref_devices.vhd"
  synth ref_devices
  WORK=$saved; GFLAGS=(--std=93c --ieee=synopsys -fexplicit --workdir="$WORK")
}

ALL=(decode_table core_units cpu devices)
for t in "${@:-${ALL[@]}}"; do "t_$t"; done
