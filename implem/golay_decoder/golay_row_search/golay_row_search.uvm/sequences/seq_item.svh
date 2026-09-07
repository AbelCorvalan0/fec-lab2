// A class called seq_item is defined to hold random input stimul.
// It also has variables to hold output status so that they can be compared easily in a scoreboard.
class seq_item extends uvm_sequence_item;

    rand bit    [NB_WORD        -1:0]   vector      ;
    bit         [NB_WORD        -1:0]   result      ;
    bit         [NB_ROW_INDEX   -1:0]   row_index   ;
    bit                                 found       ;
    
    // Use utility macros to implement standard functions
    // like print, copy, clone, etc
    `uvm_object_utils_begin(seq_item)
        `uvm_field_int(vector       , UVM_DEFAULT | UVM_BIN )
        `uvm_field_int(result       , UVM_DEFAULT | UVM_BIN )
        `uvm_field_int(row_index    , UVM_DEFAULT | UVM_DEC )
        `uvm_field_int(found        , UVM_DEFAULT           )
    `uvm_object_utils_end

    function new(string name = "seq_item");
        super.new(name);
    endfunction

endclass