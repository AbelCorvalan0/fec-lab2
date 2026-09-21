class codewords_with_error_sequence extends uvm_sequence;
    `uvm_object_utils(codewords_with_error_sequence)

    function new(string name= "codewords_with_error_sequence");
        super.new(name);
        file_handle = $fopen("../../../../decoder.uvm/sequences/codewords_testing_golay_code.txt", "r");
        if (file_handle == 0) begin
            `uvm_fatal("FILE_OPEN_ERROR", "Failed to open file for reading!")
        end
    endfunction

    int file_handle;

    virtual task body();
        seq_item    item;
        string      dump;
        int         status;

        while (!$feof(file_handle)) begin
            item = seq_item::type_id::create("item");
            
            start_item(item);
            // format: rx msg err corrected uncorrectable
            status = $fscanf(file_handle, "%b %b %b %b %b\n", item.rx_data ,item.msg_data, item.error_pattern, item.corrected, item.uncorrectable);
            if (status == 0) begin
                `uvm_fatal("FILE_READ_ERROR", "Failed to read file!")
            end
            // why dont "drive output ports"
            item.msg_data       = 0;
            item.error_pattern  = 0;
            item.corrected      = 0;
            item.uncorrectable  = 0;
            finish_item(item);
        end
    endtask

endclass
