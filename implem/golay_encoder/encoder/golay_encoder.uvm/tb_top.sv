`include "dut_if.sv"

module tb_top;
    import uvm_pkg::*;
    import tb_pkg::*;

    logic i_clock = 0;
    always #10 i_clock <= ~i_clock;

    dut_if #()
    vif (
        .i_clock ( i_clock )
    );

    golay_encoder # (
        .NB_WORD        ( NB_WORD       ),
        .NB_CODEWORD    ( NB_CODEWORD   )
    )
    dut (
        .i_word         ( vif.i_word    ),
        .cw             ( vif.cw        )
    );

    initial begin
        uvm_config_db#(virtual dut_if)::set(null, "uvm_test_top", "vif", vif);
        run_test("tb_test");
    end

    initial begin
        $dumpvars;
        $dumpfile("dump.vcd");
    end

endmodule