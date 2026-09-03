`timescale 1ns/1ps

module golay_err_gen(
     input logic [11 : 0] i_syn, //s
     input logic [11 : 0]   i_q, //q
     
     input logic [11 : 0] i_res_syn, //s^bi
     input logic [11 : 0] i_res_q,   //q^bi 

     input logic [3  : 0] i_w_syn,   //w(s)
     input logic [3  : 0] i_w_q,     //w(q)

     input logic [3  : 0] i_idx_syn, //for {u_{i}, s^bi}
     input logic [3  : 0] i_idx_q,   //for {q^bi, u_{i}} 

     input logic          i_found_syn, // se encontró índice síndrome (flag)
     input logic          i_found_q,   // se encontró índice q (flag)

     output logic [23 : 0] o_err,      // error mask
     output logic          o_uncorrectable, // uncorrectable flag

     input logic  [3  : 0] i_w_res_syn, // w(s^bi)
     input logic  [3  : 0] i_w_res_q    // w(q^bi)

);

localparam int NB_WORD = 11; 

logic [2 : 0] prev_err;

always_comb begin
	if (i_w_syn <= 3) begin
		prev_err = {{NB_WORD{1'b0}}, i_syn};	
	end
	else if (i_w_res_syn <= 2) begin
		prev_err = {(1 << (i_idx_syn + NB_WORD)), i_res_syn};
	end
	else if (i_w_q <= 3) begin
		prev_err = {i_q, {NB_WORD{1'b0}}};
	end
	else if (i_w_res_q <= 2) begin
		prev_err = {i_res_q, (1 << i_idx_q)};
	end
end

assign o_err = prev_err;

endmodule
