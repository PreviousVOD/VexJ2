# AGENTS.md — VexJ2

## Basic Guidance

- Terms
    - The keywords "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED",  "MAY",
      and "OPTIONAL" in this document are to be interpreted as described in RFC 2119.

- Ask for more information
    - If more information required which can not be located in project directory, agents SHALL ask for the user to
      download and acquire for them.

- Code style for C/C++
    - Make coding style as consistent as possible.
    - Format code using clang-format before commit.
    - Additional coding style
        - Brace every if, including single-statement guards.
        - Prefer one preflight check per guard; avoid long ||/&& chains.
        - Leave a blank line after if blocks and before return.
        - Separate completed switch cases with a blank line, except the last; keep fall-through labels together.
        - Keep functions, if statements, and case bodies expanded.
        - Align consecutive declarations, macros, assignments, and compound assignments.
        - Group includes so clang-format's include sorting keeps them in place: standard headers first, then one
          block per module headed by a `/* <Name> */` comment (e.g. `/* SDK */`, `/* FreeRTOS */`,
          `/* Board */`), separated by blank lines; project-owned headers last under `/* App */`.

## Primary goal and duty

This is the VexJ2 CPU which is compatible with SuperH SH2 ISA, modelling J2 and VexRiscv. It follows SH-2 pipelining but with a
re-designed AHB5 interface. The mission is to:

- Implement ISA features and perform validations against the ISA documentation
- Make the core and SoC re-usable and modular, which fits into different design.
