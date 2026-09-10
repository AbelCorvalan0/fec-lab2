class tb_driver extends uvm_driver #(seq_item);
	`uvm_component_utils(tb_driver)
	// uvm_component parent represents the component UVM that contains
	// tb_driver within the hierarchy
	//
	//
        //   uvm_test
        //   |
        //   +-- tb_env
        //         |
        //         +-- tb_agent
        //               |
        //               +-- tb_driver
        //               +-- tb_monitor
        //               +-- tb_sequencer
	
	function new(
		input string name = "tb_driver", 
		input uvm_component parent = null
	);
		super.new(name, parent);
	endfunction
	
	// virtual allows to subclass override a method defined in a class of
	// a higher level.
	
	// Pointer/reference for other files (instance).
	virtual dut_if vif;

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif))
			`uvm_fatal("DRV", "no virtual interface")
	endfunction

	virtual task run_phase(uvm_phase phase);
		forever begin 
			seq_item tr;
			seq_item_port.get_next_item(tr); // block until a sequence provides one
			@(posedge vif.i_clock);
			vif.i_syn       <= tr.i_syn;
            		vif.i_q         <= tr.i_q;
            		vif.i_res_syn   <= tr.i_res_syn;
            		vif.i_res_q     <= tr.i_res_q;
            		vif.i_w_syn     <= tr.i_w_syn;
            		vif.i_w_q       <= tr.i_w_q;
            		vif.i_w_res_syn <= tr.i_w_res_syn;
            		vif.i_w_res_q   <= tr.i_w_res_q;
            		vif.i_idx_syn   <= tr.i_idx_syn;
            		vif.i_idx_q     <= tr.i_idx_q;
            		vif.i_found_syn <= tr.i_found_syn;
            		vif.i_found_q   <= tr.i_found_q;

			seq_item_port.item_done();	// release finish_item() in the sequence
		end
	endtask
endclass	
