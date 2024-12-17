/*
 * Alejandro Hernandez-Farias
 * Carlos A. Moreno Escalera
 * 1/10/2024
 * EE 371
 * Lab 1

 * Keeps the count based on increasing and decreasing values
 * Input ports:
 * 	clock - 1-bit number that is the rate at which inputs are processed
 * 	reset - 1-bit number to restart the program, active low
 * 	inc - 1-bit, increases the value of the count
 * 	dec - 1-bit, decreases the value of the count
 * Output ports:
 * 	count - the running count based on the input
 */
 
module counter (clock, reset, inc, dec, count);

	// Variable declaration
		input logic clock, reset, inc, dec;
		output logic [4:0] count;
		
	// Updates count
		always_ff @(posedge clock) begin
			if (reset)
				count <= 0;
			else begin
				if (inc)
					count <= count + 1'b1;
				else if (dec)
					count <= count - 1'b1;
				else
					count <= count;
			end
		end
		
endmodule 



/*
 * Tests the counter module with various combinations of input
 */

module counter_testbench();

	// Variable declaration
		logic clock, reset, inc, dec;
		logic [4:0] count;
		
	// Instantiates a counter object with the combinations below
		counter dut (.clock, .reset, .inc, .dec, .count);
	
	// Clock setup
		parameter clock_period = 100;
	
		initial begin
			clock <= 0;
			forever #(clock_period / 2) clock <= ~clock;
			
		end // initial
	
	// Combinations of input values
		initial begin
			reset <= 1;				@(posedge clock);
			reset <= 0; inc <= 1; dec <= 0;		@(posedge clock); // Increases
								@(posedge clock);
								@(posedge clock);
								@(posedge clock);
								@(posedge clock);
				inc <= 0; dec <= 1;		@(posedge clock); // Decreases
								@(posedge clock);
								@(posedge clock);
								@(posedge clock);
								@(posedge clock);
				inc <= 1; dec <= 0;		@(posedge clock); // Increases
								@(posedge clock);
			reset <= 1;				@(posedge clock); // Reset
			reset <= 0; inc <= 1; dec <= 0;		@(posedge clock);
								@(posedge clock);
															
			$stop; // End simulation
		end // initial
		
endmodule 
*/
