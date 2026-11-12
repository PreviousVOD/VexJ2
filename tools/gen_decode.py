#!/usr/bin/env python3
"""J2 instruction decoder generator.

Replaces the Clojure/vMAGIC generator in
reference/soc_top/components/cpu/decode/gen. Reads spec/j2_isa.csv (converted
from 'SH-2 Instruction Set.ods' by ods2csv.py) and emits:

  rtl/core/j2_decode_table.sv   combinational decode table (op -> controls)
  sim/gen/j2_isa_table.inc      opcode match table for the C++ disassembler/ISS

Semantics follow cpugen/parser.clj (spreadsheet parsing), vhdlmicrocode.clj
(gen-assigns: slot -> control assignments) and genvhdl.clj (simple_logic
architecture). The internal representation uses the VHDL record paths and
literal names so it can be cross-checked against the original generated
decode_table_simple.vhd with --check-vhdl.
"""
import argparse
import csv
import re
import sys

# --------------------------------------------------------------- parsing

HDR_KEYS = {
    'table': 'table', 'format': 'format', 'state': 'state',
    'instruction': 'name', 'plane': 'plane', 'op code': 'op',
    'operation': 'desc', 'xbus': 'x', 'ybus': 'y', 'func': 'func',
    'alu x': 'alux', 'alu y': 'aluy', 'zbus': 'z', 'wbus': 'w',
    'pc': 'inc-pc', 'if addy': 'if-addr', 'latch s_mac': 'latch-s-mac',
    'pr': 'pr', 'if issue': 'if-issue', 'dispatch': 'dispatch',
    'debug': 'debug', 'mac stage': 'mac-stage', 'mac busy': 'mac-busy',
    'mac op': 'mac-op', 'mac stall sense': 'mac-stall-sense',
    'macin_1': 'macin1', 'macin_2': 'macin2', 'mach': 'mach', 'macl': 'macl',
    'event': 'event', 'halt': 'halt', 'ilevel capture': 'ilevel-capture',
    'delay jmp': 'delay-jump', 'ma op': 'ma-op', 'ma mask': 'ma-mask',
    'ma size': 'ma-size', 'ma data': 'ma-data', 'ma addy': 'ma-addr',
    'ma lock': 'ma-lock', 'mask int': 'mask-int',
    'zbus sel': 'zbus', 'sr': 'sr', 'arith': 'arith', 'arith sr': 'arith-sr',
    'logic': 'logic', 'logic sr': 'logic-sr', 'carryin en': 'carryin-en',
    'shift': 'shift', 'manip': 'manip',
}

COMMON_KEYS = ['name', 'plane', 'op', 'desc', 'table', 'format', 'state']


class SpecError(Exception):
    pass


def parse_const(v):
    m = re.fullmatch(r'([us])(?:\s*[x*]\s*([0-9]+))?', v)
    if m:
        return ('c', m.group(1), int(m.group(2) or 1))
    m = re.fullmatch(r'[x*]\s*([0-9]+)\s*([us])', v)
    if m:
        return ('c', m.group(2), int(m.group(1)))
    m = re.fullmatch(r'([+-])?(0[xb])?([0-9]+)', v)
    if m:
        base = {'0x': 16, '0b': 2}.get(m.group(2), 10)
        return int((m.group(1) or '') + m.group(3), base)
    return None


REGISTER_MAP = {
    'r0': ('r', 0), 'rn': 'rn', 'rm': 'rm', 'r15': ('r', 15),
    'gbr': ('r', 16), 'vbr': ('r', 17), 'pr': ('r', 18),
    'temp0': ('r', 19), 'temp1': ('r', 20),
}

YES = {'yes': True, 'y': True}


def _strip_wr(v):
    return v[3:] if v.startswith('wr ') else v


def _manip(v):
    fixed = {'xtract': 'xtract', 'set b7': 'bit7'}
    if v in fixed:
        return fixed[v]
    m = re.fullmatch(r'(ext|swap) *([a-z]+[0-9]*)?', v)
    if m:
        return (m.group(1), m.group(2)) if m.group(2) else m.group(1)
    return None


