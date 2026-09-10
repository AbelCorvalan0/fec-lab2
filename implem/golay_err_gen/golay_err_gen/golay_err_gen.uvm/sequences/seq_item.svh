class seq_item extends uvm_sequence_item;

	// ----- stimulus: DUT inputs -----
	rand bit [tb_pkg::NB_WORD - 1 : 0] i_syn; 	   
	rand bit [tb_pkg::NB_WORD - 1 : 0] i_q  ;
	rand bit [tb_pkg::NB_WORD - 1 : 0] i_res_syn;
	rand bit [tb_pkg::NB_WORD - 1 : 0] i_res_q; 	   
	rand bit [tb_pkg::NB_CNT  - 1 : 0] i_w_syn;
	rand bit [tb_pkg::NB_CNT  - 1 : 0] i_w_q;
        rand bit [tb_pkg::NB_CNT  - 1 : 0] i_idx_syn;
	rand bit [tb_pkg::NB_CNT  - 1 : 0] i_idx_q;	
	rand bit	                   i_found_syn;
        rand bit	                   i_found_q;  
        rand bit [tb_pkg::NB_CNT - 1: 0]   i_w_res_syn;
        rand bit [tb_pkg::NB_CNT - 1: 0]   i_w_res_q;

	bit [tb_pkg::NB_ERR - 1 : 0] o_err;
	bit                          o_uncorrectable;

	// ----- automation ------
	`uvm_object_utils_begin(seq_item)
		`uvm_field_int(i_syn,  UVM_DEFAULT | UVM_HEX)
	        `uvm_field_int(i_q,  UVM_DEFAULT | UVM_HEX)
	        `uvm_field_int(i_res_syn,  UVM_DEFAULT | UVM_HEX)
	        `uvm_field_int(i_res_q,  UVM_DEFAULT | UVM_HEX)    
		`uvm_field_int(i_w_syn,  UVM_DEFAULT | UVM_HEX)      
		`uvm_field_int(i_w_q,    UVM_DEFAULT | UVM_HEX)      
		`uvm_field_int(i_w_res_syn,    UVM_DEFAULT | UVM_HEX)
                `uvm_field_int(i_w_res_q,    UVM_DEFAULT | UVM_HEX)      
                `uvm_field_int(i_idx_syn,    UVM_DEFAULT | UVM_HEX)	
                `uvm_field_int(i_idx_q,    UVM_DEFAULT | UVM_HEX) //
                `uvm_field_int(i_found_syn,    UVM_DEFAULT | UVM_HEX)
                `uvm_field_int(i_found_q,    UVM_DEFAULT | UVM_HEX)
                `uvm_field_int(o_err,    UVM_DEFAULT | UVM_HEX)
                `uvm_field_int(o_uncorrectable,    UVM_DEFAULT | UVM_HEX)
	`uvm_object_utils_end

	function new(string name = "seq_item");
		super.new(name);
	endfunction


	// Keep weight fields in [0...12]; full 0...15 random would rarely
	// touch the <=3 / <=2 boundaries and would waste cycles on
	// impossible weights.
	constraint c_weight_range {
		i_w_syn      inside {[0:12]};
		i_w_q        inside {[0:12]};
		i_w_res_syn  inside {[0:12]};
		i_w_res_q    inside {[0:12]};	
	}

	// idx addresses a 12-bit position. `soft` so a directed sequence can
	// override it to 12...15 and exercise the "shift past MSB" corner.
	constraint c_idx_range {
		// 0 <= i_idx_syn <= 11
		// soft is preference of [0:11] but another overriding constraint can be determinated.
		soft i_idx_syn inside {[0:11]};
		soft i_idx_q   inside {[0:11]};
	}

endclass
