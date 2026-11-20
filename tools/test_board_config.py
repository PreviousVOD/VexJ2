import tempfile
import unittest
from pathlib import Path
from board_config import generate, load, load_file, validate, tcl_quote


class BoardConfigTests(unittest.TestCase):
    def test_shared_schema(self):
        tang = load("tang-primer", {})
        wukong = load("wukong-v1", {})
        self.assertEqual(tang["memoryType"], "sdram")
        self.assertEqual(wukong["memoryType"], "ddr3")

    def test_override_isolation_and_bypass(self):
        env = dict(J2_CLOCK_HZ="24000000", J2_USE_PLL="0")
        self.assertEqual(load("tang-primer", env)["clockHz"], "24000000")
        self.assertEqual(load("wukong-v1", env)["clockHz"], "72000000")
        self.assertEqual(load("tang-primer", dict(J2_USE_PLL="0"))["usePll"], "0")

    def test_invalid_hardware_and_flash_windows(self):
        for board in ("tang-primer", "wukong-v1"):
            for key, value in (("xipBytes", "0x2000000"), ("memoryBase", "0x80000001")):
                with self.subTest(board=board, key=key), self.assertRaises(ValueError):
                    validate(dict(load(board, {}), **{key: value}))

    def test_new_board_without_registry(self):
        profile = dict(load("wukong-v1", {}), name="example-board", part="another-fpga",
                       memoryType="psram", memoryBytes="0x02000000", clockHz="40000000",
                       uartBaud="115200", clockHzEnv="EXAMPLE_CLOCK")
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "board.properties"
            path.write_text("\n".join(f"{k}={v}" for k, v in profile.items()))
            result = load_file(path, dict(EXAMPLE_CLOCK="48000000"))
            self.assertEqual(result["name"], "example-board")
            self.assertEqual(result["clockHz"], "48000000")

    def test_tcl_values_are_data(self):
        import subprocess
        value = 'part [error bad] $name "quoted" \\ path'
        script = f"set part {tcl_quote(value)}\nputs $part\n"
        result = subprocess.run(["tclsh"], input=script, text=True, capture_output=True, check=True)
        self.assertEqual(result.stdout.strip(), value)

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

    def test_boot_peripheral_address_validation(self):
        profile = load("wukong-v1", {})
        moved = validate(dict(profile, sciBase="0xff006000", cmtBase="0xff007000"))
        self.assertEqual(moved["sciBase"], "0xff006000")
        for key, value in (("sciBase", "-4096"), ("sciBase", "0xff006001"),
                           ("cmtBase", "0x100000000"), ("cmtBase", profile["sciBase"]),
                           ("sciBase", "0xffffe000")):
            with self.subTest(key=key, value=value), self.assertRaises(ValueError):
                validate(dict(profile, **{key: value}))

    def test_interrupt_sources_validate_and_generate_per_board(self):
        profile = load("tang-primer", {})
        for sources in ("", ",".join(f"IRQ_{i}" for i in range(192))):
            validate(dict(profile, interruptSources=sources))
        for sources in ("CMT0,CMT0", "CMT0,", "bad-name",
                        ",".join(f"IRQ_{i}" for i in range(193))):
            with self.subTest(sources=sources), self.assertRaises(ValueError):
                validate(dict(profile, interruptSources=sources))
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp)
            generate(dict(profile, interruptSources="SCI_RXI,CMT0,EXTRA"), out)
            header = "\n".join(" ".join(line.split()) for line in (out / "include/j2_board_irqs.h").read_text().splitlines())
            self.assertIn("#define J2_INTC_SOURCE_COUNT 3\n", header)
            self.assertIn("#define J2_IRQ_SCI_RXI 0\n", header)
            self.assertIn("#define J2_VECTOR_CMT0 65\n", header)
            self.assertNotIn("J2_IRQ_SCI_ERI", header)

    def test_relocated_header_works_in_c_and_assembly(self):
        import subprocess
        root = Path(__file__).resolve().parents[1]
        profile = validate(dict(load("wukong-v1", {}),
                                sciBase="0xff006000", cmtBase="0xff007000"))
        with tempfile.TemporaryDirectory() as tmp:
            out = Path(tmp)
            generate(profile, out)
            includes = ['-I', str(out / 'include'), '-include', str(out / 'rom/board.h'), '-I', str(root / 'sw/include')]
            source = '#include "sci.h"\n#include "cmt.h"\n#include "j2_board_irqs.h"\n'
            subprocess.run(['cc', *includes, '-x', 'c', '-c', '-o', str(out / 'c.o'), '-'],
                           input=source + '_Static_assert(SCI_BASE == 0xff006000, "SCI base");\n'
                           '_Static_assert(CMT_CMCSR_ADDRESS(1) == 0xff007008, "CMT base");\n',
                           text=True, check=True)
            subprocess.run(['cc', *includes, '-x', 'assembler-with-cpp', '-c',
                            '-o', str(out / 'asm.o'), '-'],
                           input=source + '.long SCI_BASE + SCI_SCTDR\n.long CMT_CMCSR_ADDRESS(0)\n.long J2_VECTOR_SCI_RXI\n',
                           text=True, check=True)


if __name__ == "__main__":
    unittest.main()