SANITIZE = {
    'x': lambda v: _or(parse_const(v), {**REGISTER_MAP, 'pc': 'pc', 'const': 'const', 'w': 'w'}.get(v)),
    'y': lambda v: _or(parse_const(v), {**REGISTER_MAP, 'pc': 'pc', 'mach': 'mach', 'macl': 'macl',
                                        'const': 'const', 'sr': 'sr'}.get(v)),
    'alux': {'fc': 'fc', 'rotcl': 'rotcl', 'zero': 'zero'}.get,
    'aluy': lambda v: _or(parse_const(v), {'r0': 'r0'}.get(v)),
    'w': lambda v: {**REGISTER_MAP, 'sr': 'sr'}.get(_strip_wr(v)),
    'z': lambda v: {**REGISTER_MAP, 'pc': 'pc', 't(pc)': 'pc-t', 'nt(pc)': 'pc-nt',
                    'sr': 'sr'}.get(_strip_wr(v)),
    'pr': {'rd pc': 'pc'}.get,
    'if-addr': {'zbus': 'z'}.get,
    'ma-op': {'read': 'read', 'write': 'write'}.get,
    'ma-mask': {'t': 't', 'nt': 'nt'}.get,
    'ma-size': int,
    'ma-data': {'zbus': 'z', 'ybus': 'y'}.get,
    'ma-addr': {'zbus': 'z', 'xbus': 'x', 'ybus': 'y'}.get,
    'ma-lock': YES.get,
    'inc-pc': {'inc': True, 'hold': False}.get,
    'delay-jump': {'set': True}.get,
    'if-issue': {**YES, 't': 't', 'nt': 'nt'}.get,
    'dispatch': {**YES, 't': 't', 'nt': 'nt'}.get,
    'debug': YES.get,
    'mac-stage': {'ex': 'ex', 'wb': 'wb'}.get,
    'mac-busy': {'busy': 'busy', 'not stall': 'not-stall'}.get,
    'mac-op': {'macl': 'macl', 'macw': 'macw', 'dmulsl': 'dmulsl', 'dmulul': 'dmulul',
               'mull': 'mull', 'mulsw': 'mulsw', 'muluw': 'muluw'}.get,
    'mac-stall-sense': YES.get,
    'macin1': {'xbus': 'x', 'wbus': 'w', 'zbus': 'z'}.get,
    'macin2': {'ybus': 'y', 'wbus': 'w', 'zbus': 'z'}.get,
    'mach': {'clear': 'clear', 'load': 'load'}.get,
    'macl': {'clear': 'clear', 'load': 'load'}.get,
    'halt': {'set': True}.get,
    'event': {'ack': 'ack'}.get,
    'ilevel-capture': YES.get,
    'mask-int': YES.get,
    'zbus': {'arith': 'arith', 'logic': 'logic', 'shift': 'shift', 'manip': 'manip',
             'y': 'ybus', 'w': 'wbus'}.get,
    'sr': {'arith': 'arith', 'logic': 'logic', 'z': 'zbus', 'w': 'wbus', 'div0u': 'div0u',
           'int_mask': 'int-mask', 't=0': ('t', 'clear'), 't=1': ('t', 'set'),
           'shift': ('t', 'shift'), 'carry': ('t', 'carry')}.get,
    'arith': {'add': 'add', 'sub': 'sub'}.get,
    'arith-sr': {'ugrter_eq': 'u>=', '>=': 'u>=', 'sgrter_eq': 's>=', 's>=': 's>=',
                 'ugrter': 'u>', '>': 'u>', 'sgrter': 's>', 's>': 's>', 'zero': 'zero',
                 'overunderflow': 'overunderflow', 'div0s': 'div0s', 'div1': 'div1'}.get,
    'logic': {'and': 'and', 'or': 'or', 'not': 'not', 'xor': 'xor'}.get,
    'logic-sr': {'byte_eq': 'b=', 'byte =': 'b=', 'byte=': 'b=', 'zero': 'zero'}.get,
    'carryin-en': {'1': 1}.get,
    'latch-s-mac': {'1': 1}.get,
    'shift': {'rotate': 'rotate', 'rotatec': 'rotatec', 'shiftl': 'logic',
              'shifta': 'arith'}.get,
    'manip': _manip,
}

FORMATS = {'0': '0', 'n': 'n', 'm': 'm', 'nm': 'nm', 'mn': 'nm', 'md': 'md', 'nd4': 'nd4',
           'nmd': 'nmd', 'd8': 'd8', 'd12': 'd12', 'nd8': 'nd8', 'i8': 'i8', 'ni': 'ni'}


def _or(a, b):
    return a if a is not None else b


def clean_chars(s):
    for a, b in (('≥', '>='), ('→', '->'), ('←', '<-'), ('×', 'x'), ('–', '-')):
        s = s.replace(a, b)
    return s


def read_rows(path):
    with open(path, newline='') as f:
        lines = list(csv.reader(f))
    hdr = [HDR_KEYS.get(h.strip().lower(), h.strip().lower()) for h in lines[0]]
    rows = []
    for n, line in enumerate(lines[1:]):
        d = {}
        for k, v in zip(hdr, line):
            v = v.strip()
            if v and v != '-':
                d[k] = v
        if d:
            d['line'] = n + 2
            rows.append(d)
    return rows


def sanitize_slot(raw, name):
    s = {}
    for k, v in raw.items():
        if k == 'line':
            s[k] = v
            continue
        fn = SANITIZE.get(k)
        if fn is None:
            s[k] = v.lower()
            continue
        v2 = fn(v.lower())
        if v2 is None:
            raise SpecError(f'line {raw["line"]}: {name}: invalid value {k}="{v}"')
        s[k] = v2
    ma_keys = {'ma-addr': 'addr', 'ma-data': 'data', 'ma-size': 'size', 'ma-op': 'op',
               'ma-mask': 'mask'}
    if any(k in s for k in ma_keys):
        s['ma'] = {ma_keys[k]: s.pop(k) for k in list(s) if k in ma_keys}
    mac_keys = {'mac-stage': 'stage', 'mac-busy': 'busy', 'mac-op': 'op', 'macin1': 'in1',
                'macin2': 'in2', 'mach': 'h', 'macl': 'l'}
    if 'mac-stage' in s:
        s['mac'] = {mac_keys[k]: s.pop(k) for k in list(s) if k in mac_keys}
    else:
        for k in mac_keys:
            s.pop(k, None)
    return s


IMM_COLS = ('x', 'y', 'aluy')
FMT_IMM_WIDTH = {'md': 4, 'nd4': 4, 'nmd': 4, 'd8': 8, 'd12': 12, 'nd8': 8, 'i8': 8, 'ni': 8}


def extract_imm(op, slot):
    width = FMT_IMM_WIDTH.get(op['format'], 0)
    for k in IMM_COLS:
        v = slot.get(k)
        if isinstance(v, tuple) and v[0] == 'c':
            _, sign, mult = v
            if width == 0:
                raise SpecError(f'{op["name"]}: immediate {v} with format {op["format"]}')
            if mult == 1 or mult < 1 or mult % 2:
                shift = 0
            else:
                shift = mult.bit_length() - 1
            slot[k] = ('imm', sign, width, shift)
    return slot


