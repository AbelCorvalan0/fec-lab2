class tb_report extends uvm_object;

    localparam MAX_ERROR_WEIGHT = 4;

    // array index represent error weight, ranges from 0 to 4
    int unsigned error_weight   [MAX_ERROR_WEIGHT+1]    = '{(MAX_ERROR_WEIGHT+1){0}};
    int unsigned corrected      [MAX_ERROR_WEIGHT+1]    = '{(MAX_ERROR_WEIGHT+1){0}};
    int unsigned detected       [MAX_ERROR_WEIGHT+1]    = '{(MAX_ERROR_WEIGHT+1){0}};

    `uvm_object_utils_begin(tb_report)
        `uvm_field_sarray_int(error_weight  , UVM_DEFAULT | UVM_DEC)
        `uvm_field_sarray_int(corrected     , UVM_DEFAULT | UVM_DEC)
        `uvm_field_sarray_int(detected      , UVM_DEFAULT | UVM_DEC)
    `uvm_object_utils_end

    function new(string name="tb_report");
        super.new(name);
    endfunction

    function void update(seq_item item);
        int unsigned weight = $countones(item.error_pattern);

        // uncorrectable will give zero error_pattern
        if (item.uncorrectable) begin
            weight = 4;
        end
        error_weight[weight]++;
        corrected[weight]   += item.corrected;
        detected[weight]    += item.uncorrectable;
    endfunction

endclass