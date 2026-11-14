#!/usr/bin/env python3
"""Convert the J-Core 'SH-2 Instruction Set.ods' decoder spec to CSV.

Stdlib only. Mirrors cpugen.parser/load-ods: the column count is taken from
the first non-blank header cells, and rows end after 20 consecutive blank rows.
"""
import csv
import io
import sys
import zipfile
import xml.etree.ElementTree as ET

T = '{urn:oasis:names:tc:opendocument:xmlns:table:1.0}'
TXT = '{urn:oasis:names:tc:opendocument:xmlns:text:1.0}'


def cell_text(c):
    # Join <text:p> paragraphs with newlines; expand <text:s c=N/> spaces.
    paras = []
    for p in c.iter(TXT + 'p'):
        out = []
        def walk(e):
            if e.text:
                out.append(e.text)
            for ch in e:
                if ch.tag == TXT + 's':
                    out.append(' ' * int(ch.get(TXT + 'c', '1')))
                else:
                    walk(ch)
                if ch.tail:
                    out.append(ch.tail)
        walk(p)
        paras.append(''.join(out))
    return '\n'.join(paras)


def read_rows(path):
    with zipfile.ZipFile(path) as z:
        root = ET.fromstring(z.read('content.xml'))
    table = next(root.iter(T + 'table'))
    rows = []
    for r in table.iter(T + 'table-row'):
        cells = []
        for c in r:
            if c.tag not in (T + 'table-cell', T + 'covered-table-cell'):
                continue
            rep = int(c.get(T + 'number-columns-repeated', '1'))
            txt = cell_text(c)
            cells.extend([txt] * min(rep, 256))
        rrep = int(r.get(T + 'number-rows-repeated', '1'))
        rows.extend([cells] * min(rrep, 64))
    return rows


def main():
    if len(sys.argv) != 3:
        sys.exit('usage: ods2csv.py <in.ods> <out.csv>')
    rows = read_rows(sys.argv[1])
    hdr = rows[0]
    ncols = 0
    while ncols < len(hdr) and hdr[ncols].strip():
        ncols += 1
    out = []
    blank = 0
    for r in rows:
        r = (r + [''] * ncols)[:ncols]
        if any(x.strip() for x in r):
            out.extend([[''] * ncols] * blank)
            blank = 0
            out.append(r)
        else:
            blank += 1
            if blank >= 20:
                break
    with open(sys.argv[2], 'w', newline='') as f:
        csv.writer(f, lineterminator='\n').writerows(out)
    print(f'{len(out)} rows x {ncols} cols -> {sys.argv[2]}')


if __name__ == '__main__':
    main()
