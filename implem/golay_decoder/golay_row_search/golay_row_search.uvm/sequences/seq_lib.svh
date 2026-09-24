class constant_vector_sequence extends uvm_sequence;
    `uvm_object_utils(constant_vector_sequence)

    function new(string name="constant_vector_sequence");
        super.new(name);
    endfunction

    rand int constant = 0;

    virtual task body();
        seq_item item_s = seq_item::type_id::create("item_s");

        start_item(item_s);
        item_s.vector = constant;
        finish_item(item_s);
    endtask
endclass

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
