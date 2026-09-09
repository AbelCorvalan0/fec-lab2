// Purpose: passively watch the interface, rebuild a "seq_item" holding both
// the inputs it sees and the outputs they produced, and broadcasts it.

class tb_monitor extends uvm_monitor;
	`uvm_component_utils(tb_monitor)
	function new(
                input string name = "tb_monitor", 
                input uvm_component parent = null);
		super.new(name, parent);
	endfunction

	virtual dut_if                vif;
	uvm_analysis_port #(seq_item)  ap;

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif))
			`uvm_fatal("MON", "no virtual interface")
		ap = new("ap", this);
	endfunction

	virtual task run_phase(uvm_phase phase);
		forever begin
			seq_item tr = seq_item::type_id::create("tr");
			
			@(posedge vif.i_clock);
                        // inputs currently on the bus...
                        tr.i_syn        = vif.i_syn;
                        tr.i_q          = vif.i_q;
                        tr.i_res_syn    = vif.i_res_syn;
                        tr.i_res_q      = vif.i_res_q;
                        tr.i_w_syn      = vif.i_w_syn;
                        tr.i_w_q        = vif.i_w_q;
                        tr.i_w_res_syn  = vif.i_w_res_syn;
                        tr.i_w_res_q    = vif.i_w_res_q;
                        tr.i_idx_syn    = vif.i_idx_syn;
                        tr.i_idx_q      = vif.i_idx_q;
                        tr.i_found_syn  = vif.i_found_syn;
                        tr.i_found_q    = vif.i_found_q;
                        // ...and the combinational outputs they produced
                        tr.o_err            = vif.o_err;
                        tr.o_uncorrectable  = vif.o_uncorrectable;

                        ap.write(tr);
                end
        endtask
endclass
