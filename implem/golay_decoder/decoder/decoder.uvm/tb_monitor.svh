class tb_monitor extends uvm_monitor;
    `uvm_component_utils(tb_monitor)

    function new(string name="tb_monitor", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    // DUT Latency
    localparam int PIPE_LATENCY = 3;

    virtual dut_if                  vif;
    uvm_analysis_port#(seq_item)    mon_analysis_port;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "Could not get vif")
        mon_analysis_port = new("mon_analysis_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        // queue
        bit [NB_CODEWORD-1:0] rx_pipe[$];
        super.run_phase(phase);

        forever begin
            @(posedge vif.i_clock);
            #1; // state

            // save any i_rx that that arrives to DUT
            // history needed to compensate pipeline latency
            rx_pipe.push_back(vif.i_rx);

            // pop when size > 3. three latency cycles
            if (rx_pipe.size() > PIPE_LATENCY) begin
                seq_item item = seq_item::type_id::create("item", this);

                item.rx_data        = rx_pipe.pop_front();
                item.msg_data       = vif.o_msg;
                item.error_pattern  = vif.o_err;
                item.corrected      = vif.o_corrected;
                item.uncorrectable  = vif.o_uncorrectable;

                mon_analysis_port.write(item);
            end
        end
    endtask

endclass