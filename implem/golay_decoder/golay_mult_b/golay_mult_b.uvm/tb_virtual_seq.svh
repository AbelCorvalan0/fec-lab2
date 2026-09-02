// A virtual sequence is a container to start multiple sequences on different sequencers in the environment.
// The best way to start and control different sequences would be from a virtual sequence.
// It becomes virtual because it is not associated with any particular data type.
class tb_virtual_seq extends uvm_sequence;
    `uvm_object_utils(tb_virtual_seq)

    function new(string name="tb_virtual_seq");
        super.new(name);
    endfunction

    uvm_sequencer#(seq_item)        sequencer;
    vector_sweep_sequence           vector_sweep_seq;
    random_weighted_vector_sequence random_weighted_vector_seq;
    
    task body();
        vector_sweep_seq            = vector_sweep_sequence::type_id::create("vector_sweep_seq");
        random_weighted_vector_seq  = random_weighted_vector_sequence::type_id::create("random_weighted_vector_seq");
        
        `uvm_info(get_name(), $sformatf("\n\nLaunching vector_sweep_seq...\n"), UVM_NONE)
        repeat (2) vector_sweep_seq.start(sequencer);
    
        `uvm_info(get_name(), $sformatf("\n\nLaunching random_weighted_vector_seq (weight = 2)...\n"), UVM_NONE)
        random_weighted_vector_seq.vector_weight = 2;
        repeat (10) random_weighted_vector_seq.start(sequencer);

        `uvm_info(get_name(), $sformatf("\n\nLaunching random_weighted_vector_seq (weight = random)...\n"), UVM_NONE)
        random_weighted_vector_seq.vector_weight = $urandom_range(0, NB_VECTOR);
        repeat (100) random_weighted_vector_seq.start(sequencer);
    endtask

endclass