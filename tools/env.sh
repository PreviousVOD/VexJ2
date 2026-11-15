# Source this file to make the repository-local toolchain available:
#   . tools/env.sh
# Repository-local tools take precedence over system installations.
J2_ROOT=$(cd "$(dirname "${BASH_SOURCE[0]:-${(%):-%x}}")/.." && pwd)
export J2_ROOT
case ":$PATH:" in
  *":$J2_ROOT/tools/local/bin:"*) ;;
  *) export PATH="$J2_ROOT/tools/local/bin:$J2_ROOT/tools/local/sh-none-elf/bin:$PATH" ;;
esac
