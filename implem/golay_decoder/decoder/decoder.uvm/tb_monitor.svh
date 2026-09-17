class tb_monitor extends uvm_monitor;
    `uvm_component_utils(tb_monitor)

    function new(string name="tb_monitor", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual dut_if               vif;
    uvm_analysis_port#(seq_item) mon_analysis_port;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif))
            `uvm_fatal("MON", "Could not get vif")

        mon_analysis_port = new("mon_analysis_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        // cycle_count = 0;
        
        forever begin
            seq_item item = seq_item::type_id::create("item", this);

            @(posedge vif.i_clock);
            
            // // Reset
            // if (vif.i_rst) begin
            //     cycle_count = 0;
            //     rx_pipe.delete();
            //     continue;
            // end

            // cycle_count++;

            // // Guardar input actual
            // rx_pipe.push_back(vif.i_rx);

            // if (rx_pipe.size() >= PIPE_LATENCY) begin

            //     item = 

            //     // Input correspondiente a la salida actual
                item.rx_data = vif.i_rx;
                // item.rx_data = rx_pipe.pop_front();

                // Outputs del DUT
                item.msg_data      = vif.o_msg;
                item.error_pattern = vif.o_err;
                item.corrected     = vif.o_corrected;
                item.uncorrectable = vif.o_uncorrectable;

                mon_analysis_port.write(item);
            // end
        end

    endtask

endclass