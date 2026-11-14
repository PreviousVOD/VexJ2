#!/usr/bin/env python3
"""Create the SH-2-only variant of the original J2 test ROM.

The source ROM contains two explicitly excluded J2 extensions:
  * testshift, which exercises SHAD and SHLD
  * the CAS.L section at the end of testmov

This script verifies the expected original instructions before replacing them
with branch/NOP pairs. Every other test remains byte-for-byte unchanged.
"""

from __future__ import annotations

import argparse
import struct
from pathlib import Path


def read_u16(image: bytearray, offset: int) -> int:
    return struct.unpack_from(">H", image, offset)[0]


def expect(image: bytearray, offset: int, value: int) -> None:
    actual = read_u16(image, offset)
    if actual != value:
        raise ValueError(f"{offset:#x}: expected {value:#06x}, found {actual:#06x}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()

    image = bytearray(args.source.read_bytes())

    # _start: skip the J2-only SHAD/SHLD test call.
    expect(image, 0x138, 0xD022)  # mov.l testshift_k,r0
    expect(image, 0x13A, 0x400B)  # jsr @r0
    struct.pack_into(">H", image, 0x138, 0xA001)  # bra 0x13e
    struct.pack_into(">H", image, 0x13A, 0x0009)  # nop

    # testmov: skip the CAS.L-only section and go to its success path.
    expect(image, 0x18B8, 0xD02D)  # mov.l _pram0_cas,r0
    struct.pack_into(">H", image, 0x18B8, 0xA066)  # bra 0x1988
    struct.pack_into(">H", image, 0x18BA, 0x0009)  # nop

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_bytes(image)


if __name__ == "__main__":
    main()
