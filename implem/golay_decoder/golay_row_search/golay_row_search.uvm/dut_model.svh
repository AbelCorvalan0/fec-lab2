class row_search_model#(NB_CODEWORD, NB_WORD) extends uvm_object;
    `uvm_object_param_utils(row_search_model#(NB_CODEWORD, NB_WORD))

    function new(string name="row_search_model");
        super.new(name);
    endfunction

    typedef bit [NB_WORD-1:0] vector_t;
    typedef bit [NB_ROW_INDEX-1:0] index_t;

    // LOCALPARAM/VARIABLES
    // Fila    Hex     Binario         Fila    Hex Binario
    // b0      98F     100110001111    b6      53D 010100111101
    // b1      4E7     010011100111    b7      2BE 001010111110
    // b2      357     001101010111    b8      87B 100001111011
    // b3      BE2     101111100010    b9      E74 111001110100
    // b4      DD1     110111010001    b10     F1A 111100011010
    // b5      7CC     011111001100    b11     EA9 111010101001
    vector_t golay_matrix_b [12] = '{
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

    function void get_output(vector_t vector, ref vector_t result, ref index_t row_index, ref bit found);
        result      = '0;
        row_index   = '0;
        found       = '0;
        foreach (golay_matrix_b[i]) if ($countones(vector ^ golay_matrix_b[i]) <= 2) begin
            result      = vector ^ golay_matrix_b[i];
            row_index   = i;
            found       = 1;
            break;
        end
    endfunction
    
endclass