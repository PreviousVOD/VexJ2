#!/usr/bin/env python3
"""Shared board.properties loader and firmware/vendor-build settings generator."""
import argparse
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BOARDS = ("tang-primer", "wukong-v1")


def validate(values):
    number = lambda key: int(values[key], 0)
    board = values["name"]
    clock = number("clockHz")
    pll = number("usePll")
    if not 0 < clock < (1 << 31) or pll not in (0, 1):
        raise ValueError("invalid clock/PLL setting")
    if not values["uartDevice"] or number("uartBaud") != 19200 or clock // number("uartBaud") < 5:
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
    if board == "tang-primer":
        if values["flashType"] != "winbond":
            raise ValueError("Tang application flash uses the Winbond protocol")
        if values["part"] != "EG4S20BG256" or number("inputClockHz") != 24000000:
            raise ValueError("unsupported Tang device/oscillator")
        if values["memoryType"] != "sdram" or number("memoryBytes") != 0x800000:
            raise ValueError("Tang requires its 8 MiB SDRAM")
        if number("memoryBase") % number("memoryBytes"):
            raise ValueError("Tang SDRAM window must align to its size")
        if number("flashOffset") != 0:
            raise ValueError("Tang loader uploads start at flash offset zero")
        vco = 384000000 if clock == 32000000 else 360000000
        if (pll and vco % clock) or (not pll and clock != 24000000):
            raise ValueError("invalid Tang PLL/bypass clock")
    elif board == "wukong-v1":
        if values["flashType"] != "micron":
            raise ValueError("Wukong SF3 uses the Micron protocol")
        if values["part"] != "xc7a100tfgg676-2" or number("inputClockHz") != 50000000:
            raise ValueError("unsupported Wukong device/oscillator")
        if clock != 72000000 or not pll:
            raise ValueError("update and validate the Wukong MMCM before changing clocks")
        if values["memoryType"] != "ddr3" or number("memoryBytes") != 0x10000000:
            raise ValueError("Wukong MIG requires 256 MiB DDR3")
        if number("configurationSlotBytes") <= 0:
            raise ValueError("Wukong requires configuration flash slots")
    else:
        raise ValueError("unsupported board: " + board)
    return values


def load(board, environment=None):
    if board not in BOARDS:
        raise ValueError("unsupported board: " + board)
    values = {}
    for line in (ROOT / "fpga" / board / "board.properties").read_text().splitlines():
        line = line.strip()
        if line and not line.startswith("#"):
            key, value = line.split("=", 1)
            values[key.strip()] = value.strip()
    if values["name"] != board:
        raise ValueError("board profile name does not match its directory")
    environment = os.environ if environment is None else environment
    # Keep the existing Tang clock diagnostics; a recursive Make exports these
    # globally, so they must never change the Wukong profile.
    if board == "tang-primer":
        for env, key in (("J2_CLOCK_HZ", "clockHz"), ("J2_USE_PLL", "usePll")):
            if env in environment:
                values[key] = environment[env]
    return validate(values)


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
                     f'#define J2_BOARD_NAME "{values["name"]}"\n' +
                     f'#define J2_FLASH_MICRON {int(values["flashType"] == "micron")}\n' +
                     "".join(f"#define {name} {int(values[key], 0)}{'' if name == 'J2_SRAM_BYTES' else 'u'}\n" for name, key in definitions.items()))
    # The part is whitelisted by validate(); all other Tcl values are numeric.
    write_if_changed(out / "board.tcl",
        f'set board_part "{values["part"]}"\n' +
        f'set board_clock_period {1e9 / int(values["inputClockHz"], 0):.6f}\n' +
        f'set board_soc_clock_period {1e9 / int(values["clockHz"], 0):.9f}\n' +
        f'set configuration_slot_bytes {int(values["configurationSlotBytes"], 0)}\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("board", choices=BOARDS)
    parser.add_argument("--get", metavar="KEY", help="print a validated setting")
    args = parser.parse_args()
    values = load(args.board)
    if args.get:
        print(values[args.get])
    else:
        generate(values, ROOT / "build" / args.board)


if __name__ == "__main__":
    main()
