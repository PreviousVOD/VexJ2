#!/usr/bin/env python3

import argparse
from pathlib import Path


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--words", type=int, default=8192)
    parser.add_argument("--mif", type=Path)
    args = parser.parse_args()

    data = args.input.read_bytes()
    if len(data) > args.words * 4:
        raise ValueError(f"ROM image needs {(len(data) + 3) // 4} words, limit is {args.words}")

    words = []
    for offset in range(0, args.words * 4, 4):
        chunk = data[offset:offset + 4].ljust(4, b"\0")
        words.append(int.from_bytes(chunk, "big"))

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text("".join(f"{word:08x}\n" for word in words))
    if args.mif:
        lines = [
            f"DEPTH = {args.words};",
            "WIDTH = 32;",
            "ADDRESS_RADIX = HEX;",
            "DATA_RADIX = HEX;",
            "CONTENT BEGIN",
        ]
        lines.extend(f"{address:04x} : {word:08x};" for address, word in enumerate(words))
        lines.extend(["END;", ""])
        args.mif.parent.mkdir(parents=True, exist_ok=True)
        args.mif.write_text("\n".join(lines))


if __name__ == "__main__":
    main()
