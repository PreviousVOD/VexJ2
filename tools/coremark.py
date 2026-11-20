#!/usr/bin/env python3
"""Build provenance, CRC validation, and matched J2 CoreMark runs."""
from board_config import load as load_board
import argparse
import contextlib
import hashlib
import json
import os
from pathlib import Path
import re
import select
import shutil
import subprocess
import termios
import time
import tty

ROOT = Path(__file__).resolve().parents[1]
COMPLETE = b"J2 CoreMark complete"
SHORT_WARNING = "ERROR! Must execute for at least 10 secs for a valid result!"
EXPECTED = {
    "performance": (0xe9f5, 0xe714, 0x1fd7, 0x8e3a),
    "validation": (0x18f2, 0xe3c1, 0x0747, 0x8d84),
}


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def check_sources():
    directory = ROOT / "third_party/coremark"
    upstream = json.loads((directory / "UPSTREAM.json").read_text())
    for name, digest in upstream["sha256"].items():
        if sha(directory / name) != digest:
            raise ValueError(f"upstream CoreMark source changed: {name}")
    return upstream


def environment_hashes(board="tang-primer"):
    files = list((ROOT / "spinal/src/main/scala/j2/periph").glob("*.scala"))
    files += list((ROOT / "spinal/src/main/scala/j2/board").rglob("*.scala"))
    files += [ROOT / f"fpga/{board}/board.properties", ROOT / "tools/board_config.py"]
    files += list((ROOT / "verilog/verif").glob("*_model.v"))
    files += list((ROOT / "third_party/qspiflash/bench/cpp").glob("flashsim.*"))
    files += [ROOT / "sw/bootrom/Makefile", ROOT / "sw/bootrom/uart.c"]
    files += list((ROOT / "sw/include").glob("*.h"))
    return {str(p.relative_to(ROOT)): sha(p) for p in sorted(files)}


def parse_result(text, run, iterations, clock_hz, require_duration=True):
    """Require ten measured seconds unless explicitly running a short regression."""
    text = text.replace("\r", "")
    if "J2 CoreMark complete" not in text or "J2 timer error" in text:
        raise ValueError("incomplete run or invalid timer")
    errors = [line for line in text.splitlines() if "ERROR" in line]
    if any(line != SHORT_WARNING for line in errors):
        raise ValueError("CoreMark validation errors: " + str(errors))

    def number(key, base=10):
        values = re.findall(r"^" + re.escape(key) + r"\s*:\s*(\w+)\s*$", text, re.M)
        if len(values) != 1:
            raise ValueError(f"missing/duplicate field {key}")
        return int(values[0], base)

    ticks = number("Total ticks")
    if not 0 < ticks < 0xffffffff:
        raise ValueError("timer is zero or saturated")
    if number("Timer Hz") != 1000000 or number("Clock Hz") != clock_hz:
        raise ValueError("clock/timer configuration mismatch")
    if number("Iterations") != iterations or number("CoreMark Size") != 666:
        raise ValueError("iteration count or data size mismatch")
    crcs = [number(key, 16) for key in ["seedcrc", "[0]crclist", "[0]crcmatrix", "[0]crcstate"]]
    if tuple(crcs) != EXPECTED[run]:
        raise ValueError(f"incorrect {run} CRCs: {crcs}")
    full = ticks >= 10000000
    if full and (errors or "Correct operation validated." not in text or "Errors detected" in text):
        raise ValueError("upstream validation did not succeed")
    if not full and (errors != [SHORT_WARNING] or "Errors detected" not in text):
        raise ValueError("unexpected short-run validation status")
    if require_duration and not full:
        raise ValueError("CoreMark run must last at least ten seconds; increase --iterations")
    seconds = ticks / 1000000
    return dict(run=run, iterations=iterations, ticks=ticks, timer_hz=1000000,
                clock_hz=clock_hz, seconds=seconds, crc_valid=True,
                seedcrc=crcs[0], crclist=crcs[1], crcmatrix=crcs[2], crcstate=crcs[3],
                crcfinal=number("[0]crcfinal", 16), reportable_duration=full,
                iterations_per_second=iterations / seconds,
                coremark_per_mhz=(iterations / seconds) / (clock_hz / 1000000))


def validate_cmt_interrupts(text, result):
    counts = re.findall(r"^CMT interrupts:\s*(\d+)\s*$", text.replace("\r", ""), re.M)
    if len(counts) != 1:
        raise ValueError("missing/duplicate CMT ISR count")
    count = int(counts[0])
    if result["reportable_duration"] and count < 2:
        raise ValueError("timed run did not service repeated CMT interrupts")
    # stop_time may account for one final pending wrap without running its ISR.
    # Allow a one-wrap difference, including microsecond conversion rounding.
    wraps = result["ticks"] * result["clock_hz"] // (1000000 * 512 * 65536)
    if abs(count - wraps) > 1:
        raise ValueError("CMT ISR count disagrees with elapsed timer ticks")
    return count


