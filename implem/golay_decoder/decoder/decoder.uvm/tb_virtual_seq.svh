class tb_virtual_seq extends uvm_sequence;
    `uvm_object_utils(tb_virtual_seq)

    function new(string name="tb_virtual_seq");
        super.new(name);
    endfunction

    uvm_sequencer#(seq_item)        sequencer;
    codewords_with_error_sequence   codewords_with_error_seq;

    task body();
        codewords_with_error_seq = codewords_with_error_sequence::type_id::create("codewords_with_error_seq");

        `uvm_info(get_name(), $sformatf("\n\nLaunching codewords_with_error_seq...\n"), UVM_NONE)
        codewords_with_error_seq.start(sequencer);
    endtask

endclass