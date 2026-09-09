class tb_test extends uvm_test;
  `uvm_component_utils(tb_test)

  function new(string name = "tb_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  tb_environment env;
  virtual dut_if vif;

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    env = tb_environment::type_id::create("env", this);

    if (!uvm_config_db#(virtual dut_if)::get(this, "", "vif", vif))
      `uvm_fatal("TEST", "no virtual interface")

    // hand the same handle to every component under env.agent
    uvm_config_db#(virtual dut_if)::set(this, "env.agent.*", "vif", vif);
  endfunction

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction

  virtual task run_phase(uvm_phase phase);
    tb_virtual_seq vseq = tb_virtual_seq::type_id::create("vseq");

    phase.raise_objection(this);

    vseq.sequencer = env.agent.sequencer;

    // "reset": park benign values on the bus for a couple of cycles
    vif.i_w_syn     = '1;
    vif.i_w_q       = '1;
    vif.i_w_res_syn = '1;
    vif.i_w_res_q   = '1;
    vif.i_found_syn =  0;
    vif.i_found_q   =  0;
    // init i_syn, i_q, i_res_syn, i_res_q,
    // i_idx_syn, i_idx_q

    repeat (2) @(posedge vif.i_clock);

    vseq.start(env.agent.sequencer); 
    repeat (5) @(posedge vif.i_clock);

    phase.drop_objection(this);
 endtask
endclass