def program_loader(device, log_path, timeout):
    """Capture boot and enter the loader before the previously installed app runs."""
    fd = os.open(device, os.O_RDWR | os.O_NOCTTY | os.O_NONBLOCK)
    output = bytearray()
    try:
        tty.setraw(fd)
        attrs = termios.tcgetattr(fd)
        attrs[4] = attrs[5] = termios.B19200
        termios.tcsetattr(fd, termios.TCSANOW, attrs)
        termios.tcflush(fd, termios.TCIFLUSH)
        with log_path.with_suffix(".program.log").open("w") as log:
            proc = subprocess.Popen([str(ROOT / "tools/program_tang_primer_verilog_td.sh")],
                                    cwd=ROOT, stdout=log, stderr=subprocess.STDOUT)
            try:
                deadline = time.monotonic() + timeout
                requested = False
                while time.monotonic() < deadline:
                    ready, _, _ = select.select([fd], [], [], 0.1)
                    if ready:
                        output.extend(os.read(fd, 4096))
                    if b"Send U to load" in output and not requested:
                        os.write(fd, b"U")
                        requested = True
                    code = proc.poll()
                    if code is not None and code != 0:
                        raise RuntimeError("FPGA programming failed")
                    if code == 0 and b"J2 loader" in output:
                        return
                raise TimeoutError("FPGA did not enter UART loader")
            finally:
                if proc.poll() is None:
                    proc.terminate()
                    proc.wait(timeout=10)
    finally:
        log_path.with_suffix(".boot.log").write_bytes(output)
        os.close(fd)


def run_suite(args):
    upstream = check_sources()
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=True)
    (out / "results.json").unlink(missing_ok=True)
    board = args.board
    profile = load_board(board)
    clock_hz = int(profile["clockHz"])
    device = args.device or profile["uartDevice"]
    if args.command == "sim" and board != "tang-primer":
        raise ValueError("native CoreMark simulation currently supports Tang Primer only")
    report = dict(source_revision=subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=ROOT, text=True).strip(),
                  source_diff_sha256=hashlib.sha256(subprocess.check_output(["git", "diff", "HEAD"], cwd=ROOT)).hexdigest(),
                  upstream_revision=upstream["revision"], mode=args.command, board=board,
                  compiler=subprocess.check_output([os.environ.get("CROSS", "sh-none-elf-") + "gcc", "--version"], text=True).splitlines()[0],
                  clock_hz=clock_hz, memory="code/rodata SPI XIP; data/stack SRAM", results=[])
    report["memory_environment_sha256"] = environment_hashes(board)
    subprocess.run(["git", "archive", "--format=tar.gz", "--output=" + str(out / "source.tar.gz"), "HEAD"],
                   cwd=ROOT, check=True)
    if args.command == "hardware":
        from fpga import paths
        board_paths = paths(board, profile)
        rtl = board_paths["rtl"]
        bitstream = board_paths["work"] / (profile["top"] + ".bit")
        report["bitstream_sha256"] = sha(bitstream)
        shutil.copy2(bitstream, out / bitstream.name)
        if profile["vendor"] == "anlogic":
            timing = board_paths["reports"] / (profile["top"] + "_timing.txt")
            summaries = re.findall(r"(\d+) errors detected", timing.read_text())
            if not summaries or any(int(x) for x in summaries):
                raise ValueError("FPGA timing has not passed")
            reports = [timing, board_paths["reports"] / (profile["top"] + "_area.txt")]
        else:
            timing = board_paths["work"] / "timing_routed.rpt"
            if not (board_paths["work"] / "implementation.pass").is_file():
                raise ValueError("FPGA implementation has not passed")
            if "All user specified timing constraints are met." not in timing.read_text():
                raise ValueError("FPGA timing has not passed")
            reports = [timing]
        for path in reports:
            shutil.copy2(path, out / path.name)
    else:
        rtl = ROOT / "build/spinal/verilog"
    shutil.copytree(rtl, out / "rtl", dirs_exist_ok=True)
    report["rtl_sha256"] = {p.name: sha(p) for p in sorted(rtl.glob("*")) if p.is_file()}
    (out / "source.patch").write_bytes(subprocess.check_output(["git", "diff", "HEAD"], cwd=ROOT))
    for directory in ("sw/coremark", "third_party/coremark", "sw/bootrom", "sw/include", "spinal/src"):
        shutil.copytree(ROOT / directory, out / "source" / directory, dirs_exist_ok=True)
    shutil.copy2(__file__, out / "source/coremark.py")
    for run in ("performance", "validation"):
        firmware = ROOT / f"build/sw/coremark/{board}/{clock_hz}/{run}-{args.iterations}"
        shutil.copytree(firmware, out / run, dirs_exist_ok=True)
        log_path = out / (run + ".log")
        print(f"Running {args.command} {run}, {args.iterations} iterations", flush=True)
        if args.command == "sim":
            sim = ROOT / "build/verilog/xip_verif/Vj2_tang_primer"
            with log_path.open("w") as log:
                subprocess.run([str(sim), str(firmware / "flash.bin"), "--cold-boot", "--expect", COMPLETE.decode(),
                                "--max-cycles", str(args.max_cycles)], cwd=sim.parent,
                               stdout=log, stderr=subprocess.STDOUT, timeout=args.timeout, check=True)
        elif board == "wukong-v1":
            if device != profile["uartDevice"]:
                raise ValueError("Wukong UART device is selected by its board profile")
            with log_path.open("w") as log:
                subprocess.run(["python3", str(ROOT / "tools/check_wukong_boot.py"),
                                "--upload", "--image", str(firmware / "flash.bin"),
                                "--expect", COMPLETE.decode(), "--timeout", str(args.timeout),
                                "--output", str(out / (run + "-board"))],
                               cwd=ROOT, stdout=log, stderr=subprocess.STDOUT, check=True,
                               timeout=args.timeout + 180)
        else:
            program_loader(device, log_path, 90)
            import xip_image
            with log_path.open("w") as log, contextlib.redirect_stdout(log):
                xip_image.upload(firmware / "flash.bin", device, False, COMPLETE, args.timeout)
        result = parse_result(log_path.read_text(), run, args.iterations, clock_hz,
                              not args.allow_short)
        result["cmt_interrupts"] = validate_cmt_interrupts(log_path.read_text(), result)
        result["firmware_sha256"] = sha(firmware / "flash.bin")
        result["compiler_flags"] = re.search(r"Compiler flags\s*:\s*([^\r\n]+)", log_path.read_text())[1]
        report["results"].append(result)
        (out / "results.json").write_text(json.dumps(report, indent=2) + "\n")
        print(json.dumps(result), flush=True)
    report["complete"] = True
    (out / "results.json").write_text(json.dumps(report, indent=2) + "\n")