def load_spec(path):
    rows = read_rows(path)
    groups = []
    for r in rows:
        if groups and groups[-1][0].get('name') == r.get('name'):
            groups[-1].append(r)
        else:
            groups.append([r])
    ops = []
    for grp in groups:
        first = grp[0]
        common = {k: first[k] for k in COMMON_KEYS if k in first}
        name = common.get('name', '?')
        common['plane'] = 1 if common.get('plane') == 'system' else 0
        if 'name' in common:
            common['name'] = clean_chars(common['name'])
        if 'desc' in common:
            common['desc'] = clean_chars(common['desc'])
        if 'format' in common:
            if common['format'] not in FORMATS:
                raise SpecError(f'{name}: bad format {common["format"]}')
            common['format'] = FORMATS[common['format']]
        slots = []
        for i, r in enumerate(grp):
            raw = {k: v for k, v in r.items() if k not in COMMON_KEYS}
            s = sanitize_slot(raw, name)
            if i == len(grp) - 1 and 'if-issue' not in s and 'dispatch' not in s:
                s['if-issue'] = True
                s['dispatch'] = True
            slots.append(s)
        common['slots'] = slots
        common['line'] = first['line']
        ops.append(common)
    # Propagate table/format/state/desc to ops that lack a format.
    prev = {}
    for op in ops:
        if 'format' in op:
            prev = {k: op[k] for k in ('table', 'format', 'state', 'desc') if k in op}
        else:
            op.update(prev)
    for op in ops:
        op.setdefault('format', None)
        op['slots'] = [extract_imm(op, s) for s in op['slots']]
    return ops


def op_pattern(op):
    """17-char std_match string: plane bit followed by code[15:0]."""
    bits = op['op'].replace(' ', '')
    m = {}
    for i, c in enumerate(reversed(bits)):
        if c in '01':
            m[i] = c
    return str(op['plane']) + ''.join(m.get(i, '-') for i in range(15, -1, -1))


# ------------------------------------------------------- slot -> controls
#
# Control keys follow vhdlmicrocode.clj. Values are converted to
# (vhdl_target_path, value) where value is one of:
#   int 0/1           std_logic constant
#   'T' / 'NT'        t_bcc / not t_bcc
#   ('lit', NAME)     VHDL enumeration literal
#   ('reg', n|'ra'|'rb')  register number (ra = code[11:8], rb = code[7:4])
#   ('imm', NAME)     immediate enum

def is_imm(v):
    return isinstance(v, int) and not isinstance(v, bool) or (isinstance(v, tuple) and v[0] == 'imm')


def imm_name(v):
    if isinstance(v, int):
        if v == 0:
            return 'IMM_ZERO'
        return f'IMM_P{v}' if v > 0 else f'IMM_N{-v}'
    _, sign, width, shift = v
    return f'IMM_{sign.upper()}_{width}_{shift}'


def gen_assigns(op, mc):
    fmt = op['format']
    rn, rm = {'n': ('ra', None), 'm': (None, 'ra'), 'nm': ('ra', 'rb'), 'md': (None, 'rb'),
              'nd4': ('rb', None), 'nmd': ('ra', 'rb'), 'nd8': ('ra', None),
              'ni': ('ra', None)}.get(fmt, (None, None))
    out = []

    def ao(k, v):
        out.append((k, v))

    def reg(r):
        if isinstance(r, tuple) and r[0] == 'r':
            return r[1]
        if r == 'rn':
            if rn is None:
                raise SpecError(f'{op["name"]}: format {fmt} cannot use Rn')
            return rn
        if r == 'rm':
            if rm is None:
                raise SpecError(f'{op["name"]}: format {fmt} cannot use Rm')
            return rm
        return None

    x = mc.get('x')
    if x is not None:
        r = reg(x)
        if r is not None:
            ao('xbus-sel', 'reg'); ao('regnum-x', r)
        elif x == 'pc':
            ao('xbus-sel', 'pc')
        elif is_imm(x):
            ao('xbus-sel', 'imm')
        elif x == 'w':
            ao('xbus-sel', 'wbus')
        else:
            raise SpecError(f'{op["name"]}: bad X {x}')
    y = mc.get('y')
    if y is not None:
        r = reg(y)
        if r is not None:
            ao('ybus-sel', 'reg'); ao('regnum-y', r)
        elif y in ('pc', 'mach', 'macl', 'sr'):
            ao('ybus-sel', y)
        elif is_imm(y):
            ao('ybus-sel', 'imm')
        else:
            raise SpecError(f'{op["name"]}: bad Y {y}')

    aluy = mc.get('aluy')
    aluy = 'r0' if aluy == 'r0' else ('imm' if aluy is not None and is_imm(aluy) else None)
    if 'alux' in mc:
        ao('aluinx-sel', mc['alux'])
    if aluy:
        ao('aluiny-sel', aluy)
    for k, v in (('arith', 'arith-func'), ('arith-sr', 'arith-sr-func'), ('logic', 'logic-func'),
                 ('logic-sr', 'logic-sr-func'), ('manip', 'alumanip'), ('shift', 'shiftfunc'),
                 ('zbus', 'zbus-sel')):
        if k in mc:
            ao(v, mc[k])
    if 'carryin-en' in mc:
        ao('arith-ci-en', mc['carryin-en'])

    sr = mc.get('sr')
    if isinstance(sr, tuple):
        ao('sr-sel', 'set-t'); ao('t-sel', sr[1])
    elif sr == 'wbus':
        ao('wrsr-w', 1)
    elif sr:
        ao('sr-sel', sr)

    for k in ('x', 'y', 'aluy'):
        v = mc.get(k)
        if v is not None and is_imm(v):
            ao('imm-val', v)
            break

    mac = mc.get('mac')
    if mac:
        st = mac['stage']
        if 'in1' in mac:
            ao(f'{st}-macsel1', {'x': 'xbus', 'z': 'zbus', 'w': 'wbus'}[mac['in1']])
            if mac.get('h') not in ('clear', 'load'):
                ao(f'{st}-mulcom1', 1)
        if 'in2' in mac:
            ao(f'{st}-macsel2', {'y': 'ybus', 'z': 'zbus', 'w': 'wbus'}[mac['in2']])
            if 'op' in mac:
                ao(f'{st}-mulcom2', mac['op'])
        if mac.get('l') in ('clear', 'load'):
            ao(f'{st}-wrmacl', 1)
        if mac.get('h') in ('clear', 'load'):
            ao(f'{st}-wrmach', 1)
        if 'busy' in mac:
            ao('mac-busy', (st, mac['busy']))
    if mc.get('mac-stall-sense'):
        ao('mac-stall-sense', 1)
    if mc.get('latch-s-mac'):
        ao('mac-s-latch', 1)
    if mc.get('event') == 'ack':
        ao('event-ack-0', 1)
    if mc.get('ilevel-capture'):
        ao('ilevel-cap', 1)
    if mc.get('mask-int'):
        ao('maskint-next', 1)

    ma = mc.get('ma')
    if ma:
        ao('ma-issue', ma.get('mask', True))
        ao('ma-wr', 1 if ma.get('op') == 'write' else 0)
        ao('mem-addr-sel', {'x': 'xbus', 'z': 'zbus', 'y': 'ybus'}[ma['addr']])
        if ma.get('data') is not None:
            ao('mem-wdata-sel', {'y': 'ybus', 'z': 'zbus'}[ma['data']])
        ao('mem-size', {8: 'byte', 16: 'word', 32: 'long'}[ma['size']])
    if mc.get('ma-lock'):
        ao('mem-lock', 1)

    z = mc.get('z')
    if z is not None:
        r = reg(z)
        if r is not None:
            ao('wrreg-z', 1); ao('regnum-z', r)
        elif z == 'pc':
            ao('wrpc-z', 1)
        elif z == 'pc-t':
            ao('wrpc-z', 't')
        elif z == 'pc-nt':
            ao('wrpc-z', 'nt')
        elif z == 'sr':
            ao('wrsr-z', 1)
        else:
            raise SpecError(f'{op["name"]}: bad Z {z}')
    if mc.get('pr') == 'pc':
        ao('wrpr-pc', 1); ao('wrreg-z', 1); ao('regnum-z', 18)
    w = mc.get('w')
    if w is not None:
        r = reg(w)
        if r is not None:
            ao('wrreg-w', 1); ao('regnum-w', r)
        elif w == 'pc':
            ao('wrpc-z', 1)
        elif w == 'sr':
            pass  # no w-bus clause in vhdlmicrocode.clj; SR column 'W' does the write
        else:
            raise SpecError(f'{op["name"]}: bad W {w}')

    if mc.get('if-addr') == 'z':
        ao('ifadsel', 1)
    if mc.get('inc-pc'):
        ao('incpc', 1)
    if 'dispatch' in mc:
        ao('dispatch', mc['dispatch'])
    if mc.get('debug'):
        ao('debug', 1)
    if 'if-issue' in mc:
        ao('if-issue', mc['if-issue'])
    if mc.get('delay-jump'):
        ao('delay-jump', 1)
    if mc.get('halt'):
        ao('slp', 1)

    seen = {}
    for k, _ in out:
        seen[k] = seen.get(k, 0) + 1
    dup = [k for k, n in seen.items() if n > 1]
    if dup:
        raise SpecError(f'line {mc["line"]}: {op["name"]}: controls set twice: {dup}')
    return out


