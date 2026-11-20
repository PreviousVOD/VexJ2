import contextlib
import copy
import io
import json
from pathlib import Path
import tempfile
import unittest

from coremark import compare, parse_result, validate_cmt_interrupts


def output(ticks=12000000):
    status = ("Correct operation validated. See README.md for run and reporting rules."
              if ticks >= 10000000 else
              "ERROR! Must execute for at least 10 secs for a valid result!\nErrors detected")
    return f"""J2 CoreMark start
Clock Hz: 32000000
Timer Hz: 1000000
CoreMark Size    : 666
Total ticks      : {ticks}
Iterations       : 10
seedcrc          : 0xe9f5
[0]crclist       : 0xe714
[0]crcmatrix     : 0x1fd7
[0]crcstate      : 0x8e3a
[0]crcfinal      : 0x1234
{status}
J2 CoreMark complete
"""


class ResultValidation(unittest.TestCase):
    def parse(self, text, **kwargs):
        return parse_result(text, "performance", 10, 32000000, **kwargs)

    def test_full_run_uses_timer_ticks(self):
        result = self.parse(output(), require_duration=True)
        self.assertEqual(result["seconds"], 12)
        self.assertAlmostEqual(result["iterations_per_second"], 10 / 12)

    def test_short_run_is_only_a_regression(self):
        self.assertFalse(self.parse(output(100), require_duration=False)["reportable_duration"])
        with self.assertRaises(ValueError):
            self.parse(output(100))

    def test_ten_second_boundary(self):
        with self.assertRaises(ValueError):
            self.parse(output(9999999))
        self.assertTrue(self.parse(output(10000000))["reportable_duration"])

    def test_corrupt_crc_fails_even_with_completion_marker(self):
        with self.assertRaises(ValueError):
            self.parse(output().replace("0xe714", "0xdead"))

    def test_timeout_or_truncated_output_fails(self):
        with self.assertRaises(ValueError):
            self.parse(output().replace("J2 CoreMark complete", ""))

    def test_zero_or_saturated_timer_fails(self):
        for ticks in (0, 0xffffffff):
            with self.subTest(ticks=ticks), self.assertRaises(ValueError):
                self.parse(output(ticks))

    def test_unexpected_error_fails(self):
        with self.assertRaises(ValueError):
            self.parse(output(100) + "ERROR! CoreMark aborted\n")

    def test_wrong_configuration_fails(self):
        for original, replacement in (("32000000", "30000000"),
                                      ("Iterations       : 10", "Iterations       : 11"),
                                      ("Timer Hz: 1000000", "Timer Hz: 32000000")):
            with self.subTest(original=original), self.assertRaises(ValueError):
                self.parse(output().replace(original, replacement))

    def test_duplicate_field_fails(self):
        with self.assertRaises(ValueError):
            self.parse(output() + "Total ticks : 12000000\n")

    def test_wukong_clock_and_rate(self):
        text = output().replace("32000000", "72000000")
        result = parse_result(text, "performance", 10, 72000000)
        self.assertAlmostEqual(result["coremark_per_mhz"], 10 / 12 / 72)
        with self.assertRaises(ValueError):
            self.parse(text)

    def test_cmt_interrupts_match_clock_and_duration(self):
        for clock, count in ((32000000, 11), (72000000, 25)):
            with self.subTest(clock=clock):
                result = parse_result(output().replace("32000000", str(clock)),
                                      "performance", 10, clock)
                self.assertEqual(validate_cmt_interrupts(f"CMT interrupts: {count}\r\n", result), count)
                # A final pending wrap need not have entered its handler.
                self.assertEqual(validate_cmt_interrupts(f"CMT interrupts: {count - 1}\n", result), count - 1)
                for text in ("", "CMT interrupts: 0\n", "CMT interrupts: 99\n",
                             f"CMT interrupts: {count}\nCMT interrupts: {count}\n"):
                    with self.subTest(text=text), self.assertRaises(ValueError):
                        validate_cmt_interrupts(text, result)

    def test_short_regression_need_not_wrap(self):
        result = self.parse(output(100), require_duration=False)
        self.assertEqual(validate_cmt_interrupts("CMT interrupts: 0\n", result), 0)


class MatchedComparison(unittest.TestCase):
    def fixture(self):
        report = dict(upstream_revision="pinned", compiler="GCC", clock_hz=32000000,
                      memory="XIP/SRAM", mode="hardware", memory_environment_sha256={},
                      complete=True, results=[])
        for run in ("performance", "validation"):
            report["results"].append(dict(run=run, iterations=10, firmware_sha256="same",
                                          compiler_flags="-O2", seedcrc=1, crclist=2,
                                          crcmatrix=3, crcstate=4, crcfinal=5, ticks=12000000))
        return report

    def check(self, left, right):
        with tempfile.TemporaryDirectory() as directory:
            a, b = [Path(directory) / name for name in ("a.json", "b.json")]
            a.write_text(json.dumps(left))
            b.write_text(json.dumps(right))
            with contextlib.redirect_stdout(io.StringIO()) as output:
                compare(a, b)
            return [json.loads(line) for line in output.getvalue().splitlines()]

    def test_matched_workloads_compare_timer_ticks(self):
        a = self.fixture()
        b = copy.deepcopy(a)
        b["results"][0]["ticks"] = 6000000
        self.assertEqual(self.check(a, b)[0]["speedup"], 2)

    def test_changed_firmware_is_rejected(self):
        a = self.fixture()
        b = copy.deepcopy(a)
        b["results"][0]["firmware_sha256"] = "different"
        with self.assertRaises(ValueError):
            self.check(a, b)

    def test_missing_seed_set_is_rejected(self):
        a = self.fixture()
        b = copy.deepcopy(a)
        b["results"].pop()
        with self.assertRaises(ValueError):
            self.check(a, b)

    def test_changed_memory_environment_is_rejected(self):
        a = self.fixture()
        b = copy.deepcopy(a)
        b["memory_environment_sha256"] = {"SPI": "different"}
        with self.assertRaises(ValueError):
            self.check(a, b)

    def test_changed_board_is_rejected_even_at_same_clock(self):
        a = self.fixture()
        b = copy.deepcopy(a)
        b["board"] = "wukong-v1"
        with self.assertRaisesRegex(ValueError, "unmatched board"):
            self.check(a, b)

    def test_legacy_reports_default_to_tang(self):
        a = self.fixture()
        b = copy.deepcopy(a)
        b["board"] = "tang-primer"
        self.assertEqual(self.check(a, b)[0]["speedup"], 1)


if __name__ == "__main__":
    unittest.main()
