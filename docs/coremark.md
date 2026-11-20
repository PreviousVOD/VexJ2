# CoreMark benchmark

[Project overview](../README.md) · [Development](development.md)

The hardware workflow supports Tang Primer at 32 MHz and Wukong at 72 MHz,
selected with `BOARD`. Native CoreMark simulation currently supports Tang only.
Run commands from the repository root. The later hybrid-decoder results are recorded in
[SH-2 pipeline validation](sh2-pipeline.md#validation).

## Workload and measurement

CoreMark's unmodified algorithms are vendored from EEMBC revision
`1f483d5b8316753a742cbf5590caf5bd0a4e4777`; `third_party/coremark/UPSTREAM.json`
pins their SHA-256 hashes. The J2 port uses SH-2 big-endian GCC with `-O2`, no
LTO, one context, volatile seeds, and a 2,000-byte static buffer. Code and
read-only data execute from SPI XIP flash; writable data and an 8 KiB stack use
internal SRAM. Startup copies initialized data from flash and clears BSS.
The upstream legacy `coremark.md5` contains a stale digest for `coremark.h`;
the build checks the pinned SHA-256 hashes of all vendored files instead.

J2CMT measures the benchmark at PCLK/512. A CMI0 ISR extends its 16-bit
counter, and the port converts hardware ticks to microseconds outside the timed
region. The API reports 1 MHz ticks; zero or saturated readings fail validation.
The rollover ISR is included in the measured interval. See [CMT](cmt.md).
UART reporting is outside the timed region. Scores describe this XIP memory
configuration, including flash access latency.

## Build and run

```sh
. tools/env.sh
make coremark-build             # both standard seed sets; 300 iterations each
make coremark-sim               # full SoC/XIP simulation; both seed sets
export TD_HOME=/path/to/TD_4.6.7_Linux
make coremark-fpga-build        # FPGA build and timing checks
make coremark-hw                # ttyACM0 at 19200 baud; 300 iterations per seed set

make BOARD=wukong-v1 coremark-fpga-build
make BOARD=wukong-v1 coremark-hw # ttyUSB0; volatile Vivado programming and SF3 upload
```

`coremark-hw` reloads FPGA SRAM and replaces the dedicated application flash
image through the UART loader for each seed set. It leaves the validation
workload installed. Wukong backs up affected SF3 sectors before each upload.
Configuration flash is untouched. Clock and SRAM size come from the selected
board profile; leave `J2_CLOCK_HZ` unset to use that profile. Set `COREMARK_ITERATIONS`
to override the count. Both simulator and hardware runs must measure at least
ten seconds per seed set; the default is 300 iterations. Faster configurations may need more
iterations: the runner rejects results below ten seconds. Simulation allows
1,800 seconds of host time per seed set and two billion simulated clocks.
The CMT/SCIF regression measured 34.747184 seconds for 300 performance iterations;
its 100-iteration validation-seed check measured 11.621744 seconds. Both passed
CRCs. These checks used different iteration counts; see [CMT validation notes](cmt.md#validation-notes).
For intentional short CRC regressions, build with a smaller count and invoke
`tools/coremark.py sim` or `hardware` with matching `--iterations` and
`--allow-short`. Such runs are not reportable scores, following
[CoreMark's run rules](https://github.com/eembc/coremark#run-rules).

New results default to `build/coremark/<board>/refactored/{simulation,hardware}/`, with
logs, firmware binaries, compiler settings, CRCs, raw timer ticks, derived
iterations/second and CoreMark/MHz, RTL, and hardware bitstream/timing reports.
Both performance and validation seed sets must pass. The integer-only firmware
report truncates rates below one iteration/second; use the JSON rate computed
from the raw timer ticks for comparisons. Completion markers alone do not
establish a pass: the runner checks expected CRCs, timer readings, iteration
counts, upstream error output, and CMT ISR counts consistent with elapsed ticks.
Firmware is built under `build/sw/coremark/<board>/<clock>/<seed>-<iterations>/`.

## INTC validation on Wukong (2026-11-19)

The 72 MHz FPGA passes both seed sets with 300 iterations, cached SPI XIP code
and internal SRAM data/stack. Both exceed ten measured seconds and pass all
expected CRCs; each services 33 CMT rollover interrupts.

| Seed set | Time (s) | Iterations/s | CoreMark/MHz |
| --- | ---: | ---: | ---: |
| Performance | 15.720369 | 19.083522 | 0.265049 |
| Validation | 15.772302 | 19.020686 | 0.264176 |

Results, UART logs, firmware, RTL and routed timing reports are archived in
`build/coremark/wukong-v1/intc-closeout/hardware/`. Per-seed `*-board/` directories
contain volatile programming logs and SF3 backups. The validation application
was restored and passed INTC/ISA checks; evidence is in the adjacent `restored/`
directory. These runs use the existing timing-qualified 72 MHz bitstream.

The updated Tang workflow also passes both one-iteration native simulation
seeds under `build/coremark/tang-primer/intc-closeout/simulation/`. These are
short CRC regressions; the prior full-duration Tang qualification is recorded in
[the PPB/INTC reference](ppb-intc.md#firmware).

## Both-board hardware confirmation (2026-11-19)

Both standard seed sets were rerun on both physical boards with **300 iterations
per seed** using the existing timing-qualified bitstreams. All four runs pass
the expected CRCs and exceed ten measured seconds. CMT ISR counts agree with
the timer readings.

| Board | Clock (MHz) | Seed set | Time (s) | CoreMark/MHz | CMT interrupts |
| --- | ---: | --- | ---: | ---: | ---: |
| Tang Primer | 32 | Performance | 34.766304 | 0.269658 | 33 |
| Tang Primer | 32 | Validation | 34.883072 | 0.268755 | 33 |
| Wukong | 72 | Performance | 15.720369 | 0.265049 | 33 |
| Wukong | 72 | Validation | 15.772302 | 0.264176 | 33 |

Results, UART logs, firmware, RTL and timing evidence are in
`build/coremark/{tang-primer,wukong-v1}/board-confirmation/hardware/`.
The corresponding top-level logs are `build/coremark-tang-board-hw.log` and
`build/coremark-wukong-board-hw.log`. Both normal validation applications were
restored and passed their INTC/ISA checks; Tang also passed a fresh volatile
reboot. Restore evidence is under each board's `board-confirmation/restored/`.

## Historical cached-XIP comparison

**CoreMark/MHz = (iterations / elapsed seconds) / clock frequency in MHz.**
The historical matched ten-iteration, 32 MHz regression results are:

| Seed set | VHDL reference simulator, zero-wait RAM | SpinalHDL FPGA, cached XIP |
|---|---:|---:|
| Performance | **1.885426 CM/MHz** | **0.417846 CM/MHz** |
| Validation | **1.880480 CM/MHz** | **0.416971 CM/MHz** |

Both implementations pass all algorithm CRC checks. The VHDL run executes code
from zero-wait-state RAM, while the SpinalHDL run executes through the two-way
XIP cache, so this is a system-level comparison rather than an isolated CPU-core
benchmark. Both runs are shorter than ten seconds and are not reportable
CoreMark scores. Sources are `build/coremark/vhdl-independent/results.json` and
`build/coremark/spinal-cache-independent/hardware/results.json`.

## Comparing results

The original results are preserved under `build/coremark/baseline/` and in
`build/coremark/baseline-2cfc302.tar.gz`. Set `COREMARK_LABEL` to choose a separate
destination for another candidate, using the same iteration counts. Compare
matching result files with:

```sh
make coremark-compare \
  COREMARK_BASELINE=build/coremark/baseline/hardware/results.json \
  COREMARK_CANDIDATE=build/coremark/tang-primer/refactored/hardware/results.json
python3 -m unittest discover -s tools -p test_coremark.py -v
```

Comparison rejects mismatched firmware hashes, compiler settings, seed sets,
iteration counts, boards, clock frequencies, and execution environments. Older
reports without a board field are treated as Tang Primer. Reuse the
saved firmware binaries when testing CPU changes.

## Pre-refactor baseline

The pre-refactor CPU at `2cfc302` passed both one-iteration simulations and
ten-iteration FPGA runs at 32 MHz. Its XIP performance and validation results
were **0.007764 CM/MHz** and **0.007752 CM/MHz**, respectively. Both passed the
upstream CRC checks and minimum duration requirement. The timer-enabled FPGA
passed timing with 0.384 ns setup and 0.104 ns hold slack. Logs and binaries
are under `build/coremark/baseline/`.
