// test_engine.v – Latches addr_done, sticky fail_latch
`ifndef TEST_ENGINE_V
`define TEST_ENGINE_V

`timescale 1ns/1ps
`default_nettype none

module test_engine (
    input  wire clk,
    input  wire rst_n,
    input  wire start,
    input  wire rvalid,
    input  wire addr_done,
    input  wire compare_done,
    input  wire pass_fail,
    input  wire protocol_error,
    output reg  addr_enable,
    output reg  pattern_enable,
    output reg  write_enable,
    output reg  read_enable,
    output reg  compare_enable,
    output reg  test_done,
    output reg  overall_pass,
    output reg  overall_fail,
    output reg  addr_start
);

    localparam IDLE         = 3'd0;
    localparam PATTERN      = 3'd1;
    localparam WRITE        = 3'd2;
    localparam READ         = 3'd3;
    localparam COMPARE      = 3'd4;
    localparam NEXT_ADDRESS = 3'd5;
    localparam DONE         = 3'd6;

    reg [2:0] state, next_state;
    reg       fail_latch;
    reg       addr_done_seen;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state          <= IDLE;
            test_done      <= 1'b0;
            addr_start     <= 1'b0;
            overall_pass   <= 1'b0;
            overall_fail   <= 1'b0;
            fail_latch     <= 1'b0;
            addr_done_seen <= 1'b0;
        end else begin
            addr_start <= 1'b0;

            // ---- Clear latch on entering DONE ----
            if (next_state == DONE)
                addr_done_seen <= 1'b0;

            // ---- Latch addr_done ----
            if (addr_done)
                addr_done_seen <= 1'b1;

            // ---- Fix 5: Clear fail_latch only on new run ----
            if (state == IDLE && start)
                fail_latch <= 1'b0;

            // ---- Fix 5: Set fail_latch on compare failure or protocol error ----
            if (compare_done && !pass_fail)
                fail_latch <= 1'b1;
            if (protocol_error)
                fail_latch <= 1'b1;

            state <= next_state;
            test_done <= (next_state == DONE);

            if (next_state == DONE) begin
                overall_pass <= !fail_latch;
                overall_fail <= fail_latch;
            end

            // ---- addr_start pulse when leaving IDLE ----
            if (state == IDLE && start)
                addr_start <= 1'b1;
        end
    end

    // ---- Next‑state logic ----
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: if (start) next_state = PATTERN;
            PATTERN: next_state = WRITE;
            WRITE:   next_state = READ;
            READ:    if (rvalid) next_state = COMPARE; else next_state = READ;
            COMPARE: if (compare_done) next_state = NEXT_ADDRESS; else next_state = COMPARE;
            NEXT_ADDRESS: if (addr_done_seen) next_state = DONE; else next_state = PATTERN;
            DONE:    if (start) next_state = IDLE;
            default: next_state = IDLE;
        endcase
    end

    // ---- Combinational enables ----
    always @(*) begin
        addr_enable    = 1'b0;
        pattern_enable = 1'b0;
        write_enable   = 1'b0;
        read_enable    = 1'b0;
        compare_enable = 1'b0;

        case (state)
            IDLE: ;
            PATTERN:      pattern_enable = 1'b1;
            WRITE:        write_enable = 1'b1;
            READ:         read_enable = 1'b1;
            COMPARE:      compare_enable = 1'b1;
            NEXT_ADDRESS: addr_enable = 1'b1;
            DONE: ;
            default: ;
        endcase
    end

endmodule

`default_nettype wire
`endif
