`timescale 1ns / 1ps

module decoder
#(
    parameter                               NB_WORD         = 12    ,
    parameter                               NB_CODEWORD     = 24    
)(
    output  logic   [NB_WORD        -1:0]   o_msg                   ,
    output  logic   [NB_CODEWORD    -1:0]   o_err                   ,
    output  logic                           o_corrected             ,
    output  logic                           o_uncorrectable         ,
    input   logic   [NB_CODEWORD    -1:0]   i_rx                    ,
    input   logic                           i_rst                   ,
    input   logic                           i_clk                   
);
    // LOCALPARAM/VARIABLES

    // OUTPUT ASSIGNATION
    assign o_msg            = 'b0   ;
    assign o_err            = 'b0   ;
    assign o_corrected      = 'b0   ;
    assign o_uncorrectable  = 'b0   ;

endmodule
