/*
 * Alejandro Hernandez-Farias
 * Carlos Alberto Morelos Escalera
 * 3/5/2024
 * EE 371
 * Lab 6
 *
 * Controls the status of the parking lot simulation
 * Defines when rush hour has started, or if there is no valid rush hour, defined as 3->anything->0 car pattern
 * Input ports:
 *		clock - 1-bit, the rate at which inputs are processed
 *		reset - 1-bit, sets the program to its original state
 *		count - 4 bits, the number of cars currently in the parking lot
 *		hour - 4 bits, the current hour in the workday
 * Output ports:
 *		start_rush - 1-bit, status for the time rush hour starts
 *		end_rush - 1-bit, status for the time rush hour ends
 *		no_rush - 1-bit, status for no valid rush hour being detected
 
module controller (clock, reset, count, hour, start_rush, end_rush, no_rush);

	// Variable declaration
		input logic clock, reset;
		input logic [3:0] count, hour;
		output logic start_rush, end_rush, no_rush;
		
	// Cases for classifying sensor input
		enum {S0, S1, S2} ps, ns; // Present state, next state
		
	// Identifies cars going through sensors
		always_comb begin
			case (ps)
				S0: if (count == 4'd3)			ns = S1;
						else if (hour == 4'd8)	ns = S2;
						else							ns = S0;
				S1: if (count == 4'd0)			ns = S2;
						else if (hour == 4'd8)	ns = S2;
						else							ns = S1;
				S2: 									ns = S2; // stays until reset
			endcase 
		end
		
	// Assign rush hour signals for the datapath
		assign start_rush = (ps == S0) & (count == 4'd3);
		assign end_rush = (ps == S1) & (count == 4'd0);
		assign no_rush = ((ps == S1) & (hour == 4'd8)) |
								((ps == S0) & (hour == 4'd8));
		
	// Process input from the number of cars and time of day
		always_ff @(posedge clock) begin
			if (reset)
				ps <= S0;
			else
				ps <= ns;
		end
		
endmodule // controller



/* Tests the controller module with various combinations of inputs 
module controller_tb();

	// Variable declaration
		logic clock, reset;
		logic [3:0] count, hour;
		logic start_rush, end_rush, no_rush;
	
	// Instantiates a controller module with varying inputs
		controller dut (.clock, .reset, .count, .hour, .start_rush, .end_rush, .no_rush);
		
	// Clock setup
		parameter clock_period = 100;

		initial begin
			clock <= 0;
			forever #(clock_period / 2) clock <= ~clock;
	 
		end // initial
		
	// Combinations of input
		initial begin
			// Valid rush hour
			reset <= 1;									@(posedge clock);
			reset <= 0; hour <= 0; count <= 0;	@(posedge clock);
							hour <= 0; count <= 1;	@(posedge clock);
							hour <= 0; count <= 2;	@(posedge clock);
							hour <= 0; count <= 3;	@(posedge clock);
							hour <= 1; count <= 3;	@(posedge clock);
							hour <= 2; count <= 3;	@(posedge clock);
							hour <= 3; count <= 1;	@(posedge clock);
							hour <= 4; count <= 2;	@(posedge clock);
							hour <= 5; count <= 0;	@(posedge clock);
							hour <= 6; count <= 0;	@(posedge clock);
							hour <= 7; count <= 0;	@(posedge clock);
							hour <= 8; count <= 1;	@(posedge clock);
			// No end to rush hour
			reset <= 1;									@(posedge clock);
			reset <= 0; hour <= 0; count <= 0;	@(posedge clock);
							hour <= 0; count <= 1;	@(posedge clock);
							hour <= 0; count <= 2;	@(posedge clock);
							hour <= 0; count <= 3;	@(posedge clock);
							hour <= 1; count <= 3;	@(posedge clock);
							hour <= 2; count <= 3;	@(posedge clock);
							hour <= 3; count <= 1;	@(posedge clock);
							hour <= 4; count <= 2;	@(posedge clock);
							hour <= 5; count <= 1;	@(posedge clock);
							hour <= 6; count <= 1;	@(posedge clock);
							hour <= 7; count <= 1;	@(posedge clock);
							hour <= 8; count <= 1;	@(posedge clock);
			// No start to rush hour
			reset <= 1;									@(posedge clock);
			reset <= 0; hour <= 0; count <= 0;	@(posedge clock);
							hour <= 0; count <= 1;	@(posedge clock);
							hour <= 0; count <= 2;	@(posedge clock);
							hour <= 0; count <= 2;	@(posedge clock);
							hour <= 1; count <= 2;	@(posedge clock);
							hour <= 2; count <= 1;	@(posedge clock);
							hour <= 3; count <= 1;	@(posedge clock);
							hour <= 4; count <= 2;	@(posedge clock);
							hour <= 5; count <= 0;	@(posedge clock);
							hour <= 6; count <= 0;	@(posedge clock);
							hour <= 7; count <= 0;	@(posedge clock);
							hour <= 8; count <= 1;	@(posedge clock);
			$stop;
			
		end // initial
		
endmodule // controller_tb
*/