// data_comparator.v – compare_done pulses for one cycle
`timescale 1ns/1ps
`ifndef DATA_COMPARATOR_V
`define DATA_COMPARATOR_V

`default_nettype none

module data_comparator (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       enable,
    input  wire [3:0] read_data,
    input  wire [3:0] expected_data,
    output reg        compare_done,
    output reg        pass_fail,
    output reg  [3:0] fail_code
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            compare_done <= 1'b0;
            pass_fail    <= 1'b1;
            fail_code    <= 4'b0000;
        end else begin
            compare_done <= 1'b0;   // default: no pulse
            if (enable) begin
                compare_done <= 1'b1;
                if (read_data == expected_data) begin
                    pass_fail <= 1'b1;
                    fail_code <= 4'b0000;
                end else begin
                    pass_fail <= 1'b0;
                    fail_code <= 4'b0001;
                end
            end
        end
    end

endmodule
`default_nettype wire
`endif
