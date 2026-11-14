#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
td_log_dir="$repo_root/build/logs/td"
fpga_out_dir="$repo_root/build/fpga"

mkdir -p "$td_log_dir" "$fpga_out_dir"
cp "$repo_root/rtl/fpga/j2_tang_primer_original.al.in" \
   "$fpga_out_dir/j2_tang_primer_original.al"

if [[ -n ${TD_BIN:-} ]]; then
  TD_EXE=$TD_BIN
elif [[ -n ${TD_HOME:-} && -x $TD_HOME/bin/td ]]; then
  TD_EXE=$TD_HOME/bin/td
elif command -v td >/dev/null 2>&1; then
  TD_EXE=$(command -v td)
else
  printf 'Set TD_HOME or TD_BIN to the Tang Dynasty installation.\n' >&2
  exit 2
fi

# TD creates its automatic td_*.log in the process working directory.
cd "$td_log_dir"
exec env QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-offscreen}" \
  "$TD_EXE" "$repo_root/tools/build_tang_primer.tcl"
