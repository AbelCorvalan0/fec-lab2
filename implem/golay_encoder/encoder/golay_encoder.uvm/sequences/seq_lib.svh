class codewords_test extends uvm_sequence;
    `uvm_object_utils(codewords_test)

    function new(string name= "codewords_test");
        super.new(name);
    endfunction

    virtual task body();
        seq_item item;

        foreach(golay_code[i]) begin
            item = seq_item::type_id::create("item");
            start_item(item);
            item.rx_data = golay_code[i];
            finish_item(item);
        end
    endtask

endclass
