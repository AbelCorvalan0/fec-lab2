class codewords_test extends uvm_sequence;
    `uvm_object_utils(codewords_test)

    // Constructor
    function new(string name="codewords_test");
        super.new(name);
    endfunction

    virtual task body();
        //Create transaction item to send to the driver.
        seq_item item_s = seq_item::type_id::create("item_s");

        foreach (golay_code[i]) begin
            
            `uvm_info("GOLAY",
                      $sformatf("\ncodeword[%0d] = %024b",
                      i, golay_code[i]),
                      UVM_LOW)
                      
            start_item(item_s);
            item_s.rx_data = golay_code[i];
            finish_item(item_s);
        end
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
            item_s.rx_data = golay_code[i];
            
            if (insert_error) begin
                error_mask[error_position] = 1;
                item_s.rx_data ^= error_mask;
                `uvm_info(get_name(), $sformatf("\n%024b", item_s.rx_data), UVM_DEBUG)
            end
            finish_item(item_s);
        end
    endtask
endclass
