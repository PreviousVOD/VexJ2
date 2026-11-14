#!/usr/bin/env python3
"""Create a block-ROM decoder variant and its 256x72 MIF image."""

from __future__ import annotations

import re
import sys
from pathlib import Path


def main() -> None:
    source = Path(sys.argv[1])
    output = Path(sys.argv[2])
    mif = Path(sys.argv[3])

    text = source.read_text()
    entries = re.findall(r'x"([0-9a-fA-F]{18})"', text)
    if len(entries) != 256:
        raise ValueError(f"expected 256 microcode lines, found {len(entries)}")

    with mif.open("w") as stream:
        stream.write("DEPTH = 256;\nWIDTH = 72;\n")
        stream.write("ADDRESS_RADIX = HEX;\nDATA_RADIX = HEX;\nCONTENT BEGIN\n")
        for address, value in enumerate(entries):
            stream.write(f"{address:04x} : {value.upper()};\n")
        stream.write("END;\n")

    declaration_start = text.index("    type mem is array")
    declaration_end = text.index("begin", declaration_start)
    component = """
    component j2_microcode_rom
      port (
        clk  : in  std_logic;
        addr : in  std_logic_vector(7 downto 0);
        dout : out std_logic_vector(71 downto 0)
      );
    end component;
"""
    text = (
        text[:declaration_start]
        + component
        + text[declaration_end:]
    )

    process_start = text.index("    -- Read microcode line on falling edge of")
    process_end = text.index("    end process;", process_start) + len("    end process;")
    instance = """
    u_microcode_rom : j2_microcode_rom
      port map (
        clk => clk,
        addr => op.addr,
        dout => line
      );
"""
    text = text[:process_start] + instance + text[process_end:]
    output.write_text(text)


if __name__ == "__main__":
    main()
