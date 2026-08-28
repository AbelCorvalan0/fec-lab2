`timescale 1ns/1ps

module tb_golay_encode;

    localparam int NB_WORD     = 12;
    localparam int NB_CODEWORD = 24;
    localparam int I_DIM       = 12;
    localparam int NB_MSGS     = 1 << NB_WORD; // 4096

    logic [NB_WORD     - 1 : 0] i_word;
    logic [NB_CODEWORD - 1 : 0] cw;

    int errors = 0;
    int checks = 0;

    golay_encoder #(
        .NB_WORD     (NB_WORD),
        .NB_CODEWORD (NB_CODEWORD),
        .I_DIM       (I_DIM)
    ) dut (
        .i_word (i_word),
        .cw     (cw)
    );

    // ---------------------------------------------------------------
    // Reference model, independent from the DUT's internal wiring.
    // G = [I | B], row j = {identity_row_j, b_row_j}. Built with an
    // explicit per-row loop (unlike the DUT's `{id_matrix, word_matrix}`
    // whole-array concatenation, this can't silently interleave rows).
    // The B constants are the same 12 rows golay_encoder.sv uses.
    // ---------------------------------------------------------------
    logic [NB_WORD - 1 : 0][NB_CODEWORD - 1 : 0] g_ref;

    function automatic logic [NB_WORD - 1 : 0][NB_CODEWORD - 1 : 0] build_reference_g();
        logic [NB_WORD - 1 : 0][NB_WORD - 1 : 0] id_m;
        logic [NB_WORD - 1 : 0][NB_WORD - 1 : 0] b_m;
        logic [NB_WORD - 1 : 0][NB_CODEWORD - 1 : 0] g;
        begin
            id_m = '0;
            for (int i = 0; i < NB_WORD; i++)
                id_m[i][i] = 1'b1;

            b_m[0]  = 12'h98F;
            b_m[1]  = 12'h4E7;
            b_m[2]  = 12'h357;
            b_m[3]  = 12'hBE2;
            b_m[4]  = 12'hDD1;
            b_m[5]  = 12'h7CC;
            b_m[6]  = 12'h53D;
            b_m[7]  = 12'h2BE;
            b_m[8]  = 12'h87B;
            b_m[9]  = 12'hE74;
            b_m[10] = 12'hF1A;
            b_m[11] = 12'hEA9;

            for (int j = 0; j < NB_WORD; j++)
                g[j] = {id_m[j], b_m[j]};

            return g;
        end
    endfunction

    function automatic int popcount(logic [NB_CODEWORD - 1 : 0] v);
        int cnt;
        begin
            cnt = 0;
            for (int b = 0; b < NB_CODEWORD; b++)
                cnt += v[b];
            return cnt;
        end
    endfunction

    function automatic logic [NB_CODEWORD - 1 : 0] expected_codeword(input logic [NB_WORD - 1 : 0] word);
        logic [NB_CODEWORD - 1 : 0] c;
        begin
            c = '0;
            for (int i = 0; i < NB_CODEWORD; i++)
                for (int j = 0; j < NB_WORD; j++)
                    c[i] ^= word[j] & g_ref[j][i];
            return c;
        end
    endfunction

    task automatic check(input bit cond, input string msg);
        checks++;
        if (!cond) begin
            errors++;
            $display("[FAIL] %s", msg);
        end
    endtask

    task automatic check_encode(input logic [NB_WORD - 1 : 0] word);
        logic [NB_CODEWORD - 1 : 0] expected;
        begin
            i_word = word;
            #1;
            expected = expected_codeword(word);
            check(cw === expected,
                $sformatf("i_word=%03h  cw=%06h  expected=%06h", word, cw, expected));
        end
    endtask

    initial begin
        $dumpfile("tb_golay_encode.vcd");
        $dumpvars(0, tb_golay_encode);

        g_ref = build_reference_g();

        // -----------------------------------------------------------
        // 0) Sanity-check the reference model itself: every nonzero
        //    codeword it produces must have weight >= 8, confirming
        //    the B-matrix constants form a genuine [24,12,8] Golay
        //    code before we trust it as an oracle for the DUT.
        // -----------------------------------------------------------
        begin
            int min_w;
            min_w = NB_CODEWORD;
            for (int m = 1; m < NB_MSGS; m++) begin
                int w;
                w = popcount(expected_codeword(m[NB_WORD - 1 : 0]));
                if (w < min_w) min_w = w;
            end
            check(min_w == 8,
                $sformatf("reference model minimum nonzero weight is %0d, expected 8 (bad oracle)", min_w));
        end

        // -----------------------------------------------------------
        // 1) i_word = 0 must produce cw = 0
        // -----------------------------------------------------------
        check_encode(12'h000);

        // -----------------------------------------------------------
        // 2) Exhaustive comparison: DUT vs. reference model for all
        //    4096 possible 12-bit messages.
        // -----------------------------------------------------------
        for (int m = 1; m < NB_MSGS; m++)
            check_encode(m[NB_WORD - 1 : 0]);

        // -----------------------------------------------------------
        // 3) Linearity: cw(a) ^ cw(b) == cw(a ^ b), a property any
        //    correct GF(2) linear encoder (cw = i_word * G) must have.
        // -----------------------------------------------------------
        for (int t = 0; t < 200; t++) begin
            logic [NB_WORD-1:0] a, b;
            logic [NB_CODEWORD-1:0] cw_a, cw_b, cw_ab;
            a = $urandom();
            b = $urandom();

            i_word = a; #1; cw_a = cw;
            i_word = b; #1; cw_b = cw;
            i_word = a ^ b; #1; cw_ab = cw;

            check((cw_a ^ cw_b) === cw_ab,
                $sformatf("linearity violated for a=%0h b=%0h: cw(a)^cw(b)=%0h cw(a^b)=%0h",
                          a, b, cw_a ^ cw_b, cw_ab));
        end

        if (errors == 0)
            $display("\nRESULT: PASS (%0d/%0d checks ok)", checks, checks);
        else
            $display("\nRESULT: FAIL (%0d/%0d checks failed)", errors, checks);

        $finish;
    end

endmodule
