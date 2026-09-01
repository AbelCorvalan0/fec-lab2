// A virtual sequence is a container to start multiple sequences on different sequencers in the environment.
// The best way to start and control different sequences would be from a virtual sequence.
// It becomes virtual because it is not associated with any particular data type.
class tb_virtual_seq extends uvm_sequence;
    `uvm_object_utils(tb_virtual_seq)

    function new(string name="tb_virtual_seq");
        super.new(name);
    endfunction

    uvm_sequencer#(seq_item)        sequencer;
    codeword_with_error_sequence    codeword_with_error_seq;

    task body();
        codeword_with_error_seq = codeword_with_error_sequence::type_id::create("codeword_with_error_seq");

        `uvm_info(get_name(), $sformatf("\nLauching codeword_with_error_seq (no errors)...\n"), UVM_NONE)
        repeat (100) codeword_with_error_seq.start(sequencer);
        
    endtask

endclass