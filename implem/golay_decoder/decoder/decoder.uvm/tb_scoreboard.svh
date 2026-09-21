class tb_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(tb_scoreboard)

    function new(string name="tb_scoreboard", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    // DUT Latency
    localparam int PIPE_LATENCY = 3 + 1;

    int                                         file_handle;
    int                                         latency;
    seq_item                                    item;
    tb_report                                   report;
    uvm_analysis_imp#(seq_item, tb_scoreboard)  scb_analysis_imp;

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        $system("pwd");
        file_handle = $fopen("../../../../decoder.uvm/sequences/codewords_testing_golay_code.txt", "r");
        if (file_handle == 0) begin
            `uvm_fatal("FILE_OPEN_ERROR", "Failed to open file for reading!")
        end
        latency = 0;
        item    = null;
        report  = tb_report::type_id::create("report");

        scb_analysis_imp = new("scb_analysis_imp", this);
    endfunction
  
    virtual function void write(seq_item item);
        // compensate latency
        if (latency < PIPE_LATENCY) begin
            `uvm_info("0 LEVEL", $sformatf("\nlatency = %0d", latency), UVM_DEBUG)
            latency++;
            return;
        end

        `uvm_info("TRIGGER", $sformatf("\nlatency = %0d", latency), UVM_DEBUG)
        report.update(item);
        this.item = item;
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        while (!$feof(file_handle)) begin
            seq_item    model_output = seq_item::type_id::create("model_output");
            int         status;
            
            wait(item != null);
            `uvm_info("RECEIVED", $sformatf("\nwait(this.item != null);"), UVM_DEBUG)

            
            // format: rx msg err corrected uncorrectable
            status = $fscanf(   file_handle, "%b %b %b %b %b\n", model_output.rx_data   ,
                                model_output.msg_data, model_output.error_pattern       ,
                                model_output.corrected, model_output.uncorrectable      );
            if (status == 0) begin
                `uvm_fatal("FILE_READ_ERROR", "Failed to read file!")
            end

            // we dont need rx_data for model
            model_output.rx_data = item.rx_data;
            
            // insert random errors, for testing
            // item.msg_data ^= $urandom_range(0,1);

            if (!item.compare(model_output)) begin
                if (item.msg_data != model_output.msg_data)
                    `uvm_error(get_name(), $sformatf(   "\n[MSG ERROR] rx=%06h : DUT=%06h, esperado=%06h",
                                                        item.rx_data, item.msg_data, model_output.msg_data))
        
                if (item.error_pattern != model_output.error_pattern)
                    `uvm_error(get_name(), $sformatf(   "\n[ERR ERROR] rx=%06h : DUT=%024b, esperado=%024b",
                                                        item.rx_data, item.error_pattern, model_output.error_pattern))
        
                if (item.corrected != model_output.corrected)
                    `uvm_error(get_name(), $sformatf(   "\n[CORRECTED ERROR] rx=%06h : DUT=%0b, esperado=%0b",
                                                        item.rx_data, item.corrected, model_output.corrected))
        
                if (item.uncorrectable != model_output.uncorrectable)
                    `uvm_error(get_name(), $sformatf(   "\n[UNCORRECTABLE ERROR] rx=%06h : DUT=%0b, esperado=%0b",
                                                        item.rx_data, item.uncorrectable, model_output.uncorrectable))
                item.print();
                model_output.print();
            end
            item = null;
        end

        $fclose(file_handle);
    endtask

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        report.print();
    endfunction

endclass
