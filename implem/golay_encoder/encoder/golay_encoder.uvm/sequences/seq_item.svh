class seq_item extends uvm_sequence_item;

    bit [tb_pkg::NB_WORD        -1:0]   word        ;
    bit [tb_pkg::NB_CODEWORD    -1:0]   codeword    ;
    
    `uvm_object_utils_begin(seq_item)
        `uvm_field_int(word     , UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(codeword , UVM_DEFAULT | UVM_BIN)
    `uvm_object_utils_end

    function new(string name = "seq_item");
        super.new(name);
    endfunction
endclass