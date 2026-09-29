class seq_item extends uvm_sequence_item;

    bit [tb_pkg::NB_WORD      - 1 : 0]    word          ;
    bit [tb_pkg::NB_CODEWORD  - 1 : 0]    input_error   ;
    bit [tb_pkg::NB_WORD      - 1 : 0]    msg_data      ;
    bit [tb_pkg::NB_CODEWORD  - 1 : 0]    error_pattern ;
    bit                                   corrected     ;
    bit                                   uncorrectable ;

    `uvm_object_utils_begin(seq_item)
        `uvm_field_int(word             , UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(input_error      , UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(msg_data         , UVM_DEFAULT | UVM_HEX)
        `uvm_field_int(error_pattern    , UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(corrected        , UVM_DEFAULT | UVM_BIN)
        `uvm_field_int(uncorrectable    , UVM_DEFAULT | UVM_BIN)
    `uvm_object_utils_end

    function new(string name = "seq_item");
        super.new(name);
    endfunction
endclass