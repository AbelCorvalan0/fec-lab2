// tb_top just does "import tb_pkg::*"
// The order of includes matters: a file can only use classes/params defined
// above it.

package tb_pkg;
	import uvm_pkg::*;
	// pulls in the UVM base classes and `uvm_* macros.
	`include "uvm_macros.svh"

	`timescale 1ns/1ps

// ---- design parameters, shared by interface + top + classes ----

parameter int NB_WORD = 12; // i_syn, i_q, i_res_* width
parameter int NB_ERR  = 24; // o_err width
parameter int NB_CNT  =  4; // weight and index field width
parameter bit [3:0] COND_1 = 4'd3;  
parameter bit [3:0] COND_2 = 4'd2;

// ---- transaction first: everything else refers to it ---

`include "sequences/seq_item.svh"

// ---- reference model: its predict() takes a seq_item handle ----
`include "dut_model.svh"

// ---- stimulus generatos: build seq_items ----
`include "sequences/seq_lib.svh"

// ---- passive components ----
`include "tb_scoreboard.svh"
`include "tb_coverage.svh"

// ---- active path ----
`include "tb_driver.svh"
`include "tb_monitor.svh"
`include "tb_agent.svh"

// ---- container + test ----
`include "tb_environment.svh"
`include "tb_virtual_seq.svh"
`include "tb_test.svh"

endpackage
