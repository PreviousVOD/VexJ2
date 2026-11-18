#!/usr/bin/env bash
set -euo pipefail
vivado_home=${VIVADO_HOME:-/home/imi415/Softwares/Tools/Xilinx/2025.2/Vivado}
# Use the Xilinx installer's Ubuntu 24 runtime on this host.
vivado_release=$(basename "$(dirname "$vivado_home")")
compat_lib=${VIVADO_COMPAT_LIB:-"$vivado_home/../../.xinstall/$vivado_release/lib/lnx64.o/Ubuntu/24"}
if [[ -d "$compat_lib" ]]; then
  export LD_LIBRARY_PATH="$compat_lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
fi
# XSim's bundled linker needs the host C runtime objects on multiarch Linux.
if command -v gcc >/dev/null; then
  host_crt=$(gcc -print-file-name=crt1.o)
  if [[ -f "$host_crt" ]]; then
    export LIBRARY_PATH="$(dirname "$host_crt")${LIBRARY_PATH:+:$LIBRARY_PATH}"
  fi
fi
exec "$vivado_home/bin/vivado" "$@"
