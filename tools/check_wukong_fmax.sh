#!/usr/bin/env bash
# Timing-only experiment; never changes board configuration or generates a bitstream.
set -euo pipefail
repo_root=$(cd "$(dirname "$0")/.." && pwd)
divider=${1:?Usage: bash tools/check_wukong_fmax.sh CLOCK_OUTPUT_DIVIDER [ROUTED_SEED_DIVIDER]}
if [[ ! "$divider" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
  echo 'Divider must be numeric (range checked by Tcl)' >&2
  exit 2
fi
seed=${2:-}
label="div$divider"
if [[ -n "$seed" ]]; then
  if [[ ! "$seed" =~ ^[0-9]+([.][0-9]+)?$ ]]; then
    echo 'Invalid routed seed divider' >&2
    exit 2
  fi
  label="div${divider}-from${seed}"
fi
out="$repo_root/build/wukong-v1/fmax/$label"
mkdir -p "$out"
cd "$out"
rm -f results.tsv
bash "$repo_root/tools/run_vivado.sh" -mode batch -notrace -log vivado.log -journal vivado.jou \
  -source "$repo_root/tools/check_wukong_fmax.tcl" -tclargs "$divider" ${seed:+"$seed"}
test -s results.tsv
