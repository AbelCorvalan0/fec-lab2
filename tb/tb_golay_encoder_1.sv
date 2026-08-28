`timescale 1ns/1ps

module tb_golay_encoder_1;

    localparam int NB_WORD     = 12;
    localparam int NB_CODEWORD = 24;
    localparam int I_DIM       = 12;

    logic [NB_WORD     - 1 : 0] i_word;
    logic [NB_CODEWORD - 1 : 0] cw;

    golay_encoder #(
        .NB_WORD     (NB_WORD),
        .NB_CODEWORD (NB_CODEWORD),
        .I_DIM       (I_DIM)
    ) dut (
        .i_word (i_word),
        .cw     (cw)
    );

    initial begin
        $dumpfile("tb_golay_encoder_1.vcd");
        $dumpvars(0, tb_golay_encoder_1);

        i_word = 12'hA5C;
        #1;

        $display("i_word = %03h  cw = %06h", i_word, cw);

        $finish;
    end

endmodule
