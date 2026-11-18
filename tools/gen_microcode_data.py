#!/usr/bin/env python3
"""Generate canonical microcode data from the reference J2 decoder."""

from __future__ import annotations

import argparse
import re
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent


def write_if_changed(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists() and path.read_text() == content:
        return
    path.write_text(content)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--source",
        type=Path,
        default=ROOT / "reference/soc_top/components/cpu/decode/decode_table_rom.vhd",
    )
    parser.add_argument(
        "--decode-body",
        type=Path,
        default=ROOT / "reference/soc_top/components/cpu/decode/decode_body.vhd",
    )
    parser.add_argument(
        "--hex",
        type=Path,
        default=ROOT / "spinal/src/main/resources/j2_microcode.hex",
    )
    parser.add_argument(
        "--predecode",
        type=Path,
        default=ROOT / "spinal/src/main/resources/j2_predecode.tsv",
    )
    parser.add_argument(
        "--mif",
        type=Path,
        help="also generate an EG4 MIF at this path",
    )
    args = parser.parse_args()

    entries = re.findall(r'x"([0-9a-fA-F]{18})"', args.source.read_text())
    if len(entries) != 256:
        raise SystemExit(f"expected 256 microcode lines, found {len(entries)}")

    predecode = re.findall(
        r"--\s*([01nmdi]{4}(?: [01nmdi]{4}){3})\s*=>\s*([01]{8})\s+(\S.*?)\s*$",
        args.decode_body.read_text(),
        re.MULTILINE,
    )
    if not predecode:
        raise SystemExit("no reference predecode entries found")

    # The reference contains J2 additions; this core targets the SH-2 ISA.
    extensions = {"BGND", "CAS.L", "SHAD", "SHLD"}
    predecode = [entry for entry in predecode if entry[2].split()[0] not in extensions]

    hex_data = "".join(f"{entry.upper()}\n" for entry in entries)
    predecode_data = "".join(
        f"{pattern.replace(' ', '')}\t{int(address, 2):02x}\t{name}\n"
        for pattern, address, name in predecode
    )
    mif_lines = [
        "DEPTH = 256;",
        "WIDTH = 72;",
        "ADDRESS_RADIX = HEX;",
        "DATA_RADIX = HEX;",
        "CONTENT BEGIN",
    ]
    mif_lines.extend(f"{address:04x} : {entry.upper()};" for address, entry in enumerate(entries))
    mif_lines.extend(["END;", ""])

    write_if_changed(args.hex, hex_data)
    write_if_changed(args.predecode, predecode_data)
    if args.mif is not None:
        write_if_changed(args.mif, "\n".join(mif_lines))
    print(
        f"generated {len(entries)} microcode entries and {len(predecode)} predecode entries"
    )


if __name__ == "__main__":
    main()
