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

    // Microcode Blocks
    wire mc_put_reg_iop0_lo_bus = mc_out[0] && (state == STATE_EXEC); // Done
    wire mc_put_reg_iop0_hi_bus = mc_out[1] && (state == STATE_EXEC); // Done
    wire mc_str_reg_iop0_lo_bus = mc_out[2] && (state == STATE_EXEC); // Done
    wire mc_str_reg_iop0_hi_bus = mc_out[3] && (state == STATE_EXEC); // Done

    wire mc_put_val_iop0_bus = mc_out[4] && (state == STATE_EXEC);
    wire mc_put_val_iop1_bus = mc_out[5] && (state == STATE_EXEC);

    wire mc_str_reg_0_bus = mc_out[6] && (state == STATE_EXEC);
    wire mc_str_reg_1_bus = mc_out[7] && (state == STATE_EXEC);
    wire mc_str_reg_2_bus = mc_out[8] && (state == STATE_EXEC);
    wire mc_str_reg_3_bus = mc_out[9] && (state == STATE_EXEC);

    wire mc_ram_write_bus_a = mc_out[10] && (state == STATE_EXEC);
    wire mc_ram_write_bus_b = mc_out[11] && (state == STATE_EXEC);

    wire mc_ram_read_bus_a = mc_out[12] && (state == STATE_EXEC);
    wire mc_ram_read_bus_b = mc_out[13] && (state == STATE_EXEC);

    wire mc_io_write_bus_a = mc_out[14] && (state == STATE_EXEC);
    wire mc_io_write_bus_b = mc_out[15] && (state == STATE_EXEC);

    wire mc_io_read_bus_a = mc_out[16] && (state == STATE_EXEC);
    wire mc_io_read_bus_b = mc_out[17] && (state == STATE_EXEC);

    wire mc_str_alu_reg_0_bus = mc_out[18] && (state == STATE_EXEC); // Done
    wire mc_str_alu_reg_1_bus = mc_out[19] && (state == STATE_EXEC); // Done

    wire mc_alu_add = mc_out[20] && (state == STATE_EXEC);
    wire mc_alu_add_ov = mc_out[21] && (state == STATE_EXEC);
    wire mc_alu_sub = mc_out[22] && (state == STATE_EXEC);
    wire mc_alu_sub_ov = mc_out[23] && (state == STATE_EXEC);
    wire mc_alu_and = mc_out[24] && (state == STATE_EXEC);
    wire mc_alu_or = mc_out[25] && (state == STATE_EXEC);
    wire mc_alu_not = mc_out[26] && (state == STATE_EXEC);
    wire mc_alu_cmp = mc_out[27] && (state == STATE_EXEC);
    wire mc_alu_flag_reset = mc_out[28] && (state == STATE_EXEC);
    wire mc_put_alu_res_bus = mc_out[29] && (state == STATE_EXEC);

    wire mc_jeq = mc_out[30] && (state == STATE_EXEC);
    wire mc_jneq = mc_out[31] && (state == STATE_EXEC);
    wire mc_hlt = mc_out[32] && (state == STATE_EXEC); // Done
    wire mc_jmp = mc_out[33] && (state == STATE_EXEC);

    wire mc_finish = mc_out[63] && (state == STATE_EXEC); // Done

    // CPU

    // 16 8 bit Registers
    reg [7:0] regs [0:8'hF];

    // 8 bit Data Bus
    reg [7:0] data_bus;


    // ALU
    
    reg [7:0] alu0d;
    wire [7:0] alu0o;
    reg [7:0] alu1d;
    wire [7:0] alu1o;
    wire alu_flag_ov_o;
    wire alu_flag_eq_o;
    wire alu_flag_hlt_o;
    wire [7:0] alu_out;
    reg alu_add;
    reg alu_add_ov;
    reg alu_sub;
    reg alu_sub_ov;
    reg alu_and;
    reg alu_or;
    reg alu_not;
    reg alu_cmp;
    reg alu_hlt;
    reg alu_flag_res;
    GoofyALU alu (
        .clk(clk),
        .res(res),
        .alu0w(mc_str_alu_reg_0_bus),
        .alu0o(alu0o),
        .alu0d(data_bus),
        .alu1w(mc_str_alu_reg_1_bus),
        .alu1o(alu1o),
        .alu1d(data_bus),
        .alu_flag_ov_o(alu_flag_ov_o),
        .alu_flag_eq_o(alu_flag_eq_o),
        .alu_flag_hlt_o(alu_flag_hlt_o),
        .alu_out(alu_out),

        .alu_add(mc_alu_add),
        .alu_add_ov(alu_add_ov),
        .alu_sub(alu_sub),
        .alu_sub_ov(alu_sub_ov),
        .alu_and(alu_and),
        .alu_or(alu_or),
        .alu_not(alu_not),
        .alu_cmp(alu_cmp),
        .alu_hlt(alu_hlt),
        .alu_flag_res(alu_flag_res)
    );
    
    

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


    // First
    always @(negedge clk) begin
        if (res) begin
            rip <= 0;
            state <= STATE_FETCH_IOP;
            mc_counter <= 0;
            mc_addr <= 0;

            regs[0] <= 10;
            regs[1] <= 0;
            regs[2] <= 0;
            regs[3] <= 0;
            regs[4] <= 0;
            regs[5] <= 0;
            regs[6] <= 0;
            regs[7] <= 0;
            regs[8] <= 0;
            regs[9] <= 0;
            regs[10] <= 0;
            regs[11] <= 0;
            regs[12] <= 0;
            regs[13] <= 0;  
            regs[14] <= 0;
            regs[15] <= 0;

            alu_add <= 0;
            alu_add_ov <= 0;
            alu_sub <= 0;
            alu_sub_ov <= 0;
            alu_and <= 0;
            alu_or <= 0;
            alu_not <= 0;
            alu_cmp <= 0;
            alu_hlt <= 0;
            alu_flag_res <= 0;

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

                    mc_addr <= {iop, mc_counter[3:0]};
                    mc_counter <= mc_counter + 1;
                end



                // WRITES
                STATE_EXEC:
                begin
                    $display("MC W STEP %h", mc_counter);


                    if (mc_alu_add) begin
                        $display("MC> ALU ADD");
                        alu_add <= 1;
                        alu0d <= data_bus;
                    end

                    if (mc_alu_add_ov) begin
                        $display("MC> ALU ADD OV");
                        alu_add_ov <= 1;
                        alu0d <= data_bus;
                    end

                    if (mc_put_reg_iop0_lo_bus) begin
                        $display("MC> PUT REG %h (%h)", op0[3:0], regs[op0[3:0]]);
                        data_bus <= regs[op0[3:0]];
                    end

                    if (mc_put_reg_iop0_hi_bus) begin
                        $display("MC> PUT REG %h (%h)", op0[7:4], regs[op0[7:4]]);
                        data_bus <= regs[op0[7:4]];
                    end

                    if (mc_put_val_iop0_bus) begin
                        $display("MC> PUT VAL %h", op0);
                        data_bus <= op0;
                    end

                    if (mc_put_val_iop1_bus) begin
                        $display("MC> PUT VAL %h", op1);
                        data_bus <= op1;
                    end

                    if (mc_put_alu_res_bus) begin
                        $display("MC> PUT ALU RES %h", alu_out);
                        data_bus <= alu_out;
                    end



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
                    $display("INST");
                end

                // READS
                STATE_EXEC:
                begin
                    $display("MC R STEP %h", mc_counter);

                    if (mc_finish) begin
                        $display("MC> FINISH");
                        state <= STATE_FETCH_IOP;
                    end

                    if (mc_hlt) begin
                        alu_hlt <= 1;
                        $display("MC> HLT");
                    end

                    if (mc_str_alu_reg_0_bus) begin
                        $display("MC> STR ALU REG 0 (%h)", data_bus);
                    end

                    if (mc_str_alu_reg_1_bus) begin
                        $display("MC> STR ALU REG 1 (%h)", data_bus);
                    end
                    

                    if (mc_str_reg_iop0_lo_bus) begin
                        $display("MC> STR REG %h (%h)", op0[3:0], data_bus);
                        regs[op0[3:0]] <= data_bus;
                    end

                    if (mc_str_reg_iop0_hi_bus) begin
                        $display("MC> STR REG %h (%h)", op0[7:4], data_bus);
                        regs[op0[7:4]] <= data_bus;
                    end






                    mc_addr <= {iop, mc_counter[3:0]};
                    mc_counter <= mc_counter + 1;                    
                end
            endcase
        end
    end


    

endmodule