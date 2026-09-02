class golay_mult_b_model#(NB_VECTOR) extends uvm_object;
    `uvm_object_param_utils(golay_mult_b_model#(NB_VECTOR))

    function new(string name="golay_mult_b_model");
        super.new(name);
    endfunction

    typedef bit [NB_VECTOR-1:0] vector_t;

    // # KEY PROPERTIES: B == BT, B*B == I
    vector_t golay_matrix_b [12] = '{
        12'b100110001111    ,
        12'b010011100111    ,
        12'b001101010111    ,
        12'b101111100010    ,
        12'b110111010001    ,
        12'b011111001100    ,
        12'b010100111101    ,
        12'b001010111110    ,
        12'b100001111011    ,
        12'b111001110100    ,
        12'b111100011010    ,
        12'b111010101001
    };

    function void get_output(vector_t input_vector, ref vector_t output_vector);
        output_vector = vector_mul_b(input_vector);
    endfunction
    
    function vector_t vector_mul_b(bit [0:NB_VECTOR-1] vector);
        vector_t ans = 'b0;
        foreach (vector[i]) if (vector[i] == 1) begin
            ans ^= golay_matrix_b[i];
        end
        return ans;
    endfunction

endclass