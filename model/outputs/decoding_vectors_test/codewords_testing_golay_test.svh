	// Selected received test vectors: 0xA5D9A6, 0xA5F9A4, 0xA5C9AA
	bit [NB_CODEWORD-1:0] rx_test_vectors [3] = '{
		24'b101001011101100110100110	,
		24'b101001011111100110100100	,
		24'b101001011100100110101010	};

	// Decoded message for the selected test vectors
	bit [NB_WORD-1:0] msg_test_vectors [3] = '{
		12'b101001011100	,
		12'b101001011100	,
		12'b101001011100	};

	// Recovered error pattern for the selected test vectors
	bit [NB_CODEWORD-1:0] err_pattern_test_vectors [3] = '{
		24'b000000000001000000000011	,
		24'b000000000011000000000001	,
		24'b000000000000000000000000	};

	// Corrected flag for the selected test vectors
	bit corrected_flag_test_vectors [3] = '{
		1'b1	,
		1'b1	,
		1'b0	};

	// Uncorrectable flag for the selected test vectors
	bit uncorrectable_flag_test_vectors [3] = '{
		1'b0	,
		1'b0	,
		1'b1	};

