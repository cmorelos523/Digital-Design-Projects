// Carlos A. Morelos Escalera and Alejandro Hernandez-Farias
// 03/09/2024 
// EE371 
// Lab 6
// This program controls the 8x16 RAM module

// This module sends the necessary signals to the data path and keeps track of the counters
// Input ports:
//		* clock: the rate at which inputs are processed
//		* reset: to return the controller to its initial state
//		* hour: increase the hour count by 1
//		* car_in: increase the car count by 1
//		* start: signal to start the address cycle
//		* data_out: 16bit word that stores the count of cars that have entered the parking lot in an hour
// Output ports:
//		* car_count: stores the total number of cars observed throught the day
//		* read_address: signal that cycles between the addresses of the 8x16 RAM module
//		* hour_count: stores the total number of hours
module car_tracking_RAM (clock, reset, hour, car_in, start, wr_en, out, car_count, read_address, hour_count);
	
	// Variable declaration
	input logic clock, reset; 
	input logic hour, car_in, start, wr_en; 	
	output logic [15:0] out;
	output logic [15:0] car_count;	
	output logic [3:0] read_address;
	output logic [2:0] hour_count;
	
	
	// Increase car count when a car is in and hour count when signal hour is asserted	
	always_ff @(posedge clock) begin
		if (reset) begin
			car_count <= 0;
			hour_count <= 0;
		end
		else begin
			if (car_in) begin
				car_count <= car_count + 1;		// Increse car count
			end
			if (hour) begin
				hour_count <= hour_count + 1;		// Increase hour count
			end
		end
	end
	
	
	// 1 second clock for read address
	logic [31:0] clk;
	logic clock_1Hz;
	clock_divider clkdiv(.clock(CLOCK_50), .divided_clocks(clk));
	assign clock_1Hz = clk[25];

	// Counting up and donw fsm
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
	logic [15:0] data_out;
	ram8x16 memory (.clock(clock), .data(car_count), .rdaddress(read_address), .wraddress(hour_count), .wren(wr_en), 
						 .q(data_out));
						 
	assign out = data_out;

endmodule


// Testbench module
`timescale 1 ps / 1 ps
module car_tracking_RAM_tb();

	// Variable declaration
	logic clock, reset; 
	logic hour, car_in, start, wr_en; 	
	logic [15:0] out;	
	logic [15:0] car_count;
	logic [3:0] read_address;
	logic [2:0] hour_count;
	
	// car_tracking_RAM module instantiation
	car_tracking_RAM dut (.clock, .reset, .hour, .car_in, .start, .wr_en, .out, .car_count, .read_address, .hour_count);
	
	// Clock set up
	parameter clock_period = 100;

	initial begin
		clock <= 0;
		forever #(clock_period / 2) clock <= ~clock;
	 
	end
	 
	// User input simulation
	initial begin
		reset = 0; hour = 0; car_in = 0;
					  start = 0; wr_en = 0;		@(posedge clock); // hour 0, car count = 0, start = 0
		reset = 1;									@(posedge clock); // reset
		reset = 0; start = 0; wr_en = 1;		@(posedge clock); // start address cycling
					  hour = 0; car_in = 1;
					  start = 0;					@(posedge clock); // hour 0, car count = 1
					  hour = 1; car_in = 1;		@(posedge clock); // hour 1, car count = 1
					  hour = 0; car_in = 0; wr_en = 0;		@(posedge clock); // hour 1, car count = 1
					  start = 1;	repeat(4)	@(posedge clock);
										repeat(10)  @(posedge clock);

					  /*
					  hour = 1; car_in = 0;		@(posedge clock); // hour 2, car count = 1
					  hour = 1; car_in = 1;		@(posedge clock); // hour 3, car count = 2
					  hour = 0; car_in = 1;		@(posedge clock); // hour 3, car count = 3 
					  hour = 0; car_in = 0;		@(posedge clock); // hour 3, car count = 3
					  hour = 1; car_in = 0;		@(posedge clock); // hour 4, car count = 3
					  hour = 1; car_in = 1;		@(posedge clock); // hour 5, car count = 4
					  hour = 1; car_in = 1;		@(posedge clock); // hour 6, car count = 5
					  hour = 1; car_in = 0;		@(posedge clock); // hour 7, car count = 5
														@(posedge clock);
														@(posedge clock);
					*/
		$stop; // end simulation
	end
endmodule
													
	
	