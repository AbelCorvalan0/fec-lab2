`timescale 1ns/1ps

module error_injection #(
	parameter int NB_CODEWORD = 24	
)(
	input  logic [NB_CODEWORD - 1 : 0] i_codeword,
	input  logic [NB_CODEWORD - 1 : 0] i_error,
	output logic [NB_CODEWORD - 1 : 0] o_codeword_with_errors
);

assign o_codeword_with_errors = i_codeword ^ i_error; 

endmodule
