class tb_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(tb_scoreboard)

    function new(string name="tb_scoreboard", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    uvm_analysis_imp#(seq_item, tb_scoreboard) scb_analysis_imp;

    // Indice dentro de los arrays golden (msg, err, corrected_data, uncorrectable)
    int unsigned idx;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        scb_analysis_imp = new("scb_analysis_imp", this);
        idx = 0;
    endfunction

    virtual function void write(seq_item item);
        if (idx >= $size(golay_code)) begin
            `uvm_warning(get_name(), $sformatf("Item recibido fuera de rango (idx=%0d) - se ignora", idx))
            return;
        end

        if (item.msg_data != msg[idx])
            `uvm_error(get_name(), $sformatf("[MSG ERROR] idx=%0d rx=%0h : DUT=%0h, esperado=%0h",
                                              idx, item.rx_data, item.msg_data, msg[idx]))

        if (item.error_pattern != err[idx])
            `uvm_error(get_name(), $sformatf("[ERR ERROR] idx=%0d rx=%0h : DUT=%0h, esperado=%0h",
                                              idx, item.rx_data, item.error_pattern, err[idx]))

        if (item.corrected != corrected_data[idx])
            `uvm_error(get_name(), $sformatf("[CORRECTED ERROR] idx=%0d rx=%0h : DUT=%0b, esperado=%0b",
                                              idx, item.rx_data, item.corrected, corrected_data[idx]))

        if (item.uncorrectable != uncorrectable[idx])
            `uvm_error(get_name(), $sformatf("[UNCORRECTABLE ERROR] idx=%0d rx=%0h : DUT=%0b, esperado=%0b",
                                              idx, item.rx_data, item.uncorrectable, uncorrectable[idx]))

        idx++;
    endfunction

endclass