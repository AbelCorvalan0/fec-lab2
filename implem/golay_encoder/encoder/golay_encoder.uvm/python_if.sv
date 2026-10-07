interface python_if();
  // Encapsulate raw DPI-C declarations inside the interface block
  import "DPI-C" function void dut_model_create();
  import "DPI-C" function int dut_model_get_output(int word);
  import "DPI-C" function void dut_model_cleanup();

  // Public API methods exposed to the UVM Environment
  function void create();
    dut_model_create();
  endfunction

  function int get_output(int word);
    return dut_model_get_output(word);
  endfunction

  function void cleanup();
    dut_model_cleanup();
  endfunction

endinterface
