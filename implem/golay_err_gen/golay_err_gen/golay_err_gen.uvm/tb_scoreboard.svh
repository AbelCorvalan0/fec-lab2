import tb_pkg::*;

class tb_scoreboard extends uvm_scoreboard;
	`uvm_component_utils(tb_scoreboard)
	function new(
		input string name = "tb_scoreboard", 
		input uvm_component parent = null
	);
		super.new(name, parent);
	endfunction

	err_gen_model model;
	uvm_analysis_imp #(seq_item, tb_scoreboard) imp;

	int unsigned n_checked;
	int unsigned n_failed;

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		model = err_gen_model::type_id::create("model");
		imp   = new("imp", this);
	endfunction

	// called once per transaction broadcast by the monitor
	virtual function void write(seq_item tr);
		bit [tb_pkg::NB_ERR-1:0] exp_err;
		bit                      exp_uncorr;

		model.predict(tr, exp_err, exp_uncorr);
		n_checked++;

		if ((tr.o_err !== exp_err) || (tr.o_uncorrectable !== exp_uncorr)) begin
		n_failed++;
		`uvm_error(get_name(), $sformatf({"MISMATCH\n", 
			"  in : w_s=%0d w_q=%0d f_s=%0b w_rs=%0d idx_s=%0d | f_q=%0b w_rq=%0d idx_q=%0d\n",
			"       s=%03h q=%03h rs=%03h rq=%03h\n",
			"  DUT: o_err=%06h o_unc=%0b\n",
			"  REF: o_err=%06h o_unc=%0b"},
			tr.i_w_syn, tr.i_w_q, tr.i_found_syn, tr.i_w_res_syn, tr.i_idx_syn,
			tr.i_found_q, tr.i_w_res_q, tr.i_idx_q,
			tr.i_syn, tr.i_q, tr.i_res_syn, tr.i_res_q,
			tr.o_err, tr.o_uncorrectable, exp_err, exp_uncorr))
		end

		// spec invariant, independent of the model
		if (tr.o_uncorrectable && (tr.o_err !== '0))
			`uvm_error(get_name(), $sformatf("o_uncorrectable=1 but o_err=%06h (must be 0)", tr.o_err))
	endfunction

	virtual function void report_phase(uvm_phase phase);
		if (n_failed == 0) 
			`uvm_info(get_name(), $sformatf("PASS %0d/%0d checks", n_checked, n_checked), UVM_NONE)
		else
			`uvm_error(get_name(), $sformatf("FAIL %0d/%0d chechks mismatched", n_failed, n_checked))
	endfunction
endclass
