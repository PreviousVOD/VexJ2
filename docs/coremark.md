# CoreMark benchmark

[Project overview](../README.md) · [Development](development.md)

The commands on this page target Tang Primer at 32 MHz. They use its UART
loader and FPGA tools; they are not a Wukong hardware workflow. Run commands
from the repository root. The later hybrid-decoder results are recorded in
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

The architecture timer measures the benchmark at 1 MHz with interrupts disabled.
Its limit is set to `0xffffffff`; zero or saturated readings fail validation.
UART reporting is outside the timed region. Scores describe this XIP memory
configuration, including flash access latency.

## Build and run

```sh
. tools/env.sh
export J2_CLOCK_HZ=32000000
make coremark-build             # both standard seed sets; 300 iterations each
make coremark-sim               # full SoC/XIP simulation; both seed sets
export TD_HOME=/path/to/TD_4.6.7_Linux
make coremark-fpga-build        # timer-enabled FPGA, timing and PLL checks
make coremark-hw                # ttyACM0 at 19200 baud; 300 iterations per seed set
```

`coremark-hw` reloads FPGA SRAM and replaces the dedicated application flash
image through the UART loader for each seed set. It leaves the validation
workload installed. Configuration flash is untouched. Set `COREMARK_ITERATIONS`
to override the count. Both simulator and hardware runs must measure at least
ten seconds per seed set; the default 300 iterations targets about 16 seconds
on the current cached 32 MHz core. Faster configurations may need more
iterations: the runner rejects results below ten seconds. Simulation allows
1,800 seconds of host time per seed set and one billion simulated clocks.
For intentional short CRC regressions, build with a smaller count and invoke
`tools/coremark.py sim` or `hardware` with matching `--iterations` and
`--allow-short`. Such runs are not reportable scores, following
[CoreMark's run rules](https://github.com/eembc/coremark#run-rules).

New results default to `build/coremark/refactored/{simulation,hardware}/`, with
logs, firmware binaries, compiler settings, CRCs, raw timer ticks, derived
iterations/second and CoreMark/MHz, RTL, and hardware bitstream/timing reports.
Both performance and validation seed sets must pass. The integer-only firmware
report truncates rates below one iteration/second; use the JSON rate computed
from the raw timer ticks for comparisons. Completion markers alone do not
establish a pass: the runner checks expected CRCs, timer readings, iteration
counts, and upstream error output.

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
  COREMARK_CANDIDATE=build/coremark/refactored/hardware/results.json
python3 -m unittest discover -s tools -p test_coremark.py -v
```

Comparison rejects mismatched firmware hashes, compiler settings, seed sets,
iteration counts, clock frequencies, and execution environments. Reuse the
saved firmware binaries when testing CPU changes.

## Pre-refactor baseline

The pre-refactor CPU at `2cfc302` passed both one-iteration simulations and
ten-iteration FPGA runs at 32 MHz. Its XIP performance and validation results
were **0.007764 CM/MHz** and **0.007752 CM/MHz**, respectively. Both passed the
upstream CRC checks and minimum duration requirement. The timer-enabled FPGA
passed timing with 0.384 ns setup and 0.104 ns hold slack. Logs and binaries
are under `build/coremark/baseline/`.
