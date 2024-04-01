module GoofyALU (
    input clk,
    input res,

    input alu0w,
    output [7:0] alu0o,
    input [7:0] alu0d,

    input alu1w,
    output [7:0] alu1o,
    input [7:0] alu1d,

    output alu_flag_ov_o,
    output alu_flag_eq_o,
    output alu_flag_hlt_o, 

    output reg [7:0] alu_out,

    input alu_add,
    input alu_add_ov,
    input alu_sub,
    input alu_sub_ov,
    input alu_and,
    input alu_or,
    input alu_not,
    input alu_cmp,
    input alu_hlt,
    input alu_flag_res
);
    reg [7:0] alu0 = 0;
    reg [7:0] alu1  = 0;
    reg [8:0] alu_temp  = 0;

    reg alu_flag_ov  = 0;
    reg alu_flag_eq  = 0;
    reg alu_flag_hlt = 0;

    assign alu0o = alu0;
    assign alu1o = alu1;

    assign alu_flag_ov_o  = alu_flag_ov;
    assign alu_flag_eq_o  = alu_flag_eq;
    assign alu_flag_hlt_o = alu_flag_hlt;

    initial begin
        alu0 = 0;
        alu1 = 0;
        alu_temp = 0;
        alu_flag_ov = 0;
        alu_flag_eq = 0;
        alu_flag_hlt = 0;
    end

    always @(negedge clk) begin
        if (alu0w) begin
            alu0 <= alu0d;
        end
        if (alu1w) begin
            alu1 <= alu1d;
        end

        if (alu_add) begin
            // will perform an 8 bit add and set the overflow flag if the result is greater than 255
            alu_temp <= alu0 + alu1;
            if (alu_temp > 255) begin
                alu_flag_ov <= 1;
            end
            alu_out <= alu_temp[7:0];
        end
        if (alu_add_ov) begin
            // will perform an 8 bit add and add 1 to the result if the overflow flag is set and set the overflow flag if the result is greater than 255
            alu_temp <= alu0 + alu1 + alu_flag_ov;
            if (alu_temp > 255) begin
                alu_flag_ov <= 1;
            end
            alu_out <= alu_temp[7:0];
        end
        if (alu_sub) begin
            // will perform an 8 bit sub and set the overflow flag if the result is less than 0
            alu_temp <= alu0 - alu1;
            if (alu_temp < 0) begin
                alu_flag_ov <= 1;
            end
            alu_out <= alu_temp[7:0];
        end
        if (alu_sub_ov) begin
            // will perform an 8 bit sub and subtract 1 from the result if the overflow flag is set and set the overflow flag if the result is less than 0
            alu_temp <= alu0 - alu1 - alu_flag_ov;
            if (alu_temp < 0) begin
                alu_flag_ov <= 1;
            end
            alu_out <= alu_temp[7:0];
        end
        if (alu_and) begin
            alu_out <= alu0 & alu1;
        end
        if (alu_or) begin
            alu_out <= alu0 | alu1;
        end
        if (alu_not) begin
            alu_out <= ~alu0;
        end
        if (alu_cmp) begin
            alu_flag_eq <= alu0 == alu1;
        end
        if (alu_hlt) begin
            alu_flag_hlt <= 1;
        end
        if (alu_flag_res) begin
            alu_flag_ov <= 0;
            alu_flag_eq <= 0;
            alu_flag_hlt <= 0;
        end
    end

endmodule