# key -> (vhdl path, value kind or literal map)
def _sel(vals):
    return {v: 'SEL_' + v.upper().replace('-', '_') for v in vals}


TARGETS = {
    'xbus-sel': ('ex.xbus_sel', _sel(['imm', 'reg', 'pc'])),
    'ybus-sel': ('ex.ybus_sel', _sel(['imm', 'reg', 'mach', 'macl', 'pc', 'sr'])),
    'regnum-x': ('ex.regnum_x', 'reg'),
    'regnum-y': ('ex.regnum_y', 'reg'),
    'regnum-z': ('ex.regnum_z', 'reg'),
    'regnum-w': ('wb.regnum_w', 'reg'),
    'aluinx-sel': ('ex.aluinx_sel', _sel(['xbus', 'fc', 'rotcl', 'zero'])),
    'aluiny-sel': ('ex.aluiny_sel', _sel(['ybus', 'imm', 'r0'])),
    'arith-func': ('ex.arith_func', {'add': 'ADD', 'sub': 'SUB'}),
    'arith-sr-func': ('ex.arith_sr_func', {
        'zero': 'ZERO', 'overunderflow': 'OVERUNDERFLOW', 'u>=': 'UGRTER_EQ',
        's>=': 'SGRTER_EQ', 'u>': 'UGRTER', 's>': 'SGRTER', 'div0s': 'DIV0S', 'div1': 'DIV1'}),
    'logic-func': ('ex.logic_func', {'not': 'LOGIC_NOT', 'and': 'LOGIC_AND', 'or': 'LOGIC_OR',
                                     'xor': 'LOGIC_XOR'}),
    'logic-sr-func': ('ex.logic_sr_func', {'zero': 'ZERO', 'b=': 'BYTE_EQ'}),
    'alumanip': ('ex.alumanip', {
        ('swap', 'b'): 'SWAP_BYTE', ('swap', 'w'): 'SWAP_WORD', ('ext', 'ub'): 'EXTEND_UBYTE',
        ('ext', 'uw'): 'EXTEND_UWORD', ('ext', 'sb'): 'EXTEND_SBYTE',
        ('ext', 'sw'): 'EXTEND_SWORD', 'xtract': 'EXTRACT', 'bit7': 'SET_BIT_7'}),
    'shiftfunc': ('ex_stall.shiftfunc', {'logic': 'LOGIC', 'arith': 'ARITH', 'rotate': 'ROTATE',
                                         'rotatec': 'ROTC'}),
    'zbus-sel': ('ex_stall.zbus_sel', _sel(['arith', 'logic', 'shift', 'manip', 'ybus', 'wbus'])),
    'arith-ci-en': ('ex.arith_ci_en', 'bit'),
    'sr-sel': ('ex_stall.sr_sel', _sel(['prev', 'wbus', 'zbus', 'div0u', 'arith', 'logic',
                                        'int-mask', 'set-t'])),
    't-sel': ('ex_stall.t_sel', _sel(['clear', 'set', 'shift', 'carry'])),
    'wrsr-w': ('wb_stall.wrsr_w', 'bit'),
    'imm-val': ('imm_enum', 'imm'),
    'mac-busy': ('mac_busy', {('ex', 'not-stall'): 'EX_NOT_STALL', ('wb', 'not-stall'): 'WB_NOT_STALL',
                              ('ex', 'busy'): 'EX_BUSY', ('wb', 'busy'): 'WB_BUSY'}),
    'mac-stall-sense': ('mac_stall_sense', 'bit'),
    'mac-s-latch': ('mac_s_latch', 'bit'),
    'event-ack-0': ('event_ack_0', 'bit'),
    'ilevel-cap': ('ilevel_cap', 'bit'),
    'maskint-next': ('maskint_next', 'bit'),
    'ma-issue': ('ex_stall.ma_issue', 'bit'),
    'ma-wr': ('ex.ma_wr', 'bit'),
    'mem-addr-sel': ('ex_stall.mem_addr_sel', _sel(['xbus', 'ybus', 'zbus'])),
    'mem-wdata-sel': ('ex_stall.mem_wdata_sel', _sel(['zbus', 'ybus'])),
    'mem-size': ('ex.mem_size', {'byte': 'BYTE', 'word': 'WORD', 'long': 'LONG'}),
    'mem-lock': ('ex.mem_lock', 'bit'),
    'wrreg-z': ('ex_stall.wrreg_z', 'bit'),
    'wrpc-z': ('ex_stall.wrpc_z', 'bit'),
    'wrsr-z': ('ex_stall.wrsr_z', 'bit'),
    'wrpr-pc': ('ex_stall.wrpr_pc', 'bit'),
    'wrreg-w': ('wb_stall.wrreg_w', 'bit'),
    'ifadsel': ('id.ifadsel', 'bit'),
    'incpc': ('id.incpc', 'bit'),
    'if-issue': ('id.if_issue', 'bit'),
    'dispatch': ('dispatch', 'bit'),
    'debug': ('debug', 'bit'),
    'delay-jump': ('delay_jump', 'bit'),
    'slp': ('slp', 'bit'),
}
_MULT = {k: k.upper() for k in ('macl', 'macw', 'dmulsl', 'dmulul', 'mull', 'mulsw', 'muluw')}
for st in ('ex', 'wb'):
    rec = 'ex_stall' if st == 'ex' else 'wb_stall'
    TARGETS[f'{st}-macsel1'] = (f'{rec}.macsel1', _sel(['xbus', 'zbus', 'wbus']))
    TARGETS[f'{st}-macsel2'] = (f'{rec}.macsel2', _sel(['ybus', 'zbus', 'wbus']))
    TARGETS[f'{st}-mulcom1'] = (f'{rec}.mulcom1', 'bit')
    TARGETS[f'{st}-mulcom2'] = (f'{rec}.mulcom2', _MULT)
    TARGETS[f'{st}-wrmacl'] = (f'{rec}.wrmacl', 'bit')
    TARGETS[f'{st}-wrmach'] = (f'{rec}.wrmach', 'bit')


