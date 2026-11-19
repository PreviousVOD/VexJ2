import struct
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch
import xip_image


class UploadTests(unittest.TestCase):
    def run_upload(self, reject=False, receive_error=False):
        frames, markers = [], []
        image = bytes(range(256)) * 2
        def write(fd, data):
            frames.append(bytes(data))
            return len(data)
        def receive(fd, wanted, timeout, output):
            markers.append(wanted[0])
            if receive_error and wanted[0] == b"Received 000000":
                self.assertIn(b"Receive error", wanted)
                output.extend(b"Receive error")
                return output
            output.extend(b"Invalid image header" if reject and wanted[0] == b"Flash verified" else wanted[0])
            return output
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "flash.bin"
            path.write_bytes(image)
            with patch.object(xip_image.os, "open", return_value=42), \
                 patch.object(xip_image.os, "close"), \
                 patch.object(xip_image.os, "write", side_effect=write), \
                 patch.object(xip_image.tty, "setraw"), \
                 patch.object(xip_image.termios, "tcgetattr", return_value=[0]*7), \
                 patch.object(xip_image.termios, "tcsetattr"), \
                 patch.object(xip_image, "read_until", side_effect=receive):
                xip_image.upload(path, "/dev/test", wait_for_banner=False)
        self.assertEqual(b"".join(frames), b"J2UP" + struct.pack(">II", 0, len(image)) + image)
        self.assertEqual(markers, [b"Send image", b"Received 000000", b"Received 000100",
                                   b"Flash verified", b"XIP CPU tests passed"])

    def test_page_protocol(self):
        self.run_upload()

    def test_rejected_image_is_reported(self):
        with self.assertRaisesRegex(RuntimeError, "upload"):
            self.run_upload(reject=True)

    def test_receive_error_aborts_upload(self):
        with self.assertRaisesRegex(RuntimeError, "upload"):
            self.run_upload(receive_error=True)


if __name__ == "__main__":
    unittest.main()
