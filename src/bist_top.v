
`timescale 1ns/1ps
`ifndef BIST_TOP_V
`define BIST_TOP_V

`default_nettype none

module bist_top (
    input  wire clk,
    input  wire rst_n,
    input  wire start,
    output wire done,
    output wire pass_fail
);

    /* verilator lint_off SYNCASYNCNET */
    /* verilator lint_off UNUSEDSIGNAL */

    wire [5:0] addr;
    wire       addr_valid;
    wire       addr_done;
    wire       addr_start;

    wire [3:0] pattern;
    wire [3:0] rdata;
    wire       sram_rvalid;
    wire       protocol_error;

    wire       compare_done;
    wire       comp_pass_fail;
    wire [3:0] fail_code;

    wire       addr_enable;
    wire       pattern_enable;
    wire       write_enable;
    wire       read_enable;
    wire       compare_enable;
    wire       test_done;
    wire       overall_pass;
    wire       overall_fail;

    wire cs = (write_enable || read_enable) && addr_valid;

    add_gen u_addr_gen (
        .clk        (clk),
        .rst_n      (rst_n),
        .start      (addr_start),
        .enable     (addr_enable),
        .dir        (1'b0),
        .addr       (addr),
        .addr_valid (addr_valid),
        .done       (addr_done)
    );

    pattern_generator u_pattern_gen (
        .clk    (clk),
        .rst_n  (rst_n),
        .enable (pattern_enable),
        .pattern(pattern)
    );

    sram_wrapper #(
        .ADDR_WIDTH(6),
        .DATA_WIDTH(4)
    ) u_sram (
        .clk            (clk),
        .rst_n          (rst_n),
        .addr           (addr),
        .wdata          (pattern),
        .rdata          (rdata),
        .cs             (cs),
        .we             (write_enable),
        .re             (read_enable),
        .rvalid         (sram_rvalid),
        .protocol_error (protocol_error),
        .sleep          (1'b0),
        .retention      (1'b0)
    );

    data_comparator u_comparator (
        .clk           (clk),
        .rst_n         (rst_n),
        .enable        (compare_enable && sram_rvalid),
        .read_data     (rdata),
        .expected_data (pattern),
        .compare_done  (compare_done),
        .pass_fail     (comp_pass_fail),
        .fail_code     (fail_code)
    );

    test_engine u_fsm (
        .clk           (clk),
        .rst_n         (rst_n),
        .start         (start),
        .rvalid        (sram_rvalid),
        .addr_done     (addr_done),
        .compare_done  (compare_done),
        .pass_fail     (comp_pass_fail),
        .protocol_error(protocol_error),
        .addr_enable   (addr_enable),
        .pattern_enable(pattern_enable),
        .write_enable  (write_enable),
        .read_enable   (read_enable),
        .compare_enable(compare_enable),
        .test_done     (test_done),
        .overall_pass  (overall_pass),
        .overall_fail  (overall_fail),
        .addr_start    (addr_start)
    );

    /* verilator lint_on UNUSEDSIGNAL */
    /* verilator lint_on SYNCASYNCNET */

    assign done      = test_done;
    assign pass_fail = overall_pass;

    wire _unused = &{1'b0, addr_valid, sram_rvalid, fail_code, overall_fail};

endmodule
`default_nettype wire
`endif
