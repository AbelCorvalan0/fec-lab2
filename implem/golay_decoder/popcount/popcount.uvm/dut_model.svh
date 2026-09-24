class decoder_model#(NB_WORD, NB_CODEWORD) extends uvm_object;
    `uvm_object_param_utils(decoder_model#(NB_WORD, NB_CODEWORD))

    function new(string name="decoder_model");
        super.new(name);
    endfunction

    typedef bit [NB_CODEWORD-1:0]   rx_data_t;
    typedef bit [NB_WORD    -1:0]   msg_data_t;

    // # KEY PROPERTIES: B == BT, B*B == I
    bit [NB_WORD-1:0] G2412B [12] = '{
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

    function void get_output(rx_data_t rx_data, ref msg_data_t msg_data, ref rx_data_t error_pattern, ref bit corrected, ref bit uncorrectable);
        msg_data        = 'b0;
        error_pattern   = 'b0;
        corrected       = 'b0;
        uncorrectable   = 'b0;
        
        correct(rx_data, error_pattern, corrected, uncorrectable);
        msg_data = rx_data[NB_CODEWORD-1-:NB_WORD];
    endfunction
    
    function void correct(ref rx_data_t rx_data, ref rx_data_t error_pattern, ref bit corrected, ref bit uncorrectable);
        msg_data_t  r_low           = 'b0; 
        msg_data_t  r_high          = 'b0;
        msg_data_t  s               = 'b0;
        msg_data_t  q               = 'b0;
        bit         success         = 'b0;
        
        {r_low, r_high} = rx_data;
        corrected       = 'b0;
        uncorrectable   = 'b0;
        
        // get syndrome and q
        s   = vector_mul_b(r_low)   ^ r_high;
        q   = vector_mul_b(r_high)  ^ r_low;

        if (s == 'b0) begin
            success = get_error(s, q, error_pattern);

            if (!success) begin
                // # r, remains uncorrected
                uncorrectable = 'b1;
            end
            else begin
                rx_data ^= error_pattern;
                corrected = 'b1;
            end
        end
    endfunction

    function bit get_error(msg_data_t s, msg_data_t q, ref rx_data_t error_pattern);
        msg_data_t          sbi     = 'b0;
        msg_data_t          qbi     = 'b0;
        bit [0:NB_WORD-1]   ui      = 'b0;
        bit                 success = 'b0;
        
        // if syndrome != 0 and error_pattern remains in zero, uncorrectable
        error_pattern = 'b0;

        // # all errors in parity
        if ($countones(s) <= 3) begin
            error_pattern = {12'd0, s};
        end
        // # all errors in word
        else if ($countones(q) <= 3) begin
            error_pattern = {q, 12'd0};
        end
        else begin
            foreach (G2412B[i]) begin
                sbi     = s ^ G2412B[i];
                qbi     = q ^ G2412B[i];
                ui[i]   = 1'b1;
                
                // # only one error in word, remaining in parity
                if ($countones(sbi) <= 2) begin
                    error_pattern = {ui, sbi};
                    break;
                end
                // # only one error in parity remaining in word
                else if ($countones(qbi) <= 2) begin
                    error_pattern = {qbi, ui};
                    break;
                end
            end
        end

        // # if more than one error in word and parity also, then errors > 3, uncorrectable
        success = error_pattern != 'b0;
        return success;
    endfunction

    function rx_data_t vector_mul_b(bit [0:NB_CODEWORD-1] vector);
        rx_data_t ans = 'b0;
        foreach (vector[i]) if (vector[i] == 1) begin
            ans ^= G2412B[i];
        end
        return ans;
    endfunction


endclass