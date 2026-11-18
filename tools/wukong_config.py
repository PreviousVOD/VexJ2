#!/usr/bin/env python3
"""Generate firmware and Vivado settings from the Wukong board profile."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def load():
    values = {}
    for line in (ROOT / "fpga/wukong-v1/board.properties").read_text().splitlines():
        line = line.strip()
        if line and not line.startswith("#"):
            key, value = line.split("=", 1)
            values[key.strip()] = value.strip()
    number = lambda key: int(values[key], 0)
    if values["part"] != "xc7a100tfgg676-2" or number("clockHz") != 32000000:
        raise ValueError("part/clock changes require a validated board clock implementation")
    if number("inputClockHz") != 50000000 or number("uartBaud") != 19200:
        raise ValueError("unsupported board oscillator/UART configuration")
    if not (0 < 2 * number("configurationSlotBytes") <= number("configurationFlashBytes")):
        raise ValueError("invalid onboard configuration flash layout")
    if not (0 <= number("flashOffset") < number("flashOffset") + number("xipBytes")
            <= min(number("flashBytes"), 1 << 24)):
        raise ValueError("application XIP partition exceeds flash or 24-bit controller range")
    if number("flashOffset") % 65536 or number("xipBytes") % 65536:
        raise ValueError("application partition must align to erase sectors")
    return values


def main():
    values = load()
    out = ROOT / "build/wukong-v1"
    (out / "rom").mkdir(parents=True, exist_ok=True)
    definitions = {"J2_CLOCK_HZ": "clockHz", "J2_FLASH_OFFSET": "flashOffset",
                   "J2_FLASH_BYTES": "flashBytes", "J2_XIP_BASE": "xipBase",
                   "J2_XIP_BYTES": "xipBytes", "J2_MEMORY_BASE": "memoryBase",
                   "J2_MEMORY_BYTES": "memoryBytes"}
    (out / "rom/board.h").write_text("/* Generated from board.properties. */\n" +
        "".join(f"#define {name} {int(values[key], 0)}u\n" for name, key in definitions.items()))
    # Only known scalar settings enter Tcl; do not interpolate arbitrary profile text.
    (out / "board.tcl").write_text(
        'set board_part "xc7a100tfgg676-2"\n' +
        f'set board_clock_period {1e9 / int(values["inputClockHz"], 0):.6f}\n' +
        f'set configuration_slot_bytes {int(values["configurationSlotBytes"], 0)}\n')


if __name__ == "__main__":
    main()
