#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
td_log_dir="$repo_root/build/logs/td_verilog"
bitstream="$repo_root/build/fpga/j2_tang_primer_verilog/j2_tang_primer.bit"

if [[ ! -f $bitstream ]]; then
  printf 'Missing %s; run make verilog-fpga first.\n' "$bitstream" >&2
  exit 2
fi
mkdir -p "$td_log_dir"

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
  "$td_exe" ../../../tools/program_tang_primer_verilog.tcl
