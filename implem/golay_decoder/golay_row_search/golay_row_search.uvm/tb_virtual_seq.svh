// A virtual sequence is a container to start multiple sequences on different sequencers in the environment.
// The best way to start and control different sequences would be from a virtual sequence.
// It becomes virtual because it is not associated with any particular data type.
class tb_virtual_seq extends uvm_sequence;
    `uvm_object_utils(tb_virtual_seq)

    function new(string name="tb_virtual_seq");
        super.new(name);
    endfunction

    uvm_sequencer#(seq_item)    sequencer;
    constant_vector_sequence    constant_vector_seq;
    random_vector_sequence      random_vector_seq;

    task body();
        constant_vector_seq = constant_vector_sequence::type_id::create("constant_vector_seq");
        random_vector_seq   = random_vector_sequence::type_id::create("random_vector_seq");

        `uvm_info(get_name(), $sformatf("\n\nLaunching constant_vector_seq (min-max)...\n"), UVM_NONE)
        repeat(5) begin
            constant_vector_seq.constant = '0;
            constant_vector_seq.start(sequencer);
            constant_vector_seq.constant = '1;
            constant_vector_seq.start(sequencer);
        end
        
        `uvm_info(get_name(), $sformatf("\n\nLaunching random_vector_seq...\n"), UVM_NONE)
        repeat (4096) random_vector_seq.start(sequencer);
    endtask

endclass