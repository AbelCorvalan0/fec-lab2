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

    golay_top # (
        .NB_WORD            ( NB_WORD               ),
        .NB_CODEWORD        ( NB_CODEWORD           )
    )
    dut (
        .i_word             ( vif.i_word            ),
        .i_error            ( vif.i_error           ),
        .i_rst              ( vif.i_rst             ),
        .i_clk              ( vif.i_clock           ),
        .o_msg              ( vif.o_msg             ),
        .o_err              ( vif.o_err             ),
        .o_corrected        ( vif.o_corrected       ),
        .o_uncorrectable    ( vif.o_uncorrectable   )
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