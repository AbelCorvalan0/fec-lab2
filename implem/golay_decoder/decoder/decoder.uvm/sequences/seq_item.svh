// A class called seq_item is defined to hold random input stimul.
// It also has variables to hold output status so that they can be compared easily in a scoreboard.
class seq_item extends uvm_sequence_item;

    rand bit    [NB_CODEWORD    -1:0]   rx_data         ;
    bit         [NB_CODEWORD    -1:0]   error_pattern   ;
    bit         [NB_WORD        -1:0]   msg_data        ;
    bit                                 corrected       ;
    bit                                 uncorrectable   ;

    // Use utility macros to implement standard functions
    // like print, copy, clone, etc
    `uvm_object_utils_begin(seq_item)
        `uvm_field_int(rx_data          , UVM_DEFAULT | UVM_BIN )
        `uvm_field_int(error_pattern    , UVM_DEFAULT | UVM_BIN )
        `uvm_field_int(msg_data         , UVM_DEFAULT | UVM_BIN )
        `uvm_field_int(corrected        , UVM_DEFAULT           )
        `uvm_field_int(uncorrectable    , UVM_DEFAULT           )
    `uvm_object_utils_end

    function new(string name = "seq_item");
        super.new(name);
    endfunction

endclass