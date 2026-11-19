#!/usr/bin/env python3
"""Exercise the exact firmware parser on the host, plus the uploader validator."""
import ctypes
import struct
import subprocess
import tempfile
import unittest
from pathlib import Path
from check_wukong_boot import validate
from wukong_config import ROOT, load


class ImageTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.temp = tempfile.TemporaryDirectory()
        lib = Path(cls.temp.name) / "image.so"
        subprocess.run(["cc", "-shared", "-fPIC", "-Wall", "-Wextra", "-Werror",
                        "-I"+str(ROOT/"build/wukong-v1/rom"), str(ROOT/"sw/wukongrom/image.c"), "-o", str(lib)], check=True)
        cls.lib = ctypes.CDLL(str(lib))
        cls.lib.image_valid.argtypes = [ctypes.c_void_p, ctypes.c_uint32, ctypes.c_int]
        cls.lib.image_checksum.argtypes = [ctypes.c_void_p, ctypes.c_uint32]
        cls.lib.image_checksum.restype = ctypes.c_uint32
        cls.profile = load()

    @classmethod
    def tearDownClass(cls):
        cls.temp.cleanup()

    def image(self, payload=b"\x00\x09", **fields):
        values = dict(magic=0x4a325831, entry=0x10000020, length=len(payload), checksum=sum(payload), load=0x10000020, r0=0, r1=0, r2=0)
        values.update(fields)
        return struct.pack(">8I", *values.values()) + payload

    def check(self, data, expected):
        buf = ctypes.create_string_buffer(data)
        self.assertEqual(bool(self.lib.image_valid(buf, len(data), 1)), expected)
        if expected:
            validate(data, self.profile)
        else:
            with self.assertRaises(ValueError): validate(data, self.profile)

    def test_boundaries_and_wrap(self):
        self.check(self.image(), True)
        for address in [0x80000000, 0x80400000, 0x8ffffffe]:
            self.check(self.image(load=address, entry=address), True)
        for fields in [dict(magic=0), dict(r0=1), dict(r1=1), dict(r2=1), dict(length=0),
                       dict(length=1), dict(length=0xffffffff), dict(entry=0x10000021),
                       dict(entry=0x10000022), dict(entry=0), dict(load=0x10000022),
                       dict(load=0x80000001, entry=0x80000002), dict(load=0x7ffffffe,entry=0x7ffffffe),
                       dict(load=0x90000000,entry=0x90000000), dict(load=0xfffffffe,entry=0xfffffffe)]:
            with self.subTest(fields=fields): self.check(self.image(**fields), False)
        self.check(self.image(b"1234",load=0x8ffffffe,entry=0x8ffffffe),False)
        self.check(self.image(b"123"),True)
        self.check(self.image(b"123",entry=0x10000022),False)
        self.check(b"short",False)
        self.check(self.image()+b"padding",False)

    def test_partition_limit_and_checksum(self):
        image=self.image(bytes([255])*((1<<20)-32))
        self.check(image,True)
        self.check(self.image(bytes(1<<20)),False)
        payload=ctypes.create_string_buffer(image[32:])
        self.assertEqual(self.lib.image_checksum(payload,len(image)-32),sum(image[32:]))
        with self.assertRaises(ValueError): validate(self.image(checksum=0),self.profile)
        # Boot validation accepts partition padding while upload requires exact size.
        buf=ctypes.create_string_buffer(self.image())
        self.assertEqual(self.lib.image_valid(buf,1<<20,0),1)


if __name__ == "__main__":
    unittest.main()
