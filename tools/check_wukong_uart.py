#!/usr/bin/env python3
"""Volatile Vivado JTAG download and full DDR3 SoC platform-ROM validation."""
import argparse
import hashlib
import json
import os
import select
import subprocess
import struct
import termios
import time
import tty

from board_config import ROOT, load


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--device")
    parser.add_argument("--timeout", type=float, default=120)
    args = parser.parse_args()
    profile = load("wukong-v1")
    device = args.device or profile["uartDevice"]
    out = ROOT / "build/wukong-v1/hardware"
    out.mkdir(parents=True, exist_ok=True)
    bitstream = ROOT / "build/wukong-v1/vivado/j2_wukong_v1.bit"
    if not (bitstream.parent / "implementation.pass").is_file():
        raise ValueError("run make wukong-bitstream before hardware validation")
    digest = hashlib.sha256(bitstream.read_bytes()).hexdigest()
    for name in ("results.json", "program.pass"):
        (out / name).unlink(missing_ok=True)
    banner = ("wukong-v1 platform ROM\r\nApplication flash offset: "
              f'{int(profile["flashOffset"], 0):08x}'
              "\r\nFlash JEDEC ID: 20ba19\r\nFlash quad XIP: PASS\r\nSend U to load\r\n").encode()
    echo = b"Bad image range\r\n"
    captured = bytearray()
    fd = os.open(device, os.O_RDWR | os.O_NOCTTY | os.O_NONBLOCK)
    try:
        tty.setraw(fd)
        attrs = termios.tcgetattr(fd)
        attrs[4] = attrs[5] = termios.B19200
        termios.tcsetattr(fd, termios.TCSANOW, attrs)
        termios.tcflush(fd, termios.TCIFLUSH)
        with (out / "program.log").open("w") as log:
            proc = subprocess.Popen([
                "python3", str(ROOT / "tools/fpga.py"), "--board", "wukong-v1", "program",
                "--bitstream", str(bitstream), "--program-dir", str(out)
            ], cwd=out, stdout=log, stderr=subprocess.STDOUT)
            try:
                deadline = time.monotonic() + args.timeout
                echo_start = None
                probe_sent = False
                while time.monotonic() < deadline:
                    ready, _, _ = select.select([fd], [], [], 0.1)
                    if ready:
                        captured.extend(os.read(fd, 4096))
                    if b"Flash quad XIP: FAIL" in captured:
                        raise RuntimeError("Platform diagnostic failed; see hardware/uart.log")
                    code = proc.poll()
                    if code is not None and (code != 0 or not (out / "program.pass").is_file()):
                        raise RuntimeError("Vivado programming failed; see hardware/program.log")
                    if banner in captured and echo_start is None:
                        echo_start = len(captured)
                        os.write(fd, b"U")
                    if b"J2 loader\r\n" in captured and not probe_sent:
                        os.write(fd, b"J2RD" + struct.pack(">II", int(profile["xipBytes"], 0), 1))
                        probe_sent = True
                    if code == 0 and echo_start is not None and echo in captured[echo_start:]:
                        report = dict(complete=True, device=device, programming="volatile JTAG",
                                      bitstream_sha256=digest, clock_hz=int(profile["clockHz"]),
                                      uart_baud=int(profile["uartBaud"]), banner=True, echo=False, loader_uart_probe=True,
                                      flash_written=False, flash_volatile_config_written=True, sf3_quad_id="20ba19", sf3_quad_xip=True, ddr_cpu=True)
                        (out / "results.json").write_text(json.dumps(report, indent=2) + "\n")
                        print("WUKONG_HARDWARE_PASS: volatile JTAG, ROM banner, SF3 quad ID/XIP, DDR CPU and loader UART")
                        return
                raise TimeoutError("Wukong programming/UART timeout; see hardware logs")
            finally:
                if proc.poll() is None:
                    proc.terminate()
                    proc.wait(timeout=10)
    finally:
        os.close(fd)
        (out / "uart.log").write_bytes(captured)


if __name__ == "__main__":
    main()
