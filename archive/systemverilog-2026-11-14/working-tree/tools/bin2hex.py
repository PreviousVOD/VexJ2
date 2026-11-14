#!/usr/bin/env python3
"""Convert a raw big-endian binary image into $readmemh format (32-bit words)."""
import sys

def main():
    if len(sys.argv) < 3:
        sys.exit('usage: bin2hex.py <in.bin> <out.hex> [words]')
    data = open(sys.argv[1], 'rb').read()
    data += b'\0' * (-len(data) % 4)
    words = int(sys.argv[3], 0) if len(sys.argv) > 3 else len(data) // 4
    with open(sys.argv[2], 'w') as f:
        for i in range(words):
            w = data[4 * i:4 * i + 4] if 4 * i < len(data) else b'\0\0\0\0'
            f.write('%08x\n' % int.from_bytes(w, 'big'))

if __name__ == '__main__':
    main()
