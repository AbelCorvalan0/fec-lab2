package tb_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `timescale 1ns/1ps

    parameter   NB_WORD     = 12;
    parameter   NB_CODEWORD = 24;

    // Datos golden: golay_code, decoded_data, msg, err, corrected_data, uncorrectable
    //`include "sequences/codewords_testing_golay_code.txt"

    `include "sequences/seq_item.svh"
    `include "sequences/seq_lib.svh"

    `include "tb_scoreboard.svh"
    `include "tb_driver.svh"
    `include "tb_monitor.svh"
    `include "tb_agent.svh"
    `include "tb_environment.svh"
    `include "tb_virtual_seq.svh"
    `include "tb_test.svh"

endpackage