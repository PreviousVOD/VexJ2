#!/usr/bin/env python3
"""Volatile FPGA download, bounded SF3 upload/backup, and application validation."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import select
import struct
import subprocess
import termios
import time
import tty
from board_config import ROOT, load


def validate(image, profile):
    number = lambda key: int(profile[key], 0)
    if not 34 <= len(image) <= number("xipBytes"):
        raise ValueError("image exceeds the application partition or is empty")
    magic, entry, length, checksum, address, *reserved = struct.unpack(">8I", image[:32])
    if magic != 0x4a325831 or any(reserved) or length != len(image) - 32:
        raise ValueError("invalid image header/length")
    if (entry | address) & 1 or entry < address or entry - address > length - 2:
        raise ValueError("entry must address a complete aligned instruction in the payload")
    if address != number("xipBase") + 32:
        raise ValueError("ROM only boots images linked at the XIP payload address")
    if (sum(image[32:]) & 0xffffffff) != checksum:
        raise ValueError("image checksum mismatch")
    return dict(entry=entry, load_address=address, payload_bytes=length)


class Serial:
    def __init__(self, fd):
        self.fd = fd
        self.buffer = bytearray()
        self.transcript = bytearray()

    def fill(self, deadline):
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            raise TimeoutError("UART timeout: " + self.transcript[-500:].decode(errors="replace"))
        ready, _, _ = select.select([self.fd], [], [], min(remaining, 1))
        if ready:
            self.buffer.extend(os.read(self.fd, 4096))

    def until(self, marker, timeout=120):
        deadline = time.monotonic() + timeout
        errors = [b"Platform failure", b"Bad image range", b"Invalid image header", b"Receive timeout",
                  b"Erase error", b"Program error", b"Header error", b"Verify error", b"checksum error",
                  b"DDR copy error", b"tests failed", b"ISA FAIL", b"Application returned"]
        while marker not in self.buffer:
            if any(error in self.buffer for error in errors):
                self.transcript.extend(self.buffer)
                self.buffer.clear()
                raise RuntimeError("ROM/application failure; see uart.log")
            self.fill(deadline)
        end = self.buffer.index(marker) + len(marker)
        result = bytes(self.buffer[:end])
        del self.buffer[:end]
        self.transcript.extend(result)
        print(result.decode("ascii", errors="replace"), end="", flush=True)
        if any(error in result for error in errors):
            raise RuntimeError("ROM/application failure; see uart.log")
        return result

    def exact(self, size, timeout=120):
        deadline = time.monotonic() + timeout
        while len(self.buffer) < size:
            self.fill(deadline)
        result = bytes(self.buffer[:size])
        del self.buffer[:size]
        return result

    def send(self, data):
        deadline = time.monotonic() + 30
        view = memoryview(data)
        while view:
            if time.monotonic() > deadline:
                raise TimeoutError("UART write timeout")
            if select.select([], [self.fd], [], 1)[1]:
                try:
                    view = view[os.write(self.fd, view):]
                except BlockingIOError:
                    pass


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--image", type=Path, required=True, help="expected packed application image")
    parser.add_argument("--upload", action="store_true", help="backup and replace SF3 application sectors")
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--timeout", type=float, default=180)
    args = parser.parse_args()
    profile = load("wukong-v1")
    image = args.image.read_bytes()
    info = validate(image, profile)
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    bitstream = ROOT / "build/wukong-v1/vivado/j2_wukong_v1.bit"
    if not (bitstream.parent / "implementation.pass").is_file():
        raise ValueError("build and validate the Wukong bitstream first")
    for name in ("results.json", "program.pass"):
        (out / name).unlink(missing_ok=True)
    fd = os.open(profile["uartDevice"], os.O_RDWR | os.O_NOCTTY | os.O_NONBLOCK)
    serial = Serial(fd)
    proc = None
    try:
        tty.setraw(fd)
        attrs = termios.tcgetattr(fd)
        attrs[4] = attrs[5] = termios.B19200
        termios.tcsetattr(fd, termios.TCSANOW, attrs)
        termios.tcflush(fd, termios.TCIFLUSH)
        with (out / "program.log").open("w") as log:
            proc = subprocess.Popen(["python3", str(ROOT / "tools/fpga.py"), "--board", "wukong-v1",
                "program", "--bitstream", str(bitstream), "--program-dir", str(out)],
                cwd=out, stdout=log, stderr=subprocess.STDOUT)
            serial.until(b"Send U to load\r\n", args.timeout)
            if args.upload:
                serial.send(b"U")
                serial.until(b"J2 loader\r\n")
                # Save every sector that will be erased before sending the update.
                size = (len(image) + 65535) & ~65535
                serial.send(b"J2RD" + struct.pack(">II", 0, size))
                serial.until(b"Read flash\r\n")
                backup = serial.exact(size, max(120, size / 1000))
                (out / "sf3-before.bin").write_bytes(backup)
                serial.until(b"Read complete\r\n")
                serial.until(b"J2 loader\r\n")
                serial.send(b"J2UP" + struct.pack(">II", 0, len(image)))
                serial.until(b"Send image\r\n")
                for offset in range(0, len(image), 256):
                    serial.send(image[offset:offset+256])
                    serial.until(f"Received {offset:06x}\r\n".encode())
                serial.until(b"Flash verified\r\n", args.timeout)
            boot = b"Booting XIP image\r\n" if info["load_address"] == int(profile["xipBase"], 0)+32 else b"Booting loaded image\r\n"
            serial.until(boot, args.timeout)
            serial.until(b"XIP CPU tests passed\r\n", args.timeout)
            if proc.wait(timeout=15) != 0 or not (out / "program.pass").is_file():
                raise RuntimeError("Vivado volatile programming failed")
        report = dict(complete=True, clock_hz=int(profile["clockHz"]),
            uart_baud=int(profile["uartBaud"]), device=profile["uartDevice"], programming="volatile JTAG",
            uploaded=args.upload, configuration_flash_written=False,
            application_partition_offset=int(profile["flashOffset"], 0),
            application_partition_bytes=int(profile["xipBytes"], 0),
            image_sha256=hashlib.sha256(image).hexdigest(),
            bitstream_sha256=hashlib.sha256(bitstream.read_bytes()).hexdigest(),
            image=info, application_isa_passed=True)
        if args.upload:
            report["backup_bytes"] = len(backup)
            report["backup_sha256"] = hashlib.sha256(backup).hexdigest()
        (out / "results.json").write_text(json.dumps(report, indent=2)+"\n")
        print("WUKONG_APPLICATION_PASS:", "upload" if args.upload else "warm boot", hex(info["load_address"]))
    finally:
        if proc is not None and proc.poll() is None:
            proc.terminate()
            proc.wait(timeout=15)
        os.close(fd)
        (out / "uart.log").write_bytes(serial.transcript + serial.buffer)


if __name__ == "__main__":
    main()
