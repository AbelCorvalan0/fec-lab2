interface dut_if#()
(
    input logic i_clock
);
    logic   [tb_pkg::NB_WORD        -1:0]   o_msg           ;
    logic   [tb_pkg::NB_CODEWORD    -1:0]   o_err           ;
    logic                                   o_corrected     ;
    logic                                   o_uncorrectable ;
    logic   [tb_pkg::NB_CODEWORD    -1:0]   i_rx            ;
    logic                                   i_rst           ;

endinterface