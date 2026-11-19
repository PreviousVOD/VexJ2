#!/usr/bin/env python3
"""Run a board-owned Tcl entry point using the Xilinx or Anlogic workflow."""
import argparse
import os
from pathlib import Path
import re
import shlex
import shutil
import subprocess
from board_config import ROOT, generate, load, tcl_quote, write_if_changed


def paths(board, profile):
    out = ROOT / "build" / board
    vendor = profile["vendor"]
    work = ROOT / profile.get("buildDirectory", str(out / ("vivado" if vendor == "xilinx" else "anlogic")))
    return dict(root=ROOT, out=out, board_dir=ROOT / "fpga" / board,
                rtl=ROOT / profile.get("rtlDirectory", str(out / "rtl")),
                work=work, reports=ROOT / profile.get("reportDirectory", str(work)))


def render_timing(template, profile):
    values = dict(profile, inputClockPeriod=f'{1e9 / int(profile["inputClockHz"], 0):.6f}',
                  clockPeriod=f'{1e9 / int(profile["clockHz"], 0):.6f}')
    active, lines = [True], []
    for line in template.splitlines():
        condition = re.fullmatch(r"@if (\w+)@", line.strip())
        if condition:
            active.append(active[-1] and int(values[condition[1]], 0) != 0)
        elif line.strip() == "@endif@":
            if len(active) == 1:
                raise ValueError("unmatched timing-template endif")
            active.pop()
        elif active[-1]:
            lines.append(re.sub(r"@(\w+)@", lambda m: values[m[1]], line))
    if len(active) != 1:
        raise ValueError("unclosed timing-template condition")
    return "\n".join(lines) + "\n"


