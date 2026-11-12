#!/usr/bin/env python3
"""Post-process 'ghdl --synth --out=verilog' output.

GHDL names the nets of instance ports <instance>_<port>. When that equals a
port of the enclosing entity (e.g. instance 'flash' port 'cs' in an entity
with port 'flash_cs'), it emits a duplicate 'wire <name>;' and a self
assignment 'assign <name> = <name>;'. The instance already drives the port,
so both lines are removed.
"""
import re
import sys

def fix(text):
    out = []
    ports = set()
    in_header = False
    for line in text.splitlines(keepends=True):
        if line.startswith('module '):
            ports = set()
            in_header = True
        if in_header:
            m = re.match(r'\s*(?:input|output|inout)\s+(?:\[[^\]]*\]\s*)?(\w+)', line)
            if m:
                ports.add(m.group(1))
            if ');' in line:
                in_header = False
            out.append(line)
            continue
        m = re.match(r'\s*wire\s+(?:\[[^\]]*\]\s*)?(\w+);', line)
        if m and m.group(1) in ports:
            continue
        m = re.match(r'\s*assign\s+(\w+)\s*=\s*(\w+);', line)
        if m and m.group(1) == m.group(2) and m.group(1) in ports:
            continue
        out.append(line)
    return ''.join(out)

if __name__ == '__main__':
    path = sys.argv[1]
    with open(path) as f:
        text = f.read()
    with open(path, 'w') as f:
        f.write(fix(text))
