#!/usr/bin/env bash
set -euo pipefail
repo_root=$(cd "$(dirname "$0")/.." && pwd)
cd "$repo_root/build/wukong-v1/vivado"
test -s synthesis.pass
rm -f implementation.pass
bash "$repo_root/tools/run_vivado.sh" -mode batch -notrace \
  -source "$repo_root/tools/implement_wukong.tcl" -log implementation.log -journal implementation.jou
test -s implementation.pass
