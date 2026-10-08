class tb_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(tb_scoreboard)

    function new(string name="tb_scoreboard", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual python_if                           model;
    uvm_analysis_imp#(seq_item, tb_scoreboard)  scb_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // Retrieve the interface handle from the database
        if (!uvm_config_db#(virtual python_if)::get(this, "", "model", model)) begin
            `uvm_fatal("PYVIF_ERR", "Could not get virtual interface handle for python golden model!")
        end

        model.create();
        scb_analysis_imp = new("scb_analysis_imp", this);
    endfunction
  
    virtual function void write(seq_item item);
        seq_item model_output = seq_item::type_id::create("model_output");

        model_output.word = item.word;
        model_output.codeword = model.get_output(item.word);

        `uvm_info(get_name(), $sformatf("\nFrom UVM: %024b = model.get_output(%012b)", model_output.codeword, item.word), UVM_NONE)
        item.print();
        model_output.print();

        if (!item.compare(model_output)) begin
            if (item.codeword != model_output.codeword)
                `uvm_error("CODEWORD ERROR", $sformatf( "\nword=%03h : DUT=%06h, esperado=%06h",
                                                        item.word, item.codeword, model_output.codeword))
        end
    endfunction

    virtual function void check_phase(uvm_phase phase);
        super.check_phase(phase);
        // Terminate Python runtime context cleanly
        model.cleanup();
    endfunction

endclass
