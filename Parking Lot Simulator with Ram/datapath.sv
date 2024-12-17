/*
 * Alejandro Hernandez-Farias
 * Carlos Alberto Morelos Escalera
 * 3/5/2024
 * EE 371
 * Lab 6
 *
 * Holds the flip-flops and digital circuit for a parking lot simulation
 * Calculates the status of rush hour for the lot
 * Stores the number of cars in a RAM unit in the lot every hour
 * Keeps the count for the number of hours passed in a work day and the cars inside the parking lot
 * Uses HEX displays to show the number of cars, the RAM address, time of day, and start and end times of rush hour
 * Input ports:
 *		clock - 1-bit, the rate at which inputs are processed
 *		reset - 1-bit, sets every data stored to be zero
 *		hour_inc - 1-bit, increments the time of day counter
 *		start_rush - 1-bit, status for the time rush hour starts
 *		end_rush - 1-bit, status for the time rush hour ends
 *		no_rush - 1-bit, status for no valid rush hour being detected
 *		enter - 1-bit, status for a new car just having entered the lot
 *		exit - 1-bit, status for a new car just having exited the lot
 * Output ports:
 *		count - 4 bits, the number of cars currently in the parking lot
 *		hour - 4 bits, the current hour in the workday
 *		HEX5 - 7 bits, shows the current hour in the workday
 *		HEX4 - 7 bits, shows the end time of rush hour once the workday ends, otherwise off
 *		HEX3 - 7 bits, shows the start time of rush hour once the workday ends, otherwise shows 'FULL' if parking lot is full
 *		HEX2 - 7 bits, shows 'FULL' if parking lot is full, otherwise off
 *		HEX1 - 7 bits, shows 'FULL' if parking lot is full, otherwise off
 *		HEX0 - 7 bits, shows the number of empty lots, and shows 'FULL' if parking lot is full, otherwise off
 
module datapath (clock, reset, hour_inc, start_rush, end_rush, no_rush, enter, exit, count, hour, HEX5, HEX4, HEX3, HEX2, HEX1, HEX0);

	// Variable declaration
		input logic clock, reset, hour_inc, start_rush, end_rush, no_rush, enter, exit;
		input logic [15:0] data_out;
		output logic [3:0] read_address;
		output logic [3:0] count, hour;
		output logic [6:0] HEX5, HEX4, HEX3, HEX2, HEX1, HEX0;
		
	// Determine value to show on HEX displays based on workday status
		logic [3:0] HEX5_v, HEX4_v, HEX3_v, HEX2_v, HEX1_v, HEX0_v;
		logic [3:0] start_time, end_time;
		always_ff @(posedge clock) begin
			if (hour < 4'd8) begin
				HEX5_v <= hour;
				HEX4_v <= 4'hE; // off
				if (count == 4'd3) begin
					HEX3_v <= 4'hA;
					HEX2_v <= 4'hB;
					HEX1_v <= 4'hC;
					HEX0_v <= 4'hC;
				end else begin
					HEX3_v <= 4'hE; // off
					HEX2_v <= 4'hE; // off
					HEX1_v <= 4'hE; // off
					HEX0_v <= (4'd3 - count);
				end
				
			end else begin
				HEX5_v <= 4'd7;
				HEX4_v <= end_time;
				HEX3_v <= start_time;
				HEX2_v <= 4'hE; // off
				HEX1_v <= 4'hE; // off
				HEX0_v <= 4'hE; // off
			
			end
		end
		
	// Assign HEX displays based on values
		seg7 hex_5 (.num(HEX5_v), .HEX(HEX5));
		seg7 hex_4 (.num(HEX4_v), .HEX(HEX4));
		seg7 hex_3 (.num(HEX3_v), .HEX(HEX3));
		seg7 hex_2 (.num(HEX2_v), .HEX(HEX2));
		seg7 hex_1 (.num(HEX1_v), .HEX(HEX1));
		seg7 hex_0 (.num(HEX0_v), .HEX(HEX0));
	
	// Determine rush hour start and end times
		always_ff @(posedge clock) begin
			if (reset) begin
				start_time <= 4'd0;
				end_time <= 4'd0;
			end else if (start_rush)
				start_time <= hour;
			else if (end_rush)
				end_time <= hour;
			else if (no_rush) begin
				start_time <= 4'hD;
				end_time <= 4'hD;
			end
			
		end
		
	// Updates car count based on cars entering or exiting
		always_ff @(posedge clock) begin
			if (reset)
				count <= 4'd0;
			else if (enter)
				count <= count + 1'b1;
			else if (exit)
				count <= count - 1'b1;
		end
		
	// Updates hour count
		always_ff @(posedge clock) begin
			if (reset)
				hour <= 4'd0;
			else if (hour_inc)
				hour <= hour + 1'b1;
		end
		
	// 1 second clock for read address
		logic [31:0] clk;
		logic clock_1Hz;
		clock_divider clkdiv(.clock, .divided_clocks(clk));
		assign clock_1Hz = clk[25];
		
	// Counting up and down fsm
	// State declaration
		enum {S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13} ps, ns;
	
	// Next state logic 
		always_comb begin
			case (ps)
				
				S0: begin
					if (start) begin
						ns = S1;
						read_address = 3'b001;
					end
					else begin
						ns = S0;
						read_address = 3'b000;
					end
				end
				
				S1: begin
					ns = S2;
					read_address = 3'b010;
				end
				
				S2: begin
					ns = S3;
					read_address = 3'b011;
				end
				
				S3: begin
					ns = S4;
					read_address = 3'b100;
				end
				
				S4: begin
					ns = S5;
					read_address = 3'b101;
				end
				
				S5: begin
					ns = S6;
					read_address = 3'b110;
				end
				
				S6: begin
					ns = S7;
					read_address = 3'b111;
				end
				
				S7: begin
					ns = S8;
					read_address = 3'b110;
				end
				
				S8: begin
					ns = S9;
					read_address = 3'b101;
				end
				
				S9: begin
					ns = S10;
					read_address = 3'b100;
				end
				
				S10: begin
					ns = S11;
					read_address = 3'b011;
				end
				
				S11: begin
					ns = S12;
					read_address = 3'b010;
				end
				
				S12: begin
					ns = S13;
					read_address = 3'b001;
				end
				
				S13: begin
					ns = S0;
					read_address = 3'b000;
				end
			endcase
		end
	
	// Block assigning reset and next states
		always_ff @(posedge clock) begin // change to clock_1hz on labs land
			if (reset)
				ps <= S0;
			else 
				ps <= ns;
		end
	
	
	// RAM module instantiation
		ram8x16 memory (.clock(clock), .data(car_count), .rdaddress(read_address), .wraddress(hour_count), .wren(1'b1), 
							 .q(data_out));
		
endmodule // datapath
*/