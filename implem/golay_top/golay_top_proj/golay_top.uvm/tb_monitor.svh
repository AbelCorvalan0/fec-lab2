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
        
        forever begin
            seq_item item = seq_item::type_id::create("item", this);

            @(posedge vif.i_clock);
            
            if (vif.i_rst) begin
                continue;
            end

            item.msg_data       = vif.o_msg;
            item.error_pattern  = vif.o_err;
            item.corrected      = vif.o_corrected;
            item.uncorrectable  = vif.o_uncorrectable;
            item.rx_data        = vif.i_rx;

            mon_analysis_port.write(item);
        end
    endtask

endclass