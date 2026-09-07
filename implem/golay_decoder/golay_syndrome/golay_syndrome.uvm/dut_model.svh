class syndrome_model#(NB_CODEWORD, NB_WORD) extends uvm_object;
    `uvm_object_param_utils(syndrome_model#(NB_CODEWORD, NB_WORD))

    function new(string name="syndrome_model");
        super.new(name);
    endfunction

    typedef bit [NB_WORD-1:0] vector_t;
    typedef bit [NB_CODEWORD-1:0] rx_t;

    vector_t golay_h_transpose [24] = '{
        'b100110001111    ,
        'b010011100111    ,
        'b001101010111    ,
        'b101111100010    ,
        'b110111010001    ,
        'b011111001100    ,
        'b010100111101    ,
        'b001010111110    ,
        'b100001111011    ,
        'b111001110100    ,
        'b111100011010    ,
        'b111010101001    ,
        'b100000000000    ,
        'b010000000000    ,
        'b001000000000    ,
        'b000100000000    ,
        'b000010000000    ,
        'b000001000000    ,
        'b000000100000    ,
        'b000000010000    ,
        'b000000001000    ,
        'b000000000100    ,
        'b000000000010    ,
        'b000000000001    
    };

    function void get_output(rx_t rx_data, ref vector_t syndrome, ref bit zero);
        syndrome    = get_syndrome(rx_data);
        zero        = syndrome == 0;
    endfunction
    
    function vector_t get_syndrome(bit [0:NB_CODEWORD-1] vector);
        vector_t ans = 'b0;
        foreach (vector[i]) if (vector[i] == 1) begin
            ans ^= golay_h_transpose[i];
        end
        return ans;
    endfunction

endclass