module GoofyMC (
	input clk,

	input [11:0] mc_addr,
	output [63:0] mc_out
);
	reg [63:0] memory [0:12'hFFF];

	assign mc_out = memory[mc_addr];

	initial begin
		`ifdef MICROCODE
				$readmemh(`MICROCODE, memory);
		`endif
    end
endmodule