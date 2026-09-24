interface dut_if#()
(
    input logic i_clock
);
    logic   [tb_pkg::NB_VECTOR  -1:0]   o_vec   ;
    logic   [tb_pkg::NB_VECTOR  -1:0]   i_vec   ;
    
endinterface