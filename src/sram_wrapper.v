// sram_wrapper.v – 1‑cycle read latency, rvalid output
`timescale 1ns/1ps
`ifndef SRAM_WRAPPER_V
`define SRAM_WRAPPER_V

`default_nettype none

module sram_wrapper #(
    parameter ADDR_WIDTH = 6,
    parameter DATA_WIDTH = 4
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire [ADDR_WIDTH-1:0] addr,
    input  wire [DATA_WIDTH-1:0] wdata,
    output reg  [DATA_WIDTH-1:0] rdata,
    input  wire                  cs,
    input  wire                  we,
    input  wire                  re,
    output reg                   rvalid,
    output reg                   protocol_error,
    input  wire                  sleep,
    input  wire                  retention
);

    localparam DEPTH = (1 << ADDR_WIDTH);
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    wire read_req = !sleep && cs && re && !we;
    reg                  re_r;
    reg [ADDR_WIDTH-1:0] addr_r;

    // Simulation init
    // synopsys translate_off
    integer init_idx;
    initial begin
        for (init_idx = 0; init_idx < DEPTH; init_idx = init_idx + 1)
            mem[init_idx] = '0;
    end
    // synopsys translate_on

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            re_r           <= 1'b0;
            addr_r         <= '0;
            rdata          <= '0;
            rvalid         <= 1'b0;
            protocol_error <= 1'b0;
        end else begin
            if (!sleep) begin
                rvalid <= 1'b0;

                // Write
                if (cs && we && !re)
                    mem[addr] <= wdata;

                // Read pipeline
                re_r   <= read_req;
                addr_r <= addr;

                if (re_r) begin
                    rdata  <= mem[addr_r];
                    rvalid <= 1'b1;
                end else begin
                    rdata  <= '0;
                end

                // Protocol error
                if (cs && we && re)
                    protocol_error <= 1'b1;
            end else begin
                re_r   <= 1'b0;
                rvalid <= 1'b0;
                rdata  <= '0;
            end
        end
    end

    wire _unused = &{1'b0, retention};

endmodule
`default_nettype wire
`endif
