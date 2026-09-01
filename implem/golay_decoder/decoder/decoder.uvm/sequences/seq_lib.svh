class codeword_with_error_sequence extends uvm_sequence;
    `uvm_object_utils(codeword_with_error_sequence)

    function new(string name="codeword_with_error_sequence");
        super.new(name);
    endfunction

    rand int    error_position  = 0;
    rand bit    insert_error    = 0;

    virtual task body();
        seq_item                item_s      = seq_item::type_id::create("item_s");
        bit [0:NB_CODEWORD-1]   error_mask  = 0;
        int unsigned            i           = $urandom_range(0,4096);

        start_item(item_s);
        item_s.rx_data = golay_code[i];
        if (insert_error) begin
            error_mask[error_position] = 1;
            item_s.rx_data ^= error_mask;
            `uvm_info(get_name(), $sformatf("\n%024b", item_s.rx_data), UVM_DEBUG)
        end
        finish_item(item_s);
    endtask
endclass
