/*
 * Alejandro Hernandez-Farias
 * Carlos Alberto Morelos Escalera
 * 3/5/2024
 * EE 371
 * Lab 6

 * Uses the DE1_SoC FPGA board's GPIO inputs to monitor the status of a parking lot
 * Keeps a running count of the cars inside and alerts when it is empty or full
 * Ports:
 * 	CLOCK_50: 50 MHz signal for processing a stream of bits
 * 	HEX0, HEX1, HEX2, HEX3, HEX4, HEX5: The individual character representation for
 * 		displaying letters
 * 	V_GPIO: General Purpose Input Output Pins that allow external components to communicate with the FPGA
 *		KEY: The keys that temporarily inputs a stream of bits, active low
 * 	LEDR: The lights on the board that display whether the pattern was found
 *		SW: The switches that input a stream of bits
 * Inputs:
 * 	GPIO_0[28] - Switch 2 for resetting the system to zero cars
 * 	GPIO_0[24] - Switch 1 that is Sensor A for cars
 * 	GPIO_0[23] - Switch 0 that is Sensor B for cars
 * Outputs:
 * 	GPIO_0[26] - LED 1 alerts if an object has been detected in Sensor A
 * 	GPIO_0[27] - LED 0 alerts if an object has been detected in Sensor A
 * 	HEX5 to HEX0 - Displays the full/empty status of the lot and the number of cars inside
 */
 

module DE1_SoC(CLOCK_50, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, LEDR, V_GPIO);
	
	// Variable declaration
		input logic CLOCK_50; // 50MHz clock
		output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
		input logic [35:23] V_GPIO;
		output logic [9:0] LEDR;
		input logic [3:0] KEY; // Active low property
		input logic [9:0] SW;
		
	// Configure clock signal
		logic clock;
		assign clock = CLOCK_50;
		
	// Configure reset function
		logic reset;
		assign reset = SW[9];
		
	// Configure parking spot input signals
		logic p1, p2, p3;
		assign p1 = V_GPIO[28];
		assign p2 = V_GPIO[29];
		assign p3 = V_GPIO[30];
		
	// Configure enter and exit input signals for single pulse
		logic enter_t, exit_t;
		assign enter_t = V_GPIO[23];
		assign exit_t = V_GPIO[24];
		
		logic enter, exit;
		pulse_edge ent (.clock, .in(enter_t), .out(enter));
		pulse_edge ex (.clock, .in(exit_t), .out(exit));
		
	// Controller
		logic [3:0] count, hour;
		logic start_rush, end_rush, no_rush;
		controller ctrl (.clock, .reset, .count, .hour, .start_rush, .end_rush, .no_rush);
		
	// Synchronize the hour incrementer button and get a single pulse
		logic hour_inc_t, hour_inc;
		signal_sync key0 (.clock, .reset, .unsync_in(~KEY[0]), .sync_out(hour_inc_t));
		pulse_edge inc (.clock, .in(hour_inc_t), .out(hour_inc));
	
	// Datapath
		datapath dp (.clock, .reset, .hour_inc, .start_rush, .end_rush, .no_rush, .enter, .exit, .count, .hour, .HEX5, .HEX4, .HEX3, .HEX2, .HEX1, .HEX0);
	
	// Configure output
		assign V_GPIO[26] = p1;	// LED parking 1
		assign V_GPIO[27] = p2;	// LED parking 2
		assign V_GPIO[32] = p3;	// LED parking 3
		assign V_GPIO[34] = (count == 3);	// LED full
		assign V_GPIO[31] = enter_t & (count < 4);	// Open entrance
		assign V_GPIO[33] = exit_t;	// Open exit
		
	// Configure output LEDs
		assign LEDR[0] = p1; // Parking spot 1
		assign LEDR[1] = p2; // Parking spot 2
		assign LEDR[2] = p3; // Parking spot 3
		assign LEDR[3] = enter_t;	// Presence entrance
		assign LEDR[4] = exit_t;	// Presence exit
		
endmodule // DE1_SoC



/* Tests the DE1_SoC module with various combinations of sensor input */
module DE1_SoC_tb();

	// Variable declaration
		logic CLOCK_50;
		logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
		wire [35:0] V_GPIO;
		logic [4:0] sw;
	
	// Instantiates a DE1_SoC object with the combinations below
		DE1_SoC dut (.CLOCK_50, .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5, .V_GPIO);
		
	// Assign external switches to assigned inputs
		assign V_GPIO[28] = sw[0]; // p1
		assign V_GPIO[29] = sw[1]; // p2
		assign V_GPIO[30] = sw[2]; // p3

		assign V_GPIO[23] = sw[3]; // enter
		assign V_GPIO[24] = sw[4]; // exit
	
	// Clock setup
		parameter clock_period = 100;
		
		initial begin
			CLOCK_50 <= 0;
			forever #(clock_period / 2) CLOCK_50 <= ~CLOCK_50;
					
		end // initial
		
	// Combinations of user input
		initial begin
			sw[4] <= 0; sw[3] <= 0; sw[2] <= 0;		@(posedge CLOCK_50);
			sw[1] <= 0; sw[0] <= 0;				@(posedge CLOCK_50);
			sw[3] <= 1;		repeat(2)		@(posedge CLOCK_50);
			sw[3] <= 0;					@(posedge CLOCK_50);
			sw[0] <= 1;		repeat(2)		@(posedge CLOCK_50);
			sw[1] <= 1; 	repeat(2)			@(posedge CLOCK_50);
			sw[2] <= 1;    repeat(2)			@(posedge CLOCK_50);
			sw[4] <= 1;		repeat(2)		@(posedge CLOCK_50);
									@(posedge CLOCK_50);
									@(posedge CLOCK_50);
							
							
			$stop; // End simulation	
		end // initial
	
endmodule 
