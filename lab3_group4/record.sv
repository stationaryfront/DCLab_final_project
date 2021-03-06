module Record(
	input i_rst,				
	input i_stop,				// KEY0
	input i_playpause,			// KEY1
	input i_record,				// SW[0]		
	// codec
	input i_BCLK,				// clk
	input i_LRC,
	input i_DAT,
	// LCD
	output [1:0] state_denote,
	// SRAM 
	input i_Memory_full_flag,  	    // not sure (1 -> full, 0 -> empty)
	output sram_start,				// not sure
	output o_reset_all_sram_addr,   // read addr & record addr become zero (not sure)      
	output [15:0] o_sram_data
);
	
	localparam RESET = 0;
	localparam RECORD = 1;
	localparam PAUSE = 2;


	logic [1:0] state_r, state_w;
	logic [4:0] period_counter_r, period_counter_w;
	logic reset_all_sram_r, reset_all_sram_w;
	logic [15:0] buffer_o_sram_data_r, buffer_o_sram_data_w;
	logic data_finish_r, data_finish_w;

	assign o_sram_data = buffer_o_sram_data_r;
	assign o_reset_all_sram_addr = reset_all_sram_r;
	assign state_denote = state_r;
	assign sram_start =  data_finish_r;

	always_comb begin										// 此處負責 state 轉換的控制

		state_w = state_r;
		period_counter_w = period_counter_r;
		buffer_o_sram_data_w = buffer_o_sram_data_r;
		reset_all_sram_w = reset_all_sram_r;
		data_finish_w = data_finish_r;

		case(state_r)
			RESET: 
				if (i_playpause == 1 && i_record ==1 && i_stop == 0) begin 			
					state_w = RECORD;
					reset_all_sram_w = 1;
					end

				else begin
					state_w = state_r;
					reset_all_sram_w = 0;
					end

			RECORD: begin
				reset_all_sram_w = 0;						// not sure 

				if(i_stop == 1 || i_record == 0) begin
					state_w = RESET;
					period_counter_w = 0;
					buffer_o_sram_data_w = 0;
					end

				else if((i_playpause == 1 || i_Memory_full_flag == 1) && i_stop == 0 && i_record == 1) begin
					state_w = PAUSE;
					period_counter_w = 0;
					buffer_o_sram_data_w = 0;
					end
					
				else 
					state_w = state_r;

				if(i_LRC == 1)begin														// data transmit
					if(period_counter_r == 0)
						period_counter_w = period_counter_r + 1;

					else if(period_counter_r == 16)begin
						period_counter_w = period_counter_r + 1;
						buffer_o_sram_data_w = (buffer_o_sram_data_r << 1) + i_DAT;
						data_finish_w = 1;
					end	

					else if(period_counter_r == 17)begin
						period_counter_w = period_counter_r;
						data_finish_w = 0;
					end

					else begin
						period_counter_w = period_counter_r + 1;
						buffer_o_sram_data_w = (buffer_o_sram_data_r << 1) + i_DAT;
					end
				end

				else begin 
					period_counter_w = 0;
					data_finish_w = 0;
					end
					
				end

			PAUSE: begin
				reset_all_sram_w = 0;						// not sure

				if(i_stop == 1 || i_record == 0) begin
					state_w = RESET;
				end

				else if(i_playpause == 1 && i_stop == 0 && i_record == 1 && i_Memory_full_flag == 0)
					state_w = RECORD;

				else 
					state_w = state_r;
			end

			default: begin
				state_w = state_r;
				period_counter_w = 0;								
				buffer_o_sram_data_w = buffer_o_sram_data_r;
				reset_all_sram_w = 0;
				data_finish_w = 0;
				end
		endcase
	end


	always_ff @(posedge i_BCLK or negedge i_rst) begin

		if(!i_rst) begin
			state_r <= RESET;
			period_counter_r <= 0;
			buffer_o_sram_data_r <= 16'b0;  			//not sure
			reset_all_sram_r <= 0;
			data_finish_r <= 0;

		end

		else begin
			state_r <= state_w;
			period_counter_r <= period_counter_w;
			buffer_o_sram_data_r <= buffer_o_sram_data_w;
			reset_all_sram_r <= reset_all_sram_w;
			data_finish_r <= data_finish_w;

		end
	end

endmodule