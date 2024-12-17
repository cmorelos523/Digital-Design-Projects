/*
 * Alejandro Hernandez-Farias
 * Carlos Alberto Morelos Escalera
 * 3/5/2024
 * EE 371
 * Lab 6
 *
 * Generates one pulsed signal from a variable pulse length signal
 * Input ports:
 *		clock - 1-bit, the rate at which inputs are processed
 *		in - 1-bit, the input signal
 * Output ports:
 *		out - 1-bit, the output pulse signal
 
module pulse_edge (clock, in, out);

	// Variable declaration
		input logic clock, in;
		output logic out;
		
	// State declaration for finding edge of pulse
		enum {S0, S1} ps, ns; // Present state, next state
		
	// Classify input signal based on pulse length
		always_comb begin
			case (ps)
				// No signal
				S0: if (in)	ns = S1;
						else 	ns = S0;
				// Pulse hold
				S1: if (in) ns = S1;
						else	ns = S0;
			
			endcase
		end
		
	// Process input to constantly look for pulse edge
		always_ff @(posedge clock) begin
			ps <= ns;
		
		end
		
	// Assign out signal with only pulse edge
		assign out = (ps == S0) & in;
		
endmodule // pulse_edge



/* Tests the pulse_edge module with various combinations of inputs 
module pulse_edge_tb();

	// Variable declaration
		logic clock, in, out;
	
	// Instantiates a pulse_edge module with varying inputs
		pulse_edge dut (.clock, .in, .out);
		
	// Clock setup
		parameter clock_period = 100;

		initial begin
			clock <= 0;
			forever #(clock_period / 2) clock <= ~clock;
	 
		end // initial
		
	// Combinations of input
		initial begin
			in <= 1; 	repeat (3) @(posedge clock);
			in <= 0; 	repeat (3) @(posedge clock);
			in <= 1; 	repeat (3) @(posedge clock);
			in <= 0; 	repeat (3) @(posedge clock);
			in <= 1; 	repeat (3) @(posedge clock);
			$stop;
			
		end // initial
		
endmodule // pulse_edge_tb
*/