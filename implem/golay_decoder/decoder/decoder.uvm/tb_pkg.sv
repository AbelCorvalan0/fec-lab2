package tb_pkg;
    // defs, classes and configs shared in common scope
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    `timescale 1ns/1ps
    
    parameter   NB_WORD     = 12;
    parameter   NB_CODEWORD = 24;

    `include "dut_model.svh"
    typedef decoder_model#(NB_WORD, NB_CODEWORD) dut_model_t;

    `include "sequences/golay_code_constraint.svh"
    `include "sequences/seq_item.svh"
    `include "sequences/seq_lib.svh"
    
    `include "tb_scoreboard.svh"
    `include "tb_driver.svh"
    `include "tb_monitor.svh"
    `include "tb_agent.svh"
    // `include "tb_coverage.svh"
    `include "tb_environment.svh"
    `include "tb_virtual_seq.svh"
    `include "tb_test.svh"

endpackage
