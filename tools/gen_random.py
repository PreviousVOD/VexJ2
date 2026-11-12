#!/usr/bin/env python3
"""Constrained-random J2 test program generator.

Generates a self-contained raw binary (loaded at address 0) that exercises
the whole J2 instruction set. Opcodes are encoded from the patterns in
spec/j2_isa.csv. The program is meant to be run under j2sim --iss: the ISS
checks every instruction, memory access and register write, and the program
only has to stay well-defined.

Register conventions:
  R0-R9   random data (R0 also used as index / CAS address, set right before use)
  R10,R11 pointers, set up right before each indirect access
  R12,R13 base pointers to the data area (never written)
  R14     scratch for the illegal-instruction handler (never used otherwise)
  R15     stack pointer
Memory map: vectors 0x000-0x3ff, code from 0x400, data area DATA..DATA+0x800,
stack below 0x7ff0. The program ends by writing 0 to TEST_RESULT.
"""
import argparse
import random
import struct
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import gen_decode  # noqa: E402

DATA = 0x5000
STACK = 0x7ff0
CODE = 0x400
TEST_RESULT = 0xbcde0010


class Spec:
    def __init__(self, path):
        self.pat = {}
        for op in gen_decode.load_spec(path):
            if op['plane'] == 0:
                self.pat[op['name']] = op['op'].replace(' ', '')
        self.defined = [(m, v) for m, v in (self._mv(p) for p in self.pat.values())]

    @staticmethod
    def _mv(p):
        mask = int(''.join('1' if c in '01' else '0' for c in p), 2)
        val = int(''.join('1' if c == '1' else '0' for c in p), 2)
        return mask, val

    def enc(self, name, n=0, m=0, imm=0):
        p = self.pat[name]
        fields = {'n': n, 'm': m, 'i': imm, 'd': imm}
        bits = []
        cnt = {k: p.count(k) for k in 'nmid'}
        pos = {k: 0 for k in 'nmid'}
        for c in p:
            if c in '01':
                bits.append(c)
            elif c in 'nmid':
                w = cnt[c]
                bit = (fields[c] >> (w - 1 - pos[c])) & 1
                pos[c] += 1
                bits.append(str(bit))
            else:
                bits.append('0')
        return int(''.join(bits), 2)

    def is_defined(self, code):
        return any((code & m) == v for m, v in self.defined)


# --------------------------------------------------------------- layout
class Prog:
    """Instruction list with labels and literal pool; resolved in two passes."""

    def __init__(self):
        self.items = []   # ('op', code) | ('label', name) | ('fix', kind, label, base_code) | ('align4',) | ('word32', v)
        self.nlabel = 0

    def label(self):
        self.nlabel += 1
        return 'L%d' % self.nlabel

    def op(self, code):
        self.items.append(('op', code))

    def place(self, lab):
        self.items.append(('label', lab))

    def fix(self, kind, lab, base):
        self.items.append(('fix', kind, lab, base))

    def resolve(self):
        addr = CODE
        labels = {}
        for it in self.items:
            if it[0] == 'label':
                labels[it[1]] = addr
            elif it[0] in ('op', 'fix'):
                addr += 2
            elif it[0] == 'align4':
                addr += addr & 2
            elif it[0] == 'word32':
                addr += 4
        out = bytearray()
        addr = CODE
        for it in self.items:
            if it[0] == 'label':
                continue
            if it[0] == 'op':
                out += struct.pack('>H', it[1]); addr += 2
            elif it[0] == 'fix':
                _, kind, lab, base = it
                t = labels[lab]
                if kind == 'd8':      # BT/BF/BT.S/BF.S: target = addr + 4 + d*2
                    d = (t - addr - 4) // 2
                    assert -128 <= d < 128, (lab, d)
                    code = base | (d & 0xff)
                elif kind == 'd12':   # BRA/BSR
                    d = (t - addr - 4) // 2
                    assert -2048 <= d < 2048
                    code = base | (d & 0xfff)
                elif kind == 'mova':  # MOVA @(disp,PC),R0: target = (addr+4)&~3 + d*4
                    d = (t - ((addr + 4) & ~3)) // 4
                    assert 0 <= d < 256 and t % 4 == 0, (lab, d, t)
                    code = base | d
                elif kind == 'rel8':  # MOV #imm,Rn with imm = target - (braf_addr + 4); braf follows
                    d = t - (addr + 2 + 4)
                    assert -128 <= d < 128 and d % 2 == 0, d
                    code = base | (d & 0xff)
                elif kind == 'pcl':   # MOV.L @(disp,PC),Rn to a literal label
                    d = (t - ((addr + 4) & ~3)) // 4
                    assert 0 <= d < 256 and t % 4 == 0
                    code = base | d
                out += struct.pack('>H', code); addr += 2
            elif it[0] == 'align4':
                if addr & 2:
                    out += struct.pack('>H', 0x0009); addr += 2
            elif it[0] == 'word32':
                out += struct.pack('>I', it[1]); addr += 4
        return bytes(out)


