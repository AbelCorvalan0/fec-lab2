class tb_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(tb_scoreboard)

    function new(string name="tb_scoreboard", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    seq_item                                    item;
    uvm_analysis_imp#(seq_item, tb_scoreboard)  scb_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        scb_analysis_imp = new("scb_analysis_imp", this);
    endfunction
  
    virtual function void write(seq_item item);
        seq_item model_output = seq_item::type_id::create("model_output");

        // model_output.word = item.word;
        // model_output.input_error = item.input_error;

        // if (!item.compare(model_output)) begin
        //     if (item.msg_data != model_output.msg_data)
        //         `uvm_error(get_name(), $sformatf(   "\n[MSG ERROR] word=%03h : DUT=%03h, esperado=%03h",
        //                                             item.word, item.msg_data, model_output.msg_data))
    
        //     if (item.error_pattern != model_output.error_pattern)
        //         `uvm_error(get_name(), $sformatf(   "\n[ERR ERROR] word=%03h : DUT=%024b, esperado=%024b",
        //                                             item.word, item.error_pattern, model_output.error_pattern))
    
        //     if (item.corrected != model_output.corrected)
        //         `uvm_error(get_name(), $sformatf(   "\n[CORRECTED ERROR] word=%03h : DUT=%0b, esperado=%0b",
        //                                             item.word, item.corrected, model_output.corrected))
    
        //     if (item.uncorrectable != model_output.uncorrectable)
        //         `uvm_error(get_name(), $sformatf(   "\n[UNCORRECTABLE ERROR] word=%03h : DUT=%0b, esperado=%0b",
        //                                             item.word, item.uncorrectable, model_output.uncorrectable))
            item.print();
            // model_output.print();
        // end
    endfunction

endclass
