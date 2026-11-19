#!/usr/bin/env bash
set -euo pipefail
repo_root=$(cd "$(dirname "$0")/.." && pwd)
args=()
exec python3 "$repo_root/tools/fpga.py" --board wukong-v1 implement "${args[@]}" "$@"
