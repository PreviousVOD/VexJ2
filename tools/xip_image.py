#!/usr/bin/env python3

from board_config import load as load_board
import argparse
import os
import select
import struct
import termios
import time
import tty
from pathlib import Path

MAGIC = 0x4A325831
XIP_BASE = 0x10000000
HEADER_SIZE = 32
XIP_LOAD_ADDRESS = XIP_BASE + HEADER_SIZE


def pack(input_path, output_path):
    load_address = XIP_LOAD_ADDRESS
    application = input_path.read_bytes()
    if not application:
        raise ValueError("empty application")
    if not 0 <= load_address <= 0xFFFFFFFF or load_address & 1:
        raise ValueError("load address must be an aligned 32-bit address")
    header = struct.pack(">IIIII12x", MAGIC, load_address, len(application),
                         sum(application) & 0xFFFFFFFF, load_address)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_bytes(header + application)
    print(f"packed {len(application)} application bytes at {load_address:#010x} "
          f"into {len(header) + len(application)}-byte image")


def read_until(fd, markers, timeout, output):
    deadline = time.monotonic() + timeout
    while not any(marker in output for marker in markers):
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            raise TimeoutError(f"did not receive any of {markers}")
        ready, _, _ = select.select([fd], [], [], remaining)
        if not ready:
            continue
        data = os.read(fd, 4096)
        if not data:
            continue
        output.extend(data)
        print(data.decode("ascii", errors="replace"), end="", flush=True)
    return output


def upload(image_path, device, wait_for_banner=True, success_marker=b"XIP CPU tests passed",
           result_timeout=120):
    image = image_path.read_bytes()
    if len(image) < HEADER_SIZE:
        raise ValueError("image is too short")
    fd = os.open(device, os.O_RDWR | os.O_NOCTTY)
    try:
        tty.setraw(fd)
        attrs = termios.tcgetattr(fd)
        attrs[4] = termios.B19200
        attrs[5] = termios.B19200
        termios.tcsetattr(fd, termios.TCSANOW, attrs)
        output = bytearray()
        if wait_for_banner:
            read_until(fd, [b"Send U to load", b"J2 loader"], 90, output)
            if b"J2 loader" not in output:
                os.write(fd, b"U")
                read_until(fd, [b"J2 loader"], 5, output)
        header = b"J2UP" + struct.pack(">II", 0, len(image))
        written = 0
        while written < len(header):
            written += os.write(fd, header[written:])
        failures = [b"Bad image range", b"Receive timeout", b"Invalid image header",
                    b"Erase error", b"Program error", b"Header error", b"Verify error",
                    b"checksum error", b"Platform failure"]

        def expect(marker, timeout):
            read_until(fd, [marker, *failures], timeout, output)
            if any(error in output for error in failures):
                raise RuntimeError("upload or application boot failed")

        expect(b"Send image", 120)
        offset = 0
        while offset < len(image):
            count = min(256, len(image) - offset)
            frame = image[offset:offset + count]
            written = 0
            while written < len(frame):
                written += os.write(fd, frame[written:])
            marker = f"Received {offset:06x}".encode()
            expect(marker, 120)
            offset += count
        expect(b"Flash verified", 120)
        expect(success_marker, result_timeout)
        if success_marker not in output:
            raise RuntimeError("upload or application boot failed")
    finally:
        os.close(fd)


def main():
    parser = argparse.ArgumentParser()
    subcommands = parser.add_subparsers(dest="command", required=True)
    pack_parser = subcommands.add_parser("pack")
    pack_parser.add_argument("input", type=Path)
    pack_parser.add_argument("output", type=Path)
    upload_parser = subcommands.add_parser("upload")
    upload_parser.add_argument("image", type=Path)
    upload_parser.add_argument("--device", default=load_board("tang-primer")["uartDevice"])
    upload_parser.add_argument("--no-wait", action="store_true",
                               help="upload to a ROM already waiting in J2 loader")
    args = parser.parse_args()

    if args.command == "pack":
        pack(args.input, args.output)
    else:
        upload(args.image, args.device, not args.no_wait)


if __name__ == "__main__":
    main()
