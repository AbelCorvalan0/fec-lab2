`timescale 1ns / 1ps

module popcount
#(
    parameter                                   NB_DATA     = 12    
)(
    output  logic   [$clog2(NB_DATA+1)  -1:0]   o_weight            ,
    input   logic   [NB_DATA            -1:0]   i_vec               
);
    // LOCALPARAM/VARIABLES
    localparam                      NB_WEIGHT   = $clog2(NB_DATA+1) ;
    logic       [NB_WEIGHT  -1:0]   weight                          ;
    
    always_comb begin
        weight  = 'b0;
        for (int i=0; i<NB_DATA; ++i) begin
            weight += i_vec[i];
        end
    end

    // OUTPUT ASSIGNATION
    assign o_weight            = weight   ;

endmodule
