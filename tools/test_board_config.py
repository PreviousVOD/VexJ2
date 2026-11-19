import tempfile
import unittest
from pathlib import Path
from board_config import generate, load, validate


class BoardConfigTests(unittest.TestCase):
    def test_shared_schema(self):
        tang = load("tang-primer", {})
        wukong = load("wukong-v1", {})
        self.assertEqual(tang.keys(), wukong.keys())
        self.assertEqual(tang["memoryType"], "sdram")
        self.assertEqual(wukong["memoryType"], "ddr3")

    def test_override_isolation_and_bypass(self):
        env = dict(J2_CLOCK_HZ="24000000", J2_USE_PLL="0")
        self.assertEqual(load("tang-primer", env)["clockHz"], "24000000")
        self.assertEqual(load("wukong-v1", env)["clockHz"], "72000000")
        with self.assertRaises(ValueError):
            load("tang-primer", dict(J2_USE_PLL="0"))

    def test_invalid_hardware_and_flash_windows(self):
        for board in ("tang-primer", "wukong-v1"):
            for key, value in (("memoryType", "unknown"), ("memoryBytes", "0x20000000"),
                               ("xipBytes", "0x2000000"), ("memoryBase", "0x80000001")):
                with self.subTest(board=board, key=key), self.assertRaises(ValueError):
                    validate(dict(load(board, {}), **{key: value}))

    def test_generated_header_and_clock_constraints(self):
        for board in ("tang-primer", "wukong-v1"):
            with tempfile.TemporaryDirectory() as tmp:
                out = Path(tmp)
                profile = load(board, {})
                generate(profile, out)
                header = out / "rom/board.h"
                self.assertIn(f'#define J2_CLOCK_HZ {profile["clockHz"]}u', header.read_text())
                self.assertIn(profile["part"], (out / "board.tcl").read_text())
                stamp = header.stat().st_mtime_ns
                generate(profile, out)
                self.assertEqual(header.stat().st_mtime_ns, stamp)

    def test_sram_size_and_address_overlap(self):
        profile = load("wukong-v1", {})
        self.assertEqual(validate(dict(profile, sramBytes="65536"))["sramBytes"], "65536")
        for size in ("0", "2048", "49152", "0x10000000", "0x100000000"):
            with self.subTest(size=size), self.assertRaises(ValueError):
                validate(dict(profile, sramBytes=size))


if __name__ == "__main__":
    unittest.main()
