`timescale 1ns/1ps

module golay_top #(
	parameter int NB_WORD     = 12,
	parameter int NB_CODEWORD = 12,
	parameter int I_DIM       = NB_WORD
)(
	input   logic [NB_WORD     - 1 : 0] i_word       ,
	input   logic [NB_CODEWORD - 1 : 0] i_error      ,	
	input   logic                       i_rst        ,
	input   logic                       i_clk        ,
	output  logic [NB_WORD     - 1 : 0] o_msg        ,
	output  logic [NB_CODEWORD - 1 : 0] o_err        ,
	output  logic 			    o_corrected  ,
	output  logic [NB_WORD     - 1 : 0] o_uncorrected	
);

logic [NB_CODEWORD - 1 : 0] cw;
logic [NB_CODEWORD - 1 : 0] codeword_with_errors;

golay_encoder #(
	.NB_WORD    (NB_WORD)    ,
	.NB_CODEWORD(NB_CODEWORD),
	.I_DIM      (NB_WORD)	
) u_golay_encoder (
	.i_word     (i_word)     ,
	.cw 	    (cw)	
);

error_injection #(
	.NB_CODEWORD(NB_CODEWORD)	
) u_error_injection (
	.i_codeword            (cw)                  ,
	.i_error               (i_error)             ,
	.o_codeword_with_errors(codeword_with_errors)
);

decoder #(
	.NB_WORD    (NB_WORD)    ,
	.NB_CODEWORD(NB_CODEWORD)	
) u_decoder (
	.i_rx           (codeword_with_errors),
	.i_rst          (i_rst)               ,
	.i_clk          (i_clk)               ,
	.o_msg          (o_msg)               ,
	.o_err          (o_err)               ,
	.o_corrected    (o_corrected)         ,
	.o_uncorrectable(o_uncorrectable)     
);

endmodule
