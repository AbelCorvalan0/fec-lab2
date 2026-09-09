import tb_pkg::*;

interface dut_if(
	// define clock
	input logic i_clock
        // pacing clock only; the DUT itself is combinational.	
);

/////////////////////////////////////////
// DUT inputs
/////////////////////////////////////////

// The DUT inputs are written by "tb_driver.sv"
	logic [tb_pkg::NB_WORD - 1: 0] i_syn    ;
	logic [tb_pkg::NB_WORD - 1: 0] i_q      ;

	logic [tb_pkg::NB_WORD - 1: 0] i_res_syn;
	logic [tb_pkg::NB_WORD - 1: 0] i_res_q  ;

	logic [tb_pkg::NB_CNT - 1: 0] i_w_syn  ;
	logic [tb_pkg::NB_CNT - 1: 0] i_w_q    ;
	
	logic [tb_pkg::NB_CNT - 1: 0] i_idx_syn;	  
	logic [tb_pkg::NB_CNT - 1: 0] i_idx_q  ;

	logic                         i_found_syn;
	logic                         i_found_q  ;

	logic [tb_pkg::NB_CNT - 1: 0] i_w_res_syn;
	logic [tb_pkg::NB_CNT - 1: 0] i_w_res_q;

/////////////////////////////////////////
// DUT outputs
/////////////////////////////////////////

// The DUT drives them, the monitor samples them
// the driver/monitos just reference vif.<signal> directly

	logic [tb_pkg::NB_ERR - 1: 0] o_err          ;
	logic o_uncorrectable;


endinterface
