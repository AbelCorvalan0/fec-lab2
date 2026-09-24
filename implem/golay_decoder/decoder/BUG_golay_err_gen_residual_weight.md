# Bug: `golay_err_gen` residual-weight inputs wired to the wrong signals

## Status
Open (root cause identified, not fixed yet).

## Symptom

Running the `decoder` UVM testbench (`decoder.uvm`, `codewords_with_error_sequence`
against `codeword_with_errors.txt`) produces a large number of `uvm_error`
mismatches in `tb_scoreboard.svh`: for many received codewords with weight-2
and weight-3 errors, the DUT reports `o_corrected = 0` / `o_uncorrectable = 1`
and `o_err = 0`, instead of correcting the codeword as expected.

Example from `simulate.log` (`decoder.sim/sim_1/behav/xsim/simulate.log`),
`@850000`:

```
[MSG ERROR] rx=6febb4 : DUT=0006fe, esperado=000efe
[ERR ERROR] rx=6febb4 : DUT=000000000000000000000000, esperado=100000000000100000000000
[CORRECTED ERROR] rx=6febb4 : DUT=0, esperado=1
[UNCORRECTABLE ERROR] rx=6febb4 : DUT=1, esperado=0
```

Note: the `rx=` printed by the scoreboard is off by 3 lines from the actual
received codeword (see [Side note](#side-note-misleading-rx-label-in-the-log)
below) — the real received word for this failure is line 37 of
`decoder.uvm/sequences/codeword_with_errors.txt`:

```
011011111110001010110100 111011111110 100000000000100000000000 1 0
```

i.e. a weight-2 error (1 bit in the message half, 1 bit in the parity half),
which the Golay(24,12) code can always correct.

## Root cause

`decoder.sv`, in the `golay_err_gen` instantiation (`err_gen_inst`,
around lines 171-191):

```systemverilog
golay_err_gen #(...) err_gen_inst (
    .i_syn              ( syndrome_dd                   ),
    .i_q                ( q_vector_d                    ),
    .i_res_syn          ( row_search_s_res_d            ),
    .i_res_q            ( row_search_q_res_d            ),
    .i_w_syn            ( weight_s_d                    ),
    .i_w_q              ( weight_q_d                    ),
    .i_idx_syn          ( row_search_s_row_index_d      ),
    .i_idx_q            ( row_search_q_row_index_d      ),
    .i_found_syn        ( row_search_s_found_d          ),
    .i_found_q          ( row_search_q_found_d          ),
    .i_w_res_syn        ( weight_s_d                    ),   // BUG
    .i_w_res_q          ( weight_q_d                    ),   // BUG
    .o_err              ( err_gen_err                   ),
    .o_uncorrectable    ( err_gen_uncorrectable         )
);
```

`golay_err_gen.sv` implements the standard 4-case Golay decode:

1. `w(s) <= 3` → error entirely in the parity half.
2. `found_syn && w(s ^ bi) <= 2` → 1 error in the message half (row `bi`),
   ≤2 in the parity half.
3. `w(q) <= 3` → error entirely in the message half.
4. `found_q && w(q ^ bi) <= 2` → 1 error in the parity half (row `bi`),
   ≤2 in the message half.
5. else → uncorrectable (≥4 errors).

Case 2 needs `i_w_res_syn` to be **the Hamming weight of the row-search
residual `row_search_s_res_d` (i.e. `w(s ^ bi)`)**. Case 4 needs `i_w_res_q`
to be **the weight of `row_search_q_res_d` (`w(q ^ bi)`)**.

Instead, both are wired to `weight_s_d` / `weight_q_d` — the weight of the
*original* syndrome/`q` vectors (`w(s)` / `w(q)`), which is a completely
different quantity. `decoder.sv` never instantiates a `popcount` on
`row_search_s_res` / `row_search_q_res` at all — that computation is simply
missing.

### Why this produces the observed symptom

For the example above (`s` has `w(s) = 6`, row search finds `bi = b0` with
residual weight `w(s ^ b0) = 1`):

- Correct case 2 check: `found_syn (1) && w(s^bi) <= 2` → `1 && (1 <= 2)` → **true**, corrects.
- Actual RTL check: `found_syn (1) && w(s) <= 2` → `1 && (6 <= 2)` → **false**.

Since `w(s) <= 3` (case 1) is also false, and `w(q)`/case-3/case-4 are
symmetric and fail the same way, execution falls through to the `else`
branch → `o_err = 0`, `o_corrected = 0`, `o_uncorrectable = 1`. This matches
the log exactly.

Verified independently against the Python golden model
(`model/classes/GolayDecoder.py`) for two failing cases pulled from
`simulate.log` (file lines 37 and 2105 of `codeword_with_errors.txt`); in
both, `w(s)`/`w(q)` (6-ish) is what actually gets compared against `<= 2`
instead of the true residual weight (1), so case 2/4 never fires even though
it should.

This also explains why msg/err/corrected/uncorrectable fail together in
almost every mismatch in the log: once the wrong branch is taken, all four
outputs derive from it.

## Fix

In `decoder.sv`, add two `popcount` instances (stage 2, alongside
`weight_s_inst` / `weight_q_inst`) computing the weight of
`row_search_s_res` / `row_search_q_res`, pipe those through `pipe_stage_2`,
and wire the resulting `weight_s_res_d` / `weight_q_res_d` signals into
`i_w_res_syn` / `i_w_res_q` of `err_gen_inst` instead of `weight_s_d` /
`weight_q_d`.

## Side note: misleading `rx=` label in the log

`decoder.uvm/tb_monitor.svh` samples `item.rx_data = vif.i_rx` in the same
clock edge as `o_msg`/`o_err`/etc, but the DUT has a 3-cycle pipeline
latency from `i_rx` to those outputs. So the `rx=` printed by the
scoreboard on a mismatch is always 3 codewords *ahead* of the codeword that
actually produced the printed DUT output — useful to know when
cross-referencing failures against `codeword_with_errors.txt` (subtract 3
lines from wherever the printed `rx` value is found in the file). This does
not affect the scoreboard's pass/fail verdict itself, only the debug
message's readability.
