`timescale 1ns / 1ps

module decoder
#(
    parameter                                   NB_WORD         = 12    ,
    parameter                                   NB_CODEWORD     = 24    
)(
    output  logic   [NB_WORD        - 1 : 0]    o_msg                   ,
    output  logic   [NB_CODEWORD    - 1 : 0]    o_err                   ,
    output  logic                               o_corrected             ,
    output  logic                               o_uncorrectable         ,
    input   logic   [NB_CODEWORD    - 1 : 0]    i_rx                    ,
    input   logic                               i_rst                   ,
    input   logic                               i_clk                   
);
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
    localparam                                  NB_PIPE_STAGE_2         = NB_CODEWORD
                                                                            +NB_WORD*4
                                                                            +NB_WEIGHT*4 
                                                                            +NB_ROW_INDEX*2
                                                                            + 2                 ;
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
    logic       [NB_WEIGHT          - 1 : 0]    weight_sbi                                      ;
    logic       [NB_WEIGHT          - 1 : 0]    weight_qbi                                      ;
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
        .NB_DATA    ( NB_WORD          )
    )
    weight_sbi_inst (
        .o_weight   ( weight_sbi       ),
        .i_vec      ( row_search_s_res )
    );

    popcount # (
        .NB_DATA    ( NB_WORD           )
    )
    weight_qbi_inst (
        .o_weight   ( weight_qbi        ),
        .i_vec      ( row_search_q_res  )
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
                                    row_search_q_found      ,
                                    weight_sbi              ,
                                    weight_qbi
                                };
        end
    end

    // LOGIC STAGE 3
    // ======================================================================

    localparam NB_PIPE_STAGE_3   = NB_WORD + NB_CODEWORD + 2;

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
    logic       [NB_WEIGHT    - 1 : 0]    weight_sbi_d                ;
    logic       [NB_WEIGHT    - 1 : 0]    weight_qbi_d                ;

    assign { syndrome_dd             ,             
             q_vector_d              ,
             weight_s_d              ,
             weight_q_d              ,
             rx_dd                   , 
             row_search_s_res_d      ,
             row_search_s_row_index_d,
             row_search_s_found_d    ,
             row_search_q_res_d      ,
             row_search_q_row_index_d,
             row_search_q_found_d    ,     
             weight_sbi_d            , 
             weight_qbi_d             } = pipe_stage_2 ;

    logic [NB_PIPE_STAGE_3 - 1 : 0] pipe_stage_3;
    logic [NB_CODEWORD     - 1 : 0] err_gen_err;
    logic                           err_gen_uncorrectable;

    golay_err_gen # (
        .NB_WORD            ( NB_WORD                       ),
        .NB_ERR             ( NB_CODEWORD                   ),
        .NB_CNT             ( NB_WEIGHT                     )
    )
    err_gen_inst  (
        .i_syn              ( syndrome_dd                   ),
        .i_q                ( q_vector_d                    ),
        .i_res_syn          ( row_search_s_res_d            ),
        .i_res_q            ( row_search_q_res_d            ),
        .i_w_syn            ( weight_s_d                    ),
        .i_w_q              ( weight_q_d                    ),
        .i_idx_syn          ( row_search_s_row_index_d      ),
        .i_idx_q            ( row_search_q_row_index_d      ),
        .i_found_syn        ( row_search_s_found_d          ),
        .i_found_q          ( row_search_q_found_d          ),
        .i_w_res_syn        ( weight_sbi_d                  ),
        .i_w_res_q          ( weight_qbi_d                  ),
        .o_err              ( err_gen_err                   ),
        .o_uncorrectable    ( err_gen_uncorrectable         )
    );

    logic [NB_CODEWORD - 1 : 0] codeword;
    logic [NB_WORD     - 1 : 0] message; 
    logic                       corrected;


    golay_correct  
    correct_inst (
        .i_rx               ( rx_dd         ),
        .i_err              ( err_gen_err   ),
        .o_cw               ( codeword      ),
        .o_msg              ( message       ),
        .o_corrected        ( corrected     )
    );

    logic [NB_WORD      - 1 : 0]    message_d; 
    logic [NB_CODEWORD  - 1 : 0]    err_gen_err_d;
    logic                           corrected_d;
    logic                           err_gen_uncorrectable_d;

    always_ff @(posedge i_clk) begin
        if (i_rst) begin
            pipe_stage_3 <= '0;
        end
        else begin
            pipe_stage_3 <= {   
                                message                    ,
                                err_gen_err                ,
                                corrected                  ,
                                err_gen_uncorrectable       
                            };            
        end
    end

assign {message_d, err_gen_err_d, corrected_d, err_gen_uncorrectable_d} = pipe_stage_3;

// OUTPUT ASSIGNATION
assign o_msg 	       = message_d                  ;
assign o_err           = err_gen_err_d              ;
assign o_corrected     = corrected_d                ;
assign o_uncorrectable = err_gen_uncorrectable_d    ;

endmodule
