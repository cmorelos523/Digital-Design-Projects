// Carlos A. Morelos Escalera and Alejandro Hernandez-Farias
// 02/14/2024 
// EE371 
// Lab 4
// This program communicates with the FPGA board

// Uses the DE1_SoC FPGA board's switches to count the number of 1s in an 8bit word
// Parameters:
// 	* CLOCK_50: 50 MHz signal for processing a stream of bits
// 	* HEX0, HEX1, HEX2, HEX3, HEX4, HEX5: Individual displays
// 	* KEY: The keys on the board for input
// 	* LEDR: The lights on the board that display the state of the switches
// 	* SW: The switches that input the bits
// Inputs:
// 	* SW9: start signal
//		* SW7 to SW0: bits input for the 8bit word
//		* KEY0: reset signal
// Outputs:
// 	* LED9: on when the system is done counting
//		* HEX0: displays the number of 1s in the input
module DE1_SoC (CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, LEDR, SW);

	// Variable declaration
	input logic CLOCK_50;
	input logic [3:0]KEY;
	input logic [9:0]SW;
	output logic [9:0]LEDR;
	output logic [6:0]HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	
	// Synchronous reset signal
	logic unsync_reset; // Unsynced reset
	logic reset; // Synced reset
	start_synchronizer treat_reset (.clock(CLOCK_50), .reset(unsync_reset), .unsync_start(~KEY[0]), .sync_start(reset));
	
	// Synchronous start signal
	logic start; // Synced start
	start_synchronizer treat_start (.clock(CLOCK_50), .reset(reset), .unsync_start(SW[9]), .sync_start(start));
	
	// Turn off other displays
	assign HEX1 = '1;
	assign HEX2 = '1;
	assign HEX3 = '1;
	assign HEX4 = '1;
	assign HEX5 = '1;
	
	// Instantiation of the controller and ones_counter modules
	logic done_overall; // done connection for both modules
	logic [3:0] result_overall; // stores the counter
	logic load_overall; // load connection for both modules
	logic shift_overall; // shift connection for both modules
	controller control (.clock(CLOCK_50), .reset_ctrl(reset), .start_ctrl(start), .done_datapath(done_overall),
							  .result(result_overall), .done_ctrl(LEDR[9]), .load_A(load_overall), 
							  .shift(shift_overall), .count(HEX0[6:0]));
	ones_counter counting (.clock(CLOCK_50), .reset_datapath(reset), .load_A(load_overall) , .shift(shift_overall), 
								  .A(SW[7:0]), .result(result_overall), .done_datapath(done_overall));
	
	
endmodule


// Tests the DE1_SoC module with different combinations of user input
module DE1_SoC_tb();
	
	// Variable declaration
	logic CLOCK_50;
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;
	
	// DE1_SoC module declaration
	DE1_SoC dut (.CLOCK_50, .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .KEY, .LEDR, .SW);
	
	// Clock set up
	parameter clock_period = 100;

	initial begin
		CLOCK_50 <= 0;
		forever #(clock_period / 2) CLOCK_50 <= ~CLOCK_50;
	 
	end
	
	// Simulation of user input
	initial begin
		KEY[0] = 1;								@(posedge CLOCK_50); // reset the system
		KEY[0] = 0;								@(posedge CLOCK_50);
		SW[9] = 0;								@(posedge CLOCK_50); // start is 0, loading A
		SW[7:0] = 8'b01010101;							@(posedge CLOCK_50); // set A = 01010101		
		SW[9] = 1;						repeat(10)	@(posedge CLOCK_50); // start = 1, on for 10 clock cycles (enough for the
													     // system to count the number of 1s)
		$stop;
	
	end
endmodule
	
		



