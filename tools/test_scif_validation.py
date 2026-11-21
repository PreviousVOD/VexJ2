import unittest

from scif_validation import ScifSerial


class ScriptedSerial(ScifSerial):
    def __init__(self, chunks):
        super().__init__(-1)
        self.chunks = iter(chunks)

    def fill(self, deadline):
        try:
            self.buffer.extend(next(self.chunks))
        except StopIteration:
            raise TimeoutError("no new boot banner") from None


class ScifBootSynchronizationTest(unittest.TestCase):
    def test_previous_loader_errors_do_not_fail_new_boot(self):
        serial = ScriptedSerial([
            b"Receive timeout\r\nJ2 loader\r\nwuk",
            b"ong-v1 platform ROM\r\nSend U to load\r\n",
        ])
        self.assertEqual(serial.wait_for_boot("wukong-v1"),
                         b"Receive timeout\r\nJ2 loader\r\n")
        self.assertEqual(serial.until(b"Send U to load\r\n"),
                         b"wukong-v1 platform ROM\r\nSend U to load\r\n")

    def test_failure_after_new_banner_is_still_reported(self):
        serial = ScriptedSerial([b"wukong-v1 platform ROM\r\nPlatform failure\r\n"])
        serial.wait_for_boot("wukong-v1")
        with self.assertRaisesRegex(RuntimeError, "ROM/application failure"):
            serial.until(b"Send U to load\r\n")

    def test_old_traffic_without_new_banner_cannot_pass(self):
        serial = ScriptedSerial([b"Receive timeout\r\nJ2 loader\r\n"])
        with self.assertRaises(TimeoutError):
            serial.wait_for_boot("wukong-v1")


if __name__ == "__main__":
    unittest.main()
