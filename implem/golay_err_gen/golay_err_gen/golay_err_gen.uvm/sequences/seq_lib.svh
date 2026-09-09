// stimulus generators

// Purpose: decide which transactions to send. The existing golay_syndrome TB
// has three sequences (bit-sweep, all-codewords, random-with-error). For
// "golay_err_gen" the useful set is: pure random, one per arm (constrained),
// and a directed corner sequence.

// ----------------------------------------------------------
// (a) Uniform-ish random ober the constrained input space.
// ----------------------------------------------------------

class rand_sequence extends uvm_sequence #(seq_item);
	`uvm_object_utils(rand_sequence)

	function new(string name = "rand_sequence");
		super.new(name);
	endfunction

	int unsigned n_items = 2000;

	virtual task body();
		repeat (n_items) begin
			seq_item tr = seq_item::type_id::create("tr");
			start_item(tr);
			if (!tr.randomize())
				`uvm_error(get_name(), "randomize() failed.")
			finish_item(tr);
		end
	endtask
endclass

// ---------------------------------------------------------------
// (b) Force a specific arm of the priority chain.
//     `arm` selects which one; constraints make that arm the winner.
// ---------------------------------------------------------------
class arm_sequence extends uvm_sequence #(seq_item);
    `uvm_object_utils(arm_sequence)
    function new(string name = "arm_sequence"); super.new(name); endfunction

    int unsigned n_items = 400;
    rand int     arm;                       // 1..5
    constraint c_arm { arm inside {[1:5]}; }

    virtual task body();
        repeat (n_items) begin
            seq_item tr = seq_item::type_id::create("tr");
            start_item(tr);
            case (arm)
                1: assert (tr.randomize() with {
                       i_w_syn <= 3;
                   });
                2: assert (tr.randomize() with {
                       i_w_syn      > 3;                      // block arm 1
                       i_found_syn  == 1;
                       i_w_res_syn  <= 2;
                   });
                3: assert (tr.randomize() with {
                       i_w_syn      > 3;
                       !(i_found_syn && i_w_res_syn <= 2);    // block arm 2
                       i_w_q        <= 3;
                   });
                4: assert (tr.randomize() with {
                       i_w_syn      > 3;
                       !(i_found_syn && i_w_res_syn <= 2);
                       i_w_q        > 3;                      // block arm 3
                       i_found_q    == 1;
                       i_w_res_q    <= 2;
                   });
                5: assert (tr.randomize() with {
                       i_w_syn      > 3;
                       !(i_found_syn && i_w_res_syn <= 2);
                       i_w_q        > 3;
                       !(i_found_q && i_w_res_q <= 2);        // block arm 4
                   });
            endcase
            finish_item(tr);
        end
    endtask
endclass

// ---------------------------------------------------------------
// (c) Named corner cases (boundaries + the idx-overflow case).
// ---------------------------------------------------------------
class corner_sequence extends uvm_sequence #(seq_item);
    `uvm_object_utils(corner_sequence)
    function new(string name = "corner_sequence"); super.new(name); endfunction

    virtual task body();
        // arm-1 boundary: w(s)=3 hits, w(s)=4 must fall through
        drive(.w_syn(3));
        drive(.w_syn(4), .expect_fallthrough(1));
        // arm-2 boundary: w(s^b)=2 hits, =3 falls through
        drive(.w_syn(8), .found_syn(1), .w_res_syn(2));
        drive(.w_syn(8), .found_syn(1), .w_res_syn(3));
        // arm-2 shift past MSB
        drive(.w_syn(8), .found_syn(1), .w_res_syn(0), .idx_syn(15));
        // all-fail => uncorrectable
        drive(.w_syn(10), .w_q(10));
    endtask

    // small helper so each corner is one readable line
    task automatic drive(int w_syn = 15, int w_q = 15, //15 -> 12
                         bit found_syn = 0, bit found_q = 0,
                         int w_res_syn = 15, int w_res_q = 15,
                         int idx_syn = 0, int idx_q = 0,
                         bit expect_fallthrough = 0);
        seq_item tr = seq_item::type_id::create("tr");
        start_item(tr);
        assert (tr.randomize() with {
            i_w_syn     == w_syn;   i_w_q       == w_q;
            i_found_syn == found_syn; i_found_q == found_q;
            i_w_res_syn == w_res_syn; i_w_res_q == w_res_q;
            i_idx_syn   == idx_syn; i_idx_q     == idx_q;
        });
        finish_item(tr);
    endtask
endclass
