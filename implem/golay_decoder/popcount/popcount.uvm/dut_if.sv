interface dut_if#()
(
    input logic i_clock
);
    logic   [tb_pkg::NB_WEIGHT  -1:0]   o_weight    ;
    logic   [tb_pkg::NB_DATA    -1:0]   i_vec       ;

endinterface