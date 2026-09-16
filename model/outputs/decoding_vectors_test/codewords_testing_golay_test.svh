	constraint golay_code_test_vectors {
    //0xA5D9A6, 0xA5F9A4, 0xA5C9AA 
		rx_data inside {
			24'b101001011101100110100110	,
			24'b101001011111100110100100	,
			24'b101001011100100110101010	};

		decoded_data inside {
			12'b101001011100	,
			12'b101001011100	,
			12'b101001011100	};

		err inside {
			24'b000000000001000000000011	,
			24'b000000000011000000000001	,
			24'b000000000000000000000000	};

		corrected_data inside {
			1'b1	,
			1'b1	,
			1'b0	};

		uncorrectable inside {
			1'b0	,
			1'b0	,
			1'b1	};
	};
