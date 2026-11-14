# Microcode ROM exploration

The reference CPU includes a 256-entry by 72-bit control ROM
(`reference/soc_top/components/cpu/decode/decode_table_rom.vhd`).

- ROM storage: 18,432 bits, or 2.25 KiB.
- Address generation: an 8-bit predecoder maps each opcode to the first
  microcode line.
- Control execution: each instruction advances through one to eight 72-bit
  microcode lines until the `dispatch` control is asserted.
- The microcode stores correlated control fields, so 72 bits replace several
  separately encoded datapath fields.

Run the TD comparison with:

```sh
TD_HOME=/home/imi415/Softwares/Tools/TD_4.6.7_Linux \
  experiments/microcode_rom/run_td_probe.sh
```

Artifacts are written under ignored `build/fpga/microcode_probe` and reports
under `build/logs/td`.

## TD results

The comparison uses the original J2 register file, datapath, multiplier,
on-chip BRAM, and UART so that only decoder/control implementation changes.

| Design | LUT | Registers | MSLICE | DSP | Notes |
|---|---:|---:|---:|---:|---|
| Current SpinalHDL combinational executor | 25,302 | 1,161 | 7,873 | 6 | placement rejected |
| Reference reverse decoder | ~4,304 | ~984 | ~4,400 logic elements | 2 | prior board baseline |
| Reference microcode constant | 4,568 | 1,053 | 1,183 | 2 | 53 LUT-ROM instances |
| Reference microcode in explicit EG4 BRAM | 3,991 | 985 | 1,038 | 2 | **fits EG4S20** |

The explicit block-ROM variant:

- Uses five `BRAM32K` blocks for the 256 x 72-bit control ROM.
- Leaves three `BRAM32K` blocks available after the eight-block program RAM.
- Maps at 24 MHz with 0 setup errors and 4 known clock-mesh hold errors.
- Has a 26.550 ns minimum period (37.665 MHz).

Simply inserting a microcode ROM in front of the current `Sh2Core` semantic
switch would not remove that switch's LUT cost. The useful path is to port the
reference three-bus pipeline and microsequencer into SpinalHDL, then back the
72-bit control table with an explicit EG4 block ROM.

The reference table implements the J2 instructions `SHAD`, `SHLD`, `CAS.L`,
and `BGND`. They are now legal in the SpinalHDL decoder and core as well.
