`timescale 1ns/1ps

module golay_wrapper #(
    parameter int NB_WORD     = 12,
	parameter int NB_CODEWORD = 24,
	parameter int I_DIM       = NB_WORD
)(
	input   logic [NB_WORD     - 1 : 0] i_word         ,
	input   logic [NB_CODEWORD - 1 : 0] i_error        ,	
	input   logic                       i_rst          ,
	input   logic                       i_clk          ,
	output  logic [NB_WORD     - 1 : 0] o_msg          ,
	output  logic [NB_CODEWORD - 1 : 0] o_err          ,
	output  logic 			    		o_corrected    ,
	output  logic                       o_uncorrectable
);

logic [NB_WORD - 1 : 0] reg_1;

always_ff @(posedge i_clk) begin
    if (!i_rst) begin
        word_reg <= '0
    end
    else begin
        word_reg <= i_word;
    end
end

golay_top #(
	.NB_WORD     (NB_WORD)     ,
	.NB_CODEWORD (NB_CODEWORD) ,
	.I_DIM       (NB_WORD)
)(
	.i_word          (i_word)         ,
	.i_error         (i_error)        ,	
	.i_rst           (i_rst)          ,
	.i_clk           (i_clk)          ,
	.o_msg           (o_msg)          ,
	.o_err           (o_err)          ,
    .o_corrected     (o_corrected)    ,
	.o_uncorrectable (o_uncorrectable)
);

endmodule