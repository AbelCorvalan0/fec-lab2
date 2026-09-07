`timescale 1ns/1ps

module golay_correct(
     input  logic [23 : 0] i_rx,
     input  logic [23 : 0] i_err,

     output logic [23 : 0] o_cw,
     output logic [11 : 0] o_msg,
     output logic          o_corrected
);

// i_rx  = {r[23:0]     , r[11:0]    }
// i_err = {i_err[23:0] | i_err[11:0]}
//              q       |      s

assign o_cw = i_rx ^ i_err;

assign o_msg = o_cw[23:12];

assign o_corrected = (i_rx[23:12] == o_msg);

endmodule