class Flow:
    def __init__(self, args):
        self.args = args
        self.profile = load(args.board)
        self.vendor = self.profile["vendor"]
        if self.vendor not in ("xilinx", "anlogic"):
            raise ValueError("vendor must be xilinx or anlogic")
        self.p = paths(args.board, self.profile)
        self.top = self.profile["top"]
        self.script = self.p["board_dir"] / "build.tcl"
        self.config = self.p["out"] / "flow.tcl"
        self.env = dict(os.environ)
        self.env["PATH"] = str(ROOT / "tools/local/bin") + ":" + str(ROOT / "tools/local/sh-none-elf/bin") + ":" + self.env.get("PATH", "")

    def run(self, command, cwd=ROOT, env=None):
        print(f"[{cwd}] {shlex.join(map(str, command))}", flush=True)
        if not self.args.dry_run:
            subprocess.run(list(map(str, command)), cwd=cwd, env=env or self.env, check=True)

    def configure(self):
        if not self.script.is_file():
            raise ValueError(f"missing board entry point: {self.script}")
        if self.args.dry_run:
            return
        generate(self.profile, self.p["out"])
        for key in ("work", "reports", "rtl"):
            self.p[key].mkdir(parents=True, exist_ok=True)
        sources = self.profile.get("rtlSources", self.top + ".v").split(",")
        values = dict(self.p, top=self.top,
                      source_files=" ".join(tcl_quote(source) for source in sources),
                      pins_file=self.p["board_dir"] / self.profile["pinConstraints"],
                      project_file=self.p["work"] / self.profile.get("projectFile", "unused.al"),
                      timing_file=self.p["work"] / Path(self.profile.get("timingTemplate", "unused.sdc.in")).stem,
                      jtag_part=self.profile.get("jtagPart", "*"),
                      jtag_cable=self.profile.get("jtagCable", "0"))
        write_if_changed(self.config, "# Generated; board Tcl owns hardware-specific hooks.\n" +
                         "".join(f"set {key} {tcl_quote(value)}\n" for key, value in values.items()) +
                         f"source {tcl_quote(self.p['out'] / 'board.tcl')}\n")

    def generate_rtl(self):
        self.configure()
        self.run(["make", "microcode-data", "toolchain-sbt", "toolchain-sh"])
        self.run(["make", "-C", "sw/bootrom", "BOARD=" + self.args.board])
        rom = self.p["out"] / "rom/boot.hex"
        if self.args.rom:
            rom = self.p["out"] / "rom/override.hex"
            self.run(["python3", "tools/gen_verilog_rom.py", Path(self.args.rom).resolve(), rom])
        env = dict(self.env, J2_BOARD_PROPERTIES=str(self.p["board_dir"] / "board.properties"),
                   J2_SPINAL_OUT=str(self.p["rtl"]), J2_ROM_HEX=str(rom))
        self.run([ROOT / "tools/local/bin/sbt", "-batch", "runMain " + self.profile["generator"]],
                 cwd=ROOT / "spinal", env=env)

    def package_anlogic(self):
        if self.args.dry_run:
            return
        for suffix in ("*.v", "*.bin", "*.mif"):
            for source in self.p["rtl"].glob(suffix):
                shutil.copy2(source, self.p["work"] / source.name)
        for key in ("projectFile", "pinConstraints"):
            source = self.p["board_dir"] / self.profile[key]
            shutil.copy2(source, self.p["work"] / source.name)
        template = self.p["board_dir"] / self.profile["timingTemplate"]
        write_if_changed(self.p["work"] / template.stem, render_timing(template.read_text(), self.profile))

    def vendor_run(self, stage):
        self.configure()
        work = self.p["work"]
        if stage == "program":
            work = Path(self.args.program_dir).resolve() if self.args.program_dir else work / "program"
        marker = work / {"build": "implementation.pass", "synth": "synthesis.pass",
                         "implement": "implementation.pass", "program": "program.pass"}[stage]
        if not self.args.dry_run:
            work.mkdir(parents=True, exist_ok=True)
            if stage in ("synth", "build"):
                (self.p["work"] / "synthesis.pass").unlink(missing_ok=True)
                (self.p["work"] / "implementation.pass").unlink(missing_ok=True)
            if stage == "implement" and not (work / "synthesis.pass").is_file():
                raise ValueError("run fpga-synth successfully before fpga-impl")
            marker.unlink(missing_ok=True)
        env = dict(self.env, J2_FPGA_CONFIG=str(self.config), J2_FPGA_ACTION=stage,
                   J2_FPGA_TOOLS=str(ROOT / "tools/fpga"))
        if stage == "program":
            bitstream = Path(self.args.bitstream).resolve() if self.args.bitstream else self.p["work"] / (self.top + ".bit")
            if not self.args.dry_run:
                if not bitstream.is_file():
                    raise ValueError(f"missing bitstream: {bitstream}")
                if not self.args.bitstream and not (self.p["work"] / "implementation.pass").is_file():
                    raise ValueError("default bitstream has no successful implementation marker")
            env["J2_FPGA_BITSTREAM"] = str(bitstream)
        if self.vendor == "xilinx":
            command = ["bash", ROOT / "tools/run_vivado.sh", "-mode", "batch", "-notrace", "-source", self.script,
                       "-log", stage + ".vivado.log", "-journal", stage + ".jou"]
        else:
            td = self.env.get("TD_BIN") or (str(Path(self.env["TD_HOME"]) / "bin/td") if self.env.get("TD_HOME") else "td")
            env.setdefault("QT_QPA_PLATFORM", "offscreen")
            command = [td, self.script]
        self.run(command, cwd=work, env=env)
        if not self.args.dry_run and (not marker.is_file() or not marker.stat().st_size):
            raise RuntimeError(f"vendor tool did not produce {marker}")

    def execute(self):
        action = self.args.action
        if self.vendor == "anlogic" and action in ("synth", "implement"):
            raise ValueError("Anlogic uses an integrated synthesis/implementation flow; use fpga")
        if action in ("synth", "build") and not self.args.dry_run:
            # A failed ROM/RTL generation must not leave a stale build-success marker.
            for marker in ("synthesis.pass", "implementation.pass"):
                (self.p["work"] / marker).unlink(missing_ok=True)
        if action in ("generate", "synth", "build"):
            self.generate_rtl()
        if action == "generate":
            return
        if self.vendor == "anlogic" and action == "build":
            self.package_anlogic()
        self.vendor_run(action)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--board", required=True)
    parser.add_argument("action", choices=("generate", "synth", "implement", "build", "program"))
    parser.add_argument("--rom", help="optional replacement boot ROM binary")
    parser.add_argument("--bitstream", help="explicit bitstream for volatile programming")
    parser.add_argument("--program-dir", help="programming logs and completion marker directory")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    Flow(args).execute()


if __name__ == "__main__":
    main()