# ----------------------------------------------------------- generator
DATA_REGS = list(range(10))

ALU_NM = ['ADD Rm, Rn', 'ADDC Rm, Rn', 'ADDV Rm, Rn', 'AND Rm, Rn', 'CMP /EQ Rm, Rn',
          'CMP /GE Rm, Rn', 'CMP /GT Rm, Rn', 'CMP /HI Rm, Rn', 'CMP /HS Rm, Rn',
          'CMP /STR Rm, Rn', 'DIV0S Rm, Rn', 'DIV1 Rm, Rn', 'DMULS.L Rm, Rn', 'DMULU.L Rm, Rn',
          'EXTS.B Rm, Rn', 'EXTS.W Rm, Rn', 'EXTU.B Rm, Rn', 'EXTU.W Rm, Rn', 'MOV Rm, Rn',
          'MUL.L Rm, Rn', 'MULS.W Rm, Rn', 'MULU.W Rm, Rn', 'NEG Rm, Rn', 'NEGC Rm, Rn',
          'NOT Rm, Rn', 'OR Rm, Rn', 'SUB Rm, Rn', 'SUBC Rm, Rn', 'SUBV Rm, Rn',
          'SWAP.B Rm, Rn', 'SWAP.W Rm, Rn', 'TST Rm, Rn', 'XOR Rm, Rn', 'XTRACT Rm, Rn',
          'SHAD Rm, Rn', 'SHLD Rm, Rn']
ALU_N = ['CMP/PL Rn', 'CMP/PZ Rn', 'DT Rn', 'MOVT Rn', 'ROTL Rn', 'ROTR Rn', 'ROTCL Rn',
         'ROTCR Rn', 'SHAL Rn', 'SHAR Rn', 'SHLL Rn', 'SHLR Rn', 'SHLL2 Rn', 'SHLR2 Rn',
         'SHLL8 Rn', 'SHLR8 Rn', 'SHLL16 Rn', 'SHLR16 Rn', 'STC SR, Rn', 'STC GBR, Rn',
         'STC VBR, Rn', 'STS MACH, Rn', 'STS MACL, Rn', 'STS PR, Rn']
# (PR is only written by calls: a random PR would send the next RTS astray)
ALU_M = ['LDS Rm, MACH', 'LDS Rm, MACL', 'LDC Rm, SR']
ALU_0 = ['CLRT', 'SETT', 'CLRMAC', 'NOP', 'DIV0U', 'SLEEP']
IMM_N = ['ADD #imm, Rn', 'MOV #imm, Rn']
IMM_R0 = ['CMP /EQ #imm, R0', 'AND #imm, R0', 'OR #imm, R0', 'XOR #imm, R0', 'TST #imm, R0']


