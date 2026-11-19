#!/usr/bin/env bash
set -euo pipefail
repo_root=$(cd "$(dirname "$0")/.." && pwd)
args=()
if [[ -n ${J2_ROM:-} ]]; then args+=(--rom "$J2_ROM"); fi
exec python3 "$repo_root/tools/fpga.py" --board tang-primer build "${args[@]}" "$@"
