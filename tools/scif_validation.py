#!/usr/bin/env python3
"""Validate a timed board bitstream by volatile JTAG and the SCIF UART loader.

Without --image, build and upload the interactive FIFO test. With --image,
validate the standard ISA application; --upload replaces its flash sectors.
--backup saves every sector touched by an upload before any erase command.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
import os
from pathlib import Path
import struct
import subprocess
import termios
import time
import tty

from board_config import ROOT, generate_interrupt_header, load
from check_wukong_boot import Serial, validate
from isa_validation import validate as validate_isa


class ScifSerial(Serial):
    def until(self, marker, timeout=120):
        self.text_mode = True
        try:
            return super().until(marker, timeout)
        finally:
            self.text_mode = False

    def fill(self, deadline):
        super().fill(deadline)
        if getattr(self, "text_mode", False) and b"SCIF FAIL " in self.buffer and b"\n" in self.buffer:
            raise RuntimeError("SCIF register test failed: " + self.buffer.decode(errors="replace"))


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def build_test(profile, depth, out):
    out.mkdir(parents=True, exist_ok=True)
    generate_interrupt_header(profile, out / "j2_board_irqs.h")
    prefix = str(ROOT / "tools/local/sh-none-elf/bin/sh-none-elf-")
    elf = out / "main.elf"
    binary = out / "main.bin"
    image = out / "flash.bin"
    subprocess.run([prefix + "gcc", "-m2", "-mb", "-Os", "-Wall", "-Wextra", "-Werror",
                    "-ffreestanding", "-fno-builtin", "-nostdlib", "-I" + str(out),
                    "-I" + str(ROOT / "sw/include"), "-I" + str(ROOT / "sw/bootrom"),
                    "-DJ2_CLOCK_HZ=" + profile["clockHz"], "-DJ2_UART_BAUD=" + profile["uartBaud"],
                    "-DJ2_SCI_BASE=" + profile["sciBase"], "-DJ2_CMT_BASE=" + profile["cmtBase"],
                    "-DJ2_SRAM_BYTES=" + profile["sramBytes"],
                    "-DJ2_SCIF_CAPACITY=" + str(max(1, depth)),
                    "-Wl,--defsym=J2_SRAM_BYTES=" + profile["sramBytes"],
                    "-T", str(ROOT / "sw/xipapp/app.x"),
                    str(ROOT / "sw/bootrom/test/scif_entry.S"),
                    str(ROOT / "sw/bootrom/test/scif.c"), str(ROOT / "sw/bootrom/uart.c"),
                    "-lgcc", "-o", str(elf)], check=True)
    subprocess.run([prefix + "objcopy", "-O", "binary", str(elf), str(binary)], check=True)
    subprocess.run(["python3", str(ROOT / "tools/xip_image.py"), "pack", str(binary), str(image)], check=True)
    return image


def fifo_protocol(serial, depth):
    capacity = max(1, depth)
    serial.until(f"SCIF capacity {capacity:04x}\r\n".encode())
    serial.until(b"SCIF TX BEGIN\r\n")
    burst = serial.until(b"\r\nSCIF TX PASS\r\n")
    expected = bytes(ord("A") + i % 26 for i in range(capacity)) + b"\r\nSCIF TX PASS\r\n"
    if burst != expected:
        raise ValueError("TX FIFO data order/full-write rejection failed")
    serial.until(b"SCIF RX FULL\r\n")
    serial.send(bytes((0x20 + i) & 255 for i in range(capacity + 1)))
    serial.until(b"SCIF RX FULL PASS\r\nSCIF RX SHORT\r\n")
    serial.send(b"m")
    serial.until(b"SCIF RX SHORT PASS\r\nSCIF RX PARITY\r\n")
    # Let firmware finish the last stop bit and switch RX to even parity. The
    # 8N1 stop bit of 0x03 is then sampled as an intentionally incorrect parity.
    time.sleep(0.1)
    serial.send(b"\x03")
    serial.until(b"SCIF RX PARITY PASS\r\nSCIF FIFO tests passed\r\n")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--board", required=True)
    parser.add_argument("--bitstream", required=True, type=Path)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--fifo-depth", type=int, help="bitstream FIFO depth; defaults to board.properties")
    parser.add_argument("--image", type=Path)
    parser.add_argument("--upload", action="store_true")
    parser.add_argument("--backup", action="store_true")
    args = parser.parse_args()
    profile = load(args.board)
    if args.fifo_depth is None:
        args.fifo_depth = int(profile["sciFifoDepth"], 0)
    if not 0 <= args.fifo_depth <= 255:
        parser.error("FIFO depth must be 0–255")
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    result = out / "results.json"
    result.unlink(missing_ok=True)
    bitstream = args.bitstream.resolve()
    if not (bitstream.parent / "implementation.pass").is_file():
        raise ValueError("bitstream has no successful implementation marker")
    image_path = args.image.resolve() if args.image else build_test(profile, args.fifo_depth, out / "app")
    image = image_path.read_bytes()
    validate(image, profile)
    upload = args.upload or args.image is None
    fd = os.open(profile["uartDevice"], os.O_RDWR | os.O_NOCTTY | os.O_NONBLOCK)
    serial = ScifSerial(fd)
    proc = None
    report = dict(board=args.board, fifo_depth=args.fifo_depth,
                  started_utc=datetime.now(timezone.utc).isoformat(),
                  clock_hz=int(profile["clockHz"], 0), device=profile["uartDevice"],
                  image_sha256=digest(image_path), bitstream_sha256=digest(bitstream),
                  programming="volatile JTAG", configuration_flash_written=False,
                  test="fifo" if args.image is None else "isa", uploaded=upload,
                  profile=dict(profile, sciFifoDepth=str(args.fifo_depth)))
    try:
        tty.setraw(fd)
        attrs = termios.tcgetattr(fd)
        attrs[4] = attrs[5] = getattr(termios, "B" + profile["uartBaud"])
        termios.tcsetattr(fd, termios.TCSANOW, attrs)
        termios.tcflush(fd, termios.TCIFLUSH)
        with (out / "program.log").open("w") as log:
            proc = subprocess.Popen(["python3", str(ROOT / "tools/fpga.py"), "--board", args.board,
                                     "program", "--bitstream", str(bitstream),
                                     "--program-dir", str(out)], cwd=ROOT, stdout=log, stderr=subprocess.STDOUT)
            serial.until(b"Send U to load\r\n", 90)
            if upload:
                serial.send(b"U")
                serial.until(b"J2 loader\r\n")
                if args.backup:
                    size = (len(image) + 65535) & ~65535
                    serial.send(b"J2RD" + struct.pack(">II", 0, size))
                    serial.until(b"Read flash\r\n")
                    backup = serial.exact(size, 120)
                    (out / "flash-before.bin").write_bytes(backup)
                    report["backup_sha256"] = hashlib.sha256(backup).hexdigest()
                    report["backup_bytes"] = size
                    serial.until(b"Read complete\r\n")
                    serial.until(b"J2 loader\r\n")
                serial.send(b"J2UP" + struct.pack(">II", 0, len(image)))
                serial.until(b"Send image\r\n")
                for offset in range(0, len(image), 256):
                    serial.send(image[offset:offset + 256])
                    serial.until(f"Received {offset:06x}\r\n".encode())
                serial.until(b"Flash verified\r\n")
            serial.until(b"Booting XIP image\r\n")
            if args.image is None:
                fifo_protocol(serial, args.fifo_depth)
            else:
                serial.until(b"XIP CPU tests passed\r\n")
                validate_isa(serial.transcript.decode(errors="replace"))
            if proc.wait(timeout=15) or not (out / "program.pass").is_file():
                raise RuntimeError("volatile programming failed")
        report["complete"] = True
        result.write_text(json.dumps(report, indent=2) + "\n")
        print("SCIF_HARDWARE_PASS:", args.board, args.fifo_depth, report["test"])
    finally:
        if proc is not None and proc.poll() is None:
            proc.terminate()
            proc.wait(timeout=15)
        (out / "uart.log").write_bytes(serial.transcript + serial.buffer)
        os.close(fd)


if __name__ == "__main__":
    main()
