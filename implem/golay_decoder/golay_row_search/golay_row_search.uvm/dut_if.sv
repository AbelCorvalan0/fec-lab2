interface dut_if#()
(
    input logic i_clock
);
    logic   [tb_pkg::NB_WORD        -1:0]   o_res       ;
    logic   [tb_pkg::NB_ROW_INDEX   -1:0]   o_row_index ;
    logic                                   o_found     ;
    logic   [tb_pkg::NB_WORD        -1:0]   i_vector    ;

endinterface