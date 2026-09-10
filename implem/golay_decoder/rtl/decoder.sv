`timescale 1ns / 1ps

module decoder
#(
    // PIPE STAGE 1
    parameter                                   NB_WORD         = 12    ,
    parameter                                   NB_CODEWORD     = 24    

    // PIPE STAGE 2
    
)(
    output  logic   [NB_WORD        - 1 : 0]    o_msg                   ,
    output  logic   [NB_CODEWORD    - 1 : 0]    o_err                   ,
    output  logic                               o_corrected             ,
    output  logic                               o_uncorrectable         ,
    input   logic   [NB_CODEWORD    - 1 : 0]    i_rx                    ,
    input   logic                               i_rst                   ,
    input   logic                               i_clk                   
);
    // LOCALPARAM/VARIABLES

    // LOGIC STAGE 1
    // ======================================================================
    localparam                                  NB_PIPE_STAGE_1 = NB_WORD+1+NB_CODEWORD ;
    logic       [NB_WORD            - 1 : 0]    syndrome                                ;
    logic                                       syndrome_zero                           ;
    logic       [NB_PIPE_STAGE_1    - 1 : 0]    pipe_stage_1                            ;

    golay_syndrome # (
        .NB_WORD        ( NB_WORD       ),
        .NB_CODEWORD    ( NB_CODEWORD   )
    )
    syndrome_inst (
        .o_syndrome     ( syndrome      ),
        .o_zero         ( syndrome_zero ),
        .i_rx           ( i_rx          )
    );
    
    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            pipe_stage_1    <= '0   ;
        end
        else begin
            pipe_stage_1    <= {
                                    syndrome        ,
                                    syndrome_zero   ,
                                    i_rx            
                                };
        end
    end
    
    // LOGIC STAGE 2
    // ======================================================================
    localparam                                  NB_ROW_INDEX            = $clog2(NB_WORD)       ;
    localparam                                  NB_WEIGHT               = $clog2(NB_WORD+1)     ;
    localparam                                  NB_PIPE_STAGE_2         = 5*NB_WORD+2*NB_WEIGHT ;
    logic       [NB_WORD            - 1 : 0]    syndrome_d                                      ;
    logic                                       syndrome_zero_d                                 ;
    logic       [NB_CODEWORD        - 1 : 0]    rx_d                                            ;
    logic       [NB_WORD            - 1 : 0]    q_vector                                        ;
    logic       [NB_WORD            - 1 : 0]    row_search_s_res                                ;
    logic       [NB_ROW_INDEX       - 1 : 0]    row_search_s_row_index                          ;
    logic                                       row_search_s_found                              ;
    logic       [NB_WORD            - 1 : 0]    row_search_q_res                                ;
    logic       [NB_ROW_INDEX       - 1 : 0]    row_search_q_row_index                          ;
    logic                                       row_search_q_found                              ;
    logic       [NB_WEIGHT          - 1 : 0]    weight_s                                        ;
    logic       [NB_WEIGHT          - 1 : 0]    weight_q                                        ;
    logic       [NB_PIPE_STAGE_2    - 1 : 0]    pipe_stage_2                                    ;
    
    assign {syndrome_d, syndrome_zero_d, rx_d}  = pipe_stage_1 ;

    golay_mult_b # (
        .NB_VECTOR  ( NB_WORD       )
    )
    q_vector_inst (
        .o_vec      ( q_vector      ),
        .i_vec      ( syndrome_d    )
    );
    
    golay_row_search # (
        .NB_WORD        ( NB_WORD                   ),
        .NB_CODEWORD    ( NB_CODEWORD               )
    )
    row_search_s_inst (
        .o_res          ( row_search_s_res          ),
        .o_row_index    ( row_search_s_row_index    ),
        .o_found        ( row_search_s_found        ),
        .i_vector       ( syndrome_d                )
    );

    golay_row_search # (
        .NB_WORD        ( NB_WORD                   ),
        .NB_CODEWORD    ( NB_CODEWORD               )
    )
    row_search_q_inst (
        .o_res          ( row_search_q_res          ),
        .o_row_index    ( row_search_q_row_index    ),
        .o_found        ( row_search_q_found        ),
        .i_vector       ( q_vector                  )
    );
    
    popcount # (
        .NB_DATA    ( NB_WORD       )
    )
    weight_s_inst (
        .o_weight   ( weight_s      ),
        .i_vec      ( syndrome_d    )
    );

    popcount # (
        .NB_DATA    ( NB_WORD       )
    )
    weight_q_inst (
        .o_weight   ( weight_q      ),
        .i_vec      ( q_vector      )
    );
    
    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            pipe_stage_2 <= '0; 
        end
        else begin
            pipe_stage_2    <= {
                                    syndrome_d              ,
                                    q_vector                ,
                                    weight_s                ,
                                    weight_q                ,
                                    rx_d                    ,
                                    row_search_s_res        ,
                                    row_search_s_row_index  ,
                                    row_search_s_found      ,
                                    row_search_q_res        ,
                                    row_search_q_row_index  ,
                                    row_search_q_found      
                                };
        end
    end

    // LOGIC STAGE 3
    // ======================================================================

    localparam NB_PIPE_STAGE_3   = NB_WORD;

    logic       [NB_CODEWORD  - 1 : 0]    rx_dd                       ;
    logic       [NB_WORD      - 1 : 0]    syndrome_dd                 ;
    logic       [NB_WORD      - 1 : 0]    q_vector_d                  ;
    logic       [NB_WEIGHT    - 1 : 0]    weight_s_d                  ;
    logic       [NB_WEIGHT    - 1 : 0]    weight_q_d                  ;
    logic       [NB_WORD      - 1 : 0]    row_search_s_res_d          ;
    logic       [NB_WORD      - 1 : 0]    row_search_q_res_d          ;
    logic       [NB_ROW_INDEX - 1 : 0]    row_search_s_row_index_d    ;
    logic       [NB_ROW_INDEX - 1 : 0]    row_search_q_row_index_d    ;
    logic                                 row_search_s_found_d        ;
    logic                                 row_search_q_found_d        ;

    
    logic       [NB_PIPE_STAGE_3 - 1 : 0] pipe_stage_3;

    golay_err_gen # (
        .NB_WORD            ( NB_WORD                       ),
        .NB_ERR             ( NB_ERR                        ),
        .NB_CNT             ( NB_CNT                        ),
    )
    golay_err_gen_inst  (
        .i_syn              ( syndrome_dd                   ),
        .i_q                ( q_vector_d                    ),
        .i_res_syn          ( row_search_s_res_d            ),
        .i_res_q            ( row_search_q_res_d            ),
        .i_w_syn            ( weight_s_d                    ),
        .i_w_q              ( weight_q_d                    ),
        .i_idx_syn          ( row_search_s_row_index_d      ),
        .i_idx_q            ( row_search_q_row_index_q      ),
        .i_found_syn        ( row_search_s_found_d          ),
        .i_found_q          ( row_search_q_found_d          ),
        .i_w_res_syn        ( weight_s_d                    ),
        .i_w_res_q          ( weight_q_d                    ),
        .o_err              ( golay_correct_err             ),
        .o_uncorrectable    ( golay_correct_uncorrectable   )
    );

    logic [NB_ERR - 1 : 0] golay_correct_err;

    golay_correct  
    golay_correct_inst (
        .i_rx               ( rx_dd                 ),
        .i_err              ( golay_correct_err     ),
        .o_cw               ( o_cw                  ),
        .o_msg              ( o_msg                 ),
        .o_corrected        ( o_corrected           )
    );

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            pipe_stage_3 <= '0;
        end
        else begin
            pipe_stage_3 <= {   
                                rx_dd            , 
                                golay_correct_err, 
                                o_cw             , 
                                o_msg            , 
                                o_corrected
                            };            
        end
    end

// OUTPUT ASSIGNATION

endmodule
