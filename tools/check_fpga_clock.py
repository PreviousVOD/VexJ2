#!/usr/bin/env python3
"""Measure the generated FPGA PLL with Anlogic's model (not the RTL bypass)."""

import argparse
import os
from pathlib import Path
import re
import subprocess


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--rtl", type=Path, required=True)
    parser.add_argument("--td-home", type=Path, required=True)
    parser.add_argument("--clock-hz", type=int, required=True)
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    output = root / "build/verilog/pll_verif"
    output.mkdir(parents=True, exist_ok=True)
    match = re.search(r"  EG_PHY_PLL #\(.*?\n  \) eg4Pll \(.*?\n  \);", args.rtl.read_text(), re.S)
    if not match:
        parser.error("RTL must contain the FPGA PLL instance; generate with J2_FPGA=1 J2_USE_PLL=1")

    # TD 4.6.7's model reuses the input name load_reg for an internal 5-bit
    # signal. Rename only that internal net in a build-directory copy so that
    # Verilator accepts it. Leave clock generation and divider logic unchanged.
    model = (args.td_home / "sim/eg/eg_phy_pll.v").read_text()
    model = model.replace("sclk, load_reg, rotate", "sclk, load_reg_internal, rotate")
    model = model.replace("assign load_reg  =", "assign load_reg_internal  =")
    model = model.replace("shot(load_reg[", "shot(load_reg_internal[")
    (output / "eg_phy_pll.v").write_text(model)
    expected = 1e9 / args.clock_hz
    (output / "pll_probe.v").write_text(f"""`timescale 1ns/1ps
module pll_probe;
  reg clk24 = 0;
  always #20.833333 clk24 = ~clk24;
  wire [4:0] eg4Pll_clkc;
  wire eg4Pll_extlock, eg4Pll_psdone;
  wire [7:0] eg4Pll_do;
  wire eg4Bufg_o = eg4Pll_clkc[0];
{match.group()}
  real start_time, period;
  initial begin
    #10000;
    @(posedge eg4Pll_clkc[0]);
    start_time = $realtime;
    repeat (100) @(posedge eg4Pll_clkc[0]);
    period = ($realtime - start_time) / 100.0;
    $display("PLL period: %.6f ns; expected {expected:.6f} ns; locked=%b", period, eg4Pll_extlock);
    if (!eg4Pll_extlock || period < {expected - 0.05:.6f} || period > {expected + 0.05:.6f}) begin
      $display("FAIL: FPGA PLL frequency does not match J2_CLOCK_HZ");
      $stop;
    end
    $finish;
  end
  initial begin #100000; $display("FAIL: PLL did not start"); $stop; end
endmodule
""")
    env = dict(os.environ)
    env.setdefault("CCACHE_DIR", str(output / "ccache"))
    command = [str(root / "tools/local/bin/verilator"), "--binary", "--timing",
               "--language", "1364-2005", "-Wno-fatal", "-Wno-lint", "-Wno-BLKANDNBLK",
               "--top-module", "pll_probe", "--Mdir", str(output / "obj"), "-j", "4",
               str(output / "pll_probe.v"), str(output / "eg_phy_pll.v")]
    with (output / "build.log").open("w") as log:
        result = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT, env=env)
    if result.returncode:
        raise RuntimeError(f"PLL model build failed; see {output / 'build.log'}")
    subprocess.run([str(output / "obj/Vpll_probe")], check=True)


if __name__ == "__main__":
    main()
