class tb_test extends uvm_test;
    `uvm_component_utils(tb_test)

    function new(string name = "tb_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    tb_environment  env;
    virtual dut_if  vif;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = tb_environment::type_id::create("env", this);

        if (!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif))
            `uvm_fatal("TEST", "Did not get vif")
        uvm_config_db#(virtual dut_if)::set(this, "env.agent.*", "vif", vif);
    endfunction

    virtual task run_phase(uvm_phase phase);
        tb_virtual_seq vseq;

        phase.raise_objection(this);

        vseq           = tb_virtual_seq::type_id::create("vseq");
        vseq.sequencer = env.agent.sequencer;

        `uvm_info("TEST", "Reseting DUT", UVM_LOW)
        vif.i_rst = 1'b1;
        vif.i_rx  = '0;
        repeat(2) @(posedge vif.i_clock);
        vif.i_rst = 1'b0;
        @(posedge vif.i_clock);

        vseq.start(null);

        // drenar el pipeline (3 ciclos) antes de cortar
        repeat(3) @(posedge vif.i_clock);

        phase.drop_objection(this);
    endtask

endclass