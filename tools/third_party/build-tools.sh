#!/usr/bin/env bash
# Download and build the J2 project's EDA / cross toolchain into the repository.
#
#   tools/third_party/downloads/   source tarballs (cached)
#   tools/third_party/build/       build trees
#   tools/local/                   install prefix (PATH: see tools/env.sh)
#
# No root needed. Host requirements: gcc/g++, make, autoconf, m4, perl,
# python3, tcl-dev, libreadline-dev, libffi-dev, zlib1g-dev, curl.
#
# Usage: tools/third_party/build-tools.sh [component...]
#   components: flex bison help2man verilator yosys gnat ghdl sh-toolchain
#   (default: all). A component whose tool is already installed on the system
#   is skipped; set FORCE=1 to build it anyway.
set -euo pipefail

REPO=$(cd "$(dirname "$0")/../.." && pwd)
TP=$REPO/tools/third_party
DL=$TP/downloads
BUILD=$TP/build
PREFIX=$REPO/tools/local
JOBS=${JOBS:-$(nproc)}

HELP2MAN_VER=1.49.3
FLEX_VER=2.6.4
BISON_VER=3.8.2
VERILATOR_VER=5.054
YOSYS_VER=0.70
GNAT_VER=15.3.0-1
GHDL_VER=6.0.0
SH_TOOLCHAIN_TARBALL=${SH_TOOLCHAIN_TARBALL:-$REPO/../Rev_UDI/Toolchain/sh-none-elf.tar.gz}

mkdir -p "$DL" "$BUILD" "$PREFIX/bin"
SYS_PATH=$PATH
export PATH=$PATH:$PREFIX/bin   # system tools first

