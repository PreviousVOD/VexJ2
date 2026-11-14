#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
td_log_dir="$repo_root/build/logs/td"

mkdir -p "$td_log_dir"

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

cd "$td_log_dir"
exec env QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-offscreen}" \
  "$TD_EXE" "$repo_root/tools/program_tang_primer.tcl"
