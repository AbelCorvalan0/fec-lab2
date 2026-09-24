class seq_item extends uvm_sequence_item;
    // Stimulus: drives to DUT (i_rx)
    bit [NB_CODEWORD - 1 : 0] rx_data;

    // Captured by monitor to DUT output (o_msg, o_err, o_corrected, o_uncorrectable)
    bit [NB_WORD     - 1 : 0]      msg_data;
    bit [NB_CODEWORD - 1 : 0] error_pattern;
    bit                           corrected;
    bit                       uncorrectable;

    `uvm_object_utils_begin(seq_item)
        `uvm_field_int(rx_data,       UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(msg_data,      UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(error_pattern, UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(corrected,     UVM_DEFAULT)
        `uvm_field_int(uncorrectable, UVM_DEFAULT)
    `uvm_object_utils_end

    function new(string name = "seq_item");
        super.new(name);
    endfunction
endclass