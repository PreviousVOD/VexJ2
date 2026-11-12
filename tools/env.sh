# Source this file to make the repository-local toolchain available:
#   . tools/env.sh
# System tools take precedence; tools/local (built by
# tools/third_party/build-tools.sh) is only used for tools missing on PATH.
J2_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")/.." && pwd)
export J2_ROOT
case ":$PATH:" in
  *":$J2_ROOT/tools/local/bin:"*) ;;
  *) export PATH="$PATH:$J2_ROOT/tools/local/bin:$J2_ROOT/tools/local/sh-none-elf/bin" ;;
esac
