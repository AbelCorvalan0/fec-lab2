class err_gen_model extends uvm_object;       
	`uvm_object_utils(err_gen_model)

	function new(string name = "err_gen_model");
		super.new(name);
	endfunction

	localparam int       NB_WORD = tb_pkg::NB_WORD; // 12
	localparam bit [3:0] COND_1  = tb_pkg::COND_1;  // 3
	localparam bit [3:0] COND_2  = tb_pkg::COND_2;  // 2

	// Given the inputs carried bt `t`, predict the DUT outputs.
	function void predict(seq_item t,
			      output bit [tb_pkg::NB_ERR - 1 : 0] err,
			      output bit                          uncorr);

		err    =   '0;
		uncorr = 1'b0;

		if (t.i_w_syn <= COND_1) begin
			err = {12'b0, t.i_syn};
		end
		else if (t.i_found_syn && (t.i_w_res_syn <= COND_2)) begin
			err = (24'd1 << (t.i_idx_syn + NB_WORD)) | {12'b0, t.i_res_syn}; // arm 2
		end
		else if (t.i_w_q <= COND_1) begin
			err = {t.i_q, 12'b0}; // arm 3
		end
		else if (t.i_found_q && (t.i_w_res_q <= COND_2)) begin
        		err = {t.i_res_q, 12'b0} | (24'd1 << t.i_idx_q); //arm 4
        	end
        	else begin
            		uncorr = 1'b1;  // arm 5
        	end
	endfunction

endclass
