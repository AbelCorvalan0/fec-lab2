// A virtual sequence is a container to start multiple sequences on different sequencers in the environment.
// The best way to start and control different sequences would be from a virtual sequence.
// It becomes virtual because it is not associated with any particular data type.
class tb_virtual_seq extends uvm_sequence;
    `uvm_object_utils(tb_virtual_seq)

    function new(string name="tb_virtual_seq");
        super.new(name);
    endfunction

    uvm_sequencer#(seq_item)            sequencer;
    bit_sweep_sequence                  bit_sweep_seq;
    all_codeword_with_error_sequence    all_codeword_with_error_seq;
    random_codeword_with_error_sequence random_codeword_with_error_seq;

    task body();
        all_codeword_with_error_seq     = all_codeword_with_error_sequence::type_id::create("all_codeword_with_error_seq");
        bit_sweep_seq                   = bit_sweep_sequence::type_id::create("bit_sweep_seq");
        random_codeword_with_error_seq  = random_codeword_with_error_sequence::type_id::create("random_codeword_with_error_seq");

        `uvm_info(get_name(), $sformatf("\n\nLaunching bit_sweep_seq...\n"), UVM_NONE)
        bit_sweep_seq.start(sequencer);
        
        `uvm_info(get_name(), $sformatf("\n\nLaunching all_codeword_with_error_seq (no error)...\n"), UVM_NONE)
        all_codeword_with_error_seq.start(sequencer);
        
        `uvm_info(get_name(), $sformatf("\n\nLaunching random_codeword_with_error_seq (random error)...\n"), UVM_NONE)
        repeat(4096) begin 
            random_codeword_with_error_seq.insert_error     = 1;
            random_codeword_with_error_seq.error_position   = $urandom_range(0, NB_CODEWORD-1);
            `uvm_info(get_name(), $sformatf("\n\nLaunching random_codeword_with_error_seq (bit: %0d)...\n"  ,
                                            random_codeword_with_error_seq.error_position                   ), UVM_NONE)
            random_codeword_with_error_seq.start(sequencer);
        end
    endtask

endclass