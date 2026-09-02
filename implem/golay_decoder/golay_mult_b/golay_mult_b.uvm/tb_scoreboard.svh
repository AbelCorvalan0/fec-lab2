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
        
        model_output.copy(item);
        model.get_output(model_output.input_vector, model_output.output_vector);
        `uvm_info(get_name(), $sformatf(    "\ninput_vector = %03h: output_vector = %03h"   ,
                                            item.input_vector, model_output.output_vector   ), UVM_NONE)

        if (!item.compare(model_output)) begin
            error_flags = '{
                item.output_vector != model_output.output_vector
            };

            if (error_flags[0]) begin
                `uvm_error(get_name(), $sformatf("\n[VECTOR ERROR] vector = %012b: DUT = %012b, model = %012b"          ,
                                                    item.input_vector, item.output_vector, model_output.output_vector   ))
            end
            item.print();
            model_output.print();
        end

    endfunction
    
endclass