def to_targets(op, assigns):
    res = {}
    for k, v in assigns:
        if k not in TARGETS:
            raise SpecError(f'{op["name"]}: no target for control {k}')
        path, kind = TARGETS[k]
        if kind == 'bit':
            if v is True or v == 1:
                val = 1
            elif v == 0:
                val = 0
            elif v == 't':
                val = 'T'
            elif v == 'nt':
                val = 'NT'
            else:
                raise SpecError(f'{op["name"]}: bad bit value {k}={v}')
        elif kind == 'reg':
            val = ('reg', v)
        elif kind == 'imm':
            val = ('imm', imm_name(v))
        else:
            if v not in kind:
                raise SpecError(f'{op["name"]}: bad value {k}={v}')
            val = ('lit', kind[v])
        res[path] = val
    return res


def build_table(ops):
    table = []
    for op in ops:
        steps = []
        for mc in op['slots']:
            try:
                steps.append(to_targets(op, gen_assigns(op, mc)))
            except SpecError as e:
                raise SpecError(f'line {mc["line"]}: {e}') from None
        table.append((op, steps))
    return table


def imm_enum_order(ops):
    """Literal order of immval_t, as interface.clj generate-interface builds it."""
    seen = []
    for op in ops:
        for s in op['slots']:
            for k in ('aluy', 'x', 'y'):
                v = s.get(k)
                if v is not None and is_imm(v) and v not in seen:
                    seen.append(v)
    out = []
    if 0 in seen:
        out.append(0)
    out += sorted(v for v in seen if isinstance(v, int) and v > 0)
    out += sorted(v for v in seen if isinstance(v, int) and v < 0)
    out += [v for v in seen if not isinstance(v, int)]
    return [imm_name(v) for v in out]


# -------------------------------------------------------- SV emission

# VHDL path -> (SV path, VHDL enum literal -> SV literal prefix)
SV_PREFIX = {
    'ex.xbus_sel': 'XBUS_', 'ex.ybus_sel': 'YBUS_', 'ex.aluinx_sel': 'ALUX_',
    'ex.aluiny_sel': 'ALUY_', 'ex.arith_func': 'ARITH_', 'ex.arith_sr_func': 'ASR_',
    'ex.logic_func': '', 'ex.logic_sr_func': 'LSR_', 'ex.alumanip': 'MANIP_',
    'ex_stall.shiftfunc': 'SHIFT_', 'ex_stall.zbus_sel': 'ZBUS_', 'ex_stall.sr_sel': 'SR_',
    'ex_stall.t_sel': 'T_', 'mac_busy': 'MACB_', 'ex_stall.mem_addr_sel': 'MADDR_',
    'ex_stall.mem_wdata_sel': 'MWDATA_', 'ex.mem_size': 'SZ_',
    'ex_stall.macsel1': 'MACIN1_', 'wb_stall.macsel1': 'MACIN1_',
    'ex_stall.macsel2': 'MACIN2_', 'wb_stall.macsel2': 'MACIN2_',
    'ex_stall.mulcom2': 'MULT_', 'wb_stall.mulcom2': 'MULT_',
}

