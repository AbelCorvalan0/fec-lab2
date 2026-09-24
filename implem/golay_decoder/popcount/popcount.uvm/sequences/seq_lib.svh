class random_vector_sequence extends uvm_sequence;
    `uvm_object_utils(random_vector_sequence)

    function new(string name="random_vector_sequence");
        super.new(name);
    endfunction

    virtual task body();
        seq_item item_s = seq_item::type_id::create("item_s");

        start_item(item_s);
        item_s.randomize();
        finish_item(item_s);
    endtask
endclass

class max_min_vector_sequence extends uvm_sequence;
    `uvm_object_utils(max_min_vector_sequence)

    function new(string name="max_min_vector_sequence");
        super.new(name);
    endfunction

    virtual task body();
        seq_item    item_s = seq_item::type_id::create("item_s");
        bit         all_ones = $urandom();

        start_item(item_s);
        if (all_ones) begin
            item_s.input_data = '1;
        end
        else begin
            item_s.input_data = '0;
        end
        finish_item(item_s);
    endtask
endclass