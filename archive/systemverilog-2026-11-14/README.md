# SystemVerilog infrastructure archive

This directory freezes the J2 SystemVerilog implementation at the point where
the project switched to planning a SpinalHDL redesign.

Contents:

- `systemverilog-source-snapshot.tar.gz`: RTL, tests, simulators, generators,
  software sources and build metadata.
- `tracked-changes.patch`: binary-safe diff of tracked repository changes.
- `git-status.txt`: working-tree state when the snapshot was made.

The archive is intentionally separate from `build/` and contains no generated
bitstreams, logs, extracted original VHDL, or downloaded toolchains.

The SystemVerilog files remain in the working tree for now as reference input
and as a source of validation models. They are no longer the active redesign
target.
