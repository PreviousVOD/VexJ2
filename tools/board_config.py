#!/usr/bin/env python3
"""Shared board.properties loader and firmware/vendor-build settings generator."""
import argparse
import os
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def validate(values):
    number = lambda key: int(values[key], 0)
    clock = number("clockHz")
    pll = number("usePll")
    if not 0 < clock < (1 << 31) or pll not in (0, 1):
        raise ValueError("invalid clock/PLL setting")
    if not values["uartDevice"] or number("uartBaud") <= 0 or clock // number("uartBaud") < 5:
        raise ValueError("unsupported UART configuration")
    if not (0 <= 2 * number("configurationSlotBytes") <= number("configurationFlashBytes")):
        raise ValueError("invalid configuration flash layout")
    if not (0 <= number("flashOffset") < number("flashOffset") + number("xipBytes")
            <= min(number("flashBytes"), 1 << 24)):
        raise ValueError("application XIP partition exceeds flash or 24-bit controller range")
    if number("flashOffset") % 65536 or number("xipBytes") % 65536:
        raise ValueError("application partition must align to erase sectors")
    for base, size in (("xipBase", "xipBytes"), ("memoryBase", "memoryBytes")):
        if not (0 <= number(base) < number(base) + number(size) <= 1 << 32):
            raise ValueError("invalid address window")
    if number("memoryBase") % 16:
        raise ValueError("memory base must be 16-byte aligned")
    sram = number("sramBytes")
    if sram < 4096 or sram >= (1 << 31) or sram & (sram - 1):
        raise ValueError("SRAM size must be a power of two, at least 4 KiB")
    for base, size in (("xipBase", "xipBytes"), ("memoryBase", "memoryBytes")):
        if 0x8000 < number(base) + number(size) and number(base) < 0x8000 + sram:
            raise ValueError("SRAM overlaps another memory window")
    if 0x8000 + sram > 0xff000000:
        raise ValueError("SRAM overlaps peripherals")
    return values


def load(board, environment=None):
    return load_file(ROOT / "fpga" / board / "board.properties", environment)


def load_file(path, environment=None):
    values = {}
    for line in Path(path).read_text().splitlines():
        line = line.strip()
        if line and not line.startswith("#"):
            key, value = line.split("=", 1)
            values[key.strip()] = value.strip()
    environment = os.environ if environment is None else environment
    # Environment overrides are opt-in profile entries, e.g. clockHzEnv=J2_CLOCK_HZ.
    for key, env in list(values.items()):
        if key.endswith("Env") and env in environment:
            values[key[:-3]] = environment[env]
    return validate(values)


def tcl_quote(value):
    value = str(value)
    for old, new in (("\\", "\\\\"), ("$", "\\$"), ("[", "\\["), ("\"", "\\\""), ("\n", "\\n"), ("\r", "\\r")):
        value = value.replace(old, new)
    return '"' + value + '"'


def write_if_changed(path, content):
    path.parent.mkdir(parents=True, exist_ok=True)
    if not path.exists() or path.read_text() != content:
        path.write_text(content)


def generate(values, out):
    definitions = {"J2_CLOCK_HZ": "clockHz", "J2_FLASH_OFFSET": "flashOffset",
                   "J2_FLASH_BYTES": "flashBytes", "J2_XIP_BASE": "xipBase",
                   "J2_XIP_BYTES": "xipBytes", "J2_MEMORY_BASE": "memoryBase",
                   "J2_MEMORY_BYTES": "memoryBytes", "J2_SRAM_BYTES": "sramBytes"}
    write_if_changed(out / "rom/board.h", "/* Generated from board.properties. */\n" +
                     f'#define J2_BOARD_NAME {json.dumps(values["name"])}\n' +
                     f'#define J2_FLASH_MICRON {int(values["flashType"] == "micron")}\n' +
                     "".join(f"#define {name} {int(values[key], 0)}{'' if name == 'J2_SRAM_BYTES' else 'u'}\n" for name, key in definitions.items()))
    # Quote scalar strings as Tcl data, independent of the chosen FPGA part.
    write_if_changed(out / "board.tcl",
        f'set board_part {tcl_quote(values["part"])}\n' +
        f'set board_clock_period {1e9 / int(values["inputClockHz"], 0):.6f}\n' +
        f'set board_soc_clock_period {1e9 / int(values["clockHz"], 0):.9f}\n' +
        f'set configuration_slot_bytes {int(values["configurationSlotBytes"], 0)}\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("board", help="directory under fpga/ containing board.properties")
    parser.add_argument("--get", metavar="KEY", help="print a validated setting")
    args = parser.parse_args()
    values = load(args.board)
    if args.get:
        print(values[args.get])
    else:
        generate(values, ROOT / "build" / args.board)


if __name__ == "__main__":
    main()
