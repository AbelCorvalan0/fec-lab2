`timescale 1ns / 1ps

module golay_row_search
#(
    parameter                                   NB_WORD     = 12    ,
    parameter                                   NB_CODEWORD = 24    
)(
    output  logic   [NB_WORD            -1:0]   o_res               ,
    output  logic   [$clog2(NB_WORD)    -1:0]   o_row_index         ,
    output  logic                               o_found             ,
    input   logic   [NB_WORD            -1:0]   i_vector            
);
    // LOCALPARAM/VARIABLES
    // Fila    Hex     Binario         Fila    Hex Binario
    // b0      98F     100110001111    b6      53D 010100111101
    // b1      4E7     010011100111    b7      2BE 001010111110
    // b2      357     001101010111    b8      87B 100001111011
    // b3      BE2     101111100010    b9      E74 111001110100
    // b4      DD1     110111010001    b10     F1A 111100011010
    // b5      7CC     011111001100    b11     EA9 111010101001
    localparam [NB_WORD-1:0] golay_matrix_b [NB_WORD] = '{
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
    localparam                          NB_WEIGHT                       = $clog2(NB_WORD+1) ;
    localparam                          NB_ROW_INDEX                    = $clog2(NB_WORD)   ;
    logic       [NB_WORD        -1:0]   vector_bi           [NB_WORD]                       ;
    logic       [NB_WEIGHT      -1:0]   weight_vector_bi    [NB_WORD]                       ;
    logic       [NB_WORD        -1:0]   result                                              ;
    logic       [NB_ROW_INDEX   -1:0]   row_index                                           ;
    logic                               found                                               ;
    genvar                              gi                                                  ;

    generate;
        for (gi=0; gi<NB_WORD; ++gi) begin
            popcount # (
                .NB_DATA    ( NB_WORD               )
            )
            weight_vector_bi (
                .o_weight   ( weight_vector_bi[gi]  ),
                .i_vec      ( vector_bi[gi]         )
            );
        end
    endgenerate

    always_comb begin
        for (int i=0; i<NB_WORD; ++i) begin
            vector_bi[i] = i_vector ^ golay_matrix_b[i];
        end
    end

    always_comb begin
        result      = '0    ;
        row_index   = '0    ;
        found       = 'b0   ;

        for (int j=0; j<NB_WORD; ++j) begin
            if (weight_vector_bi[j] <= 2) begin
                result      = vector_bi[j]  ;
                row_index   = j             ;
                found       = 'b1           ;
            end
        end
    end

    // OUTPUT ASSIGNATION
    assign o_res        = result    ;
    assign o_row_index  = row_index ;
    assign o_found      = found     ;

endmodule
