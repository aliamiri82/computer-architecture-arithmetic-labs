# Computer Architecture Arithmetic Labs

Verilog coursework on unsigned iterative multiplication, signed Booth multiplication, and a 32-bit floating-point adder.

Coursework by **Ali Amiri**, Sharif University of Technology. Semester 4 — Computer Architecture Laboratory.

## Contents

- `multipliers/`: unsigned iterative and signed Booth designs with their matching testbenches. Other variants that failed their original arithmetic comparisons were omitted.
- `floating-point/`: exponent alignment, signed fractions, normalization, rounding, and supplied directed/random tests.

Example with Questa/ModelSim, from `floating-point/`:

```text
vlib work
vlog -sv SEF_Adder.v fp_adder__tb3.sv
vsim -c fp_adder__tb3 -do "run -all; quit -f"
```

These are educational arithmetic designs. Full IEEE 754 compliance and exhaustive arithmetic correctness are not claimed. MIPS copies with incomplete control logic or another student's name are not included.

## Scope and attribution

This repository is a curated coursework archive. Original exercise structure and existing credits are retained; course-provided interfaces and testbenches may be present. Bundled textbooks, assignment PDFs, vendor IP implementations, binaries, and IDE caches are excluded. No blanket open-source license has been added to material with mixed course provenance.

See `VALIDATION.md` for checks and known limits.

The floating-point test defaults to 58 directed cases and one 260,100-case randomized exponent/sign sweep. Pass `+iterations=200` to `vsim` for the original long randomized run. Multiplier testbench clock generation was adjusted to work consistently in SystemVerilog. Arithmetic design logic is otherwise retained.
