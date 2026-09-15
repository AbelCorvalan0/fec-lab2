// A virtual sequence is a container to start multiple sequences on different sequencers in the environment.
// The best way to start and control different sequences would be from a virtual sequence.
// It becomes virtual because it is not associated with any particular data type.
class tb_virtual_seq extends uvm_sequence;
    `uvm_object_utils(tb_virtual_seq)

    function new(string name="tb_virtual_seq");
        super.new(name);
    endfunction

    uvm_sequencer#(seq_item)            sequencer;
    codewords_test        codewords_test_sequence;
    
    task body();
        codewords_test_sequence  = codewords_test::type_id::create("codewords_test_sequence");
    
        `uvm_info(get_name(), $sformatf("\nLauching codewords_test_sequence sequence (no errors)...\n"), UVM_NONE)
        codewords_test_sequence.start(sequencer);
        
    endtask

endclass