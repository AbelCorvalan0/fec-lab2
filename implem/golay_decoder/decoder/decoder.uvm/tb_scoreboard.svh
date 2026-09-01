// The scoreboard receives a data object through its uvm_analysis_imp port from the monitor.
// As soon as the scoreboard receives an item, its write method will be executed which in turn runs the checker and generate reports.
class tb_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(tb_scoreboard)

    function new(string name="tb_scoreboard", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    dut_model_t                                 model;
    uvm_analysis_imp#(seq_item, tb_scoreboard)  scb_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        model               = dut_model_t::type_id::create("model");
        scb_analysis_imp    = new("scb_analysis_imp", this);
    endfunction

    virtual function write(seq_item item);
        seq_item    model_output = seq_item::type_id::create("model_output");
        bit         error_flags [$];
        
        // if (!item.input_valid) begin
        //     valid_zero: assert (!item.output_valid && item.output_data == '0 && !item.corrected)
        //         else `uvm_fatal(get_name(), $sformatf(  "Assertion valid_zero failed!: !%0b && %0b == '0 && !%0b"   ,
        //                                                 item.output_valid, item.output_data, item.corrected         ))
        // end
        // else begin
        //     model_output.copy(item);
        //     model.get_output(model_output.input_data, model_output.syndrome, model_output.output_data, model_output.corrected);

        //     if (!item.compare(model_output)) begin
        //         error_flags = '{
        //             item.output_data != model_output.output_data    ,
        //             item.corrected != model_output.corrected        
        //         };

        //         if (error_flags[0]) begin
        //             `uvm_error(get_name(), $sformatf(   "[DATA ERROR] r = %04b: DUT = %04b, model = %04b"           ,
        //                                                 item.input_data, item.output_data, model_output.output_data ))
        //         end
        //         if (error_flags[1]) begin
        //             `uvm_error(get_name(), $sformatf(   "[CORRECTED FLAG ERROR] r = %04b: DUT = %0b, model = %0b"   ,
        //                                                 item.input_data, item.corrected, model_output.corrected     ))
        //         end
        //         model_output.print();
        //         item.print();
        //     end
        // end

    endfunction
    
endclass