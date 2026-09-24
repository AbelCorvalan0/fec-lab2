class random_weighted_vector_sequence extends uvm_sequence;
    `uvm_object_utils(random_weighted_vector_sequence)

    function new(string name="random_weighted_vector_sequence");
        super.new(name);
    endfunction
    
    rand int unsigned vector_weight = 0;
    
    virtual task body();
        seq_item    item_s                  = seq_item::type_id::create("item_s");
        bit         bit_vector [NB_VECTOR]  = '{default:0};

        start_item(item_s);
        for (int i=0; i<vector_weight; ++i) begin
            bit_vector[i] = 1;
        end
        bit_vector.shuffle();

        item_s.input_vector = {>>{bit_vector}};
        finish_item(item_s);
    endtask
endclass

class vector_sweep_sequence extends uvm_sequence;
    `uvm_object_utils(vector_sweep_sequence)

    function new(string name="vector_sweep_sequence");
        super.new(name);
    endfunction

    virtual task body();
        for (int i=0; i<NB_VECTOR; ++i) begin
            seq_item item_s = seq_item::type_id::create("item_s");
            
            start_item(item_s);
            item_s.input_vector = 1<<i;
            finish_item(item_s);
        end
    endtask
endclass