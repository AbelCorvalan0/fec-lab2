`timescale 1ns / 1ps

module golay_mult_b
#(
    parameter                           NB_VECTOR   = 12    
)(
    output  logic   [NB_VECTOR  -1:0]   o_vec           ,
    input   logic   [NB_VECTOR  -1:0]   i_vec   
);
    // LOCALPARAM/VARIABLES
    // Fila    Hex     Binario         Fila    Hex Binario
    // b0      98F     100110001111    b6      53D 010100111101
    // b1      4E7     010011100111    b7      2BE 001010111110
    // b2      357     001101010111    b8      87B 100001111011
    // b3      BE2     101111100010    b9      E74 111001110100
    // b4      DD1     110111010001    b10     F1A 111100011010
    // b5      7CC     011111001100    b11     EA9 111010101001
    localparam [NB_VECTOR-1:0] golay_matrix_b [12] = '{
        'b100110001111  ,
        'b010011100111  ,
        'b001101010111  ,
        'b101111100010  ,
        'b110111010001  ,
        'b011111001100  ,
        'b010100111101  ,
        'b001010111110  ,
        'b100001111011  ,
        'b111001110100  ,
        'b111100011010  ,
        'b111010101001  
    };
    logic   [0:NB_VECTOR    -1] input_vector    ;
    logic   [0:NB_VECTOR    -1] output_vector   ;

    assign  input_vector = i_vec;

    always_comb begin
        output_vector   = 'b0;
        foreach (input_vector[i]) begin
            if (input_vector[i]) begin
                output_vector ^= golay_matrix_b[i];
            end
        end
    end

    // OUTPUT ASSIGNATION
    assign o_vec    = output_vector;

endmodule
