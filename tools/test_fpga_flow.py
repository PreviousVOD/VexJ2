import argparse
import contextlib
import io
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest.mock import patch
import board_config
import fpga


class FlowTests(unittest.TestCase):
    def args(self, **changes):
        values = dict(board="example-board", action="build", dry_run=True,
                      rom=None, bitstream=None, program_dir=None)
        values.update(changes)
        return argparse.Namespace(**values)

    def fixture(self, directory, vendor):
        root = Path(directory)
        board = root / "fpga/example-board"
        board.mkdir(parents=True)
        values = dict(board_config.load("tang-primer", {}), name="example-board", vendor=vendor,
                      generator="example.Generate", top="example_top", part="different-part")
        for key in ("buildDirectory", "reportDirectory", "rtlDirectory", "clockHzEnv", "usePllEnv"):
            values.pop(key, None)
        (board / "board.properties").write_text("\n".join(f"{k}={v}" for k, v in values.items()))
        (board / "build.tcl").write_text(f'source [file join $::env(J2_FPGA_TOOLS) {vendor}.tcl]\nfpga_run\n')
        return root, board

    def test_new_boards_use_either_vendor_without_registry(self):
        for vendor in ("xilinx", "anlogic"):
            with self.subTest(vendor=vendor), tempfile.TemporaryDirectory() as tmp:
                root, board = self.fixture(tmp, vendor)
                with patch.object(fpga, "ROOT", root), patch.object(board_config, "ROOT", root):
                    flow = fpga.Flow(self.args())
                    output = io.StringIO()
                    with contextlib.redirect_stdout(output):
                        flow.execute()
                    self.assertIn("example.Generate", output.getvalue())
                    self.assertIn(str(board / "build.tcl"), output.getvalue())
                    self.assertFalse((root / "build").exists(), "dry-run must not produce outputs")

    def test_anlogic_timing_uses_profile_and_handles_bypass(self):
        template = (board_config.ROOT / "fpga/tang-primer/j2_tang_primer.sdc.in").read_text()
        profile = board_config.load("tang-primer", {})
        self.assertIn("31.250000", fpga.render_timing(template, profile))
        bypass = fpga.render_timing(template, dict(profile, clockHz="24000000", usePll="0"))
        self.assertNotIn("soc_clk", bypass)
        self.assertIn("41.666667", bypass)

    def test_missing_completion_marker_is_not_success(self):
        with tempfile.TemporaryDirectory() as tmp:
            root, _ = self.fixture(tmp, "xilinx")
            with patch.object(fpga, "ROOT", root), patch.object(board_config, "ROOT", root):
                flow = fpga.Flow(self.args(dry_run=False, action="synth"))
                with patch.object(flow, "run"):
                    with self.assertRaisesRegex(RuntimeError, "synthesis.pass"):
                        flow.vendor_run("synth")

    def test_generation_failure_invalidates_old_bitstream_marker(self):
        with tempfile.TemporaryDirectory() as tmp:
            root, _ = self.fixture(tmp, "xilinx")
            with patch.object(fpga, "ROOT", root), patch.object(board_config, "ROOT", root):
                flow = fpga.Flow(self.args(dry_run=False))
                flow.p["work"].mkdir(parents=True)
                marker = flow.p["work"] / "implementation.pass"
                marker.write_text("old success")
                with patch.object(flow, "generate_rtl", side_effect=RuntimeError("generation failed")):
                    with self.assertRaises(RuntimeError):
                        flow.execute()
                self.assertFalse(marker.exists())

    def test_xdc_clock_variables_are_visible_during_synthesis(self):
        tools_dir = board_config.ROOT / "tools/fpga"
        with tempfile.TemporaryDirectory() as tmp:
            root, board = self.fixture(tmp, "xilinx")
            with patch.object(fpga, "ROOT", root), patch.object(board_config, "ROOT", root):
                flow = fpga.Flow(self.args(dry_run=False, action="synth"))
                flow.configure()
            harness = root / "synth.tcl"
            harness.write_text('''
proc unknown {args} { return {} }
proc synth_design {args} {
    uplevel 1 {
        if {![info exists board_clock_period]} { error "XDC cannot see board clock" }
    }
}
source $::env(BOARD_ENTRY)
''')
            env = dict(os.environ, J2_FPGA_CONFIG=str(flow.config), J2_FPGA_ACTION="synth",
                       J2_FPGA_TOOLS=str(tools_dir), BOARD_ENTRY=str(board / "build.tcl"))
            subprocess.run(["tclsh", str(harness)], cwd=root, env=env, check=True)
            self.assertTrue((flow.p["work"] / "synthesis.pass").is_file())

    def test_generic_xilinx_programming_entry_and_marker(self):
        tools_dir = board_config.ROOT / "tools/fpga"
        with tempfile.TemporaryDirectory() as tmp:
            root, board = self.fixture(tmp, "xilinx")
            with patch.object(fpga, "ROOT", root), patch.object(board_config, "ROOT", root):
                flow = fpga.Flow(self.args(dry_run=False, action="program"))
                flow.configure()
            harness = root / "program.tcl"
            harness.write_text('''
proc open_hw_manager {} {}
proc connect_hw_server {} {}
proc get_hw_targets {} { return cable }
proc current_hw_target {args} {}
proc open_hw_target {} {}
proc get_hw_devices {args} { return device }
proc current_hw_device {args} {}
proc set_property {args} {}
proc program_hw_devices {args} {}
proc refresh_hw_device {args} {}
proc close_hw_manager {} {}
source $::env(BOARD_ENTRY)
''')
            env = dict(os.environ, J2_FPGA_CONFIG=str(flow.config), J2_FPGA_ACTION="program",
                       J2_FPGA_TOOLS=str(tools_dir), J2_FPGA_BITSTREAM="validated.bit",
                       BOARD_ENTRY=str(board / "build.tcl"))
            subprocess.run(["tclsh", str(harness)], cwd=root, env=env, check=True)
            self.assertEqual((root / "program.pass").read_text().strip(), "FPGA_PROGRAM_PASS")


if __name__ == "__main__":
    unittest.main()
