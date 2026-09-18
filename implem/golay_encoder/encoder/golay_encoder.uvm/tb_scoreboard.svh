class tb_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(tb_scoreboard)

    function new(string name="tb_scoreboard", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    // DUT Latency
    localparam int PIPE_LATENCY = 3 + 1;

    uvm_analysis_imp#(seq_item, tb_scoreboard) scb_analysis_imp;
    
    int unsigned idx;
    // Pipeline de inputs
    bit [NB_CODEWORD-1:0] rx_pipe [$];

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        scb_analysis_imp = new("scb_analysis_imp", this);
    endfunction

    virtual function void write(seq_item item);
        rx_pipe.push_front(item.rx_data);
        if (rx_pipe.size() > PIPE_LATENCY) begin
            void'(rx_pipe.pop_back());
        end
        // `uvm_error(get_name(), $sformatf("\nrx_pipe: %0p", rx_pipe))

        // if (rx_pipe.size() >= PIPE_LATENCY) begin
            foreach (golay_code[i]) begin 
                // `uvm_error(get_name(), $sformatf("\ngolay_code[%0d] == rx_pipe[$] = %024h == %024h = %0b : %0p", i, golay_code[i], rx_pipe[$], golay_code[i] == rx_pipe[$], rx_pipe))
                if (golay_code[i] == rx_pipe[$]) begin
                    // `uvm_error(get_name(), $sformatf("\nINDEX: %0p", rx_pipe))
                    idx = i;
                end
            end

            if (item.msg_data != msg[idx])
                `uvm_error(get_name(), $sformatf("\n[MSG ERROR] idx=%0d rx=%0h : DUT=%0h, esperado=%0h",
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
        // end

    endfunction

endclass