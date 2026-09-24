// The scoreboard receives a data object through its uvm_analysis_imp port from the monitor.
// As soon as the scoreboard receives an item, its write method will be executed which in turn runs the checker and generate reports.
class tb_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(tb_scoreboard)

    function new(string name="tb_scoreboard", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    uvm_analysis_imp#(seq_item, tb_scoreboard)  scb_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        scb_analysis_imp    = new("scb_analysis_imp", this);
    endfunction

    virtual function write(seq_item item);
        seq_item    model_output = seq_item::type_id::create("model_output");
        bit         error_flags [$];
        
        MAX_LIMIT: assert (item.weight <= NB_DATA)
            else $error("Assertion MAX_LIMIT failed!");
        
        model_output.copy(item);
        model_output.weight = $countones(model_output.input_data);

        if (!item.compare(model_output)) begin
            error_flags = '{
                item.weight != model_output.weight
            };

            if (error_flags[0]) begin
                `uvm_error(get_name(), $sformatf("\n[WEIGHT ERROR] vector = %012b: DUT = %0d, model = %0d"  ,
                                                    item.input_data, item.weight, model_output.weight       ))
            end
            model_output.print();
            item.print();
        end

    endfunction
    
endclass