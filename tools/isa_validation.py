#!/usr/bin/env python3
"""Run the same ISA application in the native SoC simulator and on Tang Primer."""
from board_config import load as load_board
import argparse
import contextlib
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import termios
import tty

from coremark import program_loader
import xip_image

ROOT = Path(__file__).resolve().parents[1]
MARKERS = (
    "Startup initialization passed",
    "APB4 subword tests passed", "XIP cache tests passed",
    "SDRAM tests passed", "CMT tests passed",
    "ISA atomics passed (SRAM/SDRAM)", "ISA word fetch passed (SRAM/SDRAM)",
    "ISA forwarding passed",
    "ISA multiply pipeline passed", "ISA MAC saturation passed", "ISA exceptions passed",
    "ISA SH-2 illegal extensions passed",
    "ISA regression tests passed", "XIP CPU tests passed",
)


def validate(text):
    for marker in MARKERS:
        if marker not in text:
            raise ValueError("missing completion marker: " + marker)
    if "FAIL" in text or "failed" in text or "Verify error" in text:
        raise ValueError("application or simulator reported a failure")


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def reboot(device, log_path, timeout):
    """Capture an independent boot from flash after volatile JTAG reconfiguration."""
    fd = os.open(device, os.O_RDWR | os.O_NOCTTY)
    try:
        tty.setraw(fd)
        attrs = termios.tcgetattr(fd)
        attrs[4] = attrs[5] = termios.B19200
        termios.tcsetattr(fd, termios.TCSANOW, attrs)
        termios.tcflush(fd, termios.TCIFLUSH)
        with log_path.with_suffix(".program.log").open("w") as program_log:
            proc = subprocess.Popen([str(ROOT / "tools/program_tang_primer_verilog_td.sh")],
                                    cwd=ROOT, stdout=program_log, stderr=subprocess.STDOUT)
            try:
                with log_path.open("w") as log, contextlib.redirect_stdout(log):
                    xip_image.read_until(fd, [MARKERS[-1].encode()], timeout, bytearray())
                if proc.wait(timeout=15):
                    raise RuntimeError("FPGA programming failed")
            finally:
                if proc.poll() is None:
                    proc.terminate()
                    proc.wait(timeout=10)
    finally:
        os.close(fd)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", choices=("sim", "hardware"))
    parser.add_argument("--device", default=load_board("tang-primer")["uartDevice"])
    parser.add_argument("--output", type=Path, default=ROOT / "build/isa-validation")
    parser.add_argument("--timeout", type=int, default=180)
    args = parser.parse_args()
    out = args.output.resolve() / args.mode
    out.mkdir(parents=True, exist_ok=True)
    result_path = out / "results.json"
    result_path.unlink(missing_ok=True)
    image = ROOT / "build/sw/xipapp/flash.bin"
    report = {"mode": args.mode, "image_sha256": digest(image), "runs": []}
    paths = list((ROOT / "spinal/src/main/scala").rglob("*.scala"))
    paths += list((ROOT / "sw/xipapp").glob("*"))
    paths += [Path(__file__), ROOT / "verilog/verif/j2_xip_sim.cpp"]
    report["source_sha256"] = {str(p.relative_to(ROOT)): digest(p) for p in paths if p.is_file()}
    if args.mode == "sim":
        sim = ROOT / "build/verilog/xip_verif/Vj2_tang_primer"
        report["simulator_sha256"] = digest(sim)
        for name, flags in (("reset", []), ("cold", ["--cold-boot"]),
                            ("loader", ["--loader", "--cold-boot"])):
            log = out / (name + ".log")
            with log.open("w") as stream:
                subprocess.run([str(sim), str(image), *flags, "--max-cycles", "200000000"],
                               cwd=sim.parent, stdout=stream, stderr=subprocess.STDOUT,
                               timeout=args.timeout, check=True)
            validate(log.read_text())
            report["runs"].append(name)
            print(name + ": PASS", flush=True)
    else:
        bitstream = ROOT / "build/fpga/tang-primer/j2_tang_primer.bit"
        report["bitstream_sha256"] = digest(bitstream)
        timing = ROOT / "build/logs/td_verilog/j2_tang_primer_timing.txt"
        errors = re.findall(r"(\d+) errors detected", timing.read_text())
        if not errors or any(int(count) for count in errors):
            raise ValueError("FPGA timing has not passed")
        report["timing_sha256"] = digest(timing)
        log = out / "upload.log"
        program_loader(args.device, log, 90)
        with log.open("w") as stream, contextlib.redirect_stdout(stream):
            xip_image.upload(image, args.device, False, MARKERS[-1].encode(), args.timeout)
        validate(log.read_text())
        report["runs"].append("upload")
        print("upload: PASS", flush=True)
        log = out / "reboot.log"
        reboot(args.device, log, args.timeout)
        validate(log.read_text())
        report["runs"].append("reboot")
        print("reboot: PASS", flush=True)
    report["complete"] = True
    result_path.write_text(json.dumps(report, indent=2) + "\n")


if __name__ == "__main__":
    main()
