class decoder_model#(NB_WORD, NB_CODEWORD) extends uvm_object;
    `uvm_object_param_utils(decoder_model#(NB_WORD, NB_CODEWORD))

    function new(string name="decoder_model");
        super.new(name);
    endfunction

    typedef bit [NB_CODEWORD-1:0]   rx_data_t;
    typedef bit [NB_WORD    -1:0]   msg_data_t;

    function void get_output(rx_data_t rx_data, ref msg_data_t msg_data, ref rx_data_t error_pattern, ref bit corrected, ref bit uncorrectable);
        msg_data        = 'b0;
        error_pattern   = 'b0;
        corrected       = 'b0;
        uncorrectable   = 'b0;
        
    endfunction


endclass