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
        

        // else begin
            model_output.copy(item);
            model.get_output(model_output.rx_data, model_output.msg_data, model_output.error_pattern, model_output.corrected, model_output.uncorrectable);
            model_output.print();
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