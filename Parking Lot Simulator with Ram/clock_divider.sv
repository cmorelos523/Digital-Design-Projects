// Carlos Morelos 
// 11/06/2023 
// EE271 
// Lab 3 

// Takes in a clock signal, divides the clock cycle and outputs 32
// divided clock signals of varying frequency.
// divided_clocks[0] = 25MHz, [1] = 12.5Mhz, ...
// [23] = 3Hz, [24] = 1.5Hz, [25] = 0.75Hz, ...
module clock_divider (clock, divided_clocks);
	
	input logic clock;
	output logic [31:0] divided_clocks = 32'b0;
	
	always_ff @(posedge clock) begin
		divided_clocks <= divided_clocks + 1;
	end
endmodule

// Testbench module used for testing and simulation purposes
module clock_divider_testbench();
	logic clock;
	logic [31:0] divided_clocks;
	
	clock_divider dut (.clock, .divided_clocks);
	
	// TODO: Set up the clock.
	parameter clock_period = 100;

	initial begin
		clock <= 0;
		forever #(clock_period / 2) clock <= ~clock;
		
	end
	
	integer i;
	initial begin
	
		// TODO:
		
		// Run the simulation for a limited number of
		// clock cycles until $stop directive ends the sim.
		// Otherwise simulation will run forever
		
		// Use @(posedge clock); to run 1 clock
		// cycle.
		
		// A for-loop can be leveraged to
		// efficiently run many cycles here ......
		for (i = 0; i < 100; i++) begin
			{divided_clocks [31:0]} <= i; @(posedge clock);
		end
		
		$stop;
	end
endmodule
