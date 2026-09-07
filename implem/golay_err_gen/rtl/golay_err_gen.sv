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

localparam int NB_WORD = 12; 

logic [23 : 0] prev_err;

localparam logic [3:0] COND_1 = 4'd3;
localparam logic [3:0] COND_2 = 4'd2;


// 1. w(s) <= 3
// 2. found_syn && w(s^bi) <= 2
// 3. w(q) <= 3
// 4. found_q && w(q^bi) <= 2
// 5. uncorrectable
always_comb begin
     prev_err        =   '0;
     o_uncorrectable = 1'b0;

	if (i_w_syn <= COND_1) begin
		prev_err = {{NB_WORD{1'b0}}, i_syn};	
	end
	else if (i_found_syn && (i_w_res_syn <= COND_2)) begin 
		prev_err = {(24'b1 << (i_idx_syn + NB_WORD)) | {12'b0 , i_res_syn}};
     end
	else if (i_w_q <= COND_1) begin
		prev_err = {i_q, {NB_WORD{1'b0}}};
	end
	else if (i_found_q && (i_w_res_q <= COND_2)) begin
		prev_err = {i_res_q, 12'b0} | (24'b1 << i_idx_q);
     end
     else begin
          o_uncorrectable = 1'b1;
     end
end

assign o_err = prev_err;

endmodule
