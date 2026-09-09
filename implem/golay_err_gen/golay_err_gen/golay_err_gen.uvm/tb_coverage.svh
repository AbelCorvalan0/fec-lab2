class tb_coverage extends uvm_subscriber #(seq_item); // uvm_subscriber gives analysis_export + an abstract write()
    `uvm_component_utils(tb_coverage)                  // register this component with the factory

    seq_item     item;                                 // last transaction; the covergroup samples its fields
    int unsigned arm;                                  // which arm fired; sampled by the ARM coverpoint

    function int unsigned active_arm(seq_item t);       // recompute the winning arm from the inputs
        if      (t.i_w_syn <= 3)                        return 1; // arm 1
        else if (t.i_found_syn && t.i_w_res_syn <= 2)   return 2; // arm 2
        else if (t.i_w_q   <= 3)                        return 3; // arm 3
        else if (t.i_found_q   && t.i_w_res_q   <= 2)   return 4; // arm 4
        else                                           return 5; // arm 5
    endfunction

    covergroup cg_dut;                                  // the functional-coverage model
        ARM : coverpoint arm { bins a[] = {1,2,3,4,5}; } // one bin per arm; top goal = all five hit

        W_SYN : coverpoint item.i_w_syn {              // w(s), split at the arm-1 boundary
            bins le3  = {[0:3]};                        //   values that take arm 1
            bins four = {4};                            //   first value that does NOT
            bins hi   = {[5:15]};                       //   clearly above the boundary
        }
        W_RES_SYN : coverpoint item.i_w_res_syn {      // w(s^b), split at the arm-2 boundary
            bins le2   = {[0:2]};                       //   takes arm 2
            bins three = {3};                           //   first value that does not
            bins hi    = {[4:15]};                      //   above
        }
        W_Q : coverpoint item.i_w_q {                  // w(q), split at the arm-3 boundary
            bins le3 = {[0:3]}; bins four = {4}; bins hi = {[5:15]};
        }
        W_RES_Q : coverpoint item.i_w_res_q {          // w(q^b), split at the arm-4 boundary
            bins le2 = {[0:2]}; bins three = {3}; bins hi = {[4:15]};
        }
        FOUND_SYN : coverpoint item.i_found_syn;        // 0 and 1 both seen
        FOUND_Q   : coverpoint item.i_found_q;          // 0 and 1 both seen
        IDX_SYN   : coverpoint item.i_idx_syn {         // s-side index
            bins pos[] = {[0:11]};                      //   real bit positions
            bins ovf   = {[12:15]};                     //   shift-past-MSB corner
        }
        UNCORR : coverpoint item.o_uncorrectable;       // was the uncorrectable path exercised

        ARMxFOUND : cross arm, FOUND_SYN;               // each arm seen with found_syn = 0 and = 1
    endgroup

    function new(
		// Warning cannot omit port direction for function/task
		// declarations
		input string name = "tb_coverage", 
		input uvm_component parent = null
	); // component ctor
        super.new(name, parent);                        // mandatory base-class call
        cg_dut = new();                                 // covergroups must be explicitly constructed
    endfunction

    virtual function void write(seq_item t);            // called for every transaction from the monitor
        item = t;                                       // publish it for the covergroup
        arm  = active_arm(t);                            // compute the value for the ARM coverpoint
        cg_dut.sample();                                 // record one coverage hit
    endfunction
endclass