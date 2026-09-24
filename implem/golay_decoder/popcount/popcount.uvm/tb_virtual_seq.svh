// A virtual sequence is a container to start multiple sequences on different sequencers in the environment.
// The best way to start and control different sequences would be from a virtual sequence.
// It becomes virtual because it is not associated with any particular data type.
class tb_virtual_seq extends uvm_sequence;
    `uvm_object_utils(tb_virtual_seq)

    function new(string name="tb_virtual_seq");
        super.new(name);
    endfunction

    uvm_sequencer#(seq_item)    sequencer;
    random_vector_sequence      random_vector_seq;
    max_min_vector_sequence     max_min_vector_seq;
    
    task body();
        random_vector_seq  = random_vector_sequence::type_id::create("random_vector_seq");
        max_min_vector_seq  = max_min_vector_sequence::type_id::create("max_min_vector_seq");
            
        `uvm_info(get_name(), $sformatf("\n\nLauching max_min_vector_seq...\n"), UVM_NONE)
        repeat (100) max_min_vector_seq.start(sequencer);
        `uvm_info(get_name(), $sformatf("\n\nLauching random_vector_seq...\n"), UVM_NONE)
        repeat (100) random_vector_seq.start(sequencer);
    endtask

endclass