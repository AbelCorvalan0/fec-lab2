// Include a design element, not a class
//`include "dut_if.sv"

module tb_top;

	import uvm_pkg::*;
	import tb_pkg::*;

// pacing clock (DUT is combinational; this only sequences driver/monitor)
logic i_clock = 0;
always #10 i_clock = ~i_clock;
 
// the wire bundle
dut_if #()vif(
	.i_clock(i_clock)
);

// Device Under Test - port list copied from "rtl/golay_err_gen.sv"

golay_err_gen
dut(
	.i_syn(vif.i_syn),
	.i_q(vif.i_q),
	.i_res_syn(vif.i_res_syn),
	.i_res_q(vif.i_res_q),
	.i_w_syn(vif.i_w_syn),
	.i_w_q(vif.i_w_q),
	.i_idx_syn(vif.i_idx_syn),
	.i_idx_q(vif.i_idx_q),
	.i_found_syn(vif.i_found_syn),
	.i_found_q(vif.i_found_q),
	.i_w_res_syn(vif.i_w_res_syn),
	.i_w_res_q(vif.i_w_res_q)
);

// publish the interface handle so classes can retrieve it by name.

initial begin
	uvm_config_db#(
		virtual dut_if
	)::set(
		null, 
		"uvm_test_top", 
		"vif", 
		vif
	);
	
	run_test("tb_test");
end

initial begin
	$dumpfile("dump.vcd");
	$dumpvars;
end

endmodule