class Gen:
    def __init__(self, spec, rng, args):
        self.s, self.r, self.a = spec, rng, args
        self.p = Prog()
        self.subs = []

    def E(self, name, **kw):
        return self.s.enc(name, **kw)

    def rd(self):
        return self.r.choice(DATA_REGS)

    def rs(self):
        return self.r.randrange(14)  # any readable register (not R14/R15)

    # straight-line instruction safe for a delay slot (no PC use, no memory setup)
    def simple(self):
        r = self.r.random()
        if r < 0.55:
            return self.E(self.r.choice(ALU_NM), n=self.rd(), m=self.rs())
        if r < 0.75:
            return self.E(self.r.choice(ALU_N), n=self.rd())
        if r < 0.85:
            return self.E(self.r.choice(IMM_N), n=self.rd(), imm=self.r.randrange(256))
        if r < 0.93:
            return self.E(self.r.choice(IMM_R0), imm=self.r.randrange(256))
        if r < 0.97:
            name = self.r.choice(ALU_M)
            m = self.rs()
            return self.E(name, m=m)
        return self.E(self.r.choice(ALU_0))

    def setptr(self, reg, size, span=0x100):
        off = self.r.randrange(0, span, size) & 0x7f
        base = self.r.choice([12, 13])
        self.p.op(self.E('MOV Rm, Rn', n=reg, m=base))
        if off:
            self.p.op(self.E('ADD #imm, Rn', n=reg, imm=off))

    def setr0(self, size):
        self.p.op(self.E('MOV #imm, Rn', n=0, imm=self.r.randrange(0, 0x60, size)))

    def memop(self):
        p, E, r = self.p, self.E, self.r
        k = r.randrange(16)
        sz = r.choice([1, 2, 4])
        sfx = {1: 'B', 2: 'W', 4: 'L'}[sz]
        if k == 0:    # @Rn / @Rm
            self.setptr(10, sz)
            if r.random() < 0.5:
                p.op(E('MOV.%s Rm, @Rn' % sfx, n=10, m=self.rs()))
            else:
                p.op(E('MOV.%s @Rm, Rn' % sfx, n=self.rd(), m=10))
        elif k == 1:  # post-increment / pre-decrement
            self.setptr(10, sz)
            if r.random() < 0.5:
                p.op(E('MOV.%s @Rm+, Rn' % sfx, n=self.rd(), m=10))
            else:
                p.op(E('MOV.%s Rm,@-Rn' % sfx if sz != 4 else 'MOV.L Rm,@-Rn', n=10, m=self.rs()))
        elif k == 2:  # @(disp,Rn)
            base = r.choice([12, 13])
            d = r.randrange(16)
            if sz == 4:
                if r.random() < 0.5:
                    p.op(E('MOV.L Rm, @(disp, Rn)', n=base, m=self.rs(), imm=d))
                else:
                    p.op(E('MOV.L @(disp, Rm), Rn', n=self.rd(), m=base, imm=d))
            else:
                if r.random() < 0.5:
                    p.op(E('MOV.%s R0, @(disp, Rn)' % sfx, n=base, imm=d))
                else:
                    p.op(E('MOV.%s @(disp, Rm), R0' % sfx, m=base, imm=d))
        elif k == 3:  # @(R0,Rn)
            self.setr0(sz)
            base = r.choice([12, 13])
            if r.random() < 0.5:
                p.op(E('MOV.%s Rm, @(R0, Rn)' % sfx, n=base, m=r.choice(DATA_REGS[1:])))
            else:
                p.op(E('MOV.%s @(R0, Rm), Rn' % sfx, n=r.choice(DATA_REGS[1:]), m=base))
        elif k == 4:  # GBR relative
            p.op(E('LDC, Rm, GBR', m=12))
            d = r.randrange(0x40)
            if r.random() < 0.5:
                p.op(E('MOV.%s R0, @(disp, GBR)' % sfx, imm=d))
            else:
                p.op(E('MOV.%s @(disp, GBR), R0' % sfx, imm=d))
        elif k == 5:  # logic on @(R0,GBR)
            p.op(E('LDC, Rm, GBR', m=13))
            self.setr0(1)
            p.op(E(r.choice(['AND.B #imm, @(R0, GBR)', 'OR.B #imm, @(R0, GBR)',
                             'XOR.B #imm, @(R0, GBR)', 'TST.B #imm, @(R0, GBR)']),
                   imm=r.randrange(256)))
        elif k == 6:  # MAC
            self.setptr(10, 4)
            self.setptr(11, 4)
            if r.random() < 0.5:
                p.op(E('MAC.W @Rm+, @Rn+', n=10, m=11))
            else:
                p.op(E('MAC.L @Rm+, @Rn+', n=10, m=11))
        elif k == 7:  # TAS.B
            self.setptr(10, 1)
            p.op(E('TAS.B @Rn', n=10))
        elif k == 8:  # CAS.L
            p.op(E('MOV Rm, Rn', n=0, m=r.choice([12, 13])))
            p.op(E('ADD #imm, Rn', n=0, imm=r.randrange(0, 0x40, 4)))
            p.op(E('CAS.L Rm, Rn, @R0', n=r.choice(DATA_REGS[1:]), m=r.choice(DATA_REGS[1:])))
        elif k == 9:  # system register load / store through memory
            self.setptr(10, 4)
            name = r.choice(['STS.L MACH, @-Rn', 'STS.L MACL, @-Rn', 'STS.L PR, @-Rn',
                             'STC.L SR, @-Rn', 'STC.L GBR, @-Rn', 'STC.L VBR, @-Rn',
                             'LDS.L @Rm+, MACH', 'LDS.L @Rm+, MACL',
                             'LDC.L @Rm+, SR', 'LDC.L @Rm+, GBR'])
            p.op(E(name, n=10, m=10))
        elif k == 10:  # PC relative (reads code as data)
            if r.random() < 0.5:
                p.op(E('MOV.W @(disp, PC), Rn', n=self.rd(), imm=r.randrange(256)))
            else:
                p.op(E('MOV.L @(disp, PC), Rn', n=self.rd(), imm=r.randrange(256)))
        elif k == 11:
            p.op(E('MOVA @(disp, PC), R0', imm=r.randrange(256)))
        else:         # plain ALU
            p.op(self.simple())

    def branch(self):
        p, E, r = self.p, self.E, self.r
        lab = p.label()
        kind = r.randrange(8)
        delayed = True
        conditional = kind in (3, 4)  # BT/S, BF/S: no delay slot when not taken
        if kind == 0:
            p.fix('d12', lab, E('BRA label'))
        elif kind == 1:
            p.fix('d8', lab, E('BT label')); delayed = False
        elif kind == 2:
            p.fix('d8', lab, E('BF label')); delayed = False
        elif kind == 3:
            p.fix('d8', lab, E('BT /S label'))
        elif kind == 4:
            p.fix('d8', lab, E('BF /S label'))
        elif kind == 5:  # BRAF via computed offset
            p.fix('rel8', lab, E('MOV #imm, Rn', n=9))
            p.op(E('BRAF Rm', m=9))
        elif kind == 6:  # JMP via MOVA
            p.fix('mova', lab, E('MOVA @(disp, PC), R0'))
            p.op(E('JMP @Rm', m=0))
        else:            # BSR/JSR/BSRF to an inline subroutine (returns with RTS)
            sub, over = p.label(), p.label()
            c = r.randrange(3)
            if c == 0:
                p.fix('d12', sub, E('BSR label'))
            elif c == 1:
                p.fix('mova', sub, E('MOVA @(disp, PC), R0'))
                p.op(E('JSR @Rm', m=0))
            else:
                p.fix('rel8', sub, E('MOV #imm, Rn', n=9))
                p.op(E('BSRF Rm', m=9))
            p.op(self.simple())                 # delay slot
            p.fix('d12', over, E('BRA label'))  # return lands here
            p.op(E('NOP'))
            p.items.append(('align4',))
            p.place(sub)
            for _ in range(r.randrange(1, 6)):
                p.op(self.simple())
            p.op(E('RTS'))
            p.op(self.simple())
            p.place(over)
            return
        if delayed:
            # (a PC-modifying instruction after a not-taken BT/S would really
            # execute, so slot-illegal tests only follow unconditional branches)
            if not conditional and r.random() < self.a.slot_illegal:
                p.op(self.slot_illegal_op())
            else:
                p.op(self.simple())
        if lab:
            # a few instructions that may be skipped, then the target
            for _ in range(r.randrange(0, 6)):
                p.op(self.simple())
            p.items.append(('align4',))  # MOVA/JMP targets must be 4-aligned
            p.place(lab)

    def slot_illegal_op(self):
        # a PC-modifying instruction in a delay slot -> slot illegal exception
        return self.r.choice([self.E('RTS'), self.E('BRA label') | 0, self.E('TRAPA #imm', imm=40)])

    def loop(self):
        p, E, r = self.p, self.E, self.r
        p.op(E('MOV #imm, Rn', n=9, imm=r.randrange(1, 5)))
        top = p.label()
        p.place(top)
        for _ in range(r.randrange(1, 5)):
            c = self.simple()
            # the loop counter R9 must not be written in the body
            if ((c >> 8) & 15) == 9 and (c >> 12) not in (8, 0xc):
                c = E('NOP')
            p.op(c)
        p.op(E('DT Rn', n=9))
        p.fix('d8', top, E('BF label'))

    def undefined(self):
        while True:
            c = self.r.randrange(0x10000) if self.r.random() < 0.8 else 0xff00 | self.r.randrange(256)
            if not self.s.is_defined(c):
                return c

    def build(self, n):
        p, E, r = self.p, self.E, self.r
        # ---- start: stack, bases, GBR, random register values
        lit_stack, lit_data, lit_result, lit_end = p.label(), p.label(), p.label(), p.label()
        p.fix('pcl', lit_stack, E('MOV.L @(disp, PC), Rn', n=15))
        p.fix('pcl', lit_data, E('MOV.L @(disp, PC), Rn', n=12))
        p.op(E('MOV Rm, Rn', n=13, m=12))
        p.op(E('ADD #imm, Rn', n=13, imm=0x7c))
        p.op(E('ADD #imm, Rn', n=13, imm=0x7c))
        p.op(E('LDC, Rm, GBR', m=12))
        for rr in range(10):
            p.op(E('MOV #imm, Rn', n=rr, imm=r.randrange(256)))
        skip = p.label()
        p.fix('d12', skip, E('BRA label'))
        p.op(E('NOP'))
        p.items.append(('align4',))
        p.place(lit_stack); p.items.append(('word32', STACK))
        p.place(lit_data); p.items.append(('word32', DATA))
        p.place(lit_result); p.items.append(('word32', TEST_RESULT))
        p.place(skip)
        # ---- random body
        for _ in range(n):
            x = r.random()
            if x < 0.45:
                p.op(self.simple())
            elif x < 0.75:
                self.memop()
            elif x < 0.90:
                self.branch()
            elif x < 0.94:
                self.loop()
            elif x < 0.97:
                p.op(E('TRAPA #imm', imm=r.randrange(32, 64)))
            else:
                p.op(self.undefined())
        # ---- end: TEST_RESULT = 0, spin (literal after the loop)
        lit_result2 = p.label()
        p.fix('pcl', lit_result2, E('MOV.L @(disp, PC), Rn', n=1))
        p.op(E('MOV #imm, Rn', n=0, imm=0))
        p.op(E('MOV.L Rm, @Rn', n=1, m=0))
        p.place(lit_end)
        p.fix('d12', lit_end, E('BRA label'))
        p.op(E('NOP'))
        p.items.append(('align4',))
        p.place(lit_result2); p.items.append(('word32', TEST_RESULT))
        return p

    def finish(self):
        p = self.build(self.a.length)
        return p


