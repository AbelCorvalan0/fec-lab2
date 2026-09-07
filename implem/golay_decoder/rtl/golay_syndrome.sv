`timescale 1ns / 1ps

module golay_syndrome
#(
    parameter                               NB_WORD         = 12    ,
    parameter                               NB_CODEWORD     = 24    
)(
    output  logic   [NB_WORD        -1:0]   o_syndrome              ,
    output  logic                           o_zero                  ,
    input   logic   [NB_CODEWORD    -1:0]   i_rx                    
);
    // LOCALPARAM/VARIABLES
    logic   [NB_WORD    -1:0]   r_left      ;
    logic   [NB_WORD    -1:0]   r_right     ;
    logic   [NB_WORD    -1:0]   r_left_b    ;
    logic   [NB_WORD    -1:0]   syndrome    ;
    logic                       zero        ;

    assign {r_left, r_right}    = i_rx;

    golay_mult_b # (
        .NB_VECTOR  ( NB_WORD   )
    )
    golay_mult_b_inst (
        .o_vec      ( r_left_b  ),
        .i_vec      ( r_left    )
    );

    assign syndrome = r_left_b ^ r_right    ;
    assign zero     = syndrome == 0         ;

    // OUTPUT ASSIGNATION
    assign o_syndrome   = syndrome  ;
    assign o_zero       = zero      ;

endmodule