def compare(baseline, candidate):
    left, right = [json.loads(p.read_text()) for p in (baseline, candidate)]
    if left.get("board", "tang-primer") != right.get("board", "tang-primer"):
        raise ValueError("unmatched board")
    for key in ("upstream_revision", "compiler", "clock_hz", "memory", "mode", "memory_environment_sha256"):
        if left[key] != right[key]:
            raise ValueError("unmatched " + key)
    if not left.get("complete") or not right.get("complete"):
        raise ValueError("comparison requires complete suites")
    for report in (left, right):
        if [r["run"] for r in report["results"]] != ["performance", "validation"]:
            raise ValueError("comparison requires both seed sets")
    for a, b in zip(left["results"], right["results"]):
        for key in ("run", "iterations", "firmware_sha256", "compiler_flags", "seedcrc", "crclist", "crcmatrix", "crcstate", "crcfinal"):
            if a[key] != b[key]:
                raise ValueError("unmatched workload: " + key)
        print(json.dumps(dict(run=a["run"], baseline_ticks=a["ticks"], candidate_ticks=b["ticks"],
                              speedup=a["ticks"] / b["ticks"])))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    commands.add_parser("check-sources")
    for name in ("sim", "hardware"):
        p = commands.add_parser(name)
        p.add_argument("--iterations", type=int, default=300)
        p.add_argument("--output", type=Path, required=True)
        p.add_argument("--timeout", type=int, default=1800 if name == "sim" else 300,
                       help="Wall-clock timeout per seed set (simulated time is checked separately)")
        p.add_argument("--max-cycles", type=int, default=2000000000)
        p.add_argument("--board", choices=("tang-primer", "wukong-v1"), default="tang-primer")
        p.add_argument("--device", help="override the Tang UART device")
        p.add_argument("--allow-short", action="store_true", help="Calibration only; not a reportable score")
    p = commands.add_parser("compare")
    p.add_argument("baseline", type=Path)
    p.add_argument("candidate", type=Path)
    args = parser.parse_args()
    if args.command == "check-sources":
        print("CoreMark upstream sources verified: " + check_sources()["revision"])
    elif args.command == "compare":
        compare(args.baseline, args.candidate)
    else:
        if args.iterations < 1:
            parser.error("iterations must be positive")
        run_suite(args)


if __name__ == "__main__":
    main()