SV_PATH = {'mac_busy': 'mac_busy', 'imm_enum': 'imm_enum'}


def sv_path(p):
    if p in SV_PATH:
        return SV_PATH[p]
    return 'o.' + p


def sv_value(path, v):
    if v == 1:
        return "1'b1"
    if v == 0:
        return "1'b0"
    if v == 'T':
        return 't_bcc'
    if v == 'NT':
        return '~t_bcc'
    kind = v[0]
    if kind == 'reg':
        r = v[1]
        if r == 'ra':
            return "{1'b0, op.code[11:8]}"
        if r == 'rb':
            return "{1'b0, op.code[7:4]}"
        return f"5'd{r}"
    if kind == 'imm':
        return v[1]
    if kind == 'lit':
        lit = v[1]
        if lit.startswith('SEL_'):
            lit = lit[4:]
        return SV_PREFIX[path] + lit
    raise ValueError(v)


def op_mnemonic_hex(op):
    parts = []
    for p in op['op'].split():
        m = {'iiii': 'i', 'nnnn': 'n', 'mmmm': 'm', 'dddd': 'd', '----': '-'}
        if p in m:
            parts.append(m[p])
        elif re.fullmatch(r'[01]+', p):
            parts.append('%X' % int(p, 2))
        else:
            parts.append('(' + ''.join(c if c in '01' else '-' for c in p) + ')')
    return ''.join(parts)


IMM_EXPR = {
    'IMM_ZERO': "32'h00000000", 'IMM_U_4_0': "{28'd0, op.code[3:0]}",
    'IMM_U_4_1': "{27'd0, op.code[3:0], 1'b0}", 'IMM_U_4_2': "{26'd0, op.code[3:0], 2'b00}",
    'IMM_U_8_0': "{24'd0, op.code[7:0]}", 'IMM_U_8_1': "{23'd0, op.code[7:0], 1'b0}",
    'IMM_U_8_2': "{22'd0, op.code[7:0], 2'b00}",
    'IMM_S_8_0': "{{24{op.code[7]}}, op.code[7:0]}",
    'IMM_S_8_1': "{{23{op.code[7]}}, op.code[7:0], 1'b0}",
    'IMM_S_12_1': "{{19{op.code[11]}}, op.code[11:0], 1'b0}",
}


def imm_expr(name):
    if name in IMM_EXPR:
        return IMM_EXPR[name]
    m = re.fullmatch(r'IMM_([PN])(\d+)', name)
    if m:
        v = int(m.group(2)) * (1 if m.group(1) == 'P' else -1)
        return "32'h%08x" % (v & 0xffffffff)
    raise SpecError(f'no expression for immediate {name}')


def emit_sv(table, imm_names, src):
    L = []
    w = L.append
    w('// ******************************************************************')
    w('// GENERATED by tools/gen_decode.py from %s -- do not edit.' % src)
    w('// ******************************************************************')
    w('//')
    w('// J2 decode table: maps the current operation (plane, opcode, micro-step)')
    w('// to the control signals of each pipeline stage. Equivalent to the')
    w('// simple_logic architecture of the original decode_table.vhd.')
    w('module j2_decode_table')
    w('  import j2_cpu_pkg::*;')
    w('  import j2_decode_pkg::*;')
    w('(')
    w('  input  logic            next_id_stall,')
    w('  input  operation_t      op,')
    w('  input  logic            t_bcc,')
    w('  output decode_table_o_t o,')
    w('  // raw MAC busy select (lets the pipeline apply next_id_stall itself)')
    w('  output mac_busy_t       mac_busy_sel')
    w(');')
    w('')
    nbits = max(1, (len(imm_names) - 1).bit_length())
    w('  typedef enum logic [%d:0] {' % (nbits - 1))
    for i, n in enumerate(imm_names):
        w('    %s%s' % (n, ',' if i < len(imm_names) - 1 else ''))
    w('  } immval_t;')
    w('')
    w('  immval_t   imm_enum;')
    w('  mac_busy_t mac_busy;')
    w('')
    w('  assign mac_busy_sel = mac_busy;')
    w('')
    w('  // Immediate value mux')
    w('  always_comb begin')
    w('    unique case (imm_enum)')
    for n in imm_names:
        w('      %-11s: o.ex.imm_val = %s;' % (n, imm_expr(n)))
    w("      default    : o.ex.imm_val = 32'h00000000;")
    w('    endcase')
    w('  end')
    w('')
    w('  // MAC busy muxes')
    w('  always_comb begin')
    w("    o.ex.mac_busy = 1'b0;")
    w("    o.wb.mac_busy = 1'b0;")
    w('    unique case (mac_busy)')
    w('      MACB_EX_NOT_STALL: o.ex.mac_busy = ~next_id_stall;')
    w('      MACB_WB_NOT_STALL: o.wb.mac_busy = ~next_id_stall;')
    w("      MACB_EX_BUSY     : o.ex.mac_busy = 1'b1;")
    w("      MACB_WB_BUSY     : o.wb.mac_busy = 1'b1;")
    w('      default          : ;')
    w('    endcase')
    w('  end')
    w('')
    w('  always_comb begin')
    w('    // zero outputs by default')
    w("    o.debug           = 1'b0;")
    w("    o.delay_jump      = 1'b0;")
    w("    o.dispatch        = 1'b0;")
    w("    o.event_ack_0     = 1'b0;")
    w("    o.ilevel_cap      = 1'b0;")
    w("    o.mac_s_latch     = 1'b0;")
    w("    o.mac_stall_sense = 1'b0;")
    w("    o.maskint_next    = 1'b0;")
    w("    o.slp             = 1'b0;")
    w('    o.id              = STAGE_ID_RESET;')
    w('    o.ex_stall        = STAGE_EX_STALL_RESET;')
    w('    o.wb_stall        = STAGE_WB_STALL_RESET;')
    w('    // ex/wb fields other than imm_val/mac_busy (driven above)')
    for f, d in (('xbus_sel', 'XBUS_IMM'), ('ybus_sel', 'YBUS_IMM'), ('regnum_z', "5'd0"),
                 ('regnum_x', "5'd0"), ('regnum_y', "5'd0"), ('alumanip', 'MANIP_SWAP_BYTE'),
                 ('aluinx_sel', 'ALUX_XBUS'), ('aluiny_sel', 'ALUY_YBUS'),
                 ('arith_func', 'ARITH_ADD'), ('arith_ci_en', "1'b0"),
                 ('arith_sr_func', 'ASR_ZERO'), ('logic_func', 'LOGIC_NOT'),
                 ('logic_sr_func', 'LSR_ZERO'), ('ma_wr', "1'b0"), ('mem_lock', "1'b0"),
                 ('mem_size', 'SZ_BYTE')):
        w('    o.ex.%-14s = %s;' % (f, d))
    w("    o.wb.regnum_w     = 5'd0;")
    w('    imm_enum          = IMM_ZERO;')
    w('    mac_busy          = MACB_NOT_BUSY;')
    w('')
    w('    casez ({op.plane, op.code})')
    for op, steps in table:
        pat = op_pattern(op).replace('-', '?')
        w("      17'b%s: begin" % pat)
        w('        // %s [%s]%s' % (op['name'], op_mnemonic_hex(op),
                                   (' -- ' + op['desc'].replace('\n', ' ')) if op.get('desc') else ''))
        w('        unique case (op.addr[3:0])')
        for i, st in enumerate(steps):
            if not st:
                w("          4'h%x: ;" % i)
                continue
            w("          4'h%x: begin" % i)
            for path in sorted(st):
                w('            %s = %s;' % (sv_path(path), sv_value(path, st[path])))
            w('          end')
        w('          default: ;')
        w('        endcase')
        w('      end')
    w('      default: ;')
    w('    endcase')
    w('  end')
    w('')
    w('endmodule')
    return '\n'.join(L) + '\n'


