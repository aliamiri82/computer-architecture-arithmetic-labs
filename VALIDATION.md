# Validation

Checked on 2026-10-23.

- QuestaSim 2024.1 compiled the retained arithmetic designs and testbenches.
- Unsigned `multiplier2`: 100/100 original comparison vectors matched.
- Signed parameterized Booth multiplier: 1,000/1,000 original comparison vectors matched.
- Floating-point adder: 58 directed cases and 260,100 randomized exponent/sign cases completed with zero reported mismatches, using the configurable default sweep.
- Two other multiplier variants failed their original comparisons and were removed from this repository. MIPS templates/incomplete versions and a copy naming another student were also excluded.
- Testbench clocks and random-run length were adjusted; arithmetic design logic was retained.
- Passing these tests does not establish exhaustive parameter coverage, ready-signal behavior, or full IEEE 754 compliance.
