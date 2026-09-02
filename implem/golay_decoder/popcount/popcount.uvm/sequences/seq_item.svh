// A class called seq_item is defined to hold random input stimul.
// It also has variables to hold output status so that they can be compared easily in a scoreboard.
class seq_item extends uvm_sequence_item;

    rand bit    [tb_pkg::NB_DATA    -1:0]   input_data  ;
    bit         [tb_pkg::NB_WEIGHT  -1:0]   weight      ;
    
    // Use utility macros to implement standard functions
    // like print, copy, clone, etc
    `uvm_object_utils_begin(seq_item)
        `uvm_field_int(input_data   , UVM_DEFAULT | UVM_BIN )
        `uvm_field_int(weight       , UVM_DEFAULT           )
    `uvm_object_utils_end

    function new(string name = "seq_item");
        super.new(name);
    endfunction

endclass