def handler_code(spec):
    """Exception handlers: general illegal skips the instruction, others RTE."""
    E = spec.enc
    gen_ill = [E('MOV.L @Rm, Rn', n=14, m=15), E('ADD #imm, Rn', n=14, imm=2),
               E('MOV.L Rm, @Rn', n=15, m=14), E('RTE'), E('NOP')]
    plain = [E('RTE'), E('NOP')]
    return gen_ill, plain


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument('--spec', default=os.path.join(os.path.dirname(__file__), '..', 'spec', 'j2_isa.csv'))
    ap.add_argument('--seed', type=int, default=1)
    ap.add_argument('--length', type=int, default=1500, help='number of random items')
    ap.add_argument('--slot-illegal', type=float, default=0.02,
                    help='probability that a delay slot holds a PC-modifying instruction')
    ap.add_argument('-o', '--output', required=True)
    args = ap.parse_args()

    spec = Spec(args.spec)
    rng = random.Random(args.seed)
    g = Gen(spec, rng, args)
    prog = g.finish()

    code = prog.resolve()

    gen_ill, plain = handler_code(spec)
    h_gen = 0x200
    h_plain = 0x220
    img = bytearray(0x400)
    vec = [CODE, STACK, CODE, STACK] + [h_plain] * 252
    vec[4] = h_gen          # general illegal: skip the instruction
    vec[6] = h_plain        # slot illegal: J2 returns to the branch target
    vec = vec[:0x200 // 4]  # vectors 0..127
    for i, v in enumerate(vec):
        struct.pack_into('>I', img, i * 4, v)
    for i, c in enumerate(gen_ill):
        struct.pack_into('>H', img, h_gen + 2 * i, c)
    for i, c in enumerate(plain):
        struct.pack_into('>H', img, h_plain + 2 * i, c)
    img += code
    assert len(img) < DATA, 'program too large'
    with open(args.output, 'wb') as f:
        f.write(img)
    print('%s: %d bytes, seed %d' % (args.output, len(img), args.seed))


if __name__ == '__main__':
    main()
