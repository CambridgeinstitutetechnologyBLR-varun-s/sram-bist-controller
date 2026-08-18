// pattern_generator.v – Generates 0000 → 1111 → 1010 → 0101
`timescale 1ns/1ps
`ifndef PATTERN_GENERATOR_V
`define PATTERN_GENERATOR_V

`default_nettype none

module pattern_generator (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       enable,
    output reg  [3:0] pattern
);

    localparam [1:0] S_ZERO  = 2'b00,
                     S_ONES  = 2'b01,
                     S_CHKA  = 2'b10,
                     S_CHKB  = 2'b11;

    reg [1:0] state_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state_r <= S_ZERO;
        else if (enable)
            state_r <= state_r + 2'd1;   // wraps 3 → 0
    end

    always @(*) begin
        pattern = 4'b0000;
        case (state_r)
            S_ZERO: pattern = 4'b0000;
            S_ONES: pattern = 4'b1111;
            S_CHKA: pattern = 4'b1010;
            S_CHKB: pattern = 4'b0101;
            default: pattern = 4'b0000;
        endcase
    end

endmodule
`default_nettype wire
`endif
