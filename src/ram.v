module GoofyRam (
	input clk,

	input sam_save,
	input [7:0] ram_in,
	output [7:0] ram_out,

	input [15:0] ram_addr
);
	reg [15:0] memory [0:16'hFFFF];

	assign ram_out = memory[ram_addr];

	always @(negedge clk) begin
		if (sam_save) begin
			memory[ram_addr] <= ram_in;
		end
	end

	initial begin
`ifdef FIRMWARE
		$readmemh(`FIRMWARE, memory);
`else
        // $readmemh("test/fib2.hex", memory);
`endif
    end
endmodule