#!/usr/bin/env python3
"""Generate the source files needed by the TD-only original-VHDL build.

The released CPU uses two textual preprocessors:

* v2p, which expands the `register variable` extension in the .vhm files;
* VHDL configurations, which select the reverse decoder and two-bank regfile.

TD's flow interpreter is happier with direct entity instantiations, so this
script makes build-local copies with exactly those two bindings applied.  The
CPU source itself remains the untouched file under reference/soc_top.
"""

from __future__ import annotations

import argparse
import os
import shutil
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "reference/soc_top"
OUT = ROOT / "build/td_vhdl"
PRE = OUT / "pre"
V2P = SRC / "tools/v2p"


def v2p(relative: str) -> Path:
    source = SRC / relative
    output = PRE / f"{source.stem}.vhd"
    PRE.mkdir(parents=True, exist_ok=True)
    if not output.exists() or source.stat().st_mtime > output.stat().st_mtime:
        with source.open("rb") as input_file, output.open("wb") as output_file:
            env = dict(os.environ)
            env.pop("LD_LIBRARY_PATH", None)
            subprocess.run(
                ["perl", "-X", str(V2P)],
                stdin=input_file,
                stdout=output_file,
                env=env,
                check=True,
            )
    return output


def replace_once(text: str, old: str, new: str, description: str) -> str:
    count = text.count(old)
    if count != 1:
        raise RuntimeError(f"{description}: expected one match, found {count}")
    return text.replace(old, new, 1)


def bind_cpu() -> None:
    components = (SRC / "components/cpu/core/components_pkg.vhd").read_text()
    components = replace_once(
        components,
        "use ieee.math_real.all;\n",
        "",
        "remove unavailable math_real dependency",
    )
    components = replace_once(
        components,
        "natural(floor(real(a'length) / real(byte_width)))",
        "a'length / byte_width",
        "replace real floor helper",
    )
    (OUT / "components_pkg_bound.vhd").write_text(components)

    decode = (SRC / "components/cpu/decode/decode.vhd").read_text()
    decode = replace_once(
        decode,
        "    core : decode_core\n",
        "    core : entity work.decode_core(arch)\n"
        "        generic map (decode_type => REVERSE, reset_vector => DEC_CORE_RESET)\n",
        "bind reverse decode core",
    )
    decode = replace_once(
        decode,
        "    table : decode_table\n",
        "    table : entity work.decode_table(reverse_logic)\n",
        "bind reverse decode table",
    )
    (OUT / "decode_bound.vhd").write_text(decode)

    datapath = v2p("components/cpu/core/datapath.vhm").read_text()
    datapath = replace_once(
        datapath,
        "u_regfile : register_file",
        "u_regfile : entity work.register_file(two_bank)",
        "bind two-bank register file",
    )
    (OUT / "datapath_bound.vhd").write_text(datapath)

    cpu = (SRC / "components/cpu/core/cpu.vhd").read_text()
    cpu = replace_once(
        cpu,
        "   u_decode: decode\n",
        "   u_decode: entity work.decode(arch)\n",
        "bind CPU decoder",
    )
    cpu = replace_once(
        cpu,
        "   u_mult : mult port map",
        "   u_mult : entity work.mult(stru) port map",
        "bind CPU multiplier",
    )
    cpu = replace_once(
        cpu,
        "   u_datapath : datapath port map",
        "   u_datapath : entity work.datapath(stru) port map",
        "bind CPU datapath",
    )
    (OUT / "cpu_bound.vhd").write_text(cpu)

    uart = (SRC / "components/uartlite/uartlitedb.vhd").read_text()
    uart = replace_once(
        uart,
        "  uart : uartlite\n",
        "  uart : entity work.uartlite(beh)\n",
        "bind original UART",
    )
    (OUT / "uartlitedb_bound.vhd").write_text(uart)


def generate_program_mif(binary: Path) -> None:
    data = binary.read_bytes()
    sram_size = 32 * 1024
    if len(data) > sram_size:
        raise RuntimeError(f"{binary} is {len(data)} bytes; SRAM holds {sram_size}")

    data += b"\0" * (-len(data) % 4)
    packed_words = [
        int.from_bytes(data[i : i + 4], "big") for i in range(0, len(data), 4)
    ]
    packed = [
        "DEPTH = 8192;",
        "WIDTH = 32;",
        "ADDRESS_RADIX = HEX;",
        "DATA_RADIX = HEX;",
        "CONTENT BEGIN",
    ]
    packed.extend(
        f"{offset:04x} : {word:08x};"
        for offset, word in enumerate(packed_words)
    )
    packed.extend(["END;", ""])
    (OUT / "j2_program.mif").write_text("\n".join(packed))


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--program",
        type=Path,
        default=ROOT / "build/sw/testrom/main.bin",
        help="raw big-endian testrom image",
    )
    args = parser.parse_args()

    if not V2P.is_file():
        raise SystemExit(f"missing original v2p preprocessor: {V2P}")
    if not args.program.is_file():
        raise SystemExit(f"missing program image: {args.program}")

    OUT.mkdir(parents=True, exist_ok=True)
    v2p("components/cpu/core/mult.vhm")
    v2p("components/cpu/decode/decode_core.vhm")
    v2p("components/uartlite/uart.vhm")
    bind_cpu()
    generate_program_mif(args.program)

    # pio.vhd refers to a signal group added by the board's soc_gen metadata.
    # It is ignored during synthesis, but the package still has to parse.
    attr = (SRC / "lib/hwutils/attr_pkg.vhd").read_text()
    needle = "  group peripheral_bus is (signal <>);\n"
    attr = replace_once(
        attr,
        needle,
        needle + "  group bus_signals is (signal <>);\n",
        "add PIO signal-group declaration",
    )
    (OUT / "attr_pkg.vhd").write_text(attr)

    print(f"generated TD VHDL sources in {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
