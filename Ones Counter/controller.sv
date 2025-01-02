// Carlos A. Morelos Escalera and Alejandro Hernandez-Farias
// 02/14/2024 
// EE371 
// Lab 4
// This program controls the signals for the datapath

// This module sends the necessary signals to the data path according to the inputs from the DE1 SoC board
// Input ports:
//		* clock: the rate at which inputs are processed
//		* reset_ctrl: to return the controller to its initial or idle state
//		* start_ctrl: signal to start the sequence
//		* done_datapath: true when the datapath is done counting the number of 1s
//		* result: 4bit word that stores the count of 1s
// Output ports:
//		* done_ctrl: true when the system is done, connected to LED9
//		* load_A: signals the data path to load input switches to a local register 
//		* shift: signals the data path to shift the register to the right one-time
//		* count: transforms the 4bit result to its equivalent number for the HEX0 display
module controller (clock, reset_ctrl, start_ctrl, done_datapath, result, done_ctrl, load_A, shift, count);

	// Variable declaration
	input logic clock, reset_ctrl, start_ctrl, done_datapath;
	input logic [3:0]result;
	output logic done_ctrl, load_A, shift;
	output logic [6:0]count;
	
	// State declaration
	enum {S_idle, S_shifting, S_done} ps, ns;
	
	// Next state logic 
	always_comb begin
		case (ps)
		
			S_idle: begin						// Initial state, waiting to start
				if (start_ctrl) begin
					ns = S_shifting;
				end
				else begin
					ns = S_idle;
				end
			end
			
			S_shifting: begin					// Shifting state
				if (done_datapath) begin
					ns = S_done;
				end
				else begin
					ns = S_shifting;
				end
			end
			
			S_done: begin						// Final state, system is done counting
				if (~start_ctrl) begin
					ns = S_idle;
				end
				else begin
					ns = S_done;
				end
			end
		endcase
	end
	
	
	// Block assigning reset and next states
	always_ff @(posedge clock) begin
		if (reset_ctrl)
			ps <= S_idle;
		else 
			ps <= ns;
	end
	
	// 4bit result to 7bit HEX0 equivalent
	always_comb begin
		case(result)
			4'b0000: count = 7'b1000000; // 0
			4'b0001: count = 7'b1111001; // 1
			4'b0010: count = 7'b0100100; // 2
			4'b0011: count = 7'b0110000; // 3
			4'b0100: count = 7'b0011001; // 4
			4'b0101: count = 7'b0010010; // 5
			4'b0110: count = 7'b0000010; // 6
			4'b0111: count = 7'b1111000; // 7
			4'b1000: count = 7'b0000000; // 8
			default: count = 7'b0000000; // Default case for safety, display is off
		endcase
	end
	
	// Output assignment
	assign shift = (((ps == S_idle) && start_ctrl) || ((ps == S_shifting) && ~done_datapath)); 	// shifting signal
	assign load_A = ((ps == S_idle) && ~start_ctrl);						// loading from switches
	assign done_ctrl = (((ps == S_shifting) && done_datapath) || (ps == S_done)); 		        // done signal
	
endmodule


// Tests the controller module with different combinations of inputs
module controller_tb();

	// Variable declaration
	logic clock, reset_ctrl, start_ctrl, done_datapath;
	logic [3:0]result;
	logic done_ctrl, load_A, shift;
	logic [6:0]count;
	
	//controller module declaration
	controller dut (.clock, .reset_ctrl, .start_ctrl, . done_datapath, .result, .done_ctrl, .load_A, .shift, .count);
	
	// Clock set up
	parameter clock_period = 100;

	initial begin
		clock <= 0;
		forever #(clock_period / 2) clock <= ~clock;
	 
	end
	 
	// Simulations of input
	initial begin
		reset_ctrl = 0;						@(posedge clock);
		reset_ctrl = 1;						@(posedge clock); // reset
		reset_ctrl = 0;						@(posedge clock);
		start_ctrl = 0;						@(posedge clock); // not starting (S_idle) -> load A
		start_ctrl = 1;						@(posedge clock); // starting (S_shifting) -> shift
		done_datapath = 0; repeat(10)				@(posedge clock); // not done for 10 cycles (S_shifting) -> shift is true
		done_datapath = 1; repeat(5)     			@(posedge clock); // done, no more shifting(S_done) -> done_ctrl is true
		result = 4'b0000;					@(posedge clock); // result = 0, count = 0
		result = 4'b0001;					@(posedge clock); // result = 1, count = 1
		result = 4'b0010;					@(posedge clock); // result = 2, count = 2
		result = 4'b0011;					@(posedge clock); // result = 3, count = 3
		result = 4'b0100;					@(posedge clock); // result = 4, count = 4
		result = 4'b0101;					@(posedge clock); // result = 5, count = 5
		result = 4'b0110;					@(posedge clock); // result = 6, count = 6
		result = 4'b0111;					@(posedge clock); // result = 7, count = 7
		result = 4'b1000;					@(posedge clock); // result = 8, count = 8
		start_ctrl = 0;						@(posedge clock); // back to S_idle
		
		$stop; // end simulation
	end
endmodule

		
		
		
		
	
	
	