# Outputs the original generator treated as don't-care when an op step does
# not assign them (interface.clj :nillable-outputs). The minimised
# reverse_logic table may drive anything on them in that case.
NILLABLE = {
    'ex_stall.shiftfunc': 'o.ex_stall.shiftfunc', 'imm_enum': 'o.ex.imm_val',
    'ex.ma_wr': 'o.ex.ma_wr', 'ex.arith_func': 'o.ex.arith_func',
    'ex.arith_sr_func': 'o.ex.arith_sr_func', 'ex.logic_func': 'o.ex.logic_func',
    'ex.logic_sr_func': 'o.ex.logic_sr_func', 'ex_stall.zbus_sel': 'o.ex_stall.zbus_sel',
    'ex_stall.mem_addr_sel': 'o.ex_stall.mem_addr_sel', 'ex.mem_size': 'o.ex.mem_size',
    'ex_stall.mem_wdata_sel': 'o.ex_stall.mem_wdata_sel', 'wb.regnum_w': 'o.wb.regnum_w',
    'ex.regnum_x': 'o.ex.regnum_x', 'ex.regnum_y': 'o.ex.regnum_y',
    'ex.regnum_z': 'o.ex.regnum_z',
}


NILLABLE_TYPE = {
    'o.ex_stall.shiftfunc': 'shiftfunc_t', 'o.ex.arith_func': 'arith_func_t',
    'o.ex.arith_sr_func': 'arith_sr_func_t', 'o.ex.logic_func': 'logic_func_t',
    'o.ex.logic_sr_func': 'logic_sr_func_t', 'o.ex_stall.zbus_sel': 'zbus_sel_t',
    'o.ex_stall.mem_addr_sel': 'mem_addr_sel_t', 'o.ex.mem_size': 'mem_size_t',
    'o.ex_stall.mem_wdata_sel': 'mem_wdata_sel_t',
}


def _care_val(tgt, ones):
    v = "'1" if ones else "'0"
    t = NILLABLE_TYPE.get(tgt)
    return "%s'(%s)" % (t, v) if t else v


def emit_sv_care(table, src):
    """Test-only module: per (op, step), a mask over decode_table_o_t of the
    bits that matter, and 'valid' = the op matched and the step exists."""
    L = []
    w = L.append
    w('// GENERATED by tools/gen_decode.py from %s -- do not edit.' % src)
    w('// Care mask for comparing decode tables (see NILLABLE in gen_decode.py).')
    w('module j2_decode_care')
    w('  import j2_cpu_pkg::*;')
    w('  import j2_decode_pkg::*;')
    w('(')
    w('  input  operation_t      op,')
    w('  output decode_table_o_t o,')
    w('  output logic            valid')
    w(');')
    w('  always_comb begin')
    w("    o = '1;")
    for tgt in sorted(set(NILLABLE.values())):
        w("    %s = %s;" % (tgt, _care_val(tgt, False)))
    w("    valid = 1'b0;")
    w('    casez ({op.plane, op.code})')
    for op, steps in table:
        w("      17'b%s: begin" % op_pattern(op).replace('-', '?'))
        w('        unique case (op.addr[3:0])')
        for i, st in enumerate(steps):
            sets = sorted(NILLABLE[p] for p in st if p in NILLABLE)
            w("          4'h%x: begin valid = 1'b1;%s end" % (
                i, ''.join(" %s = %s;" % (t, _care_val(t, True)) for t in sets)))
        w('          default: ;')
        w('        endcase')
        w('      end')
    w('      default: ;')
    w('    endcase')
    w('  end')
    w('endmodule')
    return '\n'.join(L) + '\n'


