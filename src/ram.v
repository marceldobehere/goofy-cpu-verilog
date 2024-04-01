module GoofyRam (
	input clk,

	input ram_save,
	input [7:0] ram_in,
	output [7:0] ram_out,

	input [15:0] ram_addr
);
	reg [15:0] memory [0:16'hFFFF];

	assign ram_out = memory[ram_addr];

	always @(posedge clk) begin
		if (ram_save) begin
			memory[ram_addr] <= ram_in;
		end
	end

	initial begin
		`ifdef RAM
				$readmemh(`RAM, memory);
		`endif
    end
endmodule