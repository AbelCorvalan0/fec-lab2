class random_codeword_with_error_sequence extends uvm_sequence;
    `uvm_object_utils(random_codeword_with_error_sequence)

    function new(string name="random_codeword_with_error_sequence");
        super.new(name);
    endfunction

    rand int    error_position  = 0;
    rand bit    insert_error    = 0;

    virtual task body();
        seq_item                item_s      = seq_item::type_id::create("item_s");
        bit [0:NB_CODEWORD-1]   error_mask  = 0;
        int unsigned            i           = $urandom_range(0,4096-1);

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

class all_codeword_with_error_sequence extends uvm_sequence;
    `uvm_object_utils(all_codeword_with_error_sequence)

    function new(string name="all_codeword_with_error_sequence");
        super.new(name);
    endfunction

    rand int    error_position  = 0;
    rand bit    insert_error    = 0;

    virtual task body();
        foreach (golay_code[i]) begin
            seq_item                item_s      = seq_item::type_id::create("item_s");
            bit [0:NB_CODEWORD-1]   error_mask  = 0;
        
            start_item(item_s);
            item_s.rx_data  = golay_code[i];
            
            if (insert_error) begin
                error_mask[error_position] = 1;
                item_s.rx_data ^= error_mask;
                `uvm_info(get_name(), $sformatf("\n%024b", item_s.rx_data), UVM_DEBUG)
            end
            finish_item(item_s);
        end
    endtask
endclass

class bit_sweep_sequence extends uvm_sequence;
    `uvm_object_utils(bit_sweep_sequence)

    function new(string name="bit_sweep_sequence");
        super.new(name);
    endfunction

    virtual task body();
        for (int i=0; i<NB_CODEWORD; ++i) begin
            seq_item item_s = seq_item::type_id::create("item_s");
            
            start_item(item_s);
            item_s.rx_data = 1<<i;
            finish_item(item_s);
        end
    endtask
endclass