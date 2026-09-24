`timescale 1ns/1ps

module golay_encoder #(
    parameter int NB_WORD     = 12,
    parameter int NB_CODEWORD = 24,
    parameter int I_DIM       = 12
)(
    input  logic [NB_WORD     - 1 : 0] i_word,
    output logic [NB_CODEWORD - 1 : 0] cw
);

logic [NB_WORD - 1 : 0][NB_WORD     - 1 : 0] word_matrix;
logic [I_DIM   - 1 : 0][I_DIM       - 1 : 0] id_matrix;
logic [NB_WORD - 1 : 0][NB_CODEWORD - 1 : 0] g_matrix;

function automatic logic [I_DIM - 1 : 0][I_DIM - 1 : 0] identity_matrix();
    logic [I_DIM - 1 : 0][I_DIM - 1 : 0] id_matrix;
    begin 
        id_matrix = '0;
        for(int i = 0; i < I_DIM; i++) begin 
           id_matrix[i][i] = 1'b1; 
        end

        return id_matrix;
    end
endfunction

// r 12 x c 12 
assign id_matrix = identity_matrix();

always_comb begin : c_word_matrix_assignation
    word_matrix[0]  = 12'h98F;
    word_matrix[1]  = 12'h4E7;
    word_matrix[2]  = 12'h357;
    word_matrix[3]  = 12'hBE2;
    word_matrix[4]  = 12'hDD1;
    word_matrix[5]  = 12'h7CC;
    word_matrix[6]  = 12'h53D;
    word_matrix[7]  = 12'h2BE; 
    word_matrix[8]  = 12'h87B;
    word_matrix[9]  = 12'hE74;
    word_matrix[10] = 12'hF1A;
    word_matrix[11] = 12'hEA9;
end

always_comb begin
    for (int i = 0; i < NB_WORD; i++) begin
        // Fill row by row.
        g_matrix[i] = {id_matrix[i], word_matrix[i]};
    end
end

always_comb begin
    cw = '0;
    for (int i = 0; i < NB_CODEWORD; i++) begin
        for (int j = 0; j < NB_WORD; j++) begin
            cw[i] ^= i_word[j] & g_matrix[j][i];
        end
    end
end

endmodule