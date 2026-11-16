#!/usr/bin/env python3

import argparse
import os
import select
import struct
import termios
import time
import tty
from pathlib import Path

MAGIC = 0x4A325831
ENTRY = 0x10000010


def pack(input_path, output_path):
    application = input_path.read_bytes()
    if not application:
        raise ValueError("empty application")
    header = struct.pack(">IIII", MAGIC, ENTRY, len(application), sum(application) & 0xFFFFFFFF)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_bytes(header + application)
    print(f"packed {len(application)} application bytes into {len(header) + len(application)}-byte image")


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
    if len(image) < 20:
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
        read_until(fd, [b"Program flash"], 120, output)
        offset = 0
        while offset < len(image):
            count = min(256, len(image) - offset)
            frame = image[offset:offset + count]
            written = 0
            while written < len(frame):
                written += os.write(fd, frame[written:])
            marker = f"Page {offset:06x}".encode()
            read_until(fd, [marker, b"Verify error"], 120, output)
            offset += count
        read_until(fd, [success_marker, b"Verify error", b"checksum error"], result_timeout, output)
        if success_marker not in output:
            raise RuntimeError("upload or XIP boot failed")
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
    upload_parser.add_argument("--device", default="/dev/ttyACM0")
    upload_parser.add_argument("--no-wait", action="store_true",
                               help="upload to a ROM already waiting in J2 loader")
    args = parser.parse_args()

    if args.command == "pack":
        pack(args.input, args.output)
    else:
        upload(args.image, args.device, not args.no_wait)


if __name__ == "__main__":
    main()
