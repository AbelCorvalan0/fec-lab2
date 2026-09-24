`include "dut_if.sv"

module tb_top;
    // Used classes must be imported inside a package
    import uvm_pkg::*;
    import tb_pkg::*;
    
    // Complex testbenches will have multiple clocks and hence multiple clock
    // generator modules that will be instantiated elsewhere
    // For simple designs, it can be put into testbench top
    logic i_clock = 0;

    always #10 i_clock <= ~i_clock;

    // Instantiate the Interface and pass it to Design
    dut_if #()
    vif (
        .i_clock    ( i_clock   )
    );

    golay_row_search # (
        .NB_WORD        ( NB_WORD           ),
        .NB_CODEWORD    ( NB_CODEWORD       )
    )
    dut (
        .o_res          ( vif.o_res         ),
        .o_row_index    ( vif.o_row_index   ),
        .o_found        ( vif.o_found       ),
        .i_vector       ( vif.i_vector      )
    );

    initial begin
        uvm_config_db#(virtual dut_if)::set (null, "uvm_test_top", "vif", vif);
        run_test ("tb_test");
    end

    initial begin
        $dumpvars;
        $dumpfile("dump.vcd");
    end

endmodule