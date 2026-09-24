class tb_virtual_seq extends uvm_sequence;
    `uvm_object_utils(tb_virtual_seq)

    function new(string name="tb_virtual_seq");
        super.new(name);
    endfunction

    uvm_sequencer#(seq_item) sequencer;
    codewords_test           codewords_seq;

    task body();
        codewords_seq = codewords_test::type_id::create("codewords_seq");

        `uvm_info(get_name(), $sformatf("\n\nLaunching codewords_test...\n"), UVM_NONE)
        codewords_seq.start(sequencer);
    endtask

endclass