#!/usr/bin/env bash
set -euo pipefail
repo_root=$(cd "$(dirname "$0")/.." && pwd)
mkdir -p "$repo_root/build/wukong-v1/vivado"
cd "$repo_root/build/wukong-v1/vivado"
rm -f synthesis.pass implementation.pass
bash "$repo_root/tools/run_vivado.sh" -mode batch -notrace \
  -source "$repo_root/tools/build_wukong.tcl" -log synthesis.log -journal synthesis.jou
# Some Vivado host-library initialization failures return status zero.
test -s synthesis.pass
