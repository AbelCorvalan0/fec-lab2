`timescale 1ns/1ps

module golay_err_gen #(
     parameter int NB_WORD = 12,
     parameter int NB_ERR  = 24,
     parameter int NB_CNT  =  4
)(
     input  logic [NB_WORD - 1 : 0] i_syn, //s
     input  logic [NB_WORD - 1 : 0]   i_q, //q
     input  logic [NB_WORD - 1 : 0] i_res_syn, //s^bi
     input  logic [NB_WORD - 1 : 0] i_res_q,   //q^bi 
     input  logic [NB_CNT  - 1 : 0] i_w_syn,   //w(s)
     input  logic [NB_CNT  - 1 : 0] i_w_q,     //w(q)
     input  logic [NB_CNT  - 1 : 0] i_idx_syn, //for {u_{i}, s^bi}
     input  logic [NB_CNT  - 1 : 0] i_idx_q,   //for {q^bi, u_{i}} 
     input  logic                   i_found_syn, // se encontró índice síndrome (flag)
     input  logic                   i_found_q,   // se encontró índice q (flag)
     output logic [NB_ERR  - 1 : 0] o_err,      // error mask
     output logic                   o_uncorrectable, // uncorrectable flag
     input  logic [NB_CNT  - 1 : 0] i_w_res_syn, // w(s^bi)
     input  logic [NB_CNT  - 1 : 0] i_w_res_q    // w(q^bi)
);

//localparam int NB_WORD = 12; 

logic [23 : 0] prev_err;
logic [NB_WORD - 1 : 0] ui_vector;
logic                    case_1    ;
logic                    case_2    ;
logic                    case_3    ;
logic                    case_4    ;

localparam logic [3:0] COND_1 = 4'd3;
localparam logic [3:0] COND_2 = 4'd2;

localparam logic [23:0] ui_value = 24'h800000;


always_comb begin
     ui_vector = '0;
     if (i_found_syn) begin
          ui_vector = 12'h800 >> i_idx_syn;
     end
     else if (i_found_q) begin
          ui_vector = 12'h800 >> i_idx_q;
     end
end

// case1. w(s)      <= 3
// case2. w(s^bi)   <= 2
// case3. w(q)      <= 3
// case4. w(q^bi)   <= 2
// case5. uncorrectable
assign case_1  = (i_w_syn     <= COND_1)                ;
assign case_2  = (i_w_res_syn <= COND_2) && i_found_syn ;
assign case_3  = (i_w_q       <= COND_1)                ;
assign case_4  = (i_w_res_q   <= COND_2) && i_found_q   ;

always_comb begin
     prev_err        =   '0;
     o_uncorrectable = 1'b0;

	if (case_1) begin
		prev_err = {{NB_WORD{1'b0}}, i_syn};	
	end
	else if (case_2) begin 
		prev_err = {ui_vector, i_res_syn};
     end
	else if (case_3) begin
		prev_err = {i_q, {NB_WORD{1'b0}}};
	end
	else if (case_4) begin
		prev_err = {i_res_q, ui_vector};
     end
     else begin
          o_uncorrectable = 1'b1;
     end
end

assign o_err = prev_err;

endmodule
