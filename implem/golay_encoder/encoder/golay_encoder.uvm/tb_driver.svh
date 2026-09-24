class tb_driver extends uvm_driver#(seq_item);
    `uvm_component_utils(tb_driver)

    function new(string name = "tb_driver", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual dut_if vif;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        // request handle to the interface
        if (!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRV", "Could not get vif")
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        forever begin
            seq_item item;

            // seq_item_port is the "channel" to 
            // send items to the driver
            // items generates sequence
            seq_item_port.get_next_item(item);

            @(posedge vif.i_clock);
            vif.i_rx <= item.rx_data;

            seq_item_port.item_done();
        end
    endtask

endclass