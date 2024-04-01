module GoofyCore (
    input clk,
    input res,

    output hlt
);

    // RAM
    wire ram_save;
    reg [7:0] ram_in;
    wire [7:0] ram_out;
    reg [15:0] ram_addr;
    GoofyRam ram (
        clk,
        ram_save,
        ram_in,
        ram_out,
        ram_addr
    );

    // Microcode
    reg [11:0] mc_addr;
    wire [63:0] mc_out;
    GoofyMC mc (
        clk,
        mc_addr,
        mc_out
    );

    // ALU
    wire alu0w;
    wire [7:0] alu0d;
    wire [7:0] alu0o;
    wire alu1w;
    wire [7:0] alu1d;
    wire [7:0] alu1o;
    wire alu_flag_ov_o;
    wire alu_flag_eq_o;
    wire alu_flag_hlt_o;
    wire [7:0] alu_out;
    wire alu_add;
    wire alu_add_ov;
    wire alu_sub;
    wire alu_sub_ov;
    wire alu_and;
    wire alu_or;
    wire alu_not;
    wire alu_cmp;
    wire alu_hlt;
    wire alu_flag_res;
    GoofyALU alu (
        clk,
        res,
        alu0w,
        alu0o,
        alu0d,
        alu1w,
        alu1o,
        alu1d,
        alu_flag_ov_o,
        alu_flag_eq_o,
        alu_flag_hlt_o,
        alu_out,
        alu_add,
        alu_add_ov,
        alu_sub,
        alu_sub_ov,
        alu_and,
        alu_or,
        alu_not,
        alu_cmp,
        alu_hlt,
        alu_flag_res
    );
    
    // CPU

    // Instruction Pointer
    reg [15:0] rip;
    wire rip_write;
    wire [15:0] rip_i;

    // Instruction Registers
    reg [7:0] iop;
    reg [7:0] op0;
    reg [7:0] op1;
    wire execute_op;

    localparam STATE_FETCH_IOP = 0;
    localparam STATE_FETCH_OP0 = 1;
    localparam STATE_FETCH_OP1 = 2;
    localparam STATE_EXEC = 3;
    reg [1:0] state = 0;

    // Microcode
    reg [15:0] mc_counter;



    assign hlt = alu_flag_hlt_o;
    initial begin
        
    end

    // First
    always @(negedge clk) begin
        if (res) begin
            rip <= 0;
            state <= STATE_FETCH_IOP;
            mc_counter <= 0;
            mc_addr <= 0;
        end else begin
            case (state)
                STATE_FETCH_IOP:
                begin
                    ram_addr <= rip;
                    mc_counter <= 0;
                    rip <= rip + 1;
                end

                STATE_FETCH_OP0:
                begin
                    ram_addr <= rip;
                    rip <= rip + 1;
                end

                STATE_FETCH_OP1:
                begin
                    ram_addr <= rip;
                    rip <= rip + 1;
                end

                STATE_EXEC:
                begin
                    mc_addr <= {iop, mc_counter[3:0]};
                    mc_counter <= mc_counter + 1;
                end
            endcase
        end
    end

    // Second
    always @(posedge clk) begin
        if (res) begin

        end else begin
            case (state)
                STATE_FETCH_IOP:
                begin
                    iop <= ram_out[7:0];
                    state <= STATE_FETCH_OP0;
                end

                STATE_FETCH_OP0:
                begin
                    op0 <= ram_out[7:0];
                    state <= STATE_FETCH_OP1;
                end

                STATE_FETCH_OP1:
                begin
                    op1 <= ram_out[7:0];
                    state <= STATE_EXEC;
                end

                STATE_EXEC:
                begin
                    if (mc_finish) begin
                        state <= STATE_FETCH_IOP;
                    end
                    
                end
            endcase
        end
    end



    // Microcode Blocks
    wire mc_finish;
    assign mc_finish = ((mc_out & 64'h8000000000000000) != 0) && state == STATE_EXEC;
    

endmodule