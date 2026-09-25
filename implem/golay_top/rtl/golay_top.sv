`timescale 1ns/1ps

module golay_top #(
	parameter int NB_WORD     = 12,
	parameter int NB_CODEWORD = 12,
	parameter int I_DIM       = NB_WORD
)(
	input  logic [NB_WORD     - 1 : 0] i_word,
	output logic [NB_CODEWORD - 1 : 0] cw


);

endmodule
