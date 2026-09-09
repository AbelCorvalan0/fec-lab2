class tb_virtual_seq extends uvm_sequence #(seq_item);
  `uvm_object_utils(tb_virtual_seq)

  function new(string name = "tb_virtual_seq");
    super.new(name);
  endfunction

  uvm_sequencer #(seq_item) sequencer;  // set by the test

  task body();
    corner_sequence corners =
      corner_sequence::type_id::create("corners");

    arm_sequence arm_seq;
    rand_sequence rnd =
      rand_sequence::type_id::create("rnd");

    `uvm_info(get_name(), "corner cases...", UVM_LOW)
    corners.start(sequencer);

    for (int a = 1; a <= 5; a++) begin
      arm_seq =
        arm_sequence::type_id::create($sformatf("arm%0d", a));

      arm_seq.arm = a;
      arm_seq.n_items = 400;

      `uvm_info(get_name(),
                $sformatf("forcing arm %0d...", a),
                UVM_LOW)

      arm_seq.start(sequencer);
    end

    `uvm_info(get_name(), "random sweep...", UVM_LOW)

    rnd.n_items = 5000;
    rnd.start(sequencer);
  endtask
endclass
