`timescale 1ns/1ps

// -------------------------------------------------------------------
// Testbench for golay_err_gen.sv
//
// golay_err_gen is purely combinational: it selects an error mask
// (o_err) out of four candidate corrections following a fixed
// priority, and raises o_uncorrectable when none of them applies.
//
//   1. w(s)       <= 3                     -> err = {12'b0, s}
//   2. found_syn && w(s^bi) <= 2           -> err = (1 << (idx_syn+12)) | {12'b0, s^bi}
//   3. w(q)       <= 3                     -> err = {q, 12'b0}
//   4. found_q   && w(q^bi) <= 2           -> err = {q^bi, 12'b0} | (1 << idx_q)
//   5. otherwise                          -> o_uncorrectable = 1, err = 0
//
// The reference model below re-implements that priority with an
// independent if/else chain and is compared against the DUT for
// directed corner cases plus a large randomized sweep.
// -------------------------------------------------------------------
module tb_golay_err_gen;

    localparam int NB_WORD = 12;
    localparam logic [3:0] COND_1 = 4'd3; // w(.)   <= 3
    localparam logic [3:0] COND_2 = 4'd2; // w(.^b) <= 2

    // DUT inputs
    logic [11:0] i_syn;
    logic [11:0] i_q;
    logic [11:0] i_res_syn;
    logic [11:0] i_res_q;
    logic [3:0]  i_w_syn;
    logic [3:0]  i_w_q;
    logic [3:0]  i_idx_syn;
    logic [3:0]  i_idx_q;
    logic        i_found_syn;
    logic        i_found_q;
    logic [3:0]  i_w_res_syn;
    logic [3:0]  i_w_res_q;

    // DUT outputs
    logic [23:0] o_err;
    logic        o_uncorrectable;

    int errors = 0;
    int checks = 0;

    golay_err_gen dut (
        .i_syn           (i_syn),
        .i_q             (i_q),
        .i_res_syn       (i_res_syn),
        .i_res_q         (i_res_q),
        .i_w_syn         (i_w_syn),
        .i_w_q           (i_w_q),
        .i_idx_syn       (i_idx_syn),
        .i_idx_q         (i_idx_q),
        .i_found_syn     (i_found_syn),
        .i_found_q       (i_found_q),
        .o_err           (o_err),
        .o_uncorrectable (o_uncorrectable),
        .i_w_res_syn     (i_w_res_syn),
        .i_w_res_q       (i_w_res_q)
    );

    // ---------------------------------------------------------------
    // Independent reference model
    // ---------------------------------------------------------------
    task automatic ref_model(output logic [23:0] err, output logic uncorr);
        begin
            err    = 24'b0;
            uncorr = 1'b0;

            if (i_w_syn <= COND_1) begin
                err = {12'b0, i_syn};
            end
            else if (i_found_syn && (i_w_res_syn <= COND_2)) begin
                err = (24'd1 << (i_idx_syn + NB_WORD)) | {12'b0, i_res_syn};
            end
            else if (i_w_q <= COND_1) begin
                err = {i_q, 12'b0};
            end
            else if (i_found_q && (i_w_res_q <= COND_2)) begin
                err = {i_res_q, 12'b0} | (24'd1 << i_idx_q);
            end
            else begin
                uncorr = 1'b1;
            end
        end
    endtask

    task automatic check(input bit cond, input string msg);
        checks++;
        if (!cond) begin
            errors++;
            $display("[FAIL] %s", msg);
        end
    endtask

    // Apply current inputs, settle, compare DUT vs reference.
    task automatic run_case(input string tag);
        logic [23:0] exp_err;
        logic        exp_uncorr;
        begin
            #1;
            ref_model(exp_err, exp_uncorr);
            check((o_err === exp_err) && (o_uncorrectable === exp_uncorr),
                $sformatf({"%s | s=%03h q=%03h rs=%03h rq=%03h ",
                           "w_s=%0d w_q=%0d w_rs=%0d w_rq=%0d ",
                           "idx_s=%0d idx_q=%0d f_s=%0b f_q=%0b :: ",
                           "o_err=%06h/%06h o_unc=%0b/%0b"},
                    tag, i_syn, i_q, i_res_syn, i_res_q,
                    i_w_syn, i_w_q, i_w_res_syn, i_w_res_q,
                    i_idx_syn, i_idx_q, i_found_syn, i_found_q,
                    o_err, exp_err, o_uncorrectable, exp_uncorr));
        end
    endtask

    task automatic clear_inputs();
        begin
            i_syn       = '0;
            i_q         = '0;
            i_res_syn   = '0;
            i_res_q     = '0;
            i_w_syn     = 4'd15;
            i_w_q       = 4'd15;
            i_idx_syn   = '0;
            i_idx_q     = '0;
            i_found_syn = 1'b0;
            i_found_q   = 1'b0;
            i_w_res_syn = 4'd15;
            i_w_res_q   = 4'd15;
        end
    endtask

    initial begin
        $dumpfile("tb_golay_err_gen.vcd");
        $dumpvars(0, tb_golay_err_gen);

        // ---------------------------------------------------------
        // Directed: branch 1 - w(s) <= 3
        // ---------------------------------------------------------
        clear_inputs();
        i_syn = 12'h000; i_w_syn = 4'd0;
        run_case("B1 w(s)=0, err=0 but correctable");

        clear_inputs();
        i_syn = 12'h807; i_w_syn = 4'd3;
        run_case("B1 w(s)=3");

        // w(s) at the boundary: 4 must NOT take branch 1
        clear_inputs();
        i_syn = 12'h00F; i_w_syn = 4'd4;
        i_w_q = 4'd15; i_found_syn = 0; i_found_q = 0;
        run_case("B1 boundary w(s)=4 -> falls through (expect uncorrectable)");

        // ---------------------------------------------------------
        // Directed: branch 2 - found_syn && w(s^bi) <= 2
        // ---------------------------------------------------------
        clear_inputs();
        i_w_syn = 4'd8;                  // block branch 1
        i_found_syn = 1'b1;
        i_w_res_syn = 4'd2;
        i_res_syn = 12'h005;
        i_idx_syn = 4'd0;
        run_case("B2 idx_syn=0");

        clear_inputs();
        i_w_syn = 4'd8;
        i_found_syn = 1'b1;
        i_w_res_syn = 4'd1;
        i_res_syn = 12'hABC;
        i_idx_syn = 4'd11;              // set bit 11+12 = 23
        run_case("B2 idx_syn=11 (top bit)");

        // idx_syn large enough that (1 << idx+12) shifts out of 24 bits
        clear_inputs();
        i_w_syn = 4'd8;
        i_found_syn = 1'b1;
        i_w_res_syn = 4'd0;
        i_res_syn = 12'h001;
        i_idx_syn = 4'd15;             // 15+12 = 27 -> shifted out
        run_case("B2 idx_syn=15 (shift past MSB)");

        // found_syn low -> branch 2 must not fire
        clear_inputs();
        i_w_syn = 4'd8;
        i_found_syn = 1'b0;
        i_w_res_syn = 4'd0;
        i_res_syn = 12'h0FF;
        i_w_q = 4'd15;
        run_case("B2 found_syn=0 -> fall through");

        // w(s^bi)=3 -> branch 2 must not fire
        clear_inputs();
        i_w_syn = 4'd8;
        i_found_syn = 1'b1;
        i_w_res_syn = 4'd3;
        run_case("B2 boundary w(s^bi)=3 -> fall through");

        // ---------------------------------------------------------
        // Directed: branch 3 - w(q) <= 3
        // ---------------------------------------------------------
        clear_inputs();
        i_w_syn = 4'd8;                 // block 1
        i_found_syn = 1'b0;            // block 2
        i_q = 12'h341; i_w_q = 4'd3;
        run_case("B3 w(q)=3");

        clear_inputs();
        i_w_syn = 4'd8;
        i_found_syn = 1'b1;            // branch 2 armed but w_res too big
        i_w_res_syn = 4'd7;
        i_q = 12'hFFF; i_w_q = 4'd0;
        run_case("B3 w(q)=0 while syn branches blocked");

        // ---------------------------------------------------------
        // Directed: branch 4 - found_q && w(q^bi) <= 2
        // ---------------------------------------------------------
        clear_inputs();
        i_w_syn = 4'd8;
        i_found_syn = 1'b0;
        i_w_q = 4'd9;                   // block 3
        i_found_q = 1'b1;
        i_w_res_q = 4'd2;
        i_res_q = 12'h013;
        i_idx_q = 4'd5;
        run_case("B4 idx_q=5");

        clear_inputs();
        i_w_syn = 4'd8;
        i_w_q = 4'd9;
        i_found_q = 1'b1;
        i_w_res_q = 4'd0;
        i_res_q = 12'h800;
        i_idx_q = 4'd11;
        run_case("B4 idx_q=11");

        // found_q low -> uncorrectable
        clear_inputs();
        i_w_syn = 4'd8;
        i_w_q = 4'd9;
        i_found_q = 1'b0;
        i_w_res_q = 4'd0;
        run_case("B4 found_q=0 -> uncorrectable");

        // ---------------------------------------------------------
        // Directed: branch 5 - uncorrectable
        // ---------------------------------------------------------
        clear_inputs();
        i_w_syn = 4'd10; i_w_q = 4'd10;
        i_found_syn = 1'b1; i_w_res_syn = 4'd5;
        i_found_q = 1'b1;   i_w_res_q = 4'd6;
        run_case("B5 all conditions fail -> uncorrectable, o_err=0");

        // ---------------------------------------------------------
        // Priority: branch 1 wins over an otherwise-valid branch 2
        // ---------------------------------------------------------
        clear_inputs();
        i_syn = 12'h081; i_w_syn = 4'd2;         // branch 1 valid
        i_found_syn = 1'b1; i_w_res_syn = 4'd0;  // branch 2 also valid
        i_res_syn = 12'h7FF; i_idx_syn = 4'd3;
        run_case("PRIO B1 beats B2");

        // Priority: branch 2 wins over branch 3
        clear_inputs();
        i_w_syn = 4'd8;                          // branch 1 invalid
        i_found_syn = 1'b1; i_w_res_syn = 4'd1;  // branch 2 valid
        i_res_syn = 12'h021; i_idx_syn = 4'd4;
        i_q = 12'h010; i_w_q = 4'd1;             // branch 3 also valid
        run_case("PRIO B2 beats B3");

        // Priority: branch 3 wins over branch 4
        clear_inputs();
        i_w_syn = 4'd8;
        i_found_syn = 1'b0;
        i_q = 12'h044; i_w_q = 4'd2;             // branch 3 valid
        i_found_q = 1'b1; i_w_res_q = 4'd0;      // branch 4 also valid
        i_res_q = 12'h088; i_idx_q = 4'd7;
        run_case("PRIO B3 beats B4");

        // ---------------------------------------------------------
        // Randomized sweep across the whole input space
        // ---------------------------------------------------------
        for (int t = 0; t < 20000; t++) begin
            i_syn       = $urandom();
            i_q         = $urandom();
            i_res_syn   = $urandom();
            i_res_q     = $urandom();
            i_w_syn     = $urandom();
            i_w_q       = $urandom();
            i_idx_syn   = $urandom();
            i_idx_q     = $urandom();
            i_found_syn = $urandom();
            i_found_q   = $urandom();
            i_w_res_syn = $urandom();
            i_w_res_q   = $urandom();
            run_case($sformatf("RAND t=%0d", t));
        end

        // ---------------------------------------------------------
        // Focused random sweep with small weights so branches 2 and 4
        // are exercised often (uniform random rarely gives w <= 2).
        // ---------------------------------------------------------
        for (int t = 0; t < 20000; t++) begin
            i_syn       = $urandom();
            i_q         = $urandom();
            i_res_syn   = $urandom();
            i_res_q     = $urandom();
            i_w_syn     = $urandom_range(0, 6);
            i_w_q       = $urandom_range(0, 6);
            i_idx_syn   = $urandom_range(0, 12);
            i_idx_q     = $urandom_range(0, 12);
            i_found_syn = $urandom();
            i_found_q   = $urandom();
            i_w_res_syn = $urandom_range(0, 4);
            i_w_res_q   = $urandom_range(0, 4);
            run_case($sformatf("RAND-SMALL t=%0d", t));
        end

        if (errors == 0)
            $display("\nRESULT: PASS (%0d/%0d checks ok)", checks, checks);
        else
            $display("\nRESULT: FAIL (%0d/%0d checks failed)", errors, checks);

        $finish;
    end

endmodule
