// The scoreboard receives a data object through its uvm_analysis_imp port from the monitor.
// As soon as the scoreboard receives an item, its write method will be executed which in turn runs the checker and generate reports.
class tb_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(tb_scoreboard)

    function new(string name="tb_scoreboard", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    uvm_analysis_imp#(seq_item, tb_scoreboard)  scb_analysis_imp;
    // Index for rx_data (assoc).
    // for each codeword, save index
    int cw_to_idx[bit [NB_CODEWORD - 1 : 0]];
    
    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        scb_analysis_imp    = new("scb_analysis_imp", this);
    
        foreach (golay_code[i])
            cw_to_idx[golay_code[i]] = i;

    endfunction

    virtual function void write(seq_item item);
        // item comes from monitos (tb_monitor.svh), loaded with info that comes from RTL
        // item.rx_data = vif.i_rx (input)
        // item.msg_data, item.error_pattern, item.corrected, item.uncorrectable -> outputs from DUT

        int                   idx;      // index of gold model for this codeword
        bit [NB_WORD - 1 : 0] exp_msg;  // golden model msg

        // Verify
        if(!cw_to_idx.exists(item.rx_data)) begin
            // codeword isn't within golde model table
            `uvm_error(get_name(), $sformatf(
                "rx_data 0x%0h isn't within golden model table",
                item.rx_data))
            return;
        end

        idx = cw_to_idx[item.rx_data];
        
        exp_msg = decoded_data[idx][NB_CODEWORD-1 -: NB_WORD];

        // expected message = 12-bits (msg|parity)
        if (item.msg_data != exp_msg)
            `uvm_error(get_name(), $sformatf(
                "[MSG] rx=0x%0h: DUT=%0b esperado=%0b", item.rx_data, item.msg_data, exp_msg))

        if (item.error_pattern != err[idx])
            `uvm_error(get_name(), $sformatf(
                "[ERR] rx=0x%0h: DUT=%0b esperado=%0b", item.rx_data, item.error_pattern, err[idx]))

        if (item.corrected != corrected_data[idx])
            `uvm_error(get_name(), $sformatf(
                "[CORRECTED] rx=0x%0h: DUT=%0b esperado=%0b", item.rx_data, item.corrected, corrected_data[idx]))

        if (item.uncorrectable != uncorrectable[idx])
    `uvm_error(get_name(), $sformatf(
        "[UNCORRECTABLE] rx=0x%0h: DUT=%0b esperado=%0b", item.rx_data, item.uncorrectable, uncorrectable[idx]))
        
    endfunction
    
endclass