# on_system <cmd>: true if <cmd> is installed outside the repository
on_system() {
  [[ ${FORCE:-0} == 1 ]] && return 1
  local p
  p=$(PATH=$SYS_PATH command -v "$1" 2>/dev/null) || return 1
  [[ $p != "$PREFIX"/* ]] && { echo "=== $1: using system $p"; return 0; }
  return 1
}

log() { printf '\n=== %s\n' "$*"; }

fetch() {  # fetch <url> <file>
  local url=$1 out=$DL/$2
  if [[ ! -s $out ]]; then
    log "download $url"
    curl -fL --retry 3 -o "$out.part" "$url"
    mv "$out.part" "$out"
  fi
}

unpack() {  # unpack <tarball> <dir>  -> fresh $BUILD/<dir>
  rm -rf "${BUILD:?}/$2"
  mkdir -p "$BUILD/$2"
  tar -xf "$DL/$1" -C "$BUILD/$2" --strip-components=1
}

stamp() { [[ -f $PREFIX/.stamp-$1 ]]; }
done_stamp() { touch "$PREFIX/.stamp-$1"; }

build_flex() {
  on_system flex && return
  stamp flex-$FLEX_VER && return
  fetch https://github.com/westes/flex/releases/download/v$FLEX_VER/flex-$FLEX_VER.tar.gz flex-$FLEX_VER.tar.gz
  unpack flex-$FLEX_VER.tar.gz flex
  log "build flex $FLEX_VER"
  (cd "$BUILD/flex" && ./configure --prefix="$PREFIX" --disable-nls && make -j"$JOBS" && make install)
  done_stamp flex-$FLEX_VER
}

build_help2man() {  # verilator's install builds man pages with it
  on_system help2man && return
  stamp help2man-$HELP2MAN_VER && return
  fetch https://ftp.gnu.org/gnu/help2man/help2man-$HELP2MAN_VER.tar.xz help2man-$HELP2MAN_VER.tar.xz
  unpack help2man-$HELP2MAN_VER.tar.xz help2man
  log "build help2man $HELP2MAN_VER"
  (cd "$BUILD/help2man" && ./configure --prefix="$PREFIX" && make && make install)
  done_stamp help2man-$HELP2MAN_VER
}

build_bison() {
  on_system bison && return
  stamp bison-$BISON_VER && return
  fetch https://ftp.gnu.org/gnu/bison/bison-$BISON_VER.tar.xz bison-$BISON_VER.tar.xz
  unpack bison-$BISON_VER.tar.xz bison
  log "build bison $BISON_VER"
  (cd "$BUILD/bison" && ./configure --prefix="$PREFIX" --disable-nls && make -j"$JOBS" && make install)
  done_stamp bison-$BISON_VER
}

build_verilator() {
  on_system verilator && return
  stamp verilator-$VERILATOR_VER && return
  fetch https://github.com/verilator/verilator/archive/refs/tags/v$VERILATOR_VER.tar.gz verilator-$VERILATOR_VER.tar.gz
  unpack verilator-$VERILATOR_VER.tar.gz verilator
  log "build verilator $VERILATOR_VER"
  (cd "$BUILD/verilator" && autoconf && ./configure --prefix="$PREFIX" \
     && make -j"$JOBS" && make install)
  done_stamp verilator-$VERILATOR_VER
}

build_yosys() {  # yosys >= 0.6x builds with CMake (bundles abc + slang)
  on_system yosys && return
  stamp yosys-$YOSYS_VER && return
  fetch https://github.com/YosysHQ/yosys/releases/download/v$YOSYS_VER/yosys.tar.gz yosys-$YOSYS_VER.tar.gz
  rm -rf "$BUILD/yosys"; mkdir -p "$BUILD/yosys"
  tar -xf "$DL/yosys-$YOSYS_VER.tar.gz" -C "$BUILD/yosys"
  local src=$BUILD/yosys
  [[ -f $src/CMakeLists.txt ]] || src=$(dirname "$(find "$BUILD/yosys" -maxdepth 2 -name CMakeLists.txt | head -1)")
  log "build yosys $YOSYS_VER"
  cmake -S "$src" -B "$src/_build" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$PREFIX" \
        -DYOSYS_ENABLE_UNIT_TESTS=OFF -DYOSYS_WITH_PYTHON=OFF
  cmake --build "$src/_build" -j"$JOBS"
  cmake --install "$src/_build"
  done_stamp yosys-$YOSYS_VER
}

build_gnat() {  # bootstrap Ada compiler, only used to build GHDL
  stamp gnat-$GNAT_VER && return
  local f=gnat-x86_64-linux-$GNAT_VER.tar.gz
  fetch https://github.com/alire-project/GNAT-FSF-builds/releases/download/gnat-$GNAT_VER/$f $f
  fetch https://github.com/alire-project/GNAT-FSF-builds/releases/download/gnat-$GNAT_VER/$f.sha256 $f.sha256
  log "verify + unpack gnat $GNAT_VER"
  (cd "$DL" && sha256sum -c <(awk -v f="$f" '{print $1"  "f}' "$f.sha256"))
  rm -rf "$PREFIX/gnat"; mkdir -p "$PREFIX/gnat"
  tar -xf "$DL/$f" -C "$PREFIX/gnat" --strip-components=1
  done_stamp gnat-$GNAT_VER
}

build_ghdl() {
  on_system ghdl && return
  stamp ghdl-$GHDL_VER && return
  build_gnat
  fetch https://github.com/ghdl/ghdl/archive/refs/tags/v$GHDL_VER.tar.gz ghdl-$GHDL_VER.tar.gz
  unpack ghdl-$GHDL_VER.tar.gz ghdl
  log "build ghdl $GHDL_VER (mcode backend, synthesis enabled)"
  (cd "$BUILD/ghdl" && mkdir -p build && cd build \
     && PATH=$PREFIX/gnat/bin:$PATH ../configure --prefix="$PREFIX" \
     && PATH=$PREFIX/gnat/bin:$PATH make -j"$JOBS" \
     && PATH=$PREFIX/gnat/bin:$PATH make install)
  done_stamp ghdl-$GHDL_VER
}

install_sh_toolchain() {
  if on_system sh-elf-gcc; then return; fi
  stamp sh-toolchain && return
  [[ -f $SH_TOOLCHAIN_TARBALL ]] || { echo "missing $SH_TOOLCHAIN_TARBALL" >&2; return 1; }
  log "install sh-none-elf toolchain from $SH_TOOLCHAIN_TARBALL"
  rm -rf "$PREFIX/sh-none-elf"; mkdir -p "$PREFIX/sh-none-elf"
  local top
  top=$( (tar -tzf "$SH_TOOLCHAIN_TARBALL" || true) | head -1 | cut -d/ -f1)
  if [[ $top == sh-none-elf ]]; then
    tar -xzf "$SH_TOOLCHAIN_TARBALL" -C "$PREFIX/sh-none-elf" --strip-components=1
  else
    tar -xzf "$SH_TOOLCHAIN_TARBALL" -C "$PREFIX/sh-none-elf"
  fi
  "$PREFIX/sh-none-elf/bin/sh-none-elf-gcc" -dumpversion
  done_stamp sh-toolchain
}

ALL=(flex bison verilator yosys ghdl sh-toolchain)
for c in "${@:-${ALL[@]}}"; do
  case $c in
    flex) build_flex ;;
    bison) build_bison ;;
    help2man) build_help2man ;;
    verilator) build_flex; build_bison; build_help2man; build_verilator ;;
    yosys) build_flex; build_bison; build_yosys ;;
    gnat) build_gnat ;;
    ghdl) build_ghdl ;;
    sh-toolchain) install_sh_toolchain ;;
    *) echo "unknown component $c" >&2; exit 1 ;;
  esac
done
log "done. source tools/env.sh to use the tools"
