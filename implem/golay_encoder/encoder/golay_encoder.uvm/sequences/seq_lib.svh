class word_count_sequence extends uvm_sequence;
    `uvm_object_utils(word_count_sequence)

    function new(string name="word_count_sequence");
        super.new(name);
    endfunction

    virtual task body();
        seq_item item;

        for (int i=0; i<2**NB_WORD; ++i) begin
            item = seq_item::type_id::create("item");
            start_item(item);
            item.word = i;
            finish_item(item);
        end
    endtask

endclass
