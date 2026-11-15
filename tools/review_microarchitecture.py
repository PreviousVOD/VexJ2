#!/usr/bin/env python3
"""Generate directed review ROMs and retain bus traces without changing RTL."""
import struct,subprocess,pathlib
# Run make spinal-microcode-verif first to refresh the model.
# These bounded trace probes intentionally end in loops; harness timeout/FAIL
# is not an ISA verdict. Inspect the architectural stores printed below.
root=pathlib.Path(__file__).resolve().parents[1]
(root/'build/review').mkdir(parents=True, exist_ok=True)
def run(name,code,data):
 b=bytearray(0x500)
 def long(a,v): b[a:a+4]=struct.pack('>I',v)
 long(0,0x100);long(4,0x480)
 for i,op in enumerate(code): b[0x100+i*2:0x102+i*2]=struct.pack('>H',op)
 for a,v in data.items():long(a,v)
 p=root/'build/review'/f'{name}.bin';p.write_bytes(b)
 r=subprocess.run([str(root/'build/spinal/verif/microcoded/VJ2MicrocodedCore'),str(p),'--quiet','--max-cycles','600','--log-bus-from','0'],cwd=root/'build/spinal/verif/microcoded',capture_output=True,text=True)
 (root/'build/review'/f'{name}.log').write_text(r.stdout+r.stderr)
 print(name);print('\n'.join(x for x in r.stdout.splitlines() if 'dbus' in x)[:2500])
# sleep; marker in r0; destination r1=400; store; self loop
run('sleep',[0x001b,0xe02a,0xd107,0x2102,0xaffe,0x0009],{0x124:0x400})
# read long from 0x301; store result at 0x400
run('unaligned',[0xd107,0xd208,0x6012,0x2202,0xaffe,0x0009],{0x120:0x301,0x124:0x400,0x300:0x12345678})
# postincrement load then four nops then store loaded value and base
run('postinc',[0xd107,0xd208,0x6016,9,9,9,9,0x2202,0x1211,0xaffe,9],{0x120:0x300,0x124:0x400,0x300:0x12345678})
def lit(pc,r,a):return 0xd000|(r<<8)|((a-((pc+4)&~3))//4)
run('macl_wrap',[lit(0x100,0,0x140),0x400a,0xe0ff,0x401a,0xe002,0x400e,lit(0x10c,1,0x144),lit(0x10e,2,0x148),0x021f,0x030a,0x041a,lit(0x116,5,0x14c),0x2532,0x1541,0xaffe,9],{0x140:0x7fffffff,0x144:0x300,0x148:0x304,0x14c:0x400,0x300:1,0x304:1})