def emit_sv_isa_pkg(table, src):
    """Package with ISA-level helpers derived from the spec."""
    L = ['// GENERATED by tools/gen_decode.py from %s -- do not edit.' % src,
         '//',
         '// ISA helpers derived from the instruction spec.',
         'package j2_isa_pkg;',
         '',
         '  // 1 if "code" is a defined (normal-plane) J2 instruction. Every other',
         '  // opcode is undefined; the CPU can trap them as illegal instructions.',
         '  function automatic logic opcode_defined(logic [15:0] code);',
         '    casez (code)']
    for op, _ in table:
        if op['plane'] != 0:
            continue
        L.append("      16'b%s: return 1'b1;  // %s" % (op_pattern(op)[1:].replace('-', '?'), op['name']))
    L += ["      default: return 1'b0;",
          '    endcase',
          '  endfunction',
          '',
          'endpackage']
    return '\n'.join(L) + '\n'


def emit_c_table(table):
    L = ['// GENERATED by tools/gen_decode.py -- do not edit.',
         '// { match_mask, match_value, plane, name, format, n_steps }']
    for op, steps in table:
        pat = op_pattern(op)[1:]
        mask = int(''.join('0' if c == '-' else '1' for c in pat), 2)
        val = int(''.join('1' if c == '1' else '0' for c in pat), 2)
        L.append('J2_OP(0x%04x, 0x%04x, %d, "%s", "%s", %d)' % (
            mask, val, op['plane'], op['name'].replace('"', '\\"'), op['format'] or '0',
            len(steps)))
    return '\n'.join(L) + '\n'


# ------------------------------------------------ check vs original VHDL

def parse_vhdl_simple(path):
    """Parse decode_table_simple.vhd -> {pattern: [ {path: value}, ...]}."""
    text = open(path).read()
    body = text[text.index('-- set control signals for each opcode'):]
    res = {}
    cur = None
    step = None
    for line in body.splitlines():
        s = line.strip()
        m = re.match(r'(?:els)?if std_match\(cond, "([01-]+)"\) then', s)
        if m:
            cur = []
            res[m.group(1)] = cur
            continue
        m = re.match(r'when x"([0-9a-f])" =>', s)
        if m:
            step = int(m.group(1), 16)
            while len(cur) <= step:
                cur.append({})
            continue
        if s.startswith('when others'):
            step = None
            continue
        m = re.match(r'([\w.]+) <= (.+);$', s)
        if m and step is not None:
            lhs, rhs = m.group(1), m.group(2)
            if rhs == "'1'":
                v = 1
            elif rhs == "'0'":
                v = 0
            elif rhs == 't_bcc':
                v = 'T'
            elif rhs == 'not t_bcc':
                v = 'NT'
            elif rhs == "'0' & op.code(11 downto 8)":
                v = ('reg', 'ra')
            elif rhs == "'0' & op.code(7 downto 4)":
                v = ('reg', 'rb')
            elif re.fullmatch(r'"[01]{5}"', rhs):
                v = ('reg', int(rhs[1:-1], 2))
            elif lhs == 'imm_enum':
                v = ('imm', rhs)
            else:
                v = ('lit', rhs)
            cur[step][lhs] = v
    return res


def check_vhdl(table, path):
    ref = parse_vhdl_simple(path)
    errors = 0
    mine = {op_pattern(op): (op, steps) for op, steps in table}
    if set(mine) != set(ref):
        print('pattern set differs:', set(mine) ^ set(ref))
        errors += 1
    for pat, (op, steps) in mine.items():
        rsteps = ref.get(pat)
        if rsteps is None:
            continue
        n = max(len(steps), len(rsteps))
        for i in range(n):
            a = steps[i] if i < len(steps) else {}
            b = rsteps[i] if i < len(rsteps) else {}
            if a != b:
                errors += 1
                print(f'MISMATCH {op["name"]} step {i}:')
                for k in sorted(set(a) | set(b)):
                    if a.get(k) != b.get(k):
                        print(f'   {k}: gen={a.get(k)} ref={b.get(k)}')
    return errors


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument('spec', help='spec CSV (spec/j2_isa.csv)')
    ap.add_argument('--sv', help='write SystemVerilog decode table here')
    ap.add_argument('--c-table', help='write C opcode table here')
    ap.add_argument('--sv-care', help='write test-only care-mask module here')
    ap.add_argument('--sv-isa-pkg', help='write ISA helper package (opcode_defined) here')
    ap.add_argument('--check-vhdl', help='compare against original decode_table_simple.vhd')
    ap.add_argument('--check-immval', help='compare immval_t order against decode_pkg.vhd')
    args = ap.parse_args()
    try:
        ops = load_spec(args.spec)
        table = build_table(ops)
    except SpecError as e:
        sys.exit(f'spec error: {e}')
    imm_names = imm_enum_order(ops)
    print(f'{len(ops)} ops, {sum(len(s) for _, s in table)} steps, {len(imm_names)} immediates')
    rc = 0
    if args.check_immval:
        txt = open(args.check_immval).read()
        m = re.search(r'type immval_t is \(([^)]*)\)', txt)
        ref = [x.strip() for x in m.group(1).split(',')]
        if ref != imm_names:
            print('immval_t order differs:\n  gen', imm_names, '\n  ref', ref)
            rc = 1
        else:
            print('immval_t order matches reference')
    if args.check_vhdl:
        n = check_vhdl(table, args.check_vhdl)
        print(f'check against {args.check_vhdl}: {n} mismatches')
        rc |= 1 if n else 0
    if args.sv:
        with open(args.sv, 'w') as f:
            f.write(emit_sv(table, imm_names, args.spec))
    if args.sv_isa_pkg:
        with open(args.sv_isa_pkg, 'w') as f:
            f.write(emit_sv_isa_pkg(table, args.spec))
    if args.sv_care:
        with open(args.sv_care, 'w') as f:
            f.write(emit_sv_care(table, args.spec))
    if args.c_table:
        with open(args.c_table, 'w') as f:
            f.write(emit_c_table(table))
    sys.exit(rc)


if __name__ == '__main__':
    main()
