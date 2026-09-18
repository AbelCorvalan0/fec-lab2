# Golay decoder test vector files

All `.txt` files below are plain-text, space-separated tables generated from
their matching `.svh` file, following the same column layout used by the
encoder's `golay_encoder_vectors.txt`. Each line is one test case; each
column is a fixed-width binary string (no `NB'b` prefix, no separators other
than the single space between columns, no header row).

Field meaning by column:

- `codeword` (24 bits): a Golay(24,12) codeword, `[NB_CODEWORD-1:0]`.
- `message` (12 bits): the 12-bit decoded/original message word, `[NB_WORD-1:0]`.
- `flag` (1 bit): `1` or `0`.

## decoder_testing/codewords/codewords_testing_golay_code.txt

Golden case: codewords received with **no** induced errors.

| # | Column | Width | Meaning |
|---|--------|-------|---------|
| 1 | `golay_code` | 24 | Transmitted/received codeword (clean, no errors injected) |
| 2 | `decoded_data` | 24 | Codeword reconstructed by the decoder after correction |
| 3 | `msg` | 12 | Decoded 12-bit message extracted from the codeword |
| 4 | `err` | 24 | Error pattern recovered by the decoder (`rx XOR original codeword`) |
| 5 | `corrected_data` | 1 | Corrected flag: `1` if the decoder applied a correction |
| 6 | `uncorrectable` | 1 | Uncorrectable flag: `1` if the decoder could not correct the codeword |

## decoder_testing/error_1_vectors/codewords_testing_golay_1_error.txt
## decoder_testing/error_2_vectors/codewords_testing_golay_2_error.txt
## decoder_testing/error_3_vectors/codewords_testing_golay_3_error.txt
## decoder_testing/error_4_vectors/codewords_testing_golay_4_error.txt

Same layout, one file per induced error count (1 to 4 bit-flips applied to
the transmitted codeword before decoding). `N` below is `1`, `2`, `3` or `4`
depending on the file.

| # | Column | Width | Meaning |
|---|--------|-------|---------|
| 1 | `rx_N_error_vector` | 24 | Received codeword with `N` induced bit errors |
| 2 | `msg_N_error_vector` | 24 | Decoded/corrected codeword produced by the decoder |
| 3 | `err_pattern_N_error` | 24 | Recovered error pattern for the `N`-error input |
| 4 | `corrected_flag_N_error` | 1 | Corrected flag for the `N`-error input |
| 5 | `uncorrectable_flag_N_error` | 1 | Uncorrectable flag for the `N`-error input |

## decoding_vectors_test/codewords_testing_golay_test.txt

A small (3-row) hand-picked selection of received test vectors
(`0xA5D9A6`, `0xA5F9A4`, `0xA5C9AA`) used for directed/sanity testing.

| # | Column | Width | Meaning |
|---|--------|-------|---------|
| 1 | `rx_test_vectors` | 24 | Selected received codeword |
| 2 | `msg_test_vectors` | 12 | Decoded message for the selected codeword |
| 3 | `err_pattern_test_vectors` | 24 | Recovered error pattern for the selected codeword |
| 4 | `corrected_flag_test_vectors` | 1 | Corrected flag for the selected codeword |
| 5 | `uncorrectable_flag_test_vectors` | 1 | Uncorrectable flag for the selected codeword |

## codewords_testing_golay_code.txt (top level)

Same golden-case (no errors) data set as
`decoder_testing/codewords/codewords_testing_golay_code.txt`, but without the
decoded `msg` column.

| # | Column | Width | Meaning |
|---|--------|-------|---------|
| 1 | `golay_code` | 24 | Transmitted/received codeword (clean, no errors injected) |
| 2 | `decoded_data` | 24 | Codeword reconstructed by the decoder after correction |
| 3 | `err` | 24 | Error pattern recovered by the decoder (`rx XOR original codeword`) |
| 4 | `corrected_data` | 1 | Corrected flag: `1` if the decoder applied a correction |
| 5 | `uncorrectable` | 1 | Uncorrectable flag: `1` if the decoder could not correct the codeword |

## golay_encoder_vectors.txt (reference format)

Copied from the encoder project; used as the formatting reference for all
files above.

| # | Column | Width | Meaning |
|---|--------|-------|---------|
| 1 | `message` | 12 | Input message word to the encoder |
| 2 | `codeword` | 24 | Golay(24,12) codeword produced by the encoder for